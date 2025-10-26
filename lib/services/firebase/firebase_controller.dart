import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'auth_service.dart';
import 'playlist_service.dart';
import 'favorite_service.dart';
import 'history_service.dart';

class FirebaseController extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final PlaylistService _playlistService = PlaylistService();
  final FavoriteService _favoriteService = FavoriteService();
  final HistoryService _historyService = HistoryService();

  // Getters để truy cập các service trực tiếp
  AuthService get auth => _authService;
  PlaylistService get playlist => _playlistService;
  FavoriteService get favorite => _favoriteService;
  HistoryService get history => _historyService;

  // Convenience getters cho auth (vì dùng nhiều)
  bool get isLoggedIn => _authService.isLoggedIn;
  User? get currentUser => _authService.currentUser;
  String? get currentUserId => _authService.currentUser?.uid;
  String? get currentUserName => _authService.currentUser?.displayName;
  String? get currentUserEmail => _authService.currentUser?.email;

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