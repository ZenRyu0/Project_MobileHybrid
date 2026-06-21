import { Controller, Get, Post, Delete, Param, Body, UseGuards, UsePipes, PipeTransform, ArgumentMetadata, HttpException, HttpStatus, BadRequestException, Injectable } from '@nestjs/common';
import { WorkoutsService } from './workouts.service';
import { JwtAuthGuard } from '../auth/guards/jwt.guard';
import { CurrentUser } from '../auth/decorators/current-user.decorator';

interface AuthUser {
  id: string;
  [key: string]: any;
}

// No-op pipe to bypass validation
@Injectable()
class NoValidationPipe implements PipeTransform {
  transform(value: any, metadata: ArgumentMetadata) {
    return value;
  }
}
@Controller('workouts')
export class WorkoutsController {
  constructor(private workoutsService: WorkoutsService) {}
  @Get('plans')
  @UseGuards(JwtAuthGuard)
  async getWorkoutPlans(@CurrentUser() user: AuthUser) {
    return {
      success: true,
      data: await this.workoutsService.getWorkoutPlans(user.id),
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
  @UsePipes(new NoValidationPipe())
  async logWorkout(@CurrentUser() user: AuthUser, @Body() body: Record<string, any>) {
    if (!body.name || typeof body.name !== 'string') {
      throw new BadRequestException('Name is required');
    }
    if (!body.duration || typeof body.duration !== 'number' || body.duration < 1) {
      throw new BadRequestException('Duration is required and must be at least 1 minute');
    }
    if (body.caloriesBurned === undefined || typeof body.caloriesBurned !== 'number') {
      throw new BadRequestException('Calories burned is required');
    }

    const workout = await this.workoutsService.logWorkout(user.id, {
      name: body.name,
      duration: body.duration,
      caloriesBurned: body.caloriesBurned,
      difficulty: body.difficulty,
      exercises: body.exercises,
      notes: body.notes,
    });
    return {
      success: true,
      message: 'Workout logged successfully',
      data: workout,
    };
  }
  @Get('history/me')
  @UseGuards(JwtAuthGuard)
  async getMyWorkoutHistory(@CurrentUser() user: AuthUser) {
    const history = await this.workoutsService.getUserWorkoutHistory(user.id);
    return {
      success: true,
      data: history,
    };
  }
  @Get('history/:userId')
  @UseGuards(JwtAuthGuard)
  async getUserWorkoutHistory(@CurrentUser() user: AuthUser, @Param('userId') userId: string) {
    const history = await this.workoutsService.getUserWorkoutHistory(userId);
    return {
      success: true,
      data: history,
    };
  }
  @Get('stats/me')
  @UseGuards(JwtAuthGuard)
  async getMyWorkoutStats(@CurrentUser() user: AuthUser) {
    const stats = await this.workoutsService.getWorkoutStats(user.id);
    return {
      success: true,
      data: stats,
    };
  }
  @Get('stats/:userId')
  @UseGuards(JwtAuthGuard)
  async getWorkoutStats(@CurrentUser() user: AuthUser, @Param('userId') userId: string) {
    const stats = await this.workoutsService.getWorkoutStats(userId);
    return {
      success: true,
      data: stats,
    };
  }
  @Post('plans')
  @UseGuards(JwtAuthGuard)
  async createWorkoutPlan(@CurrentUser() user: AuthUser, @Body() body: Record<string, any>) {
    const planData = {
      name: body.name,
      duration: body.duration,
      difficulty: body.difficulty,
      description: body.description,
      exercises: body.exercises,
    };
    const newPlan = await this.workoutsService.createWorkoutPlan(planData as any, user.id);
    return {
      success: true,
      message: 'Custom workout plan created successfully',
      data: newPlan,
    };
  }
  @Delete(':id')
  @UseGuards(JwtAuthGuard)
  async deleteWorkout(@CurrentUser() user: AuthUser, @Param('id') id: string) {
    await this.workoutsService.deleteWorkout(id, user.id);
    return {
      success: true,
      message: 'Workout deleted successfully',
    };
  }
}
