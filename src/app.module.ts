import { Module } from '@nestjs/common';
import { APP_GUARD } from '@nestjs/core';
import { TypeOrmModule } from '@nestjs/typeorm';
import { ServeStaticModule } from '@nestjs/serve-static';
import { ConfigModule, ConfigService } from '@nestjs/config';
import { join } from 'path';
import { AppController } from './app.controller';
import { AppService } from './app.service';
import { AuthGuard } from './auth/auth.guard';
import { AuthModule } from './auth/auth.module';
import { UsersModule } from './users/users.module';
import { WeightsModule } from './weights/weights.module';
import { MealsModule } from './meals/meals.module';

@Module({
  imports: [
    ConfigModule.forRoot({ isGlobal: true }),
    ServeStaticModule.forRoot({
      rootPath: join(__dirname, '..', 'uploads'),
      serveRoot: '/uploads',
    }),
    TypeOrmModule.forRootAsync({
      inject: [ConfigService],
      useFactory: (config: ConfigService) =>
        // DB_TYPE=sqljs: Postgres 없이 로컬 파일(dev.sqlite)로 실행하는 개발용 모드
        config.get('DB_TYPE') === 'sqljs'
          ? {
              type: 'sqljs' as const,
              location: 'dev.sqlite',
              autoSave: true,
              autoLoadEntities: true,
              synchronize: true,
            }
          : {
              type: 'postgres' as const,
              host: config.get<string>('DB_HOST', 'localhost'),
              port: Number(config.get<string>('DB_PORT', '5432')),
              username: config.get<string>('DB_USER', 'postgres'),
              password: config.get<string>('DB_PASSWORD', 'postgres'),
              database: config.get<string>('DB_NAME', 'antifreeze_db'),
              autoLoadEntities: true,
              // shortcut: 개발용 자동 스키마 동기화, 운영 전에 마이그레이션으로 교체
              synchronize: true,
            },
    }),
    AuthModule,
    UsersModule,
    WeightsModule,
    MealsModule,
  ],
  controllers: [AppController],
  // 전역 문지기: 모든 API는 로그인이 필요하고, @Public()이 붙은 API만 예외
  providers: [AppService, { provide: APP_GUARD, useClass: AuthGuard }],
})
export class AppModule {}