import { ValidationPipe } from '@nestjs/common';
import { NestFactory } from '@nestjs/core';
import { AppModule } from './app.module';

async function bootstrap() {
  const app = await NestFactory.create(AppModule);

  // 입력 규칙 검사. whitelist: 규칙에 없는 항목은 버린다(userId 위조 방지)
  app.useGlobalPipes(new ValidationPipe({ whitelist: true, transform: true }));
  app.enableCors(); // 앱(웹 포함)에서의 요청 허용

  await app.listen(process.env.PORT ?? 3000);
}
void bootstrap();
