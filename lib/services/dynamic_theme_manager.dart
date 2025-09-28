import 'package:flutter/material.dart';
import 'theme_service.dart';
import '../models/song.dart';

class DynamicThemeManager {
  static final DynamicThemeManager _instance = DynamicThemeManager._internal();
  factory DynamicThemeManager() => _instance;
  DynamicThemeManager._internal();

  final ThemeService _themeService = ThemeService();
  String? _currentImageUrl;

  // Cập nhật theme từ bài hát hiện tại
  Future<void> updateThemeFromSong(Song? song) async {
    if (song?.albumImage == null || song!.albumImage == _currentImageUrl) return;
    
    _currentImageUrl = song.albumImage;
    await _themeService.extractColorsFromImage(song.albumImage);
  }

  // Reset về theme mặc định
  void resetTheme() {
    _currentImageUrl = null;
    _themeService.resetToDefault();
  }

  // Getter cho theme service
  ThemeService get themeService => _themeService;
}