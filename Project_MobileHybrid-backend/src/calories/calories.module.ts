import { Module } from '@nestjs/common';
import { CaloriesService } from './calories.service';
import { CaloriesController } from './calories.controller';

@Module({
  providers: [CaloriesService],
  controllers: [CaloriesController],
  exports: [CaloriesService],
})
export class CaloriesModule {}
