import { Injectable } from '@nestjs/common';
import { LogMealDto, DailyCalorieTargetDto, DailyCalorieStatsDto } from './dto/calorie.dto';

@Injectable()
export class CaloriesService {
  private mealLog: any[] = [];
  private dailyTargets: Map<string, number> = new Map([['1', 2000]]);

  logMeal(logMealDto: LogMealDto): any {
    const mealEntry = {
      id: Math.random().toString(36).substr(2, 9),
      ...logMealDto,
      date: new Date().toISOString().split('T')[0],
      timestamp: new Date().toISOString(),
    };

    this.mealLog.push(mealEntry);
    return mealEntry;
  }

  setDailyTarget(userId: string, target: number): any {
    this.dailyTargets.set(userId, target);
    return {
      success: true,
      message: 'Daily target updated',
      data: {
        userId,
        dailyTarget: target,
      },
    };
  }

  getDailyStats(userId: string): DailyCalorieStatsDto {
    const today = new Date().toISOString().split('T')[0];
    const todaysMeals = this.mealLog.filter(
      (meal) => meal.userId === userId && meal.date === today,
    );

    const totalConsumed = todaysMeals.reduce((sum, meal) => sum + meal.calories, 0);
    const dailyTarget = this.dailyTargets.get(userId) || 2000;

    // Mock workout calories for demo
    const totalBurned = 350; // This would come from workout logs in production

    const totalProtein = todaysMeals.reduce(
      (sum, meal) => sum + (meal.protein || 0),
      0,
    );
    const totalCarbs = todaysMeals.reduce((sum, meal) => sum + (meal.carbs || 0), 0);
    const totalFat = todaysMeals.reduce((sum, meal) => sum + (meal.fat || 0), 0);
    const macroTotal = totalProtein + totalCarbs + totalFat;

    return {
      date: today,
      userId,
      dailyTarget,
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
        timestamp: meal.timestamp,
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

  getCalorieHistory(userId: string, days: number = 7): any[] {
    const history: any[] = [];
    const today = new Date();

    for (let i = days - 1; i >= 0; i--) {
      const date = new Date(today);
      date.setDate(date.getDate() - i);
      const dateStr = date.toISOString().split('T')[0];

      const daysMeals = this.mealLog.filter(
        (meal) => meal.userId === userId && meal.date === dateStr,
      );
      const totalConsumed = daysMeals.reduce((sum, meal) => sum + meal.calories, 0);
      const dailyTarget = this.dailyTargets.get(userId) || 2000;

      history.push({
        date: dateStr,
        totalConsumed,
        dailyTarget,
        remaining: Math.max(0, dailyTarget - totalConsumed),
        mealCount: daysMeals.length,
      });
    }

    return history;
  }

  getTotalStats(userId: string): any {
    const allMeals = this.mealLog.filter((meal) => meal.userId === userId);
    const totalCalories = allMeals.reduce((sum, meal) => sum + meal.calories, 0);
    const daysTracked = new Set(allMeals.map((meal) => meal.date)).size;
    const averageDaily = daysTracked > 0 ? Math.round(totalCalories / daysTracked) : 0;

    return {
      totalCalories,
      mealsLogged: allMeals.length,
      daysTracked,
      averageDailyIntake: averageDaily,
      dailyTarget: this.dailyTargets.get(userId) || 2000,
    };
  }
}
