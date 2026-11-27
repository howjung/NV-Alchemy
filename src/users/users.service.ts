import { BadRequestException, Injectable, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { DataSource, Repository } from 'typeorm';
import { Meal } from '../meals/entities/meal.entity';
import { Weight } from '../weights/entities/weight.entity';
import { UpdateProfileDto } from './dto/update-profile.dto';
import { User } from './entities/user.entity';

const MIN_AGE = 14; // 최소 가입 연령(PRD 확정)
const MAX_AGE = 100;

// 오늘 기준 만 나이. 생일이 아직 안 지났으면 1을 뺀다.
function ageOf(birthDate: string, today = new Date()): number {
  const [y, m, d] = birthDate.split('-').map(Number);
  let age = today.getFullYear() - y;
  if (today.getMonth() + 1 < m || (today.getMonth() + 1 === m && today.getDate() < d)) age--;
  return age;
}

@Injectable()
export class UsersService {
  constructor(
    @InjectRepository(User) private users: Repository<User>,
    private dataSource: DataSource,
  ) {}

  async findMe(id: number) {
    const user = await this.users.findOneBy({ id });
    if (!user) throw new NotFoundException('계정을 찾을 수 없어요.');
    return user;
  }

  async updateMe(id: number, dto: UpdateProfileDto) {
    if (dto.birthDate !== undefined) {
      const age = ageOf(dto.birthDate);
      if (Number.isNaN(age) || age < MIN_AGE || age > MAX_AGE) {
        throw new BadRequestException(`만 ${MIN_AGE}세 이상 ${MAX_AGE}세 이하만 이용할 수 있어요.`);
      }
    }
    await this.users.update(id, dto);
    return this.findMe(id);
  }

  // 회원 탈퇴: 본인의 계정과 기록을 한 번에 삭제한다(중간에 실패하면 전부 취소).
  // shortcut: 주문 익명화·포인트 소멸은 쇼핑 기능이 생길 때 같이 처리
  remove(id: number) {
    return this.dataSource.transaction(async (m) => {
      await m.delete(Weight, { userId: id });
      await m.delete(Meal, { userId: id });
      await m.delete(User, { id });
      return { deleted: true };
    });
  }
}
