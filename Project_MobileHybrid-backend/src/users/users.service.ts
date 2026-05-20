import { Injectable, NotFoundException } from '@nestjs/common';
import { CreateUserDto, UpdateUserDto, UserProfileDto } from './dto/user.dto';
import { PrismaService } from '../database/prisma.service';

@Injectable()
export class UsersService {
  constructor(private prisma: PrismaService) {}

  async findById(id: string) {
    return this.prisma.user.findUnique({
      where: { id },
      select: {
        id: true,
        email: true,
        name: true,
        bio: true,
        avatar: true,
        createdAt: true,
      },
    });
  }

  async findByEmail(email: string) {
    return this.prisma.user.findUnique({
      where: { email },
    });
  }

  async getProfile(id: string): Promise<UserProfileDto> {
    const user = await this.prisma.user.findUnique({
      where: { id },
      include: {
        _count: {
          select: {
            workouts: true,
            posts: true,
          },
        },
      },
    });

    if (!user) {
      throw new NotFoundException('User not found');
    }

    // Calculate total calories burned from workouts
    const totalCaloriesBurned = await this.prisma.workout.aggregate({
      where: { userId: id },
      _sum: { caloriesBurned: true },
    });

    return {
      id: user.id,
      email: user.email,
      name: user.name,
      bio: user.bio || '',
      avatar: user.avatar || `https://i.pravatar.cc/150?img=${Math.floor(Math.random() * 70)}`,
      totalWorkouts: user._count.workouts,
      totalCaloriesBurned: totalCaloriesBurned._sum.caloriesBurned || 0,
      joinedDate: user.createdAt.toISOString().split('T')[0],
    };
  }

  async updateProfile(id: string, updateDto: UpdateUserDto): Promise<UserProfileDto> {
    const user = await this.prisma.user.findUnique({
      where: { id },
    });

    if (!user) {
      throw new NotFoundException('User not found');
    }

    await this.prisma.user.update({
      where: { id },
      data: updateDto,
    });

    return this.getProfile(id);
  }

  async getAllUsers() {
    return this.prisma.user.findMany({
      select: {
        id: true,
        name: true,
        email: true,
        avatar: true,
      },
    });
  }

  async create(createUserDto: CreateUserDto & { passwordHash: string }) {
    return this.prisma.user.create({
      data: {
        email: createUserDto.email,
        name: createUserDto.name,
        passwordHash: createUserDto.passwordHash,
      },
    });
  }

  async searchUsers(query: string, skip: number = 0, take: number = 10) {
    // Search by name or email (case-insensitive)
    const users = await this.prisma.user.findMany({
      where: {
        OR: [
          { name: { contains: query, mode: 'insensitive' } },
          { email: { contains: query, mode: 'insensitive' } },
        ],
      },
      select: {
        id: true,
        name: true,
        email: true,
        avatar: true,
        bio: true,
        createdAt: true,
      },
      skip,
      take,
      orderBy: { createdAt: 'desc' },
    });

    const total = await this.prisma.user.count({
      where: {
        OR: [
          { name: { contains: query, mode: 'insensitive' } },
          { email: { contains: query, mode: 'insensitive' } },
        ],
      },
    });

    return {
      users,
      total,
      page: Math.floor(skip / take) + 1,
      limit: take,
      hasMore: skip + take < total,
    };
  }

  async deleteAccount(id: string) {
    const user = await this.prisma.user.findUnique({
      where: { id },
    });

    if (!user) {
      throw new NotFoundException('User not found');
    }

    // Cascading deletes will remove:
    // - All workouts
    // - All calorie entries
    // - All posts
    // - All comments
    // - All post likes
    // - Daily calorie target
    return this.prisma.user.delete({
      where: { id },
      select: {
        id: true,
        email: true,
        name: true,
      },
    });
  }
}
