import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fluentsoul_mobile/config/theme.dart';
import 'package:fluentsoul_mobile/providers/auth_provider.dart';
import 'package:fluentsoul_mobile/providers/challenges_provider.dart';
import 'package:fluentsoul_mobile/providers/gd_provider.dart';
import 'package:fluentsoul_mobile/providers/onboarding_provider.dart';
import 'package:fluentsoul_mobile/providers/theme_provider.dart';
import 'package:fluentsoul_mobile/screens/auth_screen.dart';
import 'package:fluentsoul_mobile/screens/feedback_report_screen.dart';
import 'package:fluentsoul_mobile/screens/gd_arena_screen.dart';
import 'package:fluentsoul_mobile/screens/history_screen.dart';
import 'package:fluentsoul_mobile/screens/home_screen.dart';
import 'package:fluentsoul_mobile/screens/onboarding_screen.dart';
import 'package:fluentsoul_mobile/services/api_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const FluentSoulApp());
}

class FluentSoulApp extends StatelessWidget {
  const FluentSoulApp({super.key});

  @override
  Widget build(BuildContext context) {
    final apiService = ApiService();

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider(apiService)),
        ChangeNotifierProvider(create: (_) => GDProvider(apiService)),
        ChangeNotifierProvider(create: (_) => ChallengesProvider()),
        ChangeNotifierProvider(create: (_) => OnboardingProvider()),
      ],
      child: Consumer3<AuthProvider, ThemeProvider, OnboardingProvider>(
        builder: (context, auth, themeProvider, onboarding, _) {
          return MaterialApp(
            title: 'FluentSoul: Speak English Fluently & Confidently',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeProvider.themeMode,
            home: (auth.isLoading || onboarding.isLoading)
                ? const Scaffold(
                    body: Center(
                      child: CircularProgressIndicator(color: AppTheme.primary),
                    ),
                  )
                : (auth.isAuthenticated
                    ? (onboarding.isOnboarded
                        ? const HomeScreen()
                        : const OnboardingScreen())
                    : const AuthScreen()),
            routes: {
              '/auth': (context) => const AuthScreen(),
              '/onboarding': (context) => const OnboardingScreen(),
              '/home': (context) => const HomeScreen(),
              '/history': (context) => const HistoryScreen(),
              '/arena': (context) => const GDArenaScreen(),
              '/report': (context) => const FeedbackReportScreen(),
            },
          );
        },
      ),
    );
  }
}
