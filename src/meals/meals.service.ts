import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { ConfigService } from '@nestjs/config';
import { GoogleGenAI, Type } from '@google/genai';
import * as fs from 'fs';
import { CreateMealDto } from './dto/create-meal.dto';
import { UpdateMealDto } from './dto/update-meal.dto';
import { Meal } from './entities/meal.entity';

@Injectable()
export class MealsService {
  private ai: GoogleGenAI;

  constructor(
    @InjectRepository(Meal)
    private mealsRepository: Repository<Meal>,
    private configService: ConfigService,
  ) {
    this.ai = new GoogleGenAI({
      apiKey: this.configService.get<string>('GEMINI_API_KEY'),
    });
  }

  async analyzeFoodImage(filePath: string, mimeType: string) {
    const imageBase64 = fs.readFileSync(filePath, { encoding: 'base64' });

    const response = await this.ai.models.generateContent({
      model: 'gemini-3.0-flash',
      contents: [
        {
          inlineData: {
            data: imageBase64,
            mimeType: mimeType,
          },
        },
        '이 음식 사진을 분석해서 한국어 음식 이름(foodName), 예상 총 칼로리(calories, kcal), 탄수화물(carbs, g), 단백질(protein, g), 지방(fat, g)을 추정해줘.',
      ],
      config: {
        responseMimeType: 'application/json',
        responseSchema: {
          type: Type.OBJECT,
          properties: {
            foodName: { type: Type.STRING },
            calories: { type: Type.INTEGER },
            carbs: { type: Type.NUMBER },
            protein: { type: Type.NUMBER },
            fat: { type: Type.NUMBER },
          },
          required: ['foodName', 'calories', 'carbs', 'protein', 'fat'],
        },
      },
    });

    return JSON.parse(response.text || '{}');
  }

  // 모든 조회·수정·삭제에 userId 조건을 같이 걸어서, 남의 기록은 "없는 것"처럼 보이게 한다.
  create(userId: number, dto: CreateMealDto) {
    return this.mealsRepository.save(this.mealsRepository.create({ ...dto, userId }));
  }

  findAll(userId: number) {
    return this.mealsRepository.find({ where: { userId }, order: { recordedDate: 'ASC', id: 'ASC' } });
  }

  async findOne(userId: number, id: number) {
    const meal = await this.mealsRepository.findOneBy({ id, userId });
    if (!meal) throw new NotFoundException('식단 기록을 찾을 수 없어요.');
    return meal;
  }

  async update(userId: number, id: number, dto: UpdateMealDto) {
    await this.findOne(userId, id); // 내 기록인지 먼저 확인
    await this.mealsRepository.update({ id, userId }, dto);
    return this.findOne(userId, id);
  }

  async remove(userId: number, id: number) {
    await this.findOne(userId, id);
    return this.mealsRepository.delete({ id, userId });
  }
}
