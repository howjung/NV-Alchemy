import { Controller, Get } from '@nestjs/common';
import { UserId } from '../auth/user-id.decorator';
import { StreakService } from './streak.service';

@Controller('streak')
export class StreakController {
  constructor(private readonly streak: StreakService) {}

  @Get() // GET /streak (로그인 필요)
  find(@UserId() userId: number) {
    return this.streak.find(userId);
  }
}
