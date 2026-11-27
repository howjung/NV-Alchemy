// AI 한마디의 숫자 부분. 숫자는 Gemini가 아니라 여기서 계산한다(AI가 숫자를 틀리게 말하지 않게).

export type Nutrients = { calories: number; carbs: number; protein: number; fat: number };
export type TipKind = 'none' | 'over' | 'carbs' | 'protein' | 'fat' | 'balanced';
export type Tip = { kind: TipKind; title: string; body: string };

const NAMES = { carbs: '탄수화물', protein: '단백질', fat: '지방' } as const;

// Gemini를 못 쓸 때(키 없음, 오류) 보여 줄 문장
export const FALLBACK: Record<TipKind, string> = {
  none: '아침부터 가볍게 기록해 보세요',
  over: '다음 끼니는 채소 위주로 가볍게 드세요',
  carbs: '현미밥이나 고구마를 조금 더해 보세요',
  protein: '계란이나 두부를 더해 보세요',
  fat: '견과류를 한 줌 더해 보세요',
  balanced: '지금처럼 골고루 드세요',
};

/** 오늘 먹은 양(eaten)과 하루 목표(goal)로 가장 먼저 알려 줄 것을 고른다. */
export function pickTip(eaten: Nutrients | null, goal: Nutrients): Tip {
  const tip = (kind: TipKind, title: string): Tip => ({ kind, title, body: FALLBACK[kind] });
  if (!eaten) return tip('none', '오늘 첫 식단을 기록해보세요'); // PRD 6.1 기본 문구

  const over = eaten.calories - goal.calories;
  if (over > 0) return tip('over', `목표보다 ${Math.round(over)}kcal 더 먹었어요`);

  // 목표 대비 가장 많이 모자란 영양소. 같으면 단백질 → 탄수화물 → 지방 순
  const order = ['protein', 'carbs', 'fat'] as const;
  const short = (k: (typeof order)[number]) => (goal[k] - eaten[k]) / Math.max(goal[k], 1);
  const worst = order.reduce((a, b) => (short(b) > short(a) ? b : a));
  if (short(worst) < 0.1) return tip('balanced', '영양 균형이 좋아요');
  return tip(worst, `${NAMES[worst]}이 ${Math.round(goal[worst] - eaten[worst])}g 부족해요`);
}
