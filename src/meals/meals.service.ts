import { Injectable } from '@nestjs/common';
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

  create(createMealDto: CreateMealDto) {
    const meal = this.mealsRepository.create(createMealDto);
    return this.mealsRepository.save(meal);
  }

  findAll() {
    return this.mealsRepository.find();
  }

  findOne(id: number) {
    return this.mealsRepository.findOneBy({ id });
  }

  async update(id: number, updateMealDto: UpdateMealDto) {
    await this.mealsRepository.update(id, updateMealDto);
    return this.findOne(id);
  }

  remove(id: number) {
    return this.mealsRepository.delete(id);
  }
}