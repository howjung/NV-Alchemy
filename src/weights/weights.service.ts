import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { CreateWeightDto } from './dto/create-weight.dto';
import { UpdateWeightDto } from './dto/update-weight.dto';
import { Weight } from './entities/weight.entity';

// 모든 조회·수정·삭제에 userId 조건을 같이 걸어서, 남의 기록은 "없는 것"처럼 보이게 한다.
@Injectable()
export class WeightsService {
  constructor(
    @InjectRepository(Weight) private weights: Repository<Weight>,
  ) {}

  // 체중은 하루 한 번만: 같은 날 다시 입력하면 마지막 값으로 덮어쓴다(PRD)
  async create(userId: number, dto: CreateWeightDto) {
    const existing = await this.weights.findOneBy({ userId, recordedDate: dto.recordedDate });
    return this.weights.save(
      existing ? { ...existing, weight: dto.weight } : this.weights.create({ ...dto, userId }),
    );
  }

  findAll(userId: number) {
    return this.weights.find({ where: { userId }, order: { recordedDate: 'ASC' } });
  }

  async findOne(userId: number, id: number) {
    const weight = await this.weights.findOneBy({ id, userId });
    if (!weight) throw new NotFoundException('체중 기록을 찾을 수 없어요.');
    return weight;
  }

  async update(userId: number, id: number, dto: UpdateWeightDto) {
    await this.findOne(userId, id); // 내 기록인지 먼저 확인
    await this.weights.update({ id, userId }, dto);
    return this.findOne(userId, id);
  }

  async remove(userId: number, id: number) {
    await this.findOne(userId, id);
    return this.weights.delete({ id, userId });
  }
}
