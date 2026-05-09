import { Module } from '@nestjs/common';
import { AuthModule } from './auth/auth.module';
import { UsersModule } from './users/users.module';
import { WorkoutsModule } from './workouts/workouts.module';
import { CaloriesModule } from './calories/calories.module';
import { PostsModule } from './posts/posts.module';

@Module({
  imports: [AuthModule, UsersModule, WorkoutsModule, CaloriesModule, PostsModule],
})
export class AppModule {}
