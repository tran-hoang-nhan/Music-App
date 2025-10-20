import 'package:flutter/material.dart';
import 'theme_manager.dart';
import 'color_extractor.dart';
import 'theme_builder.dart';

class ThemeController extends ChangeNotifier {
  final ThemeManager _themeManager = ThemeManager();
  
  Color _primaryColor = const Color(0xFFE53E3E);
  Color _secondaryColor = const Color(0xFFE53E3E);
  List<Color> _gradientColors = [const Color(0xFF121212), const Color(0xFF1E1E1E)];
  Map<String, Color> _extractedColors = {};

  // Getters để truy cập theme manager
  ThemeManager get manager => _themeManager;
  
  // Getters cho colors
  Color get primaryColor => _primaryColor;
  Color get secondaryColor => _secondaryColor;
  List<Color> get gradientColors => _gradientColors;
  Map<String, Color> get extractedColors => _extractedColors;

  // Theme getters
  ThemeMode get themeMode => _themeManager.themeMode;
  bool get isDarkMode => _themeManager.isDarkMode;
  bool get isLightMode => _themeManager.isLightMode;

  ThemeController() {
    _themeManager.addListener(_onThemeManagerChanged);
    _primaryColor = _themeManager.customPrimaryColor;
    _loadInitialData();
  }

  void _onThemeManagerChanged() {
    _primaryColor = _themeManager.customPrimaryColor;
    notifyListeners();
  }

  Future<void> _loadInitialData() async {
    await _themeManager.loadThemePreferences();
    _primaryColor = _themeManager.customPrimaryColor;
    notifyListeners();
  }

  // Theme switching methods
  Future<void> setThemeMode(ThemeMode mode) async {
    await _themeManager.setThemeMode(mode);
  }

  Future<void> toggleTheme() async {
    await _themeManager.toggleTheme();
  }

  // Color methods
  Future<void> setCustomPrimaryColor(Color color) async {
    await _themeManager.setCustomPrimaryColor(color);
    _primaryColor = color;
    _secondaryColor = ColorExtractor.getComplementaryColor(color);
    notifyListeners();
  }

  Future<void> setPredefinedColor(int index) async {
    await _themeManager.setPredefinedColor(index);
  }

  // Dynamic color extraction from images
  Future<void> extractColorsFromImage(String imageUrl) async {
    try {
      final colors = await ColorExtractor.extractColorsFromImage(imageUrl);
      final gradients = await ColorExtractor.extractGradientColors(imageUrl);
      
      _extractedColors = colors;
      _primaryColor = colors['primary']!;
      _secondaryColor = colors['secondary']!;
      _gradientColors = gradients;
      
      notifyListeners();
    } catch (e) {
      debugPrint('Error extracting colors: $e');
    }
  }

  // Reset to custom theme color
  void resetToCustomColor() {
    _primaryColor = _themeManager.customPrimaryColor;
    _secondaryColor = ColorExtractor.getComplementaryColor(_primaryColor);
    _gradientColors = [const Color(0xFF121212), const Color(0xFF1E1E1E)];
    _extractedColors.clear();
    notifyListeners();
  }

  // Get themed data
  ThemeData get darkTheme => DynamicThemeBuilder.buildDarkTheme(_primaryColor);
  ThemeData get lightTheme => DynamicThemeBuilder.buildLightTheme(_primaryColor);

  // Color scheme helpers
  List<Color> getAnalogousColors() {
    return ColorExtractor.getAnalogousColors(_primaryColor);
  }

  List<Color> getTriadicColors() {
    return ColorExtractor.getTriadicColors(_primaryColor);
  }

  Color getComplementaryColor() {
    return ColorExtractor.getComplementaryColor(_primaryColor);
  }

  // Gradient helpers
  LinearGradient get primaryGradient => LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: _gradientColors,
  );

  LinearGradient get cardGradient => LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      _primaryColor.withValues(alpha: 0.1),
      _secondaryColor.withValues(alpha: 0.05),
    ],
  );

  // Predefined colors
  List<Color> get predefinedColors => ThemeManager.predefinedColors;

  @override
  void dispose() {
    _themeManager.removeListener(_onThemeManagerChanged);
    super.dispose();
  }
}