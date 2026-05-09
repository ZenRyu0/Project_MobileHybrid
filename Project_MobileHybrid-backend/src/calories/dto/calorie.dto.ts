export class LogMealDto {
  userId: string;
  mealType: 'Breakfast' | 'Lunch' | 'Dinner' | 'Snack';
  foodName: string;
  calories: number;
  protein?: number;
  carbs?: number;
  fat?: number;
}

export class DailyCalorieTargetDto {
  userId: string;
  dailyTarget: number;
}

export class CalorieEntryDto {
  id: string;
  userId: string;
  mealType: string;
  foodName: string;
  calories: number;
  date: string;
}

export class DailyCalorieStatsDto {
  date: string;
  userId: string;
  dailyTarget: number;
  totalConsumed: number;
  totalBurned: number;
  netCalories: number;
  meals: MealEntryDto[];
  macros: MacroBreakdownDto;
}

export class MealEntryDto {
  id: string;
  mealType: string;
  foodName: string;
  calories: number;
  protein: number;
  carbs: number;
  fat: number;
  timestamp: string;
}

export class MacroBreakdownDto {
  protein: number;
  carbs: number;
  fat: number;
  proteinPercent: number;
  carbsPercent: number;
  fatPercent: number;
}
