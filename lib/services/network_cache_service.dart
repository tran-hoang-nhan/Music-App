import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class NetworkCacheService {
  static const String _cachePrefix = 'network_cache_';
  static const Duration _cacheExpiry = Duration(hours: 1);

  static Future<void> cacheData(String key, Map<String, dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();
    final cacheData = {
      'data': data,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    };
    await prefs.setString('$_cachePrefix$key', json.encode(cacheData));
  }

  static Future<Map<String, dynamic>?> getCachedData(String key) async {
    final prefs = await SharedPreferences.getInstance();
    final cachedString = prefs.getString('$_cachePrefix$key');
    
    if (cachedString == null) return null;
    
    final cacheData = json.decode(cachedString);
    final timestamp = DateTime.fromMillisecondsSinceEpoch(cacheData['timestamp']);
    
    if (DateTime.now().difference(timestamp) > _cacheExpiry) {
      await prefs.remove('$_cachePrefix$key');
      return null;
    }
    
    return cacheData['data'];
  }

  static Future<void> clearCache() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys().where((key) => key.startsWith(_cachePrefix));
    for (final key in keys) {
      await prefs.remove(key);
    }
  }
}