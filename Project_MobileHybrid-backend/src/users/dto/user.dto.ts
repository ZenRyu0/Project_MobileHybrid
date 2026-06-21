import { IsEmail, IsString, IsOptional, MinLength, MaxLength, IsUrl } from 'class-validator';

export class CreateUserDto {
  @IsEmail()
  email: string;

  @IsString()
  @MinLength(8, { message: 'Password must be at least 8 characters' })
  password: string;

  @IsString()
  @MinLength(2, { message: 'Name must be at least 2 characters' })
  @MaxLength(100, { message: 'Name must be at most 100 characters' })
  name: string;
}

export class UpdateUserDto {
  @IsOptional()
  @IsString()
  @MinLength(2, { message: 'Name must be at least 2 characters' })
  @MaxLength(100, { message: 'Name must be at most 100 characters' })
  name?: string;

  @IsOptional()
  @IsString()
  @MaxLength(500, { message: 'Bio must be at most 500 characters' })
  bio?: string;

  @IsOptional()
  @IsUrl()
  avatar?: string;
}

export class UserResponseDto {
  id: string;
  email: string;
  name: string;
  bio?: string;
  avatar?: string;
  createdAt?: string;
}

export class UserProfileDto {
  id: string;
  email: string;
  name: string;
  bio: string;
  avatar: string;
  totalWorkouts: number;
  totalCaloriesBurned: number;
  totalMinutes: number;
  followersCount: number;
  followingCount: number;
  darkMode: boolean;
  notificationsEnabled: boolean;
  calorieUnit: string;
  distanceUnit: string;
  joinedDate: string;
}

// Internal DTO for creating users with hashed password
export class InternalCreateUserDto {
  email: string;
  passwordHash: string;
  name: string;
}
