import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'pages/homepage.dart';
import 'pages/loginpage.dart';
import 'providers/auth_provider.dart';
import 'providers/user_provider.dart';
import 'providers/workout_provider.dart';
import 'providers/calorie_provider.dart';
import 'providers/post_provider.dart';
import 'repositories/auth_repository.dart';
import 'repositories/user_repository.dart';
import 'repositories/workout_repository.dart';
import 'repositories/calorie_repository.dart';
import 'repositories/post_repository.dart';
import 'services/auth_service.dart';
import 'services/user_service.dart';
import 'services/workout_service.dart';
import 'services/calorie_service.dart';
import 'services/post_service.dart';
import 'themenotifier.dart';
import 'utils/app_routes.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Auth Services
        ChangeNotifierProvider(
          create: (_) => AuthProvider(AuthRepository(AuthService())),
        ),
        // User Services
        ChangeNotifierProvider(
          create: (_) => UserProvider(UserRepository(UserService())),
        ),
        // Workout Services
        ChangeNotifierProvider(
          create: (_) => WorkoutProvider(WorkoutRepository(WorkoutService())),
        ),
        // Calorie Services
        ChangeNotifierProvider(
          create: (_) => CalorieProvider(CalorieRepository(CalorieService())),
        ),
        // Post Services
        ChangeNotifierProvider(
          create: (_) => PostProvider(PostRepository(PostService())),
        ),
      ],
      child: ValueListenableBuilder<ThemeMode>(
        valueListenable: themeNotifier,
        builder: (_, ThemeMode currentMode, __) {
          return MaterialApp(
            title: 'Go-Fit',
            debugShowCheckedModeBanner: false,
            initialRoute: AppRoutes.login,
            routes: {
              AppRoutes.login: (_) => const LoginPage(),
              AppRoutes.home: (_) => const HomePage(),
            },
            theme: ThemeData(
              brightness: Brightness.light,
              colorScheme: const ColorScheme.light(
                primary: Color(0xFF1976D2),
                onPrimary: Colors.white,
                primaryContainer: Color(0xFFE3F2FD),
                onPrimaryContainer: Color(0xFF1976D2),
                secondary: Color(0xFF03DAC6),
                onSecondary: Colors.black,
                secondaryContainer: Color(0xFFE0F2F1),
                onSecondaryContainer: Color(0xFF00695C),
                tertiary: Color(0xFF03DAC6),
                onTertiary: Colors.black,
                tertiaryContainer: Color(0xFFE0F2F1),
                onTertiaryContainer: Color(0xFF00695C),
                error: Color(0xFFB00020),
                onError: Colors.white,
                errorContainer: Color(0xFFFCD8DF),
                onErrorContainer: Color(0xFF690005),
                surface: Colors.white,
                onSurface: Colors.black,
                surfaceContainerHighest: Color(0xFFE7E0EC),
                onSurfaceVariant: Color(0xFF49454F),
                outline: Color(0xFF79747E),
                outlineVariant: Color(0xFFCAC4D0),
                shadow: Colors.black,
                scrim: Colors.black,
                inverseSurface: Colors.black,
                onInverseSurface: Colors.white,
                inversePrimary: Color(0xFFBB86FC),
                surfaceTint: Color(0xFF1976D2),
              ),
              useMaterial3: true,
            ),
            darkTheme: ThemeData(
              brightness: Brightness.dark,
              colorScheme: const ColorScheme.dark(
                primary: Color(0xFF1976D2),
                onPrimary: Colors.white,
                primaryContainer: Color(0xFF0D47A1),
                onPrimaryContainer: Color(0xFFBBDEFB),
                secondary: Color(0xFF03DAC6),
                onSecondary: Colors.black,
                secondaryContainer: Color(0xFF004D40),
                onSecondaryContainer: Color(0xFFB2DFDB),
                tertiary: Color(0xFF03DAC6),
                onTertiary: Colors.black,
                tertiaryContainer: Color(0xFF004D40),
                onTertiaryContainer: Color(0xFFB2DFDB),
                error: Color(0xFFCF6679),
                onError: Colors.black,
                errorContainer: Color(0xFF93000A),
                onErrorContainer: Color(0xFFFFB4AB),
                surface: Color(0xFF121212),
                onSurface: Colors.white,
                surfaceContainerHighest: Color(0xFF49454F),
                onSurfaceVariant: Color(0xFFCAC4D0),
                outline: Color(0xFF938F99),
                outlineVariant: Color(0xFF49454F),
                shadow: Colors.black,
                scrim: Colors.black,
                inverseSurface: Colors.white,
                onInverseSurface: Colors.black,
                inversePrimary: Color(0xFFBB86FC),
                surfaceTint: Color(0xFF1976D2),
              ),
              cardTheme: CardThemeData(
                color: const Color(0xFF1E1E1E),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  side: const BorderSide(color: Color(0xFF333333), width: 1),
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              useMaterial3: true,
            ),
            themeMode: currentMode,
          );
        },
      ),
    );
  }
}
