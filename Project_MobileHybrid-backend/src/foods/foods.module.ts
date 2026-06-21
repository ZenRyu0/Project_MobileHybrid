import { Module } from '@nestjs/common';
import { HttpModule } from '@nestjs/axios';
import { FoodSearchService } from './food-search.service';
@Module({
  imports: [HttpModule],
  providers: [FoodSearchService],
  exports: [FoodSearchService],
})
export class FoodsModule {}
