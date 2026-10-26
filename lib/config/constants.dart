import 'package:flutter/material.dart';

class AppConstants {
  // Supabase Configuration
  static const String supabaseUrl = 'https://xxoslmzgvpooxwwckzia.supabase.co';
  
  // Backend CCTV Gate API (Default to local machine IP or localhost:5000)
  static const String defaultApiBaseUrl = 'http://127.0.0.1:5000';
  
  // Storage Keys
  static const String keyApiUrl = 'pref_api_base_url';
  static const String keyGuardName = 'pref_guard_name';
  static const String keyGateName = 'pref_gate_name';
  
  // Brand Colors - Clean White & #008000 Green Light Theme
  static const Color accentGreen = Color(0xFF008000);       // User requested #008000
  static const Color greenDark = Color(0xFF006400);          // Darker green for pressed states
  static const Color greenLight = Color(0xFFE8F5E9);         // Soft green badge background
  static const Color greenSubtle = Color(0xFFF0FDF4);        // Very light green tint

  static const Color scaffoldLight = Color(0xFFF8FAFC);      // Crisp clean background
  static const Color surfaceWhite = Color(0xFFFFFFFF);       // Pure White surfaces
  static const Color cardLight = Color(0xFFFFFFFF);          // White cards
  static const Color inputFill = Color(0xFFF8FAFC);          // Subtle light fill for inputs
  static const Color chipBackground = Color(0xFFF1F5F9);     // Slate 100

  // Neutral Text Colors
  static const Color textPrimary = Color(0xFF0F172A);        // Slate 900
  static const Color textSecondary = Color(0xFF475569);      // Slate 600
  static const Color textMuted = Color(0xFF94A3B8);          // Slate 400
  
  // Borders & Dividers
  static const Color borderLight = Color(0xFFE2E8F0);        // Slate 200
  static const Color borderMedium = Color(0xFFCBD5E1);       // Slate 300

  // Status / Functional Colors
  static const Color accentAmber = Color(0xFFD97706);        // Amber 600
  static const Color amberLight = Color(0xFFFEF3C7);         // Amber 100
  static const Color accentRed = Color(0xFFDC2626);          // Red 600
  static const Color redLight = Color(0xFFFEE2E2);           // Red 100
  static const Color accentBlue = Color(0xFF0284C7);         // Sky 600
  static const Color blueLight = Color(0xFFE0F2FE);          // Sky 100

  // Backwards compatibility aliases mapped to light theme
  static const Color primaryDark = scaffoldLight;
  static const Color surfaceDark = surfaceWhite;
  static const Color cardDark = chipBackground;

  // Soft modern drop shadow for cards and surfaces
  static List<BoxShadow> get softShadow => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.04),
      blurRadius: 10,
      offset: const Offset(0, 3),
    ),
    BoxShadow(
      color: const Color(0xFF008000).withValues(alpha: 0.02),
      blurRadius: 16,
      offset: const Offset(0, 6),
    ),
  ];

  static List<BoxShadow> get greenGlow => [
    BoxShadow(
      color: const Color(0xFF008000).withValues(alpha: 0.20),
      blurRadius: 12,
      offset: const Offset(0, 4),
    ),
  ];

  // Categories
  static const List<String> visitorCategories = [
    'Guest / Visitor',
    'Delivery / Courier',
    'Contractor / Maintenance',
    'Official / Business',
    'Vendor / Supplier',
    'Other'
  ];
}
