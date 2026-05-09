import { Controller, Get, Post, Put, Param, Body, UseGuards } from '@nestjs/common';
import { UsersService } from './users.service';
import { UpdateUserDto, UserProfileDto } from './dto/user.dto';

@Controller('users')
export class UsersController {
  constructor(private usersService: UsersService) {}

  @Get()
  async getAllUsers() {
    return {
      success: true,
      data: this.usersService.getAllUsers(),
    };
  }

  @Get(':id/profile')
  async getProfile(@Param('id') id: string): Promise<any> {
    const profile = this.usersService.getProfile(id);
    if (!profile) {
      return {
        success: false,
        message: 'User not found',
      };
    }
    return {
      success: true,
      data: profile,
    };
  }

  @Put(':id/profile')
  async updateProfile(
    @Param('id') id: string,
    @Body() updateDto: UpdateUserDto,
  ): Promise<any> {
    const updated = this.usersService.updateProfile(id, updateDto);
    if (!updated) {
      return {
        success: false,
        message: 'User not found',
      };
    }
    return {
      success: true,
      data: updated,
    };
  }

  @Get(':id')
  async getUserById(@Param('id') id: string): Promise<any> {
    const user = this.usersService.findById(id);
    if (!user) {
      return {
        success: false,
        message: 'User not found',
      };
    }
    return {
      success: true,
      data: {
        id: user.id,
        name: user.name,
        email: user.email,
        avatar: user.avatar,
      },
    };
  }
}
