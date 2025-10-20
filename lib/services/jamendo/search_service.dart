import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../../models/song.dart';

class SearchService extends ChangeNotifier {
  static const String _baseUrl = 'https://api.jamendo.com/v3.0';
  static const String _clientId = '75f3ac34';
  static const Duration _timeout = Duration(seconds: 10);

  // Tìm kiếm bài hát
  Future<List<Song>> searchTracks(String query, {int limit = 20}) async {
    if (query.trim().isEmpty) return [];
    
    final url = '$_baseUrl/tracks/?client_id=$_clientId&format=json&limit=$limit&search=$query&include=musicinfo&audioformat=mp32';
    
    try {
      final response = await http.get(Uri.parse(url)).timeout(_timeout);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> tracks = data['results'];
        return tracks.map((track) => Song.fromJson(track)).toList();
      }
    } catch (e) {
      debugPrint('Lỗi khi tìm kiếm tracks: $e');
    }
    return [];
  }

  // Tìm kiếm artist
  Future<List<Map<String, dynamic>>> searchArtists(String query, {int limit = 20}) async {
    if (query.trim().isEmpty) return [];
    
    final url = '$_baseUrl/artists/?client_id=$_clientId&format=json&limit=$limit&search=$query';
    
    try {
      final response = await http.get(Uri.parse(url)).timeout(_timeout);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> artists = data['results'];
        return artists.map((artist) => Map<String, dynamic>.from(artist)).toList();
      }
    } catch (e) {
      debugPrint('Lỗi khi tìm kiếm artists: $e');
    }
    return [];
  }

  // Tìm kiếm album
  Future<List<Map<String, dynamic>>> searchAlbums(String query, {int limit = 20}) async {
    if (query.trim().isEmpty) return [];
    
    final url = '$_baseUrl/albums/?client_id=$_clientId&format=json&limit=$limit&search=$query';
    
    try {
      final response = await http.get(Uri.parse(url)).timeout(_timeout);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> albums = data['results'];
        return albums.map((album) => Map<String, dynamic>.from(album)).toList();
      }
    } catch (e) {
      debugPrint('Lỗi khi tìm kiếm albums: $e');
    }
    return [];
  }

  // Tìm kiếm tổng hợp (tracks, artists, albums)
  Future<Map<String, dynamic>> searchAll(String query, {int limit = 10}) async {
    if (query.trim().isEmpty) {
      return {
        'tracks': <Song>[],
        'artists': <Map<String, dynamic>>[],
        'albums': <Map<String, dynamic>>[],
      };
    }

    try {
      final futures = await Future.wait([
        searchTracks(query, limit: limit),
        searchArtists(query, limit: limit),
        searchAlbums(query, limit: limit),
      ]);

      return {
        'tracks': futures[0] as List<Song>,
        'artists': futures[1] as List<Map<String, dynamic>>,
        'albums': futures[2] as List<Map<String, dynamic>>,
      };
    } catch (e) {
      debugPrint('Lỗi khi tìm kiếm tổng hợp: $e');
      return {
        'tracks': <Song>[],
        'artists': <Map<String, dynamic>>[],
        'albums': <Map<String, dynamic>>[],
      };
    }
  }

  // Tìm kiếm với autocomplete
  Future<List<String>> getSearchSuggestions(String query, {int limit = 5}) async {
    if (query.trim().isEmpty) return [];
    
    try {
      // Tìm kiếm tracks để lấy suggestions
      final tracks = await searchTracks(query, limit: limit);
      final suggestions = <String>[];
      
      for (final track in tracks) {
        if (!suggestions.contains(track.name)) {
          suggestions.add(track.name);
        }
        if (!suggestions.contains(track.artistName)) {
          suggestions.add(track.artistName);
        }
        
        if (suggestions.length >= limit) break;
      }
      
      return suggestions;
    } catch (e) {
      debugPrint('Lỗi khi lấy suggestions: $e');
      return [];
    }
  }

  // Tìm kiếm theo từ khóa phổ biến
  Future<List<Song>> searchByTrending(List<String> trendingKeywords, {int limit = 20}) async {
    if (trendingKeywords.isEmpty) return [];
    
    try {
      final allTracks = <Song>[];
      
      for (final keyword in trendingKeywords.take(3)) { // Chỉ lấy 3 keyword đầu
        final tracks = await searchTracks(keyword, limit: limit ~/ 3);
        allTracks.addAll(tracks);
      }
      
      // Remove duplicates
      final uniqueTracks = <String, Song>{};
      for (final track in allTracks) {
        uniqueTracks[track.id] = track;
      }
      
      return uniqueTracks.values.take(limit).toList();
    } catch (e) {
      debugPrint('Lỗi khi tìm kiếm trending: $e');
      return [];
    }
  }
}

