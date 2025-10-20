import 'package:flutter/material.dart';

class DynamicThemeBuilder {
  static ThemeData buildDarkTheme(Color primaryColor) {
    final colorScheme = ColorScheme.dark(
      primary: primaryColor,
      secondary: _adjustColor(primaryColor, 0.8),
      surface: const Color(0xFF121212),
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: Colors.white,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      brightness: Brightness.dark,
      
      // App Bar Theme
      appBarTheme: AppBarTheme(
        backgroundColor: const Color(0xFF121212),
        foregroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),

      // Card Theme
      cardTheme: CardThemeData(
        color: const Color(0xFF1E1E1E),
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),

      // Bottom Navigation Theme
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: const Color(0xFF121212),
        selectedItemColor: primaryColor,
        unselectedItemColor: Colors.grey[600],
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),

      // Button Themes
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),

      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF1E1E1E),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: primaryColor),
        ),
      ),

      // Slider Theme
      sliderTheme: SliderThemeData(
        activeTrackColor: primaryColor,
        inactiveTrackColor: Colors.grey[800],
        thumbColor: primaryColor,
        overlayColor: primaryColor.withValues(alpha: 0.2),
      ),

      // Progress Indicator Theme
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: primaryColor,
        circularTrackColor: Colors.grey[800],
        linearTrackColor: Colors.grey[800],
      ),

      // Floating Action Button Theme
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
      ),

      // Icon Theme
      iconTheme: IconThemeData(
        color: Colors.grey[300],
        size: 24,
      ),

      // Text Theme
      textTheme: const TextTheme(
        headlineLarge: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        headlineMedium: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        headlineSmall: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        bodyLarge: TextStyle(color: Colors.white),
        bodyMedium: TextStyle(color: Colors.white70),
        bodySmall: TextStyle(color: Colors.white54),
      ),
    );
  }

  static ThemeData buildLightTheme(Color primaryColor) {
    final colorScheme = ColorScheme.light(
      primary: primaryColor,
      secondary: _adjustColor(primaryColor, 0.8),
      surface: Colors.white,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: Colors.black87,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      brightness: Brightness.light,
      
      // App Bar Theme
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 1,
        iconTheme: const IconThemeData(color: Colors.black87),
        titleTextStyle: const TextStyle(
          color: Colors.black87,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),

      // Card Theme
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),

      // Bottom Navigation Theme
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: primaryColor,
        unselectedItemColor: Colors.grey[600],
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),

      // Button Themes
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),

      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.grey[100],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: primaryColor),
        ),
      ),

      // Slider Theme
      sliderTheme: SliderThemeData(
        activeTrackColor: primaryColor,
        inactiveTrackColor: Colors.grey[300],
        thumbColor: primaryColor,
        overlayColor: primaryColor.withValues(alpha: 0.2),
      ),

      // Progress Indicator Theme
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: primaryColor,
        circularTrackColor: Colors.grey[300],
        linearTrackColor: Colors.grey[300],
      ),

      // Floating Action Button Theme
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
      ),

      // Icon Theme
      iconTheme: IconThemeData(
        color: Colors.grey[700],
        size: 24,
      ),

      // Text Theme
      textTheme: const TextTheme(
        headlineLarge: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        headlineMedium: TextStyle(color: Colors.black87, fontWeight: FontWeight.w600),
        headlineSmall: TextStyle(color: Colors.black87, fontWeight: FontWeight.w600),
        bodyLarge: TextStyle(color: Colors.black87),
        bodyMedium: TextStyle(color: Colors.black54),
        bodySmall: TextStyle(color: Colors.black38),
      ),
    );
  }

  static Color _adjustColor(Color color, double factor) {
    final r = (((color.r * 255.0).round() & 0xff) * factor).round();
    final g = (((color.g * 255.0).round() & 0xff) * factor).round();
    final b = (((color.b * 255.0).round() & 0xff) * factor).round();
    return Color.fromARGB(255, r, g, b);
  }
}