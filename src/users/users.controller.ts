import { Body, Controller, Delete, Get, Patch } from '@nestjs/common';
import { UserId } from '../auth/user-id.decorator';
import { UpdateProfileDto } from './dto/update-profile.dto';
import { UsersService } from './users.service';

// 다른 사람의 번호를 받는 API는 없다. 항상 "로그인한 나"만 다룬다.
@Controller('users/me')
export class UsersController {
  constructor(private readonly users: UsersService) {}

  @Get()
  findMe(@UserId() userId: number) {
    return this.users.findMe(userId);
  }

  @Patch()
  update(@UserId() userId: number, @Body() dto: UpdateProfileDto) {
    return this.users.updateMe(userId, dto);
  }

  @Delete()
  remove(@UserId() userId: number) {
    return this.users.remove(userId);
  }
}
