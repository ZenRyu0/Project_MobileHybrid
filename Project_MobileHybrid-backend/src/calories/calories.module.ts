import { Module } from '@nestjs/common';
import { CaloriesService } from './calories.service';
import { CaloriesController } from './calories.controller';
import { DatabaseModule } from '../database/database.module';
import { FoodsModule } from '../foods/foods.module';
@Module({
  imports: [DatabaseModule, FoodsModule],
  providers: [CaloriesService],
  controllers: [CaloriesController],
  exports: [CaloriesService],
})
export class CaloriesModule {}
