import 'package:flutter/foundation.dart';
import '../../models/song.dart';
import '../../models/album.dart';
import '../../models/artist.dart';
import 'track_service.dart';
import 'search_service.dart';
import 'album_service.dart';
import 'artist_service.dart';
import 'genre_service.dart';

class JamendoController extends ChangeNotifier {
  final TrackService _trackService = TrackService();
  final SearchService _searchService = SearchService();
  final AlbumService _albumService = AlbumService();
  final ArtistService _artistService = ArtistService();
  final GenreService _genreService = GenreService();

  // Getters để truy cập các service
  TrackService get track => _trackService;
  SearchService get search => _searchService;
  AlbumService get album => _albumService;
  ArtistService get artist => _artistService;
  GenreService get genre => _genreService;

  JamendoController() {
    // Listen to changes from all services
    _trackService.addListener(_onServiceChanged);
    _searchService.addListener(_onServiceChanged);
    _albumService.addListener(_onServiceChanged);
    _artistService.addListener(_onServiceChanged);
    _genreService.addListener(_onServiceChanged);
  }

  void _onServiceChanged() {
    notifyListeners();
  }

  // Track methods
  Future<List<Song>> getPopularTracks({int limit = 20, int offset = 0}) async {
    return await _trackService.getPopularTracks(limit: limit, offset: offset);
  }

  Future<List<Song>> getLatestTracks({int limit = 20, int offset = 0}) async {
    return await _trackService.getLatestTracks(limit: limit, offset: offset);
  }

  Future<List<Song>> getTracksByGenre(String genre, {int limit = 20}) async {
    return await _trackService.getTracksByGenre(genre, limit: limit);
  }

  Future<List<Song>> getTracksByArtist(String artistId, {int limit = 20}) async {
    return await _trackService.getTracksByArtist(artistId, limit: limit);
  }

  Future<List<Song>> getTracksByAlbum(String albumId, {int limit = 20}) async {
    return await _trackService.getTracksByAlbum(albumId, limit: limit);
  }

  Future<List<Song>> getRandomTracks({int limit = 20}) async {
    return await _trackService.getRandomTracks(limit: limit);
  }

  Future<Song?> getTrackById(String trackId) async {
    return await _trackService.getTrackById(trackId);
  }

  // Search methods
  Future<List<Song>> searchTracks(String query, {int limit = 20}) async {
    return await _searchService.searchTracks(query, limit: limit);
  }

  Future<List<Map<String, dynamic>>> searchArtists(String query, {int limit = 20}) async {
    return await _searchService.searchArtists(query, limit: limit);
  }

  Future<List<Map<String, dynamic>>> searchAlbums(String query, {int limit = 20}) async {
    return await _searchService.searchAlbums(query, limit: limit);
  }

  Future<Map<String, dynamic>> searchAll(String query, {int limit = 10}) async {
    return await _searchService.searchAll(query, limit: limit);
  }

  Future<List<String>> getSearchSuggestions(String query, {int limit = 5}) async {
    return await _searchService.getSearchSuggestions(query, limit: limit);
  }

  Future<List<Song>> searchByTrending(List<String> trendingKeywords, {int limit = 20}) async {
    return await _searchService.searchByTrending(trendingKeywords, limit: limit);
  }

  // Album methods
  Future<List<Album>> getFeaturedAlbums({int limit = 20, int offset = 0}) async {
    return await _albumService.getFeaturedAlbums(limit: limit, offset: offset);
  }

  Future<List<Album>> getLatestAlbums({int limit = 20, int offset = 0}) async {
    return await _albumService.getLatestAlbums(limit: limit, offset: offset);
  }

  Future<List<Album>> getAlbumsByArtist(String artistId, {int limit = 20}) async {
    return await _albumService.getAlbumsByArtist(artistId, limit: limit);
  }

  Future<List<Album>> getAlbumsByGenre(String genre, {int limit = 20}) async {
    return await _albumService.getAlbumsByGenre(genre, limit: limit);
  }

  Future<Album?> getAlbumById(String albumId) async {
    return await _albumService.getAlbumById(albumId);
  }

  Future<List<Album>> getRandomAlbums({int limit = 20}) async {
    return await _albumService.getRandomAlbums(limit: limit);
  }

  // Artist methods
  Future<List<Artist>> getFeaturedArtists({int limit = 20, int offset = 0}) async {
    return await _artistService.getFeaturedArtists(limit: limit, offset: offset);
  }

  Future<List<Artist>> getLatestArtists({int limit = 20, int offset = 0}) async {
    return await _artistService.getLatestArtists(limit: limit, offset: offset);
  }

  Future<Artist?> getArtistById(String artistId) async {
    return await _artistService.getArtistById(artistId);
  }

  Future<List<Artist>> getArtistsByGenre(String genre, {int limit = 20}) async {
    return await _artistService.getArtistsByGenre(genre, limit: limit);
  }

  Future<List<Artist>> getRandomArtists({int limit = 20}) async {
    return await _artistService.getRandomArtists(limit: limit);
  }

  Future<List<Artist>> getArtistsByCountry(String country, {int limit = 20}) async {
    return await _artistService.getArtistsByCountry(country, limit: limit);
  }

  // Genre methods
  Future<List<Map<String, dynamic>>> getAllGenres() async {
    return await _genreService.getAllGenres();
  }

  Future<List<String>> getPopularGenres({int limit = 20}) async {
    return await _genreService.getPopularGenres(limit: limit);
  }

  Future<List<String>> getTrendingGenres({int limit = 10}) async {
    return await _genreService.getTrendingGenres(limit: limit);
  }

  Future<Map<String, dynamic>> getGenreStats(String genre) async {
    return await _genreService.getGenreStats(genre);
  }

  Future<List<String>> getRelatedGenres(String genre, {int limit = 5}) async {
    return await _genreService.getRelatedGenres(genre, limit: limit);
  }

  @override
  void dispose() {
    _trackService.removeListener(_onServiceChanged);
    _searchService.removeListener(_onServiceChanged);
    _albumService.removeListener(_onServiceChanged);
    _artistService.removeListener(_onServiceChanged);
    _genreService.removeListener(_onServiceChanged);
    
    _trackService.dispose();
    _searchService.dispose();
    _albumService.dispose();
    _artistService.dispose();
    _genreService.dispose();
    
    super.dispose();
  }
}

