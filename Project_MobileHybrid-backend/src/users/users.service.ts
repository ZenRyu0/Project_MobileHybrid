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
    const [user, workoutStats] = await Promise.all([
      this.prisma.user.findUnique({
        where: { id },
        include: {
          _count: {
            select: {
              workouts: true,
              posts: true,
              followers: true,
              following: true,
            },
          },
        },
      }),
      this.prisma.workout.aggregate({
        where: { userId: id },
        _sum: { caloriesBurned: true, duration: true },
      }),
    ]);
    if (!user) {
      throw new NotFoundException('User not found');
    }
    return {
      id: user.id,
      email: user.email,
      name: user.name,
      bio: user.bio || '',
      avatar: user.avatar || `https://i.pravatar.cc/150?img=${Math.floor(Math.random() * 70)}`,
      totalWorkouts: user._count.workouts,
      totalCaloriesBurned: workoutStats._sum.caloriesBurned || 0,
      totalMinutes: workoutStats._sum.duration || 0,
      followersCount: user._count.followers,
      followingCount: user._count.following,
      darkMode: user.darkMode,
      notificationsEnabled: user.notificationsEnabled,
      calorieUnit: user.calorieUnit,
      distanceUnit: user.distanceUnit,
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
    return this.prisma.user.delete({
      where: { id },
      select: {
        id: true,
        email: true,
        name: true,
      },
    });
  }
  async updateSettings(id: string, settingsDto: any) {
    const user = await this.prisma.user.findUnique({
      where: { id },
    });
    if (!user) {
      throw new NotFoundException('User not found');
    }
    const updated = await this.prisma.user.update({
      where: { id },
      data: {
        darkMode: settingsDto.darkMode ?? user.darkMode,
        notificationsEnabled: settingsDto.notificationsEnabled ?? user.notificationsEnabled,
        calorieUnit: settingsDto.calorieUnit ?? user.calorieUnit,
        distanceUnit: settingsDto.distanceUnit ?? user.distanceUnit,
      },
    });
    return {
      darkMode: updated.darkMode,
      notificationsEnabled: updated.notificationsEnabled,
      calorieUnit: updated.calorieUnit,
      distanceUnit: updated.distanceUnit,
    };
  }
  async followUser(followerId: string, followingId: string) {
    const follower = await this.prisma.user.findUnique({
      where: { id: followerId },
    });
    const following = await this.prisma.user.findUnique({
      where: { id: followingId },
    });
    if (!follower || !following) {
      throw new NotFoundException('User not found');
    }
    return this.prisma.userFollow.create({
      data: {
        followerId,
        followingId,
      },
    });
  }
  async unfollowUser(followerId: string, followingId: string) {
    return this.prisma.userFollow.deleteMany({
      where: {
        followerId,
        followingId,
      },
    });
  }
  async getFollowers(userId: string, skip: number = 0, take: number = 10) {
    const followers = await this.prisma.userFollow.findMany({
      where: { followingId: userId },
      include: {
        follower: {
          select: {
            id: true,
            name: true,
            email: true,
            avatar: true,
            bio: true,
          },
        },
      },
      skip,
      take,
      orderBy: { createdAt: 'desc' },
    });
    const total = await this.prisma.userFollow.count({
      where: { followingId: userId },
    });
    return {
      followers: followers.map(f => f.follower),
      total,
      page: Math.floor(skip / take) + 1,
      limit: take,
      hasMore: skip + take < total,
    };
  }
  async getFollowing(userId: string, skip: number = 0, take: number = 10) {
    const following = await this.prisma.userFollow.findMany({
      where: { followerId: userId },
      include: {
        following: {
          select: {
            id: true,
            name: true,
            email: true,
            avatar: true,
            bio: true,
          },
        },
      },
      skip,
      take,
      orderBy: { createdAt: 'desc' },
    });
    const total = await this.prisma.userFollow.count({
      where: { followerId: userId },
    });
    return {
      following: following.map(f => f.following),
      total,
      page: Math.floor(skip / take) + 1,
      limit: take,
      hasMore: skip + take < total,
    };
  }
}