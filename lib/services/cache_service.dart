import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/song.dart';

class CacheService {
  static const Duration _cacheExpiry = Duration(hours: 1);
  
  static Future<void> cacheSongs(String key, List<Song> songs) async {
    final prefs = await SharedPreferences.getInstance();
    final data = {
      'songs': songs.map((s) => s.toJson()).toList(),
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    };
    await prefs.setString(key, jsonEncode(data));
  }
  
  static Future<List<Song>?> getCachedSongs(String key) async {
    final prefs = await SharedPreferences.getInstance();
    final cached = prefs.getString(key);
    if (cached == null) return null;
    
    final data = jsonDecode(cached);
    final timestamp = DateTime.fromMillisecondsSinceEpoch(data['timestamp']);
    
    if (DateTime.now().difference(timestamp) > _cacheExpiry) {
      return null; // Cache hết hạn
    }
    
    return (data['songs'] as List)
        .map((json) => Song.fromJson(json))
        .toList();
  }
}