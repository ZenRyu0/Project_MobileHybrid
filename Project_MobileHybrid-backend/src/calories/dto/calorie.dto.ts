import { IsEnum, IsString, IsNumber, IsOptional, Min, Max, MaxLength } from 'class-validator';

export class LogMealDto {
  @IsEnum(['Breakfast', 'Lunch', 'Dinner', 'Snack'])
  mealType: 'Breakfast' | 'Lunch' | 'Dinner' | 'Snack';

  @IsString()
  @MaxLength(200)
  foodQuery: string;

  @IsNumber()
  @Min(1)
  @Max(10000)
  servingSize: number;

  @IsOptional()
  @IsString()
  fdsId?: string;
}

export class DailyCalorieTargetDto {
  @IsNumber()
  @Min(1000)
  @Max(10000)
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



