import { NestFactory } from '@nestjs/core';
import { ValidationPipe } from '@nestjs/common';
import { AppModule } from './app.module';
import { NestExpressApplication } from '@nestjs/platform-express';
import { join } from 'path';

async function bootstrap() {
  const app = await NestFactory.create<NestExpressApplication>(AppModule);

  // Enable CORS for Flutter development
  app.enableCors({
    origin: '*',
    credentials: true,
  });

  // Global validation pipe for DTOs
  app.useGlobalPipes(new ValidationPipe());

  app.useStaticAssets(join(__dirname, '..', 'uploads'), {
    prefix: '/uploads/',
  });

  const port = process.env.PORT || 3000;
  await app.listen(port, () => {
    console.log(`Server running on http://localhost:${port}`);
  });
}

bootstrap();
