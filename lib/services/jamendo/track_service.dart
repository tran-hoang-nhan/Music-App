import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../../models/song.dart';

class TrackService extends ChangeNotifier {
  static const String _baseUrl = 'https://api.jamendo.com/v3.0';
  static const String _clientId = '75f3ac34';
  static const Duration _timeout = Duration(seconds: 10);

  // Lấy danh sách bài hát phổ biến
  Future<List<Song>> getPopularTracks({int limit = 20, int offset = 0}) async {
    final url = '$_baseUrl/tracks/?client_id=$_clientId&format=json&limit=$limit&offset=$offset&order=popularity_total&include=musicinfo&audioformat=mp32';
    
    try {
      final response = await http.get(Uri.parse(url)).timeout(_timeout);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> tracks = data['results'];
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
      final response = await http.get(Uri.parse(url)).timeout(_timeout);
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

  // Lấy bài hát theo artist ID
  Future<List<Song>> getTracksByArtist(String artistId, {int limit = 20}) async {
    final url = '$_baseUrl/tracks/?client_id=$_clientId&format=json&limit=$limit&artist_id=$artistId&include=musicinfo&audioformat=mp32';
    
    try {
      final response = await http.get(Uri.parse(url)).timeout(_timeout);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> tracks = data['results'];
        return tracks.map((track) => Song.fromJson(track)).toList();
      }
    } catch (e) {
      debugPrint('Lỗi khi lấy bài hát theo artist: $e');
    }
    return [];
  }

  // Lấy bài hát theo album ID
  Future<List<Song>> getTracksByAlbum(String albumId, {int limit = 20}) async {
    final url = '$_baseUrl/tracks/?client_id=$_clientId&format=json&limit=$limit&album_id=$albumId&include=musicinfo&audioformat=mp32';
    
    try {
      final response = await http.get(Uri.parse(url)).timeout(_timeout);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> tracks = data['results'];
        return tracks.map((track) => Song.fromJson(track)).toList();
      }
    } catch (e) {
      debugPrint('Lỗi khi lấy bài hát theo album: $e');
    }
    return [];
  }

  // Lấy bài hát random
  Future<List<Song>> getRandomTracks({int limit = 20}) async {
    final url = '$_baseUrl/tracks/?client_id=$_clientId&format=json&limit=$limit&order=random&include=musicinfo&audioformat=mp32';
    
    try {
      final response = await http.get(Uri.parse(url)).timeout(_timeout);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> tracks = data['results'];
        return tracks.map((track) => Song.fromJson(track)).toList();
      }
    } catch (e) {
      debugPrint('Lỗi khi lấy bài hát random: $e');
    }
    return [];
  }

  // Lấy track theo ID
  Future<Song?> getTrackById(String trackId) async {
    final url = '$_baseUrl/tracks/?client_id=$_clientId&format=json&id=$trackId&include=musicinfo&audioformat=mp32';
    
    try {
      final response = await http.get(Uri.parse(url)).timeout(_timeout);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> tracks = data['results'];
        if (tracks.isNotEmpty) {
          return Song.fromJson(tracks.first);
        }
      }
    } catch (e) {
      debugPrint('Lỗi khi lấy track theo ID: $e');
    }
    return null;
  }
}

