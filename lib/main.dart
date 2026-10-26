import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'config/constants.dart';
import 'services/api_service.dart';
import 'screens/guard_dashboard_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ApiService()),
      ],
      child: const VisitorGuardApp(),
    ),
  );
}

class VisitorGuardApp extends StatelessWidget {
  const VisitorGuardApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gate Security Visitor Cockpit',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppConstants.primaryDark,
        primaryColor: AppConstants.accentGreen,
        colorScheme: const ColorScheme.dark(
          primary: AppConstants.accentGreen,
          secondary: AppConstants.accentAmber,
          surface: AppConstants.surfaceDark,
          background: AppConstants.primaryDark,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: AppConstants.surfaceDark,
          elevation: 0,
          centerTitle: false,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppConstants.accentGreen,
            foregroundColor: Colors.black,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ),
      home: const GuardDashboardScreen(),
    );
  }
}
