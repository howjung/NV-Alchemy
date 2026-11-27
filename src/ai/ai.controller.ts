import { Controller, Get, Query } from '@nestjs/common';
import { UserId } from '../auth/user-id.decorator';
import { AiService } from './ai.service';
import { TipQueryDto } from './dto/tip-query.dto';

@Controller('ai')
export class AiController {
  constructor(private readonly ai: AiService) {}

  @Get('tip') // GET /ai/tip?calories=2442&carbs=256&protein=128&fat=64 (로그인 필요)
  tip(@UserId() userId: number, @Query() goal: TipQueryDto) {
    return this.ai.tip(userId, goal);
  }
}
