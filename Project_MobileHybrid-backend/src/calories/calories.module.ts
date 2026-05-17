import { Module } from '@nestjs/common';
import { CaloriesService } from './calories.service';
import { CaloriesController } from './calories.controller';
import { DatabaseModule } from '../database/database.module';

@Module({
  imports: [DatabaseModule],
  providers: [CaloriesService],
  controllers: [CaloriesController],
  exports: [CaloriesService],
})
export class CaloriesModule {}
