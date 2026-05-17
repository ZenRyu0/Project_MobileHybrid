import { Injectable, NotFoundException } from '@nestjs/common';
import { LogMealDto, DailyCalorieTargetDto, DailyCalorieStatsDto } from './dto/calorie.dto';
import { PrismaService } from '../database/prisma.service';

@Injectable()
export class CaloriesService {
  constructor(private prisma: PrismaService) {}

  async logMeal(userId: string, logMealDto: LogMealDto) {
    return this.prisma.calorieEntry.create({
      data: {
        ...logMealDto,
        userId,
        date: new Date().toISOString().split('T')[0],
      },
    });
  }

  async setDailyTarget(userId: string, target: number) {
    await this.prisma.dailyCalorieTarget.upsert({
      where: { userId },
      update: { target },
      create: { userId, target },
    });

    return {
      success: true,
      message: 'Daily target updated',
      data: {
        userId,
        dailyTarget: target,
      },
    };
  }

  async getDailyStats(userId: string): Promise<DailyCalorieStatsDto> {
    const today = new Date().toISOString().split('T')[0];

    const todaysMeals = await this.prisma.calorieEntry.findMany({
      where: {
        userId,
        date: today,
      },
    });

    const totalConsumed = todaysMeals.reduce((sum, meal) => sum + meal.calories, 0);

    const dailyTarget = await this.prisma.dailyCalorieTarget.findUnique({
      where: { userId },
    });

    const targetValue = dailyTarget?.target || 2000;

    // Get workout calories burned today
    const todaysWorkouts = await this.prisma.workout.findMany({
      where: {
        userId,
        date: today,
      },
    });

    const totalBurned = todaysWorkouts.reduce((sum, w) => sum + w.caloriesBurned, 0);

    const totalProtein = todaysMeals.reduce((sum, meal) => sum + (meal.protein || 0), 0);
    const totalCarbs = todaysMeals.reduce((sum, meal) => sum + (meal.carbs || 0), 0);
    const totalFat = todaysMeals.reduce((sum, meal) => sum + (meal.fat || 0), 0);
    const macroTotal = totalProtein + totalCarbs + totalFat;

    return {
      date: today,
      userId,
      dailyTarget: targetValue,
      totalConsumed,
      totalBurned,
      netCalories: totalConsumed - totalBurned,
      meals: todaysMeals.map((meal) => ({
        id: meal.id,
        mealType: meal.mealType,
        foodName: meal.foodName,
        calories: meal.calories,
        protein: meal.protein || 0,
        carbs: meal.carbs || 0,
        fat: meal.fat || 0,
        timestamp: meal.timestamp.toISOString(),
      })),
      macros: {
        protein: totalProtein,
        carbs: totalCarbs,
        fat: totalFat,
        proteinPercent: macroTotal > 0 ? Math.round((totalProtein / macroTotal) * 100) : 0,
        carbsPercent: macroTotal > 0 ? Math.round((totalCarbs / macroTotal) * 100) : 0,
        fatPercent: macroTotal > 0 ? Math.round((totalFat / macroTotal) * 100) : 0,
      },
    };
  }

  async getCalorieHistory(userId: string, days: number = 7) {
    const history: any[] = [];
    const today = new Date();

    const dailyTarget = await this.prisma.dailyCalorieTarget.findUnique({
      where: { userId },
    });

    const targetValue = dailyTarget?.target || 2000;

    for (let i = days - 1; i >= 0; i--) {
      const date = new Date(today);
      date.setDate(date.getDate() - i);
      const dateStr = date.toISOString().split('T')[0];

      const daysMeals = await this.prisma.calorieEntry.findMany({
        where: {
          userId,
          date: dateStr,
        },
      });

      const totalConsumed = daysMeals.reduce((sum, meal) => sum + meal.calories, 0);

      history.push({
        date: dateStr,
        totalConsumed,
        dailyTarget: targetValue,
        remaining: Math.max(0, targetValue - totalConsumed),
        mealCount: daysMeals.length,
      });
    }

    return history;
  }

  async getTotalStats(userId: string) {
    const allMeals = await this.prisma.calorieEntry.findMany({
      where: { userId },
    });

    const totalCalories = allMeals.reduce((sum, meal) => sum + meal.calories, 0);
    const uniqueDates = new Set(allMeals.map((meal) => meal.date));
    const daysTracked = uniqueDates.size;
    const averageDaily = daysTracked > 0 ? Math.round(totalCalories / daysTracked) : 0;

    const dailyTarget = await this.prisma.dailyCalorieTarget.findUnique({
      where: { userId },
    });

    return {
      totalCalories,
      mealsLogged: allMeals.length,
      daysTracked,
      averageDailyIntake: averageDaily,
      dailyTarget: dailyTarget?.target || 2000,
    };
  }

  async deleteMeal(id: string, userId: string) {
    const meal = await this.prisma.calorieEntry.findUnique({
      where: { id },
    });

    if (!meal || meal.userId !== userId) {
      throw new NotFoundException('Meal not found');
    }

    return this.prisma.calorieEntry.delete({
      where: { id },
    });
  }
}
