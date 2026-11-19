import {
  ConflictException,
  Injectable,
  UnauthorizedException,
} from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { User } from '../users/entities/user.entity';
import { LoginDto } from './dto/login.dto';
import { SignupDto } from './dto/signup.dto';
import { hashPassword, verifyPassword } from './password';

@Injectable()
export class AuthService {
  constructor(
    @InjectRepository(User) private users: Repository<User>,
    private jwt: JwtService,
  ) {}

  async signup(dto: SignupDto) {
    const email = dto.email.toLowerCase();
    if (await this.users.existsBy({ email })) {
      throw new ConflictException('이미 가입된 이메일이에요.');
    }
    const user = await this.users.save(
      this.users.create({
        email,
        nickname: dto.nickname,
        passwordHash: await hashPassword(dto.password),
      }),
    );
    return this.issueToken(user);
  }

  async login(dto: LoginDto) {
    // passwordHash는 평소 조회에서 빠져 있어서(select: false) 로그인 때만 명시해서 가져온다
    const user = await this.users.findOne({
      where: { email: dto.email.toLowerCase() },
      select: { id: true, email: true, nickname: true, passwordHash: true },
    });
    // 이메일이 없든 비밀번호가 틀리든 같은 메시지: 가입 여부를 알아내지 못하게 한다
    if (!user || !(await verifyPassword(dto.password, user.passwordHash))) {
      throw new UnauthorizedException('이메일 또는 비밀번호가 올바르지 않아요.');
    }
    return this.issueToken(user);
  }

  // 토큰 안에는 유저 번호(sub)만 넣는다. 비밀번호 같은 값은 절대 넣지 않는다.
  private async issueToken(user: User) {
    return {
      accessToken: await this.jwt.signAsync({ sub: user.id }),
      user: { id: user.id, email: user.email, nickname: user.nickname },
    };
  }
}
