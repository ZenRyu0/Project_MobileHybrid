# Go-Fit Mobile App

A comprehensive Flutter-based fitness and wellness mobile application for iOS and Android. Go-Fit helps users track their workouts, monitor calorie intake, set fitness goals, and share their fitness journey with a community through a social feed.

## Features Overview

### 🏋️ Workout Management
- Browse and select from pre-built workout plans
- Create custom workout routines
- Log completed workouts with duration and difficulty
- Track calories burned per workout
- View workout history and statistics
- Dedicated workout timer for tracking active sessions

### 🍽️ Calorie & Nutrition Tracking
- Log meals and snacks throughout the day
- Track macronutrient intake (protein, carbs, fat)
- Set and manage daily calorie targets
- View daily calorie summary with remaining calories
- 7-day calorie history visualization
- Macro breakdown and percentages

### 👥 Social Features
- Create and share posts about fitness achievements
- Browse community fitness feed
- Like and comment on posts
- View detailed post information
- See user profiles with workout and post statistics

### 👤 User Management
- User authentication (Login/Register)
- User profile management
- Search and discover other users
- View user profiles and statistics

### 🎨 User Experience
- Clean, intuitive Material Design interface
- Responsive layout for different screen sizes
- Theme customization (light/dark mode support)
- Navigation between all features via bottom navigation

## Project Structure

```
lib/
├── main.dart                          # App entry point
├── models/                            # Data models
│   ├── user.dart                     # User model
│   ├── exercise.dart                 # Exercise data
│   ├── post.dart                     # Social post model
│   └── calorie_calculation.dart      # Calorie calculations
├── pages/                            # UI Pages/Screens
│   ├── loginpage.dart               # Login screen
│   ├── homepage.dart                # Home/Dashboard
│   ├── dashboardpage.dart           # Dashboard overview
│   ├── workoutpage.dart             # Workout tracking
│   ├── fitness_page.dart            # Fitness routines
│   ├── caloriepage.dart             # Calorie tracker
│   ├── feedpage.dart                # Social feed
│   ├── createroutinepage.dart       # Create workouts
│   ├── workout_timer.dart           # Workout timer
│   ├── postdetailpage.dart          # Post details
│   └── profilepage.dart             # User profile
├── providers/                        # State Management (Provider package)
│   ├── auth_provider.dart           # Authentication state
│   ├── user_provider.dart           # User data state
│   ├── workout_provider.dart        # Workout state
│   ├── calorie_provider.dart        # Calorie tracking state
│   └── post_provider.dart           # Social feed state
├── services/                         # Business Logic
│   ├── auth_service.dart            # Auth operations
│   ├── user_service.dart            # User operations
│   ├── workout_service.dart         # Workout operations
│   ├── calorie_service.dart         # Calorie operations
│   └── post_service.dart            # Post operations
├── repositories/                    # Data Access Layer
│   ├── auth_repository.dart         # Auth API calls
│   ├── user_repository.dart         # User API calls
│   ├── workout_repository.dart      # Workout API calls
│   ├── calorie_repository.dart      # Calorie API calls
│   └── post_repository.dart         # Post API calls
├── themenotifier.dart               # Theme management
└── pubspec.yaml                     # Flutter dependencies
```

## Prerequisites

- Flutter SDK 3.7.2 or higher
- Dart SDK 3.7.2 or higher
- Android Studio / Xcode (for emulator/device testing)
- Go-Fit backend running (see backend README)

## Installation

1. **Clone and Setup**
   ```bash
   # Navigate to the project directory
   cd Project_MobileHybrid-main
   
   # Get Flutter dependencies
   flutter pub get
   ```

2. **Configure Backend URL**
   - Update the backend API URL in the repository files (usually in `lib/repositories/`)
   - Ensure backend is running on `http://localhost:3000` or update the base URL

3. **Run the App**
   ```bash
   # Development
   flutter run
   
   # Release build
   flutter build apk  # Android
   flutter build ios  # iOS
   ```

## Pages & Navigation

### Login Page (`loginpage.dart`)
- User registration and login
- Email/password authentication
- JWT token management

### Dashboard (`dashboardpage.dart`)
- Overview of today's stats
- Quick access to main features
- Recent activity summary

### Workout Management (`fitnesspage.dart`, `createroutinepage.dart`, `workout_timer.dart`)
- Browse available workout plans
- Create custom routines
- Start and track workouts with timer
- Log completed workouts

### Calorie Tracker (`caloriepage.dart`)
- Log meals and snacks
- View daily calorie intake
- Track macronutrients
- Set daily calorie targets
- View 7-day history

### Social Feed (`feedpage.dart`, `postdetailpage.dart`)
- Browse community posts
- Create new posts
- View post details
- Like and comment on posts

### User Profile
- View user profile information
- Statistics (total workouts, calories burned, posts)
- Edit profile information

## State Management

The app uses the **Provider package** for state management:

- **AuthProvider**: Manages authentication state and user tokens
- **UserProvider**: Manages user profile data
- **WorkoutProvider**: Manages workout data and history
- **CalorieProvider**: Manages calorie tracking and daily stats
- **PostProvider**: Manages social feed data

## API Integration

The app communicates with the NestJS backend via REST API:

- **Base URL**: `http://localhost:3000` (configurable)
- **Authentication**: JWT tokens in Authorization header
- **Request Format**: JSON
- **Error Handling**: Proper error messages and retry logic

## Key Dependencies

```yaml
dependencies:
  flutter:
    sdk: flutter
  provider: ^6.0.6           # State management
  http: ^1.1.0              # HTTP requests
  cupertino_icons: ^1.0.8   # iOS icons
  url_launcher: ^6.1.0      # URL opening
  image_picker: ^1.2.1      # Image selection
  timeago: ^3.7.1          # Relative time formatting
```

## Features Implementation Status

### Authentication (✅ Complete)
- ✅ User registration
- ✅ User login with JWT
- ✅ Token management
- ✅ Session persistence

### Workout Management (✅ Complete)
- ✅ Browse workout plans
- ✅ Create custom routines
- ✅ Log workouts
- ✅ Workout timer
- ✅ History and statistics

### Calorie Tracking (✅ Complete)
- ✅ Log meals
- ✅ Daily stats
- ✅ Macro tracking (protein, carbs, fat)
- ✅ Daily target management
- ✅ History visualization

### Social Features (✅ Complete)
- ✅ Create posts
- ✅ View feed
- ✅ Like/unlike posts
- ✅ Comments
- ✅ User search

### User Management (✅ Complete)
- ✅ View profiles
- ✅ Update profile
- ✅ User statistics

## Development

### Running Tests
```bash
flutter test
```

### Code Analysis
```bash
flutter analyze
```

### Building Release Versions
```bash
# Android
flutter build apk --release

# iOS
flutter build ios --release
```

## Folder Structure Explanation

- **models/**: Data structures mirroring backend entities
- **pages/**: UI screens for each feature
- **providers/**: State management using Provider pattern
- **services/**: Business logic and data manipulation
- **repositories/**: API communication layer
- **themenotifier.dart**: Centralized theme management

## Architecture Pattern

The app follows a clean architecture pattern:
1. **Pages** (UI) → Display data from providers
2. **Providers** (State) → Manage application state
3. **Services** (Logic) → Process data
4. **Repositories** (API) → Fetch/update data from backend

This separation ensures:
- Easy testing of business logic
- Clean code organization
- Simple state management
- Scalability for feature additions

## Troubleshooting

### App won't connect to backend
- Ensure backend is running on correct port
- Check API base URL configuration
- Verify network connectivity

### Login issues
- Check database has user with test credentials
- Verify JWT secret matches between frontend/backend
- Check token expiration settings

### Hot reload not working
- Use `flutter run` instead of hot reload
- Check Flutter version compatibility

## Future Enhancements

- [ ] Offline mode with local database
- [ ] Push notifications
- [ ] Integration with fitness wearables
- [ ] Advanced analytics and charts
- [ ] Achievement badges and leaderboards
- [ ] In-app messaging between users
- [ ] Voice-to-text meal logging
- [ ] Food database/barcode scanning
- [ ] Personal records (PR) tracking
- [ ] Workout plan recommendations

## Testing

```bash
# Unit tests
flutter test

# Widget tests
flutter test test/
```

## Code Quality

```bash
# Analyze code
flutter analyze

# Format code
dart format lib/
```

## Support & Debugging

### Enable verbose logging
```bash
flutter run -v
```

### View device logs
```bash
flutter logs
```

## License

MIT
