import 'package:flutter/foundation.dart';
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

