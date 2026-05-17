import { Controller, Get, Post, Put, Delete, Param, Body, UseGuards } from '@nestjs/common';
import { CaloriesService } from './calories.service';
import { LogMealDto, DailyCalorieTargetDto } from './dto/calorie.dto';
import { JwtAuthGuard } from '../auth/guards/jwt.guard';
import { CurrentUser } from '../auth/decorators/current-user.decorator';

@Controller('calories')
export class CaloriesController {
  constructor(private caloriesService: CaloriesService) {}

  @Post('log-meal')
  @UseGuards(JwtAuthGuard)
  async logMeal(@CurrentUser() user: any, @Body() logMealDto: LogMealDto) {
    const meal = await this.caloriesService.logMeal(user.id, logMealDto);
    return {
      success: true,
      message: 'Meal logged successfully',
      data: meal,
    };
  }

  @Put('target')
  @UseGuards(JwtAuthGuard)
  async setDailyTarget(@CurrentUser() user: any, @Body() targetDto: DailyCalorieTargetDto) {
    return this.caloriesService.setDailyTarget(user.id, targetDto.dailyTarget);
  }

  @Get('daily-stats/me')
  @UseGuards(JwtAuthGuard)
  async getMyDailyStats(@CurrentUser() user: any) {
    const stats = await this.caloriesService.getDailyStats(user.id);
    return {
      success: true,
      data: stats,
    };
  }

  @Get('daily-stats/:userId')
  async getDailyStats(@Param('userId') userId: string) {
    const stats = await this.caloriesService.getDailyStats(userId);
    return {
      success: true,
      data: stats,
    };
  }

  @Get('history/me')
  @UseGuards(JwtAuthGuard)
  async getMyCalorieHistory(@CurrentUser() user: any) {
    const history = await this.caloriesService.getCalorieHistory(user.id);
    return {
      success: true,
      data: history,
    };
  }

  @Get('history/:userId')
  async getCalorieHistory(
    @Param('userId') userId: string,
  ) {
    const history = await this.caloriesService.getCalorieHistory(userId);
    return {
      success: true,
      data: history,
    };
  }

  @Get('stats/me')
  @UseGuards(JwtAuthGuard)
  async getMyTotalStats(@CurrentUser() user: any) {
    const stats = await this.caloriesService.getTotalStats(user.id);
    return {
      success: true,
      data: stats,
    };
  }

  @Get('stats/:userId')
  async getTotalStats(@Param('userId') userId: string) {
    const stats = await this.caloriesService.getTotalStats(userId);
    return {
      success: true,
      data: stats,
    };
  }

  @Delete('meals/:id')
  @UseGuards(JwtAuthGuard)
  async deleteMeal(@CurrentUser() user: any, @Param('id') id: string) {
    await this.caloriesService.deleteMeal(id, user.id);
    return {
      success: true,
      message: 'Meal deleted successfully',
    };
  }
}
