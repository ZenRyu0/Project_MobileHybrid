import { Controller, Get, Post, Put, Delete, Param, Body, UseGuards, Query } from '@nestjs/common';
import { UsersService } from './users.service';
import { UpdateUserDto, UserProfileDto } from './dto/user.dto';
import { JwtAuthGuard } from '../auth/guards/jwt.guard';
import { CurrentUser } from '../auth/decorators/current-user.decorator';

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

    const skip = (parseInt(page) - 1) * parseInt(limit);
    const result = await this.usersService.searchUsers(query, skip, parseInt(limit));

    return {
      success: true,
      data: result,
    };
  }

  @Get('profile/me')
  @UseGuards(JwtAuthGuard)
  async getMyProfile(@CurrentUser() user: any): Promise<any> {
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
    @CurrentUser() user: any,
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
  async deleteMyAccount(@CurrentUser() user: any) {
    await this.usersService.deleteAccount(user.id);
    return {
      success: true,
      message: 'Account deleted successfully. All data has been permanently removed.',
    };
  }
}
