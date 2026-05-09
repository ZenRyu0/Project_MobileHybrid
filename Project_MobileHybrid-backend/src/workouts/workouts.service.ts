import { Injectable } from '@nestjs/common';
import { CreateWorkoutDto, CreateWorkoutPlanDto, WorkoutPlanDto } from './dto/workout.dto';

@Injectable()
export class WorkoutsService {
  private workoutPlans: WorkoutPlanDto[] = [
    {
      id: '1',
      name: 'Full Body Strength',
      duration: 45,
      difficulty: 'Intermediate',
      description: 'Complete full body workout targeting all major muscle groups',
      caloriesBurned: 350,
      exercises: [
        {
          name: 'Warm-up Cardio',
          sets: 1,
          reps: 10,
          duration: 5,
          caloriesBurned: 50,
        },
        {
          name: 'Squats',
          sets: 4,
          reps: 10,
          caloriesBurned: 80,
          videoUrl: 'https://example.com/squat-video',
        },
        {
          name: 'Bench Press',
          sets: 4,
          reps: 8,
          caloriesBurned: 75,
          videoUrl: 'https://example.com/bench-video',
        },
        {
          name: 'Deadlifts',
          sets: 3,
          reps: 5,
          caloriesBurned: 90,
          videoUrl: 'https://example.com/deadlift-video',
        },
        {
          name: 'Cool-down Stretching',
          sets: 1,
          duration: 5,
          caloriesBurned: 20,
        },
      ],
    },
    {
      id: '2',
      name: 'Morning Cardio',
      duration: 30,
      difficulty: 'Beginner',
      description: 'Start your day with energizing cardio exercises',
      caloriesBurned: 250,
      exercises: [
        {
          name: 'Warm-up Jumping Jacks',
          sets: 1,
          reps: 30,
          caloriesBurned: 30,
        },
        {
          name: 'Running/Jogging',
          sets: 1,
          duration: 15,
          caloriesBurned: 150,
        },
        {
          name: 'Burpees',
          sets: 3,
          reps: 15,
          caloriesBurned: 50,
        },
        {
          name: 'Cool-down Walk',
          sets: 1,
          duration: 5,
          caloriesBurned: 20,
        },
      ],
    },
    {
      id: '3',
      name: 'Yoga & Flexibility',
      duration: 20,
      difficulty: 'All Levels',
      description: 'Improve flexibility and mental clarity with gentle yoga',
      caloriesBurned: 80,
      exercises: [
        {
          name: 'Breathing & Centering',
          sets: 1,
          duration: 3,
          caloriesBurned: 10,
        },
        {
          name: 'Sun Salutation',
          sets: 5,
          reps: 1,
          caloriesBurned: 30,
        },
        {
          name: 'Standing Poses',
          sets: 1,
          duration: 7,
          caloriesBurned: 25,
        },
        {
          name: 'Relaxation & Meditation',
          sets: 1,
          duration: 5,
          caloriesBurned: 15,
        },
      ],
    },
    {
      id: '4',
      name: 'Core Crusher',
      duration: 15,
      difficulty: 'Advanced',
      description: 'Intense core workout for abs and stability',
      caloriesBurned: 200,
      exercises: [
        {
          name: 'Warm-up',
          sets: 1,
          duration: 2,
          caloriesBurned: 20,
        },
        {
          name: 'Planks',
          sets: 3,
          duration: 1,
          caloriesBurned: 40,
        },
        {
          name: 'Russian Twists',
          sets: 3,
          reps: 20,
          caloriesBurned: 50,
        },
        {
          name: 'Mountain Climbers',
          sets: 3,
          reps: 30,
          caloriesBurned: 60,
        },
        {
          name: 'Ab Rollers',
          sets: 3,
          reps: 10,
          caloriesBurned: 30,
        },
      ],
    },
  ];

  private userWorkoutHistory: any[] = [
    {
      id: '1',
      userId: '1',
      name: 'Morning Cardio',
      date: new Date(Date.now() - 2 * 24 * 60 * 60 * 1000).toISOString().split('T')[0],
      duration: 30,
      caloriesBurned: 250,
      difficulty: 'Beginner',
    },
    {
      id: '2',
      userId: '1',
      name: 'Full Body Strength',
      date: new Date(Date.now() - 1 * 24 * 60 * 60 * 1000).toISOString().split('T')[0],
      duration: 45,
      caloriesBurned: 350,
      difficulty: 'Intermediate',
    },
  ];

  getWorkoutPlans(): WorkoutPlanDto[] {
    return this.workoutPlans;
  }

  getWorkoutPlanById(id: string): WorkoutPlanDto {
    return this.workoutPlans.find((plan) => plan.id === id);
  }

  logWorkout(createWorkoutDto: CreateWorkoutDto): any {
    const newWorkout = {
      id: Math.random().toString(36).substr(2, 9),
      ...createWorkoutDto,
      date: new Date().toISOString().split('T')[0],
    };

    this.userWorkoutHistory.push(newWorkout);
    return newWorkout;
  }

  getUserWorkoutHistory(userId: string): any[] {
    return this.userWorkoutHistory.filter((w) => w.userId === userId);
  }

  getWorkoutStats(userId: string): any {
    const workouts = this.userWorkoutHistory.filter((w) => w.userId === userId);
    const totalWorkouts = workouts.length;
    const totalCalories = workouts.reduce((sum, w) => sum + w.caloriesBurned, 0);
    const totalDuration = workouts.reduce((sum, w) => sum + w.duration, 0);

    return {
      totalWorkouts,
      totalCaloriesBurned: totalCalories,
      totalDuration,
      averageCaloriesPerWorkout:
        totalWorkouts > 0 ? Math.round(totalCalories / totalWorkouts) : 0,
    };
  }
  
  createWorkoutPlan(createWorkoutPlanDto: CreateWorkoutPlanDto): WorkoutPlanDto {
    const newPlan: WorkoutPlanDto = {
      id: Math.random().toString(36).substr(2, 9),
      name: createWorkoutPlanDto.name,
      duration: createWorkoutPlanDto.duration,
      difficulty: createWorkoutPlanDto.difficulty,
      description: 'Custom workout routine', 
      caloriesBurned: createWorkoutPlanDto.duration * 5,
      exercises: createWorkoutPlanDto.exercises || [],
    };

    this.workoutPlans.push(newPlan);
    
    return newPlan;
  }
}
