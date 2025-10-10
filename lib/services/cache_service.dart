import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/song.dart';

class CacheService {
  static const Duration _cacheExpiry = Duration(minutes: 30); // Giảm thời gian cache
  static const int _maxCacheSize = 50; // Giới hạn số lượng cache
  
  // Cache songs với size limit
  static Future<void> cacheSongs(String key, List<Song> songs) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Chỉ cache songs cần thiết
      final limitedSongs = songs.take(_maxCacheSize).toList();
      
      final data = {
        'songs': limitedSongs.map((s) => s.toJson()).toList(),
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      };
      
      await prefs.setString(key, jsonEncode(data));
    } catch (e) {
      // Không crash app nếu cache failed
      print('Cache failed: $e');
    }
  }
  
  static Future<List<Song>?> getCachedSongs(String key) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cached = prefs.getString(key);
      if (cached == null) return null;
      
      final data = jsonDecode(cached);
      final timestamp = DateTime.fromMillisecondsSinceEpoch(data['timestamp']);
      
      if (DateTime.now().difference(timestamp) > _cacheExpiry) {
        // Xóa cache cũ
        await prefs.remove(key);
        return null;
      }
      
      return (data['songs'] as List)
          .map((json) => Song.fromJson(json))
          .toList();
    } catch (e) {
      print('Get cache failed: $e');
      return null;
    }
  }
  
  // Clear old caches để tránh memory leak
  static Future<void> clearOldCaches() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys();
      
      for (final key in keys) {
        if (key.startsWith('cache_')) {
          final cached = prefs.getString(key);
          if (cached != null) {
            try {
              final data = jsonDecode(cached);
              final timestamp = DateTime.fromMillisecondsSinceEpoch(data['timestamp']);
              
              if (DateTime.now().difference(timestamp) > _cacheExpiry) {
                await prefs.remove(key);
              }
            } catch (e) {
              // Remove corrupted cache
              await prefs.remove(key);
            }
          }
        }
      }
    } catch (e) {
      print('Clear cache failed: $e');
    }
  }
}