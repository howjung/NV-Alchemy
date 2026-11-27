import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { RecordDay } from './entities/record-day.entity';
import { StreakController } from './streak.controller';
import { StreakService } from './streak.service';

@Module({
  imports: [TypeOrmModule.forFeature([RecordDay])],
  controllers: [StreakController],
  providers: [StreakService],
})
export class StreakModule {}
