export class CreateUserDto {
  email: string;
  password: string;
  name: string;
}

export class UpdateUserDto {
  name?: string;
  bio?: string;
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
  joinedDate: string;
}
