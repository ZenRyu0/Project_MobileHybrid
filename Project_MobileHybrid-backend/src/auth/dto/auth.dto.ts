export class LoginDto {
  email: string;
  password: string;
}

export class RegisterDto {
  email: string;
  password: string;
  name?: string;
}

export class AuthResponseDto {
  success: boolean;
  message: string;
  token?: string;
  user?: {
    id: string;
    email: string;
    name: string;
  };
}
