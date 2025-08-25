import 'package:flutter/material.dart';

class AppTheme {
  // Lumengarten Farbpalette - magisch und kinderfreundlich
  static const Color primaryBlue = Color(0xFF6B73FF);
  static const Color primaryPurple = Color(0xFF9B59B6);
  static const Color primaryPink = Color(0xFFE91E63);
  
  // Pastell-Farben für beruhigende Wirkung
  static const Color lightBlue = Color(0xFFE3F2FD);
  static const Color lightPurple = Color(0xFFF3E5F5);
  static const Color lightPink = Color(0xFFFCE4EC);
  
  // Phantasiegarten-Farben
  static const Color magicGreen = Color(0xFF4CAF50);
  static const Color crystalBlue = Color(0xFF00BCD4);
  static const Color starYellow = Color(0xFFFFC107);
  static const Color moonSilver = Color(0xFFE0E0E0);
  
  // Neutrale Farben
  static const Color white = Color(0xFFFFFFFF);
  static const Color lightGray = Color(0xFFF5F5F5);
  static const Color darkGray = Color(0xFF757575);
  
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryBlue,
        brightness: Brightness.light,
      ),
      
      // Kinderfreundliche Typografie
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: primaryPurple,
        ),
        displayMedium: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: primaryBlue,
        ),
        headlineLarge: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: primaryPurple,
        ),
        headlineMedium: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: primaryBlue,
        ),
        bodyLarge: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.normal,
          color: darkGray,
        ),
        bodyMedium: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.normal,
          color: darkGray,
        ),
      ),
      
      // Große Touch-Targets für Kinder
      materialTapTargetSize: MaterialTapTargetSize.padded,
      
      // Abgerundete Buttons
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(80, 60),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          textStyle: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      
      // Abgerundete Cards
      cardTheme: CardThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        elevation: 4,
      ),
      
      // App Bar Theme
      appBarTheme: const AppBarTheme(
        backgroundColor: lightBlue,
        foregroundColor: primaryPurple,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: primaryPurple,
        ),
      ),
    );
  }
}

// Spezielle Widget-Styles für die App
class AppStyles {
  static const EdgeInsets pagePadding = EdgeInsets.all(20);
  static const EdgeInsets cardPadding = EdgeInsets.all(16);
  static const EdgeInsets buttonPadding = EdgeInsets.symmetric(
    horizontal: 24,
    vertical: 12,
  );
  
  static BorderRadius cardRadius = BorderRadius.circular(16);
  static BorderRadius buttonRadius = BorderRadius.circular(20);
  
  // Schatten für schwebende Elemente
  static List<BoxShadow> cardShadow = [
    BoxShadow(
      color: Colors.black.withOpacity(0.1),
      blurRadius: 8,
      offset: const Offset(0, 4),
    ),
  ];
}