import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../../models/album.dart';

class AlbumService extends ChangeNotifier {
  static const String _baseUrl = 'https://api.jamendo.com/v3.0';
  static const String _clientId = '75f3ac34';
  static const Duration _timeout = Duration(seconds: 10);

  // Lấy album nổi bật
  Future<List<Album>> getFeaturedAlbums({int limit = 20, int offset = 0}) async {
    final url = '$_baseUrl/albums/?client_id=$_clientId&format=json&limit=$limit&offset=$offset&order=popularity_total';
    
    try {
      final response = await http.get(Uri.parse(url)).timeout(_timeout);
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

  // Lấy album mới nhất
  Future<List<Album>> getLatestAlbums({int limit = 20, int offset = 0}) async {
    final url = '$_baseUrl/albums/?client_id=$_clientId&format=json&limit=$limit&offset=$offset&order=releasedate_desc';
    
    try {
      final response = await http.get(Uri.parse(url)).timeout(_timeout);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> albums = data['results'];
        return albums.map((album) => Album.fromJson(album)).toList();
      }
    } catch (e) {
      debugPrint('Lỗi khi lấy album mới: $e');
    }
    return [];
  }

  // Lấy album theo artist ID
  Future<List<Album>> getAlbumsByArtist(String artistId, {int limit = 20}) async {
    final url = '$_baseUrl/albums/?client_id=$_clientId&format=json&limit=$limit&artist_id=$artistId';
    
    try {
      final response = await http.get(Uri.parse(url)).timeout(_timeout);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> albums = data['results'];
        return albums.map((album) => Album.fromJson(album)).toList();
      }
    } catch (e) {
      debugPrint('Lỗi khi lấy album theo artist: $e');
    }
    return [];
  }

  // Lấy album theo thể loại
  Future<List<Album>> getAlbumsByGenre(String genre, {int limit = 20}) async {
    final url = '$_baseUrl/albums/?client_id=$_clientId&format=json&limit=$limit&tags=$genre';
    
    try {
      final response = await http.get(Uri.parse(url)).timeout(_timeout);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> albums = data['results'];
        return albums.map((album) => Album.fromJson(album)).toList();
      }
    } catch (e) {
      debugPrint('Lỗi khi lấy album theo genre: $e');
    }
    return [];
  }

  // Lấy album theo ID
  Future<Album?> getAlbumById(String albumId) async {
    final url = '$_baseUrl/albums/?client_id=$_clientId&format=json&id=$albumId';
    
    try {
      final response = await http.get(Uri.parse(url)).timeout(_timeout);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> albums = data['results'];
        if (albums.isNotEmpty) {
          return Album.fromJson(albums.first);
        }
      }
    } catch (e) {
      debugPrint('Lỗi khi lấy album theo ID: $e');
    }
    return null;
  }

  // Lấy album random
  Future<List<Album>> getRandomAlbums({int limit = 20}) async {
    final url = '$_baseUrl/albums/?client_id=$_clientId&format=json&limit=$limit&order=random';
    
    try {
      final response = await http.get(Uri.parse(url)).timeout(_timeout);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> albums = data['results'];
        return albums.map((album) => Album.fromJson(album)).toList();
      }
    } catch (e) {
      debugPrint('Lỗi khi lấy album random: $e');
    }
    return [];
  }
}

