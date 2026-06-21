import { Controller, Get, Put, Post, Delete, Param, Body, UseGuards, Query } from '@nestjs/common';
import { UsersService } from './users.service';
import { UpdateUserDto } from './dto/user.dto';
import { JwtAuthGuard } from '../auth/guards/jwt.guard';
import { CurrentUser } from '../auth/decorators/current-user.decorator';
interface AuthUser {
  id: string;
  [key: string]: any;
}
@Controller('users')
export class UsersController {
  constructor(private usersService: UsersService) {}
  @Get()
  async getAllUsers() {
    return {
      success: true,
      data: await this.usersService.getAllUsers(),
    };
  }
  @Get('search')
  async searchUsers(
    @Query('q') query: string,
    @Query('page') page: string = '1',
    @Query('limit') limit: string = '10',
  ) {
    if (!query || query.trim().length < 2) {
      return {
        success: false,
        message: 'Search query must be at least 2 characters',
        data: { users: [], total: 0 },
      };
    }
    const pageNum = Math.max(1, parseInt(page) || 1);
    const limitNum = Math.max(1, Math.min(parseInt(limit) || 10, 100));
    const skip = (pageNum - 1) * limitNum;
    const result = await this.usersService.searchUsers(query, skip, limitNum);
    return {
      success: true,
      data: result,
    };
  }
  @Get('profile/me')
  @UseGuards(JwtAuthGuard)
  async getMyProfile(@CurrentUser() user: AuthUser): Promise<any> {
    const profile = await this.usersService.getProfile(user.id);
    return {
      success: true,
      data: profile,
    };
  }
  @Get(':id/profile')
  async getProfile(@Param('id') id: string): Promise<any> {
    const profile = await this.usersService.getProfile(id);
    return {
      success: true,
      data: profile,
    };
  }
  @Put('profile/me')
  @UseGuards(JwtAuthGuard)
  async updateMyProfile(
    @CurrentUser() user: AuthUser,
    @Body() updateDto: UpdateUserDto,
  ): Promise<any> {
    const updated = await this.usersService.updateProfile(user.id, updateDto);
    return {
      success: true,
      data: updated,
    };
  }
  @Delete('profile/me')
  @UseGuards(JwtAuthGuard)
  async deleteMyAccount(@CurrentUser() user: AuthUser) {
    await this.usersService.deleteAccount(user.id);
    return {
      success: true,
      message: 'Account deleted successfully. All data has been permanently removed.',
    };
  }
  @Post('profile/me/settings')
  @UseGuards(JwtAuthGuard)
  async updateMySettings(
    @CurrentUser() user: AuthUser,
    @Body() settingsDto: any,
  ): Promise<any> {
    const updated = await this.usersService.updateSettings(user.id, settingsDto);
    return {
      success: true,
      data: updated,
    };
  }
  @Post(':id/follow')
  @UseGuards(JwtAuthGuard)
  async followUser(
    @CurrentUser() user: AuthUser,
    @Param('id') followingId: string,
  ): Promise<any> {
    if (user.id === followingId) {
      return {
        success: false,
        message: 'You cannot follow yourself',
      };
    }
    await this.usersService.followUser(user.id, followingId);
    return {
      success: true,
      message: 'User followed successfully',
    };
  }
  @Delete(':id/follow')
  @UseGuards(JwtAuthGuard)
  async unfollowUser(
    @CurrentUser() user: AuthUser,
    @Param('id') followingId: string,
  ): Promise<any> {
    await this.usersService.unfollowUser(user.id, followingId);
    return {
      success: true,
      message: 'User unfollowed successfully',
    };
  }
  @Get(':id/followers')
  async getFollowers(
    @Param('id') userId: string,
    @Query('page') page: string = '1',
    @Query('limit') limit: string = '10',
  ): Promise<any> {
    const pageNum = Math.max(1, parseInt(page) || 1);
    const limitNum = Math.max(1, Math.min(parseInt(limit) || 10, 100));
    const skip = (pageNum - 1) * limitNum;
    const result = await this.usersService.getFollowers(userId, skip, limitNum);
    return {
      success: true,
      data: result,
    };
  }
  @Get(':id/following')
  async getFollowing(
    @Param('id') userId: string,
    @Query('page') page: string = '1',
    @Query('limit') limit: string = '10',
  ): Promise<any> {
    const pageNum = Math.max(1, parseInt(page) || 1);
    const limitNum = Math.max(1, Math.min(parseInt(limit) || 10, 100));
    const skip = (pageNum - 1) * limitNum;
    const result = await this.usersService.getFollowing(userId, skip, limitNum);
    return {
      success: true,
      data: result,
    };
  }
}
