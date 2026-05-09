import { Controller, Get, Post, Param, Body } from '@nestjs/common';
import { WorkoutsService } from './workouts.service';
import { CreateWorkoutDto, CreateWorkoutPlanDto } from './dto/workout.dto';

@Controller('workouts')
export class WorkoutsController {
  constructor(private workoutsService: WorkoutsService) {}

  @Get('plans')
  async getWorkoutPlans() {
    return {
      success: true,
      data: this.workoutsService.getWorkoutPlans(),
    };
  }

  @Get('plans/:id')
  async getWorkoutPlanById(@Param('id') id: string) {
    const plan = this.workoutsService.getWorkoutPlanById(id);
    if (!plan) {
      return {
        success: false,
        message: 'Workout plan not found',
      };
    }
    return {
      success: true,
      data: plan,
    };
  }

  @Post('log')
  async logWorkout(@Body() createWorkoutDto: CreateWorkoutDto) {
    const workout = this.workoutsService.logWorkout(createWorkoutDto);
    return {
      success: true,
      message: 'Workout logged successfully',
      data: workout,
    };
  }

  @Get('history/:userId')
  async getUserWorkoutHistory(@Param('userId') userId: string) {
    const history = this.workoutsService.getUserWorkoutHistory(userId);
    return {
      success: true,
      data: history,
    };
  }

  @Get('stats/:userId')
  async getWorkoutStats(@Param('userId') userId: string) {
    const stats = this.workoutsService.getWorkoutStats(userId);
    return {
      success: true,
      data: stats,
    };
  }

  @Post('plans')
  async createWorkoutPlan(@Body() createWorkoutPlanDto: CreateWorkoutPlanDto) {
    const newPlan = this.workoutsService.createWorkoutPlan(createWorkoutPlanDto);
    
    return {
      success: true,
      message: 'Custom workout plan created successfully',
      data: newPlan,
    };
  }
}
