# Go-Fit Backend

NestJS-based backend for the Go-Fit fitness mobile application. A comprehensive REST API providing user authentication, calorie tracking, workout management, and social features.

## Project Structure

```
src/
├── auth/                          # Authentication & Authorization
│   ├── dto/
│   │   └── auth.dto.ts           # Auth request/response DTOs
│   ├── auth.controller.ts         # Authentication endpoints
│   ├── auth.service.ts            # Auth business logic
│   ├── auth.module.ts             # Auth module definition
│   ├── decorators/
│   │   └── current-user.decorator.ts  # JWT user extraction
│   ├── guards/
│   │   └── jwt.guard.ts           # JWT protection guard
│   └── strategies/
│       └── jwt.strategy.ts        # Passport JWT strategy
├── users/                         # User Management
│   ├── dto/
│   │   └── user.dto.ts           # User DTOs
│   ├── users.controller.ts        # User endpoints
│   ├── users.service.ts           # User operations
│   └── users.module.ts            # Users module
├── workouts/                      # Workout Tracking
│   ├── dto/
│   │   └── workout.dto.ts        # Workout DTOs
│   ├── workouts.controller.ts     # Workout endpoints
│   ├── workouts.service.ts        # Workout operations
│   └── workouts.module.ts         # Workouts module
├── calories/                      # Calorie Tracking
│   ├── dto/
│   │   └── calorie.dto.ts        # Calorie DTOs
│   ├── calories.controller.ts     # Calorie endpoints
│   ├── calories.service.ts        # Calorie operations
│   └── calories.module.ts         # Calories module
├── posts/                         # Social Feed
│   ├── dto/
│   │   └── post.dto.ts           # Post DTOs
│   ├── posts.controller.ts        # Feed endpoints
│   ├── posts.service.ts           # Post operations
│   └── posts.module.ts            # Posts module
├── database/                      # Database Configuration
│   ├── database.module.ts         # Database module
│   └── prisma.service.ts          # Prisma client wrapper
├── common/                        # Shared Utilities
│   ├── interceptors/
│   │   └── logging.interceptor.ts # Request/response logging
│   ├── middleware/
│   │   └── rate-limit.middleware.ts # Rate limiting
│   └── logger/
│       └── winston.logger.ts      # Winston logging
├── app.module.ts                  # Root application module
└── main.ts                        # Application entry point
```

## Prerequisites

- Node.js 18+ and npm or yarn
- PostgreSQL database
- NestJS CLI (optional, for development)

## Setup

1. **Install dependencies**
   ```bash
   npm install
   ```

2. **Configure environment variables**
   ```bash
   cp .env.example .env
   # Edit .env with your configuration (DATABASE_URL, JWT_SECRET, etc.)
   ```

3. **Setup Database**
   ```bash
   # Run Prisma migrations
   npm run prisma:migrate
   
   # (Optional) Seed database with sample data
   npm run prisma:seed
   
   # (Optional) Open Prisma Studio to view database
   npm run prisma:studio
   ```

4. **Development Server**
   ```bash
   npm run start:dev
   ```
   The server will start on `http://localhost:3000`

5. **Build for Production**
   ```bash
   npm run build
   ```

6. **Run Production Build**
   ```bash
   npm run start:prod
   ```

## API Endpoints

### Authentication
- **POST** `/auth/register` - Register new user
  - Body: `{ email: string, password: string, name: string }`
  - Response: `{ success: boolean, token: string, user: {...} }`

- **POST** `/auth/login` - Login existing user
  - Body: `{ email: string, password: string }`
  - Response: `{ success: boolean, token: string, user: {...} }`

### Users (Protected Routes)
- **GET** `/users/profile` - Get current user's profile
- **PUT** `/users/profile` - Update profile (name, bio, avatar)
- **GET** `/users/:id` - Get user by ID
- **GET** `/users/search/:query` - Search users by name or email
- **DELETE** `/users/account` - Delete user account

### Workouts (Protected Routes)
- **POST** `/workouts/log` - Log a completed workout
  - Body: `{ name: string, duration: number, difficulty: string, caloriesBurned: number }`

- **GET** `/workouts/history` - Get user's workout history
- **GET** `/workouts/stats` - Get workout statistics
- **GET** `/workouts/plans` - Get all available workout plans
- **POST** `/workouts/plans` - Create custom workout plan
- **DELETE** `/workouts/:id` - Delete a workout log

### Calories (Protected Routes)
- **POST** `/calories/log` - Log meal/calorie entry
  - Body: `{ mealType: string, foodName: string, calories: number, protein?: number, carbs?: number, fat?: number }`

- **GET** `/calories/daily` - Get today's calorie stats
- **GET** `/calories/history` - Get calorie history (7 days default)
- **GET** `/calories/total` - Get total calorie statistics
- **POST** `/calories/target` - Set daily calorie target
- **DELETE** `/calories/:id` - Delete meal entry

### Social Feed (Protected Routes)
- **GET** `/posts/feed` - Get paginated feed (default 10 posts)
- **POST** `/posts` - Create new post
  - Body: `{ content: string, imageUrl?: string }`

- **GET** `/posts/:id` - Get post details
- **POST** `/posts/:id/like` - Like a post
- **POST** `/posts/:id/unlike` - Unlike a post
- **POST** `/posts/:id/comments` - Add comment to post
  - Body: `{ content: string }`

- **GET** `/posts/:id/comments` - Get post comments
- **DELETE** `/posts/:id` - Delete post (own posts only)
- **DELETE** `/comments/:id` - Delete comment (own comments only)

## Demo Credentials

For testing:
- **Email**: test@example.com
- **Password**: password123

## Development Commands

```bash
# Run tests
npm test

# Run tests with coverage
npm test:cov

# Lint and fix code
npm run lint

# Format code with Prettier
npm run format

# Debug mode
npm run start:debug
```

## Technology Stack

- **Framework**: NestJS 11
- **Language**: TypeScript 5
- **Database**: PostgreSQL with Prisma ORM
- **Authentication**: JWT with Passport
- **Validation**: class-validator and class-transformer
- **Logging**: Winston
- **Rate Limiting**: express-rate-limit
- **Testing**: Jest
- **Security**: bcrypt for password hashing

## Features

### Core Features (✅ Completed)
- ✅ User Authentication (Login/Register with JWT)
- ✅ User Account Management (Profile, Update, Delete)
- ✅ Workout Logging (log, history, statistics)
- ✅ Workout Plans (predefined and custom routines)
- ✅ Calorie Tracking (log meals, daily stats, history, totals)
- ✅ Calorie Macros (protein, carbs, fat tracking)
- ✅ Daily Calorie Target Setting
- ✅ Social Feed (create posts, view feed)
- ✅ Post Comments & Likes
- ✅ User Search
- ✅ Database Persistence (PostgreSQL)
- ✅ Rate Limiting
- ✅ Request Logging

### Architecture Highlights
- **Modular Design**: Each feature is organized as a module
- **Type-Safe**: Full TypeScript implementation
- **Scalable**: Prisma ORM with proper indexing and relationships
- **Secure**: JWT authentication, bcrypt password hashing, rate limiting
- **Documented**: Clear code structure and comprehensive API endpoints

## Database Schema

The database includes the following models:
- **User**: User accounts with profiles
- **Workout**: Individual workout logs
- **WorkoutPlan**: Predefined or custom workout routines
- **CalorieEntry**: Meal logs with macro tracking
- **DailyCalorieTarget**: Daily calorie goals per user
- **Post**: Social feed posts
- **Comment**: Comments on posts
- **PostLike**: Like relationships for posts

All models include proper relationships, cascading deletes, and database indexes for performance.

## Security Considerations

- JWT secret should be stored in environment variables (not hardcoded)
- CORS is configured for development - restrict in production
- All password fields are hashed with bcrypt
- Protected routes require valid JWT tokens
- Database is password-protected and should use connection pooling
- Rate limiting is enabled for DDoS protection

## Future Enhancements

- [ ] Email verification for registration
- [ ] Password reset functionality
- [ ] Two-factor authentication (2FA)
- [ ] Follow/Friend system
- [ ] Notifications service
- [ ] Push notifications
- [ ] File uploads (profile pictures, workout images)
- [ ] Advanced analytics and achievements
- [ ] Leaderboards
- [ ] Integration with fitness trackers/wearables

## Connecting to Frontend

The Flutter frontend communicates with this backend via HTTP requests to `http://localhost:3000`.

Update frontend environment configuration to point to the backend URL based on the environment (development, staging, production).

## Support & Troubleshooting

For database issues:
- Check PostgreSQL connection string in .env
- Run `npm run prisma:migrate` to apply pending migrations
- Use `npm run prisma:studio` to inspect database state

For authentication issues:
- Ensure JWT_SECRET is set in .env
- Check token expiration settings
- Verify CORS configuration for frontend origin

## License

MIT
