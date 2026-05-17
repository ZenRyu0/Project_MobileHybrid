import { Controller, Get, Post, Delete, Param, Body, UseGuards } from '@nestjs/common';
import { WorkoutsService } from './workouts.service';
import { CreateWorkoutDto, CreateWorkoutPlanDto } from './dto/workout.dto';
import { JwtAuthGuard } from '../auth/guards/jwt.guard';
import { CurrentUser } from '../auth/decorators/current-user.decorator';

@Controller('workouts')
export class WorkoutsController {
  constructor(private workoutsService: WorkoutsService) {}

  @Get('plans')
  async getWorkoutPlans() {
    return {
      success: true,
      data: await this.workoutsService.getWorkoutPlans(),
    };
  }

  @Get('plans/:id')
  async getWorkoutPlanById(@Param('id') id: string) {
    const plan = await this.workoutsService.getWorkoutPlanById(id);
    return {
      success: true,
      data: plan,
    };
  }

  @Post('log')
  @UseGuards(JwtAuthGuard)
  async logWorkout(@CurrentUser() user: any, @Body() createWorkoutDto: CreateWorkoutDto) {
    const workout = await this.workoutsService.logWorkout(user.id, createWorkoutDto);
    return {
      success: true,
      message: 'Workout logged successfully',
      data: workout,
    };
  }

  @Get('history/me')
  @UseGuards(JwtAuthGuard)
  async getMyWorkoutHistory(@CurrentUser() user: any) {
    const history = await this.workoutsService.getUserWorkoutHistory(user.id);
    return {
      success: true,
      data: history,
    };
  }

  @Get('history/:userId')
  async getUserWorkoutHistory(@Param('userId') userId: string) {
    const history = await this.workoutsService.getUserWorkoutHistory(userId);
    return {
      success: true,
      data: history,
    };
  }

  @Get('stats/me')
  @UseGuards(JwtAuthGuard)
  async getMyWorkoutStats(@CurrentUser() user: any) {
    const stats = await this.workoutsService.getWorkoutStats(user.id);
    return {
      success: true,
      data: stats,
    };
  }

  @Get('stats/:userId')
  async getWorkoutStats(@Param('userId') userId: string) {
    const stats = await this.workoutsService.getWorkoutStats(userId);
    return {
      success: true,
      data: stats,
    };
  }

  @Post('plans')
  @UseGuards(JwtAuthGuard)
  async createWorkoutPlan(@Body() createWorkoutPlanDto: CreateWorkoutPlanDto) {
    const newPlan = await this.workoutsService.createWorkoutPlan(createWorkoutPlanDto);

    return {
      success: true,
      message: 'Custom workout plan created successfully',
      data: newPlan,
    };
  }

  @Delete(':id')
  @UseGuards(JwtAuthGuard)
  async deleteWorkout(@CurrentUser() user: any, @Param('id') id: string) {
    await this.workoutsService.deleteWorkout(id, user.id);
    return {
      success: true,
      message: 'Workout deleted successfully',
    };
  }
}
