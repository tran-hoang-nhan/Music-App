import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeManager extends ChangeNotifier {
  static const String _themeKey = 'app_theme_mode';
  static const String _customColorKey = 'custom_primary_color';
  
  ThemeMode _themeMode = ThemeMode.dark;
  Color _customPrimaryColor = const Color(0xFFE53E3E);
  
  ThemeMode get themeMode => _themeMode;
  Color get customPrimaryColor => _customPrimaryColor;
  
  bool get isDarkMode => _themeMode == ThemeMode.dark;
  bool get isLightMode => _themeMode == ThemeMode.light;
  bool get isSystemMode => _themeMode == ThemeMode.system;

  Future<void> loadThemePreferences() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Load theme mode
    final themeIndex = prefs.getInt(_themeKey) ?? ThemeMode.dark.index;
    _themeMode = ThemeMode.values[themeIndex];
    
    // Load custom color
    final colorValue = prefs.getInt(_customColorKey) ?? 0xFFE53E3E;
    _customPrimaryColor = Color(colorValue);
    
    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    if (_themeMode != mode) {
      _themeMode = mode;
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_themeKey, mode.index);
      
      notifyListeners();
    }
  }

  Future<void> setCustomPrimaryColor(Color color) async {
    if (_customPrimaryColor != color) {
      _customPrimaryColor = color;
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_customColorKey, color.toARGB32());
      
      notifyListeners();
    }
  }

  Future<void> toggleTheme() async {
    final newMode = _themeMode == ThemeMode.dark 
        ? ThemeMode.light 
        : ThemeMode.dark;
    await setThemeMode(newMode);
  }

  // Predefined color schemes
  static const List<Color> predefinedColors = [
    Color(0xFFE53E3E), // Red (default)
    Color(0xFF6C63FF), // Purple
    Color(0xFF00BCD4), // Cyan
    Color(0xFF4CAF50), // Green
    Color(0xFFFF9800), // Orange
    Color(0xFF2196F3), // Blue
    Color(0xFFE91E63), // Pink
    Color(0xFF9C27B0), // Deep Purple
    Color(0xFF607D8B), // Blue Grey
    Color(0xFF795548), // Brown
  ];

  Future<void> setPredefinedColor(int index) async {
    if (index >= 0 && index < predefinedColors.length) {
      await setCustomPrimaryColor(predefinedColors[index]);
    }
  }
}

