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
  
  // App Colors
  static const Color primaryDark = Color(0xFF0F172A); // Slate 900
  static const Color surfaceDark = Color(0xFF1E293B); // Slate 800
  static const Color cardDark = Color(0xFF334155);    // Slate 700
  static const Color accentGreen = Color(0xFF10B981); // Emerald 500
  static const Color accentAmber = Color(0xFFF59E0B); // Amber 500 (Alert)
  static const Color accentRed = Color(0xFFEF4444);   // Rose 500
  static const Color accentBlue = Color(0xFF38BDF8);  // Sky 400
  
  static const Color textPrimary = Color(0xFFF8FAFC);
  static const Color textSecondary = Color(0xFF94A3B8);
  static const Color borderLight = Color(0xFF475569);

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
