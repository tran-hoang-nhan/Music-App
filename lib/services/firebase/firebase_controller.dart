import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/song.dart';
import 'auth_service.dart';
import 'playlist_service.dart';
import 'favorite_service.dart';
import 'history_service.dart';

class FirebaseController extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final PlaylistService _playlistService = PlaylistService();
  final FavoriteService _favoriteService = FavoriteService();
  final HistoryService _historyService = HistoryService();

  // Getters để truy cập các service
  AuthService get auth => _authService;
  PlaylistService get playlist => _playlistService;
  FavoriteService get favorite => _favoriteService;
  HistoryService get history => _historyService;

  FirebaseController() {
    // Listen to changes from all services
    _authService.addListener(_onServiceChanged);
    _playlistService.addListener(_onServiceChanged);
    _favoriteService.addListener(_onServiceChanged);
    _historyService.addListener(_onServiceChanged);
  }

  void _onServiceChanged() {
    notifyListeners();
  }

  // Auth methods
  Future<bool> signUp(String email, String password, String name) async {
    final user = await _authService.signUp(email, password, name);
    return user != null;
  }

  Future<bool> signIn(String email, String password) async {
    final user = await _authService.signIn(email, password);
    return user != null;
  }

  Future<void> signOut() async {
    await _authService.signOut();
  }

  Future<bool> resetPassword(String email) async {
    return await _authService.resetPassword(email);
  }

  bool get isLoggedIn => _authService.isLoggedIn;
  User? get currentUser => _authService.currentUser;
  String? get currentUserId => _authService.currentUser?.uid;
  String? get currentUserName => _authService.currentUser?.displayName;
  String? get currentUserEmail => _authService.currentUser?.email;

  // Playlist methods
  Future<String?> createPlaylist(String name, String description) async {
    return await _playlistService.createPlaylist(name, description);
  }

  Future<List<Map<String, dynamic>>> getUserPlaylists() async {
    return await _playlistService.getUserPlaylists();
  }

  Future<bool> addSongToPlaylist(String playlistId, Song song) async {
    return await _playlistService.addSongToPlaylist(playlistId, song);
  }

  Future<bool> removeSongFromPlaylist(String playlistId, String songId) async {
    return await _playlistService.removeSongFromPlaylist(playlistId, songId);
  }

  Future<bool> deletePlaylist(String playlistId) async {
    return await _playlistService.deletePlaylist(playlistId);
  }

  Future<List<Song>> getPlaylistSongs(String playlistId) async {
    return await _playlistService.getPlaylistSongs(playlistId);
  }

  Future<bool> updatePlaylist(String playlistId, {String? name, String? description}) async {
    return await _playlistService.updatePlaylist(playlistId, name: name, description: description);
  }

  // Favorite methods
  Future<bool> toggleFavorite(String songId, {Song? song}) async {
    return await _favoriteService.toggleFavorite(songId, song: song);
  }

  Future<bool> isFavorite(String songId) async {
    return await _favoriteService.isFavorite(songId);
  }

  Future<List<Song>> getFavoriteSongs() async {
    return await _favoriteService.getFavoriteSongs();
  }

  Future<bool> clearAllFavorites() async {
    return await _favoriteService.clearAllFavorites();
  }

  Future<int> getFavoriteCount() async {
    return await _favoriteService.getFavoriteCount();
  }

  // History methods
  Future<void> addToListeningHistory(String songId, String songName, String artistName, {Song? song}) async {
    await _historyService.addToListeningHistory(songId, songName, artistName, song: song);
  }
  
  Future<List<Map<String, dynamic>>> getListeningHistory({int limit = 50}) async {
    return await _historyService.getListeningHistory(limit: limit);
  }

  @override
  void dispose() {
    _authService.removeListener(_onServiceChanged);
    _playlistService.removeListener(_onServiceChanged);
    _favoriteService.removeListener(_onServiceChanged);
    _historyService.removeListener(_onServiceChanged);
    
    _authService.dispose();
    _playlistService.dispose();
    _favoriteService.dispose();
    _historyService.dispose();
    
    super.dispose();
  }
}