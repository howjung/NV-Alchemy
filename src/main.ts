import { ValidationPipe } from '@nestjs/common';
import { NestFactory } from '@nestjs/core';
import { AppModule } from './app.module';

async function bootstrap() {
  const app = await NestFactory.create(AppModule);
  
  // DTO에 적힌 규칙으로 입력을 검사한다. whitelist: DTO에 없는 항목은 버린다(userId 위조 등 방지)
  app.useGlobalPipes(new ValidationPipe({ whitelist: true, transform: true }));
  app.enableCors(); // Flutter 프론트엔드 API 요청 허용

  await app.listen(process.env.PORT ?? 3000);
}
bootstrap();