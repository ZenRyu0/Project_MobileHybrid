import { Injectable, NotFoundException } from '@nestjs/common';
import { LogMealDto, DailyCalorieTargetDto, DailyCalorieStatsDto } from './dto/calorie.dto';
import { PrismaService } from '../database/prisma.service';
import { FoodSearchService } from '../foods/food-search.service';

@Injectable()
export class CaloriesService {
  constructor(
    private prisma: PrismaService,
    private foodSearchService: FoodSearchService,
  ) {}

  async logMeal(userId: string, logMealDto: LogMealDto) {
    const foods = await this.foodSearchService.searchFoods(logMealDto.foodQuery, 1);

    if (!foods || foods.length === 0) {
      throw new NotFoundException('Food not found in database');
    }

    const food = foods[0];
    const servingSizeMultiplier = logMealDto.servingSize / 100;

    const calories = Math.round(food.caloriesPer100g * servingSizeMultiplier);
    const protein = Math.round(food.protein * servingSizeMultiplier * 10) / 10;
    const carbs = Math.round(food.carbs * servingSizeMultiplier * 10) / 10;
    const fat = Math.round(food.fat * servingSizeMultiplier * 10) / 10;

    return this.prisma.calorieEntry.create({
      data: {
        userId,
        mealType: logMealDto.mealType,
        foodName: food.description,
        calories,
        protein,
        carbs,
        fat,
        fdsId: logMealDto.fdsId || food.fdsId,
        servingSize: logMealDto.servingSize,
        foodQuery: logMealDto.foodQuery,
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

    const [todaysMeals, dailyTarget, todaysWorkouts] = await Promise.all([
      this.prisma.calorieEntry.findMany({
        where: {
          userId,
          date: today,
        },
      }),
      this.prisma.dailyCalorieTarget.findUnique({
        where: { userId },
      }),
      this.prisma.workout.findMany({
        where: {
          userId,
          date: today,
        },
      }),
    ]);

    const totalConsumed = todaysMeals.reduce((sum, meal) => sum + meal.calories, 0);
    const targetValue = dailyTarget?.target || 2000;
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
        protein: Math.round(totalProtein * 10) / 10,
        carbs: Math.round(totalCarbs * 10) / 10,
        fat: Math.round(totalFat * 10) / 10,
        proteinPercent: macroTotal > 0 ? Math.round((totalProtein / macroTotal) * 100) : 0,
        carbsPercent: macroTotal > 0 ? Math.round((totalCarbs / macroTotal) * 100) : 0,
        fatPercent: macroTotal > 0 ? Math.round((totalFat / macroTotal) * 100) : 0,
      },
    };
  }

  async getCalorieHistory(userId: string, days: number = 7) {
    const today = new Date();
    const startDate = new Date(today);
    startDate.setDate(startDate.getDate() - (days - 1));

    const [meals, dailyTarget] = await Promise.all([
      this.prisma.calorieEntry.findMany({
        where: {
          userId,
          date: {
            gte: startDate.toISOString().split('T')[0],
            lte: today.toISOString().split('T')[0],
          },
        },
        select: {
          date: true,
          calories: true,
        },
      }),
      this.prisma.dailyCalorieTarget.findUnique({
        where: { userId },
      }),
    ]);

    const targetValue = dailyTarget?.target || 2000;
    const mealsByDate = new Map<string, { calories: number; count: number }>();

    meals.forEach((meal) => {
      const existing = mealsByDate.get(meal.date) || { calories: 0, count: 0 };
      mealsByDate.set(meal.date, {
        calories: existing.calories + meal.calories,
        count: existing.count + 1,
      });
    });

    const history = [];
    for (let i = days - 1; i >= 0; i--) {
      const date = new Date(today);
      date.setDate(date.getDate() - i);
      const dateStr = date.toISOString().split('T')[0];
      const dayData = mealsByDate.get(dateStr) || { calories: 0, count: 0 };

      history.push({
        date: dateStr,
        totalConsumed: dayData.calories,
        dailyTarget: targetValue,
        remaining: Math.max(0, targetValue - dayData.calories),
        mealCount: dayData.count,
      });
    }

    return history;
  }

  async getTotalStats(userId: string) {
    const allMeals = await this.prisma.calorieEntry.findMany({
      where: { userId },
      select: {
        calories: true,
        date: true,
      },
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


