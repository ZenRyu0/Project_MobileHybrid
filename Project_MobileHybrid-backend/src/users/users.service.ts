import { Injectable } from '@nestjs/common';
import { CreateUserDto, UpdateUserDto, UserProfileDto } from './dto/user.dto';

@Injectable()
export class UsersService {
  // Mock storage - will be replaced with database
  private users: any[] = [
    {
      id: '1',
      email: 'test@example.com',
      password: 'password123',
      name: 'Test User',
      bio: 'Fitness enthusiast and gym lover',
      avatar: 'https://i.pravatar.cc/150?img=1',
      totalWorkouts: 42,
      totalCaloriesBurned: 15240,
      joinedDate: '2025-01-15',
    },
  ];

  findById(id: string): any {
    return this.users.find((user) => user.id === id);
  }

  findByEmail(email: string): any {
    return this.users.find((user) => user.email === email);
  }

  getProfile(id: string): UserProfileDto {
    const user = this.findById(id);
    if (!user) return null;

    return {
      id: user.id,
      email: user.email,
      name: user.name,
      bio: user.bio || '',
      avatar: user.avatar || 'https://i.pravatar.cc/150?img=0',
      totalWorkouts: user.totalWorkouts || 0,
      totalCaloriesBurned: user.totalCaloriesBurned || 0,
      joinedDate: user.joinedDate || new Date().toISOString().split('T')[0],
    };
  }

  updateProfile(id: string, updateDto: UpdateUserDto): UserProfileDto {
    const user = this.findById(id);
    if (!user) return null;

    Object.assign(user, updateDto);
    return this.getProfile(id);
  }

  getAllUsers(): any[] {
    return this.users.map((user) => ({
      id: user.id,
      name: user.name,
      email: user.email,
      avatar: user.avatar,
    }));
  }

  create(createUserDto: CreateUserDto): any {
    const newUser = {
      id: Math.random().toString(36).substr(2, 9),
      ...createUserDto,
      bio: '',
      avatar: 'https://i.pravatar.cc/150?img=' + Math.floor(Math.random() * 70),
      totalWorkouts: 0,
      totalCaloriesBurned: 0,
      joinedDate: new Date().toISOString().split('T')[0],
    };

    this.users.push(newUser);
    return newUser;
  }
}
