import { NestFactory } from '@nestjs/core';
import { AppModule } from './app.module';

async function bootstrap() {
  const app = await NestFactory.create(AppModule);
  
  app.enableCors(); // Flutter 프론트엔드 API 요청 허용

  await app.listen(process.env.PORT ?? 3000);
}
bootstrap();