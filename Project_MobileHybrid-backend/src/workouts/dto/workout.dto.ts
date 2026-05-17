import { IsString, IsNumber, IsEnum, IsArray, IsOptional, Min, Max, MinLength, MaxLength } from 'class-validator';

export class CreateWorkoutDto {
  @IsString()
  @MinLength(2)
  @MaxLength(100)
  name: string;

  @IsNumber()
  @Min(1)
  @Max(480)
  duration: number;

  @IsNumber()
  @Min(0)
  caloriesBurned: number;

  @IsEnum(['Beginner', 'Intermediate', 'Advanced'])
  difficulty: 'Beginner' | 'Intermediate' | 'Advanced';

  @IsArray()
  @IsString({ each: true })
  exercises: string[];

  @IsOptional()
  @IsString()
  @MaxLength(500)
  notes?: string;
}

export class WorkoutPlanDto {
  id: string;
  name: string;
  duration: number;
  difficulty: string;
  description: string;
  exercises: any[];
  caloriesBurned: number;
}

export class ExerciseDto {
  @IsString()
  name: string;

  @IsNumber()
  @Min(1)
  sets: number;

  @IsOptional()
  @IsNumber()
  @Min(1)
  reps?: number;

  @IsOptional()
  @IsNumber()
  @Min(1)
  duration?: number;

  @IsOptional()
  @IsString()
  videoUrl?: string;

  @IsOptional()
  @IsNumber()
  @Min(0)
  caloriesBurned?: number;
}

export class UserWorkoutHistoryDto {
  id: string;
  name: string;
  date: string;
  duration: number;
  caloriesBurned: number;
  difficulty: string;
}

export class CreateWorkoutPlanDto {
  @IsString()
  @MinLength(2)
  @MaxLength(100)
  name: string;

  @IsNumber()
  @Min(1)
  @Max(480)
  duration: number;

  @IsEnum(['Beginner', 'Intermediate', 'Advanced'])
  difficulty: string;

  @IsString()
  @MinLength(5)
  @MaxLength(500)
  description: string;

  @IsOptional()
  @IsArray()
  exercises?: any[];
}
