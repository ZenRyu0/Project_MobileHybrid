import { Controller, Get, Post, Put, Delete, Param, Body, UseGuards, Query, BadRequestException } from '@nestjs/common';
import { CaloriesService } from './calories.service';
import { LogMealDto, DailyCalorieTargetDto } from './dto/calorie.dto';
import { JwtAuthGuard } from '../auth/guards/jwt.guard';
import { CurrentUser } from '../auth/decorators/current-user.decorator';
import { FoodSearchService } from '../foods/food-search.service';

@Controller('calories')
export class CaloriesController {
  constructor(
    private caloriesService: CaloriesService,
    private foodSearchService: FoodSearchService,
  ) {}

  @Get('search-foods')
  async searchFoods(@Query('query') query: string) {
    if (!query || query.trim().length === 0) {
      throw new BadRequestException('Query parameter is required and cannot be empty');
    }
    if (query.length > 100) {
      throw new BadRequestException('Query parameter cannot exceed 100 characters');
    }

    const foods = await this.foodSearchService.searchFoods(query.trim(), 10);
    return {
      success: true,
      data: foods,
    };
  }

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
  @UseGuards(JwtAuthGuard)
  async getDailyStats(@CurrentUser() user: any, @Param('userId') userId: string) {
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
  @UseGuards(JwtAuthGuard)
  async getCalorieHistory(
    @CurrentUser() user: any,
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
  @UseGuards(JwtAuthGuard)
  async getTotalStats(@CurrentUser() user: any, @Param('userId') userId: string) {
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


