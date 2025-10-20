import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../../models/artist.dart';

class ArtistService extends ChangeNotifier {
  static const String _baseUrl = 'https://api.jamendo.com/v3.0';
  static const String _clientId = '75f3ac34';
  static const Duration _timeout = Duration(seconds: 10);

  // Lấy artist nổi bật
  Future<List<Artist>> getFeaturedArtists({int limit = 20, int offset = 0}) async {
    final url = '$_baseUrl/artists/?client_id=$_clientId&format=json&limit=$limit&offset=$offset&order=popularity_total';
    
    try {
      final response = await http.get(Uri.parse(url)).timeout(_timeout);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> artists = data['results'];
        return artists.map((artist) => Artist.fromJson(artist)).toList();
      }
    } catch (e) {
      debugPrint('Lỗi khi lấy artist nổi bật: $e');
    }
    return [];
  }

  // Lấy artist mới
  Future<List<Artist>> getLatestArtists({int limit = 20, int offset = 0}) async {
    final url = '$_baseUrl/artists/?client_id=$_clientId&format=json&limit=$limit&offset=$offset&order=joindate_desc';
    
    try {
      final response = await http.get(Uri.parse(url)).timeout(_timeout);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> artists = data['results'];
        return artists.map((artist) => Artist.fromJson(artist)).toList();
      }
    } catch (e) {
      debugPrint('Lỗi khi lấy artist mới: $e');
    }
    return [];
  }

  // Lấy artist theo ID  
  Future<Artist?> getArtistById(String artistId) async {
    final url = '$_baseUrl/artists/?client_id=$_clientId&format=json&id=$artistId';
    
    try {
      final response = await http.get(Uri.parse(url)).timeout(_timeout);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> artists = data['results'];
        if (artists.isNotEmpty) {
          return Artist.fromJson(artists.first);
        }
      }
    } catch (e) {
      debugPrint('Lỗi khi lấy artist theo ID: $e');
    }
    return null;
  }

  // Lấy artist theo thể loại
  Future<List<Artist>> getArtistsByGenre(String genre, {int limit = 20}) async {
    final url = '$_baseUrl/artists/?client_id=$_clientId&format=json&limit=$limit&tags=$genre';
    
    try {
      final response = await http.get(Uri.parse(url)).timeout(_timeout);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> artists = data['results'];
        return artists.map((artist) => Artist.fromJson(artist)).toList();
      }
    } catch (e) {
      debugPrint('Lỗi khi lấy artist theo genre: $e');
    }
    return [];
  }

  // Lấy artist random
  Future<List<Artist>> getRandomArtists({int limit = 20}) async {
    final url = '$_baseUrl/artists/?client_id=$_clientId&format=json&limit=$limit&order=random';
    
    try {
      final response = await http.get(Uri.parse(url)).timeout(_timeout);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> artists = data['results'];
        return artists.map((artist) => Artist.fromJson(artist)).toList();
      }
    } catch (e) {
      debugPrint('Lỗi khi lấy artist random: $e');
    }
    return [];
  }

  // Lấy top artists theo quốc gia
  Future<List<Artist>> getArtistsByCountry(String country, {int limit = 20}) async {
    final url = '$_baseUrl/artists/?client_id=$_clientId&format=json&limit=$limit&country=$country&order=popularity_total';
    
    try {
      final response = await http.get(Uri.parse(url)).timeout(_timeout);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> artists = data['results'];
        return artists.map((artist) => Artist.fromJson(artist)).toList();
      }
    } catch (e) {
      debugPrint('Lỗi khi lấy artist theo country: $e');
    }
    return [];
  }
}

