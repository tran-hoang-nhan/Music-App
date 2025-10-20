import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:http/http.dart' as http;

class ColorExtractor {
  static Future<Map<String, Color>> extractColorsFromImage(String imageUrl) async {
    try {
      final response = await http.get(Uri.parse(imageUrl));
      final image = img.decodeImage(response.bodyBytes);
      
      if (image == null) return _getDefaultColors();
      
      final colors = _extractDominantColors(image);
      final dominantColor = colors.isNotEmpty ? colors.first : const Color(0xFFE53E3E);
      
      return {
        'primary': _blendWithDark(dominantColor, 0.7),
        'secondary': _blendWithDark(dominantColor, 0.6),
        'accent': _brighten(dominantColor, 0.3),
        'dominant': dominantColor,
      };
    } catch (e) {
      return _getDefaultColors();
    }
  }

  static Future<List<Color>> extractGradientColors(String imageUrl) async {
    try {
      final colors = await extractColorsFromImage(imageUrl);
      final dominantColor = colors['dominant']!;
      
      return [
        _blendWithDark(dominantColor, 0.4),
        _blendWithDark(dominantColor, 0.2),
        const Color(0xFF1A1A1A),
        const Color(0xFF121212),
      ];
    } catch (e) {
      return [
        const Color(0xFF121212),
        const Color(0xFF1E1E1E),
      ];
    }
  }

  static List<Color> _extractDominantColors(img.Image image) {
    final colorMap = <int, int>{};
    
    for (int y = 0; y < image.height; y += 10) {
      for (int x = 0; x < image.width; x += 10) {
        final pixel = image.getPixel(x, y);
        final color = Color.fromARGB(
          pixel.a.toInt(),
          pixel.r.toInt(),
          pixel.g.toInt(),
          pixel.b.toInt(),
        );
        final colorValue = color.r.toInt() << 16 | color.g.toInt() << 8 | color.b.toInt();
        colorMap[colorValue] = (colorMap[colorValue] ?? 0) + 1;
      }
    }
    
    final sortedColors = colorMap.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    return sortedColors.take(5).map((e) => Color(e.key)).toList();
  }

  static Color _blendWithDark(Color color, double factor) {
    final r = (((color.r * 255.0).round() & 0xff) * factor).round();
    final g = (((color.g * 255.0).round() & 0xff) * factor).round();
    final b = (((color.b * 255.0).round() & 0xff) * factor).round();
    return Color.fromARGB(255, r, g, b);
  }

  static Color _brighten(Color color, double factor) {
    final rVal = (color.r * 255.0).round() & 0xff;
    final gVal = (color.g * 255.0).round() & 0xff;
    final bVal = (color.b * 255.0).round() & 0xff;
    final r = ((255 - rVal) * factor + rVal).round();
    final g = ((255 - gVal) * factor + gVal).round();
    final b = ((255 - bVal) * factor + bVal).round();
    return Color.fromARGB(255, r, g, b);
  }

  static Map<String, Color> _getDefaultColors() {
    return {
      'primary': const Color(0xFFE53E3E),
      'secondary': const Color(0xFFE53E3E),
      'accent': const Color(0xFFFF6B6B),
      'dominant': const Color(0xFFE53E3E),
    };
  }

  // Tạo màu complementary
  static Color getComplementaryColor(Color color) {
    return Color.fromARGB(
      255,
      255 - ((color.r * 255.0).round() & 0xff),
      255 - ((color.g * 255.0).round() & 0xff),
      255 - ((color.b * 255.0).round() & 0xff),
    );
  }

  // Tạo màu analogous
  static List<Color> getAnalogousColors(Color color) {
    final hsl = HSLColor.fromColor(color);
    return [
      hsl.withHue((hsl.hue - 30) % 360).toColor(),
      color,
      hsl.withHue((hsl.hue + 30) % 360).toColor(),
    ];
  }

  // Tạo màu triadic
  static List<Color> getTriadicColors(Color color) {
    final hsl = HSLColor.fromColor(color);
    return [
      color,
      hsl.withHue((hsl.hue + 120) % 360).toColor(),
      hsl.withHue((hsl.hue + 240) % 360).toColor(),
    ];
  }
}

