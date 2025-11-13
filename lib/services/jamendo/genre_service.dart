import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../../models/song.dart';

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
    // Xóa dấu cách để match API tag format
    final genreTag = genre.replaceAll(' ', '').toLowerCase();
    final url = '$_baseUrl/tracks/?client_id=$_clientId&format=json&limit=1&tags=$genreTag';
    
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
    final genreTag = genre.replaceAll(' ', '').toLowerCase();
    final url = '$_baseUrl/albums/?client_id=$_clientId&format=json&limit=1&tags=$genreTag';
    
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
    final genreTag = genre.replaceAll(' ', '').toLowerCase();
    final url = '$_baseUrl/artists/?client_id=$_clientId&format=json&limit=1&tags=$genreTag';
    
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

  // Lấy bài hát theo thể loại
  Future<List<Song>> getTracksByGenre(String genre, {int limit = 20}) async {
    // Xóa dấu cách và chuyển thành chữ thường (ví dụ: "hip hop" → "hiphop")
    final genreTag = genre.replaceAll(' ', '').toLowerCase();
    final url = '$_baseUrl/tracks/?client_id=$_clientId&format=json&limit=$limit&tags=$genreTag&include=musicinfo&audioformat=mp32';
    
    try {
      final response = await http.get(Uri.parse(url)).timeout(_timeout);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> tracks = data['results'];
        return tracks.map((track) => Song.fromJson(track)).toList();
      }
    } catch (e) {
      debugPrint('Lỗi khi lấy bài hát theo thể loại: $e');
    }
    return [];
  }

}

