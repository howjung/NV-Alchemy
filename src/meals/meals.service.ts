import { BadRequestException, Injectable, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { RecordDay } from '../streak/entities/record-day.entity';
import { todayKst } from '../streak/streak';
import { CreateMealDto } from './dto/create-meal.dto';
import { UpdateMealDto } from './dto/update-meal.dto';
import { Meal } from './entities/meal.entity';

// 모든 조회·수정·삭제에 userId 조건을 같이 걸어서, 남의 기록은 "없는 것"처럼 보이게 한다.
@Injectable()
export class MealsService {
  constructor(@InjectRepository(Meal) private meals: Repository<Meal>) {}

  async create(userId: number, dto: CreateMealDto) {
    // PRD: 식단은 오늘 날짜만 기록한다(지난 날짜를 채워 연속 기록을 만들 수 없게)
    if (dto.recordedDate !== todayKst()) {
      throw new BadRequestException('식단은 오늘 날짜만 기록할 수 있어요.');
    }
    // 식단과 기록한 날짜를 함께 저장한다. 하나라도 실패하면 둘 다 취소
    return this.meals.manager.transaction(async (m) => {
      const meal = await m.save(Meal, m.create(Meal, { ...dto, userId }));
      await m
        .createQueryBuilder()
        .insert()
        .into(RecordDay)
        .values({ userId, date: dto.recordedDate })
        .orIgnore() // 같은 날짜가 이미 있으면 넘어간다
        .updateEntity(false)
        .execute();
      return meal;
    });
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
    const meal = await this.findOne(userId, id); // 내 기록인지 먼저 확인
    if (dto.recordedDate !== undefined && dto.recordedDate !== meal.recordedDate) {
      throw new BadRequestException('기록 날짜는 바꿀 수 없어요.');
    }
    await this.meals.update({ id, userId }, dto);
    return this.findOne(userId, id);
  }

  async remove(userId: number, id: number) {
    await this.findOne(userId, id);
    return this.meals.delete({ id, userId });
  }
}
