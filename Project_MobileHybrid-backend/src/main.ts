import { NestFactory } from '@nestjs/core';
import { ValidationPipe } from '@nestjs/common';
import { AppModule } from './app.module';
import { NestExpressApplication } from '@nestjs/platform-express';
import { join } from 'path';
import { PrismaService } from './database/prisma.service';
import { apiLimiter, authLimiter } from './common/middleware/rate-limit.middleware';
import { logger } from './common/logger/winston.logger';

async function bootstrap() {
  const app = await NestFactory.create<NestExpressApplication>(AppModule);

  app.enableCors({
    origin: process.env.NODE_ENV === 'production'
      ? ['https://go-fit-frontend.netlify.app']
      : '*',
    credentials: true,
  });

  // Apply auth-specific rate limiting to auth endpoints
  app.use('/auth', authLimiter);

  // Apply global rate limiting middleware to all other endpoints
  app.use(apiLimiter);

  app.useGlobalPipes(new ValidationPipe({ transform: true }));

  app.useStaticAssets(join(__dirname, '..', 'uploads'), {
    prefix: '/uploads/',
  });

  // Enable Prisma shutdown hooks
  const prismaService = app.get(PrismaService);
  await prismaService.enableShutdownHooks(app);

  const port = process.env.PORT || 3000;
  const environment = process.env.NODE_ENV || 'development';
  const host = process.env.HOST || 'localhost';
  const protocol = environment === 'production' ? 'https' : 'http';
  const url = environment === 'production'
    ? process.env.DEPLOYED_URL || `https://go-fit-production-1a8c.up.railway.app`
    : `${protocol}://${host}:${port}`;

  await app.listen(port, () => {
    logger.info(`Server running on ${url}`);
    if (environment === 'production') {
      logger.info('🛡️  Rate limiting enabled');
    }
  });
}

bootstrap().catch((error) => {
  logger.error('Failed to start server', { error: error.message, stack: error.stack });
  process.exit(1);
});



