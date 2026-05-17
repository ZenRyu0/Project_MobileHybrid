import { INestApplication, Injectable, Logger, OnModuleInit } from '@nestjs/common';

@Injectable()
export class PrismaService implements OnModuleInit {
  private readonly logger = new Logger(PrismaService.name);
  private client: any;

  constructor() {
    // eslint-disable-next-line @typescript-eslint/no-var-requires
    const { PrismaClient } = require('@prisma/client');
    this.client = new PrismaClient();
  }

  async onModuleInit() {
    try {
      await this.client.$connect();
      this.logger.log('Database connected successfully');
    } catch (error) {
      this.logger.error('Failed to connect to database', error);
      throw error;
    }
  }

  async enableShutdownHooks(app: INestApplication) {
    this.client.$on('disconnect' as any, async () => {
      await app.close();
    });
  }

  async onModuleDestroy() {
    await this.client.$disconnect();
  }

  get user() {
    return this.client.user;
  }

  get workout() {
    return this.client.workout;
  }

  get workoutPlan() {
    return this.client.workoutPlan;
  }

  get calorieEntry() {
    return this.client.calorieEntry;
  }

  get dailyCalorieTarget() {
    return this.client.dailyCalorieTarget;
  }

  get post() {
    return this.client.post;
  }

  get comment() {
    return this.client.comment;
  }

  get postLike() {
    return this.client.postLike;
  }

  get $connect() {
    return this.client.$connect.bind(this.client);
  }

  get $disconnect() {
    return this.client.$disconnect.bind(this.client);
  }

  get $on() {
    return this.client.$on.bind(this.client);
  }
}
