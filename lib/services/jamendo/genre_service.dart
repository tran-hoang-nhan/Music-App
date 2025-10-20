import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class GenreService extends ChangeNotifier {
  static const String _baseUrl = 'https://api.jamendo.com/v3.0';
  static const String _clientId = '75f3ac34';
  static const Duration _timeout = Duration(seconds: 10);

  // Lấy danh sách tất cả thể loại
  Future<List<Map<String, dynamic>>> getAllGenres() async {
    final url = '$_baseUrl/tags/?client_id=$_clientId&format=json';
    
    try {
      final response = await http.get(Uri.parse(url)).timeout(_timeout);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> genres = data['results'];
        return genres.map((genre) => Map<String, dynamic>.from(genre)).toList();
      }
    } catch (e) {
      debugPrint('Lỗi khi lấy genres: $e');
    }
    return [];
  }

  // Lấy thể loại phổ biến
  Future<List<String>> getPopularGenres({int limit = 20}) async {
    try {
      final genres = await getAllGenres();
      final popularGenres = genres.take(limit).map((genre) => genre['name'] as String).toList();
      return popularGenres;
    } catch (e) {
      debugPrint('Lỗi khi lấy popular genres: $e');
    }
    return [];
  }

  // Lấy thể loại trending (có thể mô phỏng bằng cách lấy random)
  Future<List<String>> getTrendingGenres({int limit = 10}) async {
    try {
      final allGenres = await getPopularGenres(limit: 50);
      allGenres.shuffle();
      return allGenres.take(limit).toList();
    } catch (e) {
      debugPrint('Lỗi khi lấy trending genres: $e');
    }
    return [];
  }

  // Lấy thống kê thể loại
  Future<Map<String, dynamic>> getGenreStats(String genre) async {
    try {
      // Lấy số lượng tracks, albums, artists theo genre
      final futures = await Future.wait([
        _getTrackCountByGenre(genre),
        _getAlbumCountByGenre(genre),
        _getArtistCountByGenre(genre),
      ]);

      return {
        'genre': genre,
        'trackCount': futures[0],
        'albumCount': futures[1],
        'artistCount': futures[2],
      };
    } catch (e) {
      debugPrint('Lỗi khi lấy genre stats: $e');
      return {
        'genre': genre,
        'trackCount': 0,
        'albumCount': 0,
        'artistCount': 0,
      };
    }
  }

  // Helper methods
  Future<int> _getTrackCountByGenre(String genre) async {
    final url = '$_baseUrl/tracks/?client_id=$_clientId&format=json&limit=1&tags=$genre';
    
    try {
      final response = await http.get(Uri.parse(url)).timeout(_timeout);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['headers']['results_count'] ?? 0;
      }
    } catch (e) {
      debugPrint('Lỗi khi đếm tracks: $e');
    }
    return 0;
  }

  Future<int> _getAlbumCountByGenre(String genre) async {
    final url = '$_baseUrl/albums/?client_id=$_clientId&format=json&limit=1&tags=$genre';
    
    try {
      final response = await http.get(Uri.parse(url)).timeout(_timeout);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['headers']['results_count'] ?? 0;
      }
    } catch (e) {
      debugPrint('Lỗi khi đếm albums: $e');
    }
    return 0;
  }

  Future<int> _getArtistCountByGenre(String genre) async {
    final url = '$_baseUrl/artists/?client_id=$_clientId&format=json&limit=1&tags=$genre';
    
    try {
      final response = await http.get(Uri.parse(url)).timeout(_timeout);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['headers']['results_count'] ?? 0;
      }
    } catch (e) {
      debugPrint('Lỗi khi đếm artists: $e');
    }
    return 0;
  }

  // Lấy danh sách thể loại được đề xuất dựa trên thể loại đã chọn
  Future<List<String>> getRelatedGenres(String genre, {int limit = 5}) async {
    try {
      // Tạm thời return một số genre có liên quan
      final relatedMap = {
        'rock': ['alternative', 'metal', 'punk', 'indie', 'grunge'],
        'pop': ['dance', 'electronic', 'synthpop', 'indie-pop', 'electropop'],
        'jazz': ['blues', 'funk', 'soul', 'latin', 'swing'],
        'electronic': ['techno', 'house', 'ambient', 'trance', 'dubstep'],
        'classical': ['orchestral', 'piano', 'violin', 'opera', 'symphony'],
        'folk': ['country', 'acoustic', 'singer-songwriter', 'indie-folk', 'bluegrass'],
      };

      return relatedMap[genre.toLowerCase()]?.take(limit).toList() ?? [];
    } catch (e) {
      debugPrint('Lỗi khi lấy related genres: $e');
      return [];
    }
  }
}

