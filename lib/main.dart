import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
    // Primary base font: Nunito
    final baseTextTheme = GoogleFonts.nunitoTextTheme(
      ThemeData.light().textTheme,
    );

    // Apply Roboto specifically for headings and titles
    final appTextTheme = baseTextTheme.copyWith(
      displayLarge: GoogleFonts.roboto(
        textStyle: baseTextTheme.displayLarge,
        fontWeight: FontWeight.w800,
        color: AppConstants.textPrimary,
      ),
      displayMedium: GoogleFonts.roboto(
        textStyle: baseTextTheme.displayMedium,
        fontWeight: FontWeight.w800,
        color: AppConstants.textPrimary,
      ),
      displaySmall: GoogleFonts.roboto(
        textStyle: baseTextTheme.displaySmall,
        fontWeight: FontWeight.w700,
        color: AppConstants.textPrimary,
      ),
      headlineLarge: GoogleFonts.roboto(
        textStyle: baseTextTheme.headlineLarge,
        fontWeight: FontWeight.w800,
        color: AppConstants.textPrimary,
      ),
      headlineMedium: GoogleFonts.roboto(
        textStyle: baseTextTheme.headlineMedium,
        fontWeight: FontWeight.w700,
        color: AppConstants.textPrimary,
      ),
      headlineSmall: GoogleFonts.roboto(
        textStyle: baseTextTheme.headlineSmall,
        fontWeight: FontWeight.w700,
        color: AppConstants.textPrimary,
      ),
      titleLarge: GoogleFonts.roboto(
        textStyle: baseTextTheme.titleLarge,
        fontWeight: FontWeight.w700,
        color: AppConstants.textPrimary,
      ),
      titleMedium: GoogleFonts.roboto(
        textStyle: baseTextTheme.titleMedium,
        fontWeight: FontWeight.w600,
        color: AppConstants.textPrimary,
      ),
      titleSmall: GoogleFonts.roboto(
        textStyle: baseTextTheme.titleSmall,
        fontWeight: FontWeight.w600,
        color: AppConstants.textPrimary,
      ),
      bodyLarge: GoogleFonts.nunito(
        textStyle: baseTextTheme.bodyLarge,
        color: AppConstants.textPrimary,
      ),
      bodyMedium: GoogleFonts.nunito(
        textStyle: baseTextTheme.bodyMedium,
        color: AppConstants.textSecondary,
      ),
      bodySmall: GoogleFonts.nunito(
        textStyle: baseTextTheme.bodySmall,
        color: AppConstants.textSecondary,
      ),
    );

    return MaterialApp(
      title: 'Gate Security Visitor Cockpit',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        scaffoldBackgroundColor: AppConstants.scaffoldLight,
        primaryColor: AppConstants.accentGreen,
        textTheme: appTextTheme,
        colorScheme: const ColorScheme.light(
          primary: AppConstants.accentGreen,
          secondary: AppConstants.accentAmber,
          surface: AppConstants.surfaceWhite,
          error: AppConstants.accentRed,
          onPrimary: Colors.white,
          onSecondary: Colors.white,
          onSurface: AppConstants.textPrimary,
          onError: Colors.white,
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: AppConstants.surfaceWhite,
          foregroundColor: AppConstants.textPrimary,
          elevation: 0,
          scrolledUnderElevation: 1,
          surfaceTintColor: Colors.transparent,
          centerTitle: false,
          iconTheme: const IconThemeData(color: AppConstants.textPrimary),
          titleTextStyle: GoogleFonts.roboto(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: AppConstants.textPrimary,
            letterSpacing: 0.5,
          ),
        ),
        cardTheme: CardTheme(
          color: AppConstants.surfaceWhite,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: AppConstants.borderLight),
          ),
          margin: EdgeInsets.zero,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppConstants.accentGreen,
            foregroundColor: Colors.white,
            elevation: 1,
            shadowColor: AppConstants.accentGreen.withValues(alpha: 0.3),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            textStyle: GoogleFonts.nunito(
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: AppConstants.accentGreen,
            side: const BorderSide(color: AppConstants.accentGreen, width: 1.2),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            textStyle: GoogleFonts.nunito(
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppConstants.inputFill,
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          hintStyle: GoogleFonts.nunito(
            color: AppConstants.textMuted,
            fontSize: 13,
          ),
          labelStyle: GoogleFonts.nunito(
            color: AppConstants.textSecondary,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppConstants.borderLight),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppConstants.borderLight),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppConstants.accentGreen, width: 1.8),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppConstants.accentRed, width: 1.2),
          ),
        ),
        dialogTheme: DialogTheme(
          backgroundColor: AppConstants.surfaceWhite,
          elevation: 8,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      ),
      home: const GuardDashboardScreen(),
    );
  }
}
