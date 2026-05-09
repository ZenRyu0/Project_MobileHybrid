import { Controller, Get, Post, Put, Param, Body } from '@nestjs/common';
import { CaloriesService } from './calories.service';
import { LogMealDto, DailyCalorieTargetDto } from './dto/calorie.dto';

@Controller('calories')
export class CaloriesController {
  constructor(private caloriesService: CaloriesService) {}

  @Post('log-meal')
  async logMeal(@Body() logMealDto: LogMealDto) {
    const meal = this.caloriesService.logMeal(logMealDto);
    return {
      success: true,
      message: 'Meal logged successfully',
      data: meal,
    };
  }

  @Put('target')
  async setDailyTarget(@Body() targetDto: DailyCalorieTargetDto) {
    return this.caloriesService.setDailyTarget(targetDto.userId, targetDto.dailyTarget);
  }

  @Get('daily-stats/:userId')
  async getDailyStats(@Param('userId') userId: string) {
    const stats = this.caloriesService.getDailyStats(userId);
    return {
      success: true,
      data: stats,
    };
  }

  @Get('history/:userId')
  async getCalorieHistory(
    @Param('userId') userId: string,
  ) {
    const history = this.caloriesService.getCalorieHistory(userId);
    return {
      success: true,
      data: history,
    };
  }

  @Get('stats/:userId')
  async getTotalStats(@Param('userId') userId: string) {
    const stats = this.caloriesService.getTotalStats(userId);
    return {
      success: true,
      data: stats,
    };
  }
}
