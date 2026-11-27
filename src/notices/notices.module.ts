import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { Notice } from './entities/notice.entity';
import { NoticesController } from './notices.controller';
import { NoticesService } from './notices.service';

@Module({
  imports: [TypeOrmModule.forFeature([Notice])], // 이 module에서 Notice 테이블 사용
  controllers: [NoticesController],
  providers: [NoticesService],
})
export class NoticesModule { }