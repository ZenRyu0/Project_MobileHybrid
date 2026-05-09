import { Injectable } from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import { LoginDto, RegisterDto, AuthResponseDto } from './dto/auth.dto';

@Injectable()
export class AuthService {
  constructor(private jwtService: JwtService) {}

  async login(loginDto: LoginDto): Promise<AuthResponseDto> {
    // Temporary: hardcoded user for demo
    // In production, validate against database
    if (
      loginDto.email === 'test@example.com' &&
      loginDto.password === 'password123'
    ) {
      const user = {
        id: '1',
        email: loginDto.email,
        name: 'Test User',
      };

      const token = this.jwtService.sign({ sub: user.id, email: user.email });

      return {
        success: true,
        message: 'Login successful',
        token,
        user,
      };
    }

    return {
      success: false,
      message: 'Invalid email or password',
    };
  }

  async register(registerDto: RegisterDto): Promise<AuthResponseDto> {
    // Temporary: accept any registration for demo
    // In production, validate email uniqueness and store in database
    const user = {
      id: Math.random().toString(36).substr(2, 9),
      email: registerDto.email,
      name: registerDto.name || 'New User',
    };

    const token = this.jwtService.sign({ sub: user.id, email: user.email });

    return {
      success: true,
      message: 'Registration successful',
      token,
      user,
    };
  }

  validateToken(token: string) {
    try {
      return this.jwtService.verify(token);
    } catch (error) {
      return null;
    }
  }
}
