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
        maximumColorCount: 15,
      );

      if (paletteGenerator.colors.isNotEmpty) {
        // Lấy màu chủ đạo
        final dominantColor = paletteGenerator.dominantColor?.color ?? 
                             paletteGenerator.vibrantColor?.color ??
                             paletteGenerator.mutedColor?.color ??
                             _primaryColor;
        
        // Tạo màu mềm mại hơn bằng cách pha với đen/xám
        final softPrimary = _blendWithDark(dominantColor, 0.7);
        final softSecondary = _blendWithDark(
          paletteGenerator.vibrantColor?.color ?? 
          paletteGenerator.mutedColor?.color ?? 
          dominantColor, 0.6
        );

        _primaryColor = softPrimary;
        _secondaryColor = softSecondary;
        
        // Tạo gradient mượt với nhiều tầng màu
        _gradientColors = [
          _blendWithDark(dominantColor, 0.4),
          _blendWithDark(dominantColor, 0.2),
          const Color(0xFF1A1A1A),
          const Color(0xFF121212),
        ];

        notifyListeners();
      }
    } catch (e) {
      resetToDefault();
    }
  }

  // Pha trộn màu với đen/xám để giảm độ chói
  Color _blendWithDark(Color color, double intensity) {
    final darkBase = const Color(0xFF2A2A2A);
    return Color.lerp(darkBase, color, intensity) ?? color;
  }

  void resetToDefault() {
    _primaryColor = const Color(0xFFE53E3E);
    _secondaryColor = const Color(0xFFE53E3E);
    _gradientColors = [
      const Color(0xFF1E1E1E),
      const Color(0xFF1A1A1A), 
      const Color(0xFF121212),
      const Color(0xFF0F0F0F)
    ];
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
        backgroundColor: _gradientColors.first.withValues(alpha: 0.9),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: _primaryColor,
          foregroundColor: Colors.white,
        ),
      ),
      cardTheme: CardThemeData(
        color: _primaryColor.withValues(alpha: 0.1),
        elevation: 2,
      ),
    );
  }

  // Tạo gradient container mượt
  Widget createGradientContainer({required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: _gradientColors,
          stops: const [0.0, 0.3, 0.7, 1.0],
        ),
      ),
      child: child,
    );
  }

  // Tạo gradient cho player
  Widget createPlayerGradient({required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        gradient: RadialGradient(
          center: Alignment.topCenter,
          radius: 1.5,
          colors: [
            _primaryColor.withValues(alpha: 0.3),
            _secondaryColor.withValues(alpha: 0.2),
            const Color(0xFF121212),
          ],
        ),
      ),
      child: child,
    );
  }
}