import { Injectable, NotFoundException } from '@nestjs/common';
import { CreateWorkoutDto, CreateWorkoutPlanDto, WorkoutPlanDto } from './dto/workout.dto';
import { PrismaService } from '../database/prisma.service';

@Injectable()
export class WorkoutsService {
  constructor(private prisma: PrismaService) {}

  async getWorkoutPlans(): Promise<WorkoutPlanDto[]> {
    const plans = await this.prisma.workoutPlan.findMany();
    return plans.map((plan) => ({
      ...plan,
      exercises: (Array.isArray(plan.exercises) ? plan.exercises : []) as any[],
    }));
  }

  async getWorkoutPlanById(id: string): Promise<WorkoutPlanDto> {
    const plan = await this.prisma.workoutPlan.findUnique({
      where: { id },
    });

    if (!plan) {
      throw new NotFoundException('Workout plan not found');
    }

    return {
      ...plan,
      exercises: (Array.isArray(plan.exercises) ? plan.exercises : []) as any[],
    };
  }

  async logWorkout(userId: string, createWorkoutDto: CreateWorkoutDto) {
    return this.prisma.workout.create({
      data: {
        ...createWorkoutDto,
        userId,
        date: new Date().toISOString().split('T')[0],
      },
    });
  }

  async getUserWorkoutHistory(userId: string) {
    return this.prisma.workout.findMany({
      where: { userId },
      orderBy: { date: 'desc' },
    });
  }

  async getWorkoutStats(userId: string) {
    const workouts = await this.prisma.workout.findMany({
      where: { userId },
    });

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

  async createWorkoutPlan(
    createWorkoutPlanDto: CreateWorkoutPlanDto,
  ): Promise<WorkoutPlanDto> {
    const plan = await this.prisma.workoutPlan.create({
      data: {
        name: createWorkoutPlanDto.name,
        duration: createWorkoutPlanDto.duration,
        difficulty: createWorkoutPlanDto.difficulty,
        description: createWorkoutPlanDto.description,
        caloriesBurned: createWorkoutPlanDto.duration * 5,
        exercises: createWorkoutPlanDto.exercises || [],
      },
    });

    return {
      ...plan,
      exercises: (Array.isArray(plan.exercises) ? plan.exercises : []) as any[],
    };
  }

  async deleteWorkout(id: string, userId: string) {
    const workout = await this.prisma.workout.findUnique({
      where: { id },
    });

    if (!workout || workout.userId !== userId) {
      throw new NotFoundException('Workout not found');
    }

    return this.prisma.workout.delete({
      where: { id },
    });
  }
}
