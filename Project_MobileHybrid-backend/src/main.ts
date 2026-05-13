import { NestFactory } from '@nestjs/core';
import { ValidationPipe } from '@nestjs/common';
import { AppModule } from './app.module';
import { NestExpressApplication } from '@nestjs/platform-express';
import { join } from 'path';

async function bootstrap() {
  const app = await NestFactory.create<NestExpressApplication>(AppModule);

  app.enableCors({
    origin: '*',
    credentials: true,
  });

  app.useGlobalPipes(new ValidationPipe());

  app.useStaticAssets(join(__dirname, '..', 'uploads'), {
    prefix: '/uploads/',
  });

  const port = process.env.PORT || 3000;
  const environment = process.env.NODE_ENV || 'development';
  const host = process.env.HOST || 'localhost';
  const protocol = environment === 'production' ? 'https' : 'http';
  const url = environment === 'production' 
    ? process.env.DEPLOYED_URL || `https://go-fit-production-1a8c.up.railway.app`
    : `${protocol}://${host}:${port}`;
  
  await app.listen(port, () => {
    console.log(`Server running on ${url}`);
  });
}

bootstrap();
