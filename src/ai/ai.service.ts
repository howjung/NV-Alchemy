import { Injectable, Logger } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Meal } from '../meals/entities/meal.entity';
import { todayKst } from '../streak/streak';
import { TipQueryDto } from './dto/tip-query.dto';
import { Nutrients, pickTip, Tip } from './tip';

const MODEL = 'gemini-3.8-flash';
const URL = `https://generativelanguage.googleapis.com/v1beta/models/${MODEL}:generateContent`;

@Injectable()
export class AiService {
  private readonly logger = new Logger(AiService.name);
  // 같은 날 같은 안내면 Gemini를 다시 부르지 않는다(사용량 절약). 날짜가 바뀌면 비운다
  // shortcut: 서버 메모리에만 둬서 재시작하면 사라진다. 사용자가 많아지면 DB나 Redis로
  private cache = new Map<string, string>();
  private cacheDate = '';

  constructor(
    @InjectRepository(Meal) private meals: Repository<Meal>,
    private config: ConfigService,
  ) {}

  async tip(userId: number, goal: TipQueryDto): Promise<Tip & { source: 'gemini' | 'rule' }> {
    const today = todayKst();
    const rows = await this.meals.findBy({ userId, recordedDate: today });
    const eaten = rows.length
      ? rows.reduce<Nutrients>(
          (sum, m) => ({
            calories: sum.calories + m.calories,
            carbs: sum.carbs + m.carbs,
            protein: sum.protein + m.protein,
            fat: sum.fat + m.fat,
          }),
          { calories: 0, carbs: 0, protein: 0, fat: 0 },
        )
      : null;
    const tip = pickTip(eaten, goal);
    if (tip.kind === 'none') return { ...tip, source: 'rule' };

    if (this.cacheDate !== today) {
      this.cache.clear();
      this.cacheDate = today;
    }
    const key = `${userId}:${tip.title}`;
    const cached = this.cache.get(key);
    if (cached) return { ...tip, body: cached, source: 'gemini' };

    const foods = rows.map((m) => `${m.mealType} ${m.foodName}`).join(', ');
    const body = await this.ask(tip.title, foods);
    if (!body) return { ...tip, source: 'rule' };
    this.cache.set(key, body);
    return { ...tip, body, source: 'gemini' };
  }

  /** Gemini에게 한 줄 조언을 받는다. 키가 없거나 실패하면 null(화면은 기본 문장을 쓴다). */
  private async ask(title: string, foods: string): Promise<string | null> {
    const key = this.config.get<string>('GEMINI_API_KEY');
    if (!key) return null;
    const prompt = [
      '너는 다이어트 식단 앱의 코치야.',
      `오늘 먹은 음식: ${foods}`,
      `오늘 상태: ${title}`,
      '이 상태를 고칠 다음 끼니 제안을 한국어 한 문장으로만 답해.',
      '25자 이내, "~해 보세요"로 끝내고, 숫자와 이모지는 쓰지 마.',
    ].join('\n');
    try {
      const res = await fetch(URL, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json', 'x-goog-api-key': key },
        body: JSON.stringify({
          contents: [{ parts: [{ text: prompt }] }],
          generationConfig: { thinkingConfig: { thinkingLevel: 'low' } },
        }),
        signal: AbortSignal.timeout(10_000),
      });
      if (!res.ok) throw new Error(`Gemini ${res.status}`);
      const data = (await res.json()) as {
        candidates?: { content?: { parts?: { text?: string; thought?: boolean }[] } }[];
      };
      const text = (data.candidates?.[0]?.content?.parts ?? [])
        .filter((p) => !p.thought)
        .map((p) => p.text ?? '')
        .join('')
        .trim()
        .split('\n')[0];
      // 너무 길거나 비면 쓰지 않는다(말풍선은 한 줄)
      return text && text.length <= 40 ? text : null;
    } catch (e) {
      this.logger.warn(`AI 한마디 실패: ${(e as Error).message}`); // 키는 로그에 남기지 않는다
      return null;
    }
  }
}
