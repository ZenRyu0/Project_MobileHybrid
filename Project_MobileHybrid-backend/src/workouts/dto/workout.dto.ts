export class CreateWorkoutDto {
  userId: string;
  name: string;
  duration: number; // in minutes
  caloriesBurned: number;
  difficulty: 'Beginner' | 'Intermediate' | 'Advanced';
  exercises: string[];
  notes?: string;
}

export class WorkoutPlanDto {
  id: string;
  name: string;
  duration: number;
  difficulty: string;
  description: string;
  exercises: ExerciseDto[];
  caloriesBurned: number;
}

export class ExerciseDto {
  name: string;
  sets: number;
  reps?: number;
  duration?: number;
  videoUrl?: string;
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
