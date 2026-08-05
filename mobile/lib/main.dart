import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:soulfluent_mobile/config/theme.dart';
import 'package:soulfluent_mobile/providers/auth_provider.dart';
import 'package:soulfluent_mobile/providers/gd_provider.dart';
import 'package:soulfluent_mobile/providers/theme_provider.dart';
import 'package:soulfluent_mobile/screens/auth_screen.dart';
import 'package:soulfluent_mobile/screens/feedback_report_screen.dart';
import 'package:soulfluent_mobile/screens/gd_arena_screen.dart';
import 'package:soulfluent_mobile/screens/history_screen.dart';
import 'package:soulfluent_mobile/screens/home_screen.dart';
import 'package:soulfluent_mobile/services/api_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const SoulFluentApp());
}

class SoulFluentApp extends StatelessWidget {
  const SoulFluentApp({super.key});

  @override
  Widget build(BuildContext context) {
    final apiService = ApiService();

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider(apiService)),
        ChangeNotifierProvider(create: (_) => GDProvider(apiService)),
      ],
      child: Consumer2<AuthProvider, ThemeProvider>(
        builder: (context, auth, themeProvider, _) {
          return MaterialApp(
            title: 'SoulFluent Voice GD',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeProvider.themeMode,
            home: auth.isLoading
                ? const Scaffold(
                    body: Center(
                      child: CircularProgressIndicator(color: AppTheme.primary),
                    ),
                  )
                : (auth.isAuthenticated
                    ? const HomeScreen()
                    : const AuthScreen()),
            routes: {
              '/auth': (context) => const AuthScreen(),
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
