import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { CreateWeightDto } from './dto/create-weight.dto';
import { UpdateWeightDto } from './dto/update-weight.dto';
import { Weight } from './entities/weight.entity';

@Injectable()
export class WeightsService {
  constructor(
    @InjectRepository(Weight)
    private weightsRepository: Repository<Weight>,
  ) {}

  create(createWeightDto: CreateWeightDto) {
    const weight = this.weightsRepository.create(createWeightDto);
    return this.weightsRepository.save(weight);
  }

  findAll(userId?: number) {
    return this.weightsRepository.find({
      where: userId !== undefined ? { userId } : undefined,
      order: { recordedDate: 'ASC', id: 'ASC' },
    });
  }

  findOne(id: number) {
    return this.weightsRepository.findOneBy({ id });
  }

  async update(id: number, updateWeightDto: UpdateWeightDto) {
    await this.weightsRepository.update(id, updateWeightDto);
    return this.findOne(id);
  }

  remove(id: number) {
    return this.weightsRepository.delete(id);
  }
}