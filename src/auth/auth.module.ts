import { Module } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { JwtModule } from '@nestjs/jwt';
import { TypeOrmModule } from '@nestjs/typeorm';
import { User } from '../users/entities/user.entity';
import { AuthController } from './auth.controller';
import { AuthService } from './auth.service';

@Module({
  imports: [
    TypeOrmModule.forFeature([User]),
    JwtModule.registerAsync({
      global: true, // 문지기(AuthGuard)가 어디서든 JwtService를 쓸 수 있게
      inject: [ConfigService],
      useFactory: (config: ConfigService) => {
        const secret = config.get<string>('JWT_SECRET');
        // 비밀키가 없으면 아무나 토큰을 위조할 수 있으므로 서버를 아예 켜지 않는다
        if (!secret) throw new Error('.env에 JWT_SECRET을 설정해 주세요.');
        // shortcut: 액세스 토큰 하나만 발급(7일). 재발급(refresh)·로그아웃 폐기는 필요해질 때 추가
        return { secret, signOptions: { expiresIn: '7d' } };
      },
    }),
  ],
  controllers: [AuthController],
  providers: [AuthService],
})
export class AuthModule {}
