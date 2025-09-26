import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/song.dart';
import '../models/album.dart';
import '../models/artist.dart';
import 'network_cache_service.dart';

class JamendoService {
  static const String _baseUrl = 'https://api.jamendo.com/v3.0';
  static const String _clientId = '75f3ac34';

  // Lấy danh sách bài hát phổ biến
  Future<List<Song>> getPopularTracks({int limit = 20, int offset = 0}) async {
    final cacheKey = 'popular_tracks_${limit}_$offset';
    
    // Kiểm tra cache trước
    final cachedData = await NetworkCacheService.getCachedData(cacheKey);
    if (cachedData != null) {
      final List<dynamic> tracks = cachedData['tracks'];
      return tracks.map((track) => Song.fromJson(track)).toList();
    }
    
    final url = '$_baseUrl/tracks/?client_id=$_clientId&format=json&limit=$limit&offset=$offset&order=popularity_total&include=musicinfo&audioformat=mp32';
    
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> tracks = data['results'];
        
        // Lưu vào cache
        await NetworkCacheService.cacheData(cacheKey, {'tracks': tracks});
        
        return tracks.map((track) => Song.fromJson(track)).toList();
      }
    } catch (e) {
      debugPrint('Lỗi khi lấy bài hát phổ biến: $e');
    }
    return [];
  }

  // Lấy bài hát mới nhất
  Future<List<Song>> getLatestTracks({int limit = 20, int offset = 0}) async {
    final url = '$_baseUrl/tracks/?client_id=$_clientId&format=json&limit=$limit&offset=$offset&order=releasedate_desc&include=musicinfo&audioformat=mp32';
    
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> tracks = data['results'];
        return tracks.map((track) => Song.fromJson(track)).toList();
      }
    } catch (e) {
      debugPrint('Lỗi khi lấy bài hát mới: $e');
    }
    return [];
  }

  // Tìm kiếm bài hát
  Future<List<Song>> searchTracks(String query, {int limit = 20}) async {
    final url = '$_baseUrl/tracks/?client_id=$_clientId&format=json&limit=$limit&search=$query&include=musicinfo&audioformat=mp32';
    
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> tracks = data['results'];
        return tracks.map((track) => Song.fromJson(track)).toList();
      }
    } catch (e) {
      debugPrint('Lỗi khi tìm kiếm: $e');
    }
    return [];
  }

  // Lấy bài hát theo thể loại
  Future<List<Song>> getTracksByGenre(String genre, {int limit = 20}) async {
    final url = '$_baseUrl/tracks/?client_id=$_clientId&format=json&limit=$limit&tags=$genre&include=musicinfo&audioformat=mp32';
    
    try {
      final response = await http.get(Uri.parse(url));
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

  // Lấy album nổi bật
  Future<List<Album>> getFeaturedAlbums({int limit = 20, int offset = 0}) async {
    final url = '$_baseUrl/albums/?client_id=$_clientId&format=json&limit=$limit&offset=$offset&order=popularity_total';
    
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> albums = data['results'];
        return albums.map((album) => Album.fromJson(album)).toList();
      }
    } catch (e) {
      debugPrint('Lỗi khi lấy album nổi bật: $e');
    }
    return [];
  }

  // Lấy danh sách album
  Future<List<Album>> getAlbums({int limit = 20, int offset = 0}) async {
    final url = '$_baseUrl/albums/?client_id=$_clientId&format=json&limit=$limit&offset=$offset&order=popularity_total';
    
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> albums = data['results'];
        return albums.map((album) => Album.fromJson(album)).toList();
      }
    } catch (e) {
      debugPrint('Lỗi khi lấy album: $e');
    }
    return [];
  }

  // Lấy bài hát trong album
  Future<List<Song>> getAlbumTracks(String albumId) async {
    final url = '$_baseUrl/tracks/?client_id=$_clientId&format=json&album_id=$albumId&include=musicinfo&audioformat=mp32&order=id';
    
    try {
      debugPrint('API URL: $url');
      final response = await http.get(Uri.parse(url));
      debugPrint('Response status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> tracks = data['results'];
        debugPrint('API returned ${tracks.length} tracks');
        return tracks.map((track) => Song.fromJson(track)).toList();
      }
    } catch (e) {
      debugPrint('Lỗi khi lấy bài hát trong album: $e');
    }
    return [];
  }

  // Lấy nghệ sĩ nổi bật
  Future<List<Artist>> getFeaturedArtists({int limit = 20, int offset = 0}) async {
    final url = '$_baseUrl/artists/?client_id=$_clientId&format=json&limit=$limit&offset=$offset&order=popularity_total';
    
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> artists = data['results'];
        return artists.map((artist) => Artist.fromJson(artist)).toList();
      }
    } catch (e) {
      debugPrint('Lỗi khi lấy nghệ sĩ nổi bật: $e');
    }
    return [];
  }

  // Lấy danh sách nghệ sĩ
  Future<List<Artist>> getArtists({int limit = 20, int offset = 0}) async {
    final url = '$_baseUrl/artists/?client_id=$_clientId&format=json&limit=$limit&offset=$offset&order=popularity_total';
    
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> artists = data['results'];
        return artists.map((artist) => Artist.fromJson(artist)).toList();
      }
    } catch (e) {
      debugPrint('Lỗi khi lấy nghệ sĩ: $e');
    }
    return [];
  }

  // Lấy bài hát của nghệ sĩ
  Future<List<Song>> getArtistTracks(String artistId, {int limit = 20}) async {
    final url = '$_baseUrl/tracks/?client_id=$_clientId&format=json&artist_id=$artistId&limit=$limit&include=musicinfo&audioformat=mp32&order=popularity_total';
    
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> tracks = data['results'];
        return tracks.map((track) => Song.fromJson(track)).toList();
      }
    } catch (e) {
      debugPrint('Lỗi khi lấy bài hát của nghệ sĩ: $e');
    }
    return [];
  }
  
  // Lấy album của nghệ sĩ
  Future<List<Album>> getArtistAlbums(String artistId, {int limit = 10}) async {
    final url = '$_baseUrl/albums/?client_id=$_clientId&format=json&artist_id=$artistId&limit=$limit&order=popularity_total';
    
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> albums = data['results'];
        return albums.map((album) => Album.fromJson(album)).toList();
      }
    } catch (e) {
      debugPrint('Lỗi khi lấy album của nghệ sĩ: $e');
    }
    return [];
  }

  // Lấy thông tin chi tiết bài hát theo ID
  Future<Song?> getSongById(String songId) async {
    final url = '$_baseUrl/tracks/?client_id=$_clientId&format=json&id=$songId&include=musicinfo&audioformat=mp32';
    
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> tracks = data['results'];
        if (tracks.isNotEmpty) {
          return Song.fromJson(tracks.first);
        }
      }
    } catch (e) {
      debugPrint('Lỗi khi lấy thông tin bài hát $songId: $e');
    }
    return null;
  }
}