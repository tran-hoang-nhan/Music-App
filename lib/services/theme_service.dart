import 'package:flutter/material.dart';
import 'package:palette_generator/palette_generator.dart';

class ThemeService extends ChangeNotifier {
  static final ThemeService _instance = ThemeService._internal();
  factory ThemeService() => _instance;
  ThemeService._internal();

  Color _primaryColor = const Color(0xFFE53E3E);
  Color _secondaryColor = const Color(0xFFE53E3E);
  List<Color> _gradientColors = [const Color(0xFF121212), const Color(0xFF1E1E1E)];

  // Getters
  Color get primaryColor => _primaryColor;
  Color get secondaryColor => _secondaryColor;
  List<Color> get gradientColors => _gradientColors;

  Future<void> extractColorsFromImage(String imageUrl) async {
    try {
      final imageProvider = NetworkImage(imageUrl);
      final paletteGenerator = await PaletteGenerator.fromImageProvider(
        imageProvider,
        maximumColorCount: 10,
      );

      if (paletteGenerator.colors.isNotEmpty) {
        // Lấy màu dominant
        final dominantColor = paletteGenerator.dominantColor?.color ?? _primaryColor;
        
        // Lấy màu vibrant hoặc muted
        final vibrantColor = paletteGenerator.vibrantColor?.color ?? 
                           paletteGenerator.mutedColor?.color ?? 
                           dominantColor;

        _primaryColor = dominantColor;
        _secondaryColor = vibrantColor;
        
        // Tạo gradient từ màu dominant
        _gradientColors = [
          dominantColor.withOpacity(0.8),
          dominantColor.withOpacity(0.3),
          const Color(0xFF121212),
        ];

        notifyListeners();
      }
    } catch (e) {
      print('Lỗi extract màu: $e');
      // Fallback về màu mặc định
      resetToDefault();
    }
  }

  void resetToDefault() {
    _primaryColor = const Color(0xFFE53E3E);
    _secondaryColor = const Color(0xFFE53E3E);
    _gradientColors = [const Color(0xFF121212), const Color(0xFF1E1E1E)];
    notifyListeners();
  }

  // Tạo theme data động
  ThemeData get dynamicTheme {
    return ThemeData.dark().copyWith(
      primaryColor: _primaryColor,
      colorScheme: ColorScheme.dark(
        primary: _primaryColor,
        secondary: _secondaryColor,
        surface: const Color(0xFF121212),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: _gradientColors.first,
        foregroundColor: Colors.white,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: _primaryColor,
          foregroundColor: Colors.white,
        ),
      ),
    );
  }

  // Tạo gradient container
  Widget createGradientContainer({required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: _gradientColors,
        ),
      ),
      child: child,
    );
  }
}