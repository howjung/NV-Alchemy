import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { CreateMealDto } from './dto/create-meal.dto';
import { UpdateMealDto } from './dto/update-meal.dto';
import { Meal } from './entities/meal.entity';

// 모든 조회·수정·삭제에 userId 조건을 같이 걸어서, 남의 기록은 "없는 것"처럼 보이게 한다.
@Injectable()
export class MealsService {
  constructor(@InjectRepository(Meal) private meals: Repository<Meal>) {}

  create(userId: number, dto: CreateMealDto) {
    return this.meals.save(this.meals.create({ ...dto, userId }));
  }

  findAll(userId: number) {
    return this.meals.find({ where: { userId }, order: { recordedDate: 'ASC', id: 'ASC' } });
  }

  async findOne(userId: number, id: number) {
    const meal = await this.meals.findOneBy({ id, userId });
    if (!meal) throw new NotFoundException('식단 기록을 찾을 수 없어요.');
    return meal;
  }

  async update(userId: number, id: number, dto: UpdateMealDto) {
    await this.findOne(userId, id); // 내 기록인지 먼저 확인
    await this.meals.update({ id, userId }, dto);
    return this.findOne(userId, id);
  }

  async remove(userId: number, id: number) {
    await this.findOne(userId, id);
    return this.meals.delete({ id, userId });
  }
}
