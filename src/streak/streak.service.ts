import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { RecordDay } from './entities/record-day.entity';
import { calcStreak, todayKst } from './streak';

@Injectable()
export class StreakService {
  constructor(@InjectRepository(RecordDay) private days: Repository<RecordDay>) {}

  async find(userId: number) {
    const rows = await this.days.findBy({ userId });
    return calcStreak(rows.map((row) => row.date), todayKst());
  }
}
