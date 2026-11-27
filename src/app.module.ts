import { Module } from '@nestjs/common';
import { ConfigModule, ConfigService } from '@nestjs/config';
import { TypeOrmModule } from '@nestjs/typeorm';
import { AppController } from './app.controller';
import { AppService } from './app.service';
import { NoticesModule } from './notices/notices.module';
import { APP_GUARD } from '@nestjs/core';
import { AuthGuard } from './auth/auth.guard';
import { AuthModule } from './auth/auth.module';
import { UsersModule } from './users/users.module';
import { WeightsModule } from './weights/weights.module';
import { MealsModule } from './meals/meals.module';
import { StreakModule } from './streak/streak.module';
import { AiModule } from './ai/ai.module';

@Module({
  imports: [
    AuthModule,
    // .env 파일의 값을 어디서든 읽을 수 있게 한다
    ConfigModule.forRoot({ isGlobal: true }),
    // DB 연결 설정. .env를 읽은 뒤에 만들어야 해서 forRootAsync를 쓴다
    TypeOrmModule.forRootAsync({
      inject: [ConfigService],
      useFactory: (config: ConfigService) => ({
        type: 'postgres' as const,
        // 값이 없으면 서버가 바로 오류를 낸다
        url: config.getOrThrow<string>('DATABASE_URL'),
        // shortcut: 서버 인증서를 검증하지 않음. 운영 전에 Supabase 인증서(CA)를 등록
        ssl: { rejectUnauthorized: false },
        autoLoadEntities: true,
        // shortcut: entity에 맞춰 테이블을 자동 변경(컬럼 삭제 가능). 운영 전에 마이그레이션으로 교체
        synchronize: true,
      }),
    }),
    NoticesModule,
    UsersModule,
    WeightsModule,
    MealsModule,
    StreakModule,
    AiModule,
  ],
  controllers: [AppController],
  // 전역 문지기: @Public()이 없는 모든 API는 로그인이 필요하다
  providers: [AppService, { provide: APP_GUARD, useClass: AuthGuard }],
})
export class AppModule { }