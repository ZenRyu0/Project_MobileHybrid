# Go-Fit Backend

NestJS-based backend for the Go-Fit fitness mobile application.

## Project Structure

```
src/
├── auth/
│   ├── dto/
│   │   └── auth.dto.ts       # Data transfer objects for auth
│   ├── auth.controller.ts     # HTTP endpoints for authentication
│   ├── auth.service.ts        # Business logic for authentication
│   └── auth.module.ts         # Auth module definition
├── app.module.ts              # Root application module
└── main.ts                    # Application entry point
```

## Prerequisites

- Node.js 18+ and npm or yarn
- NestJS CLI (optional, for development)

## Setup

1. **Install dependencies**
   ```bash
   npm install
   ```

2. **Configure environment variables**
   ```bash
   # Copy the example file
   cp .env.example .env
   
   # Edit .env with your configuration
   ```

3. **Development Server**
   ```bash
   npm run start:dev
   ```
   
   The server will start on `http://localhost:3000`

4. **Build for Production**
   ```bash
   npm run build
   ```

5. **Run Production Build**
   ```bash
   npm run start:prod
   ```

## Available Endpoints

### Authentication

- **POST** `/auth/login`
  - Request: `{ email: string, password: string }`
  - Response: `{ success: boolean, message: string, token?: string, user?: {...} }`
  
- **POST** `/auth/register`
  - Request: `{ email: string, password: string, name?: string }`
  - Response: `{ success: boolean, message: string, token?: string, user?: {...} }`

### Demo Credentials

For testing, use:
- **Email**: test@example.com
- **Password**: password123

## Development

### Run Tests
```bash
npm test
```

### Lint Code
```bash
npm run lint
```

### Format Code
```bash
npm run format
```

## Technology Stack

- **Framework**: NestJS 10
- **Language**: TypeScript 5
- **Authentication**: JWT with Passport
- **Validation**: class-validator and class-transformer
- **Testing**: Jest

## Features (Current/Planned)

- ✅ User Authentication (Login/Register)
- ✅ JWT Token Generation
- 🔄 User Database Persistence
- 🔄 Calorie Tracking Service
- 🔄 Workout Logging Service
- 🔄 Social Feed Service

## Connecting to Flutter Frontend

The Flutter app communicates with this backend via HTTP requests to `http://localhost:3000`.

Update `lib/services/auth_service.dart` to point to this backend instead of the mock implementation.

## Notes

- JWT secret is currently hardcoded in `auth.module.ts`. Move to environment variables for production.
- User data is mocked. Integrate with a real database (TypeORM, Prisma, etc.) for production.
- CORS is enabled for all origins (`*`). Restrict this in production.

## Future Improvements

1. Database integration (PostgreSQL with TypeORM/Prisma)
2. Email verification for registration
3. Password reset functionality
4. User profile management
5. Role-based access control (RBAC)
6. Rate limiting and security enhancements
7. Comprehensive error handling and logging
