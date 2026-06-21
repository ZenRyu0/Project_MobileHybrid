import { Injectable, UnauthorizedException, BadRequestException } from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import { LoginDto, RegisterDto, AuthResponseDto } from './dto/auth.dto';
import { PrismaService } from '../database/prisma.service';
import { logger } from '../common/logger/winston.logger';
import * as bcrypt from 'bcrypt';
@Injectable()
export class AuthService {
  constructor(
    private jwtService: JwtService,
    private prisma: PrismaService,
  ) {}
  async login(loginDto: LoginDto): Promise<AuthResponseDto> {
    const user = await this.prisma.user.findUnique({
      where: { email: loginDto.email },
    });
    if (!user) {
      logger.warn('Login failed - user not found', { email: loginDto.email });
      throw new UnauthorizedException('Invalid email or password');
    }
    const isPasswordValid = await bcrypt.compare(
      loginDto.password,
      user.passwordHash,
    );
    if (!isPasswordValid) {
      logger.warn('Login failed - invalid password', { userId: user.id, email: loginDto.email });
      throw new UnauthorizedException('Invalid email or password');
    }
    const token = this.jwtService.sign({
      sub: user.id,
      email: user.email,
    });
    logger.info('User login successful', { userId: user.id, email: user.email });
    return {
      success: true,
      message: 'Login successful',
      token,
      user: {
        id: user.id,
        email: user.email,
        name: user.name,
      },
    };
  }
  async register(registerDto: RegisterDto): Promise<AuthResponseDto> {
    const existingUser = await this.prisma.user.findUnique({
      where: { email: registerDto.email },
    });
    if (existingUser) {
      logger.warn('Registration failed - email already registered', { email: registerDto.email });
      throw new BadRequestException('Email already registered');
    }
    const passwordHash = await bcrypt.hash(registerDto.password, 10);
    const user = await this.prisma.user.create({
      data: {
        email: registerDto.email,
        passwordHash,
        name: registerDto.name || 'New User',
        dailyCalorieTarget: {
          create: {
            target: 2000,
          },
        },
      },
    });
    const token = this.jwtService.sign({
      sub: user.id,
      email: user.email,
    });
    logger.info('User registration successful', { userId: user.id, email: user.email });
    return {
      success: true,
      message: 'Registration successful',
      token,
      user: {
        id: user.id,
        email: user.email,
        name: user.name,
      },
    };
  }
  validateToken(token: string) {
    try {
      return this.jwtService.verify(token);
    } catch (error) {
      logger.warn('Token validation failed', { error: error.message });
      return null;
    }
  }
}
