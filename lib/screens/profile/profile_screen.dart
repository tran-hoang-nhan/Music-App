import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/firebase/firebase_controller.dart';
import '../library/library_screen.dart';
import '../auth/auth_screen.dart';
import 'widgets/profile_header.dart';
import 'widgets/profile_stats.dart';
import 'widgets/profile_genre_preferences.dart';
import 'widgets/profile_settings.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic>? _userProfile;
  bool _isLoading = true;
  int _playlistCount = 0;
  int _favoritesCount = 0;
  int _listenedCount = 0;
  int _artistCount = 0;
  Map<String, int> _genreCounts = {};

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    
    try {
      final firebaseController = Provider.of<FirebaseController>(context, listen: false);
      final user = firebaseController.auth.currentUser;
      if (user != null) {
        final profile = await firebaseController.auth.getUserProfile();
        if (!mounted) return;
        
        setState(() {
          _userProfile = profile;
        });
        
        _loadCounts(user.uid);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
  
  Future<void> _loadCounts(String userId) async {
    try {
      final firebaseController = Provider.of<FirebaseController>(context, listen: false);
      
      final playlistsFuture = firebaseController.playlist.getUserPlaylists();
      final favoritesFuture = firebaseController.favorite.getFavoriteSongs();
      
      final playlists = await playlistsFuture;
      final favorites = await favoritesFuture;
      
      // Cập nhật UI ngay với data cơ bản
      if (mounted) {
        setState(() {
          _playlistCount = playlists.length;
          _favoritesCount = favorites.length;
          _isLoading = false; // Hiển thị stats cơ bản trước
        });
      }
      
      // Load listening history sau (chậm hơn, có thể mất vài giây)
      final listeningHistory = await firebaseController.history.getListeningHistory(limit: 20);
      
      final Set<String> uniqueSongs = {};
      final Set<String> uniqueArtists = {};
      final Map<String, int> genreCounts = {};
      
      // Simulate genre data based on listening history
      final fallbackGenres = ['Pop', 'Electronic', 'Hip Hop', 'Jazz', 'Rock', 'Indie'];
      for (final track in listeningHistory) {
        final songId = track['songId'] as String?;
        final artistName = track['artistName'] as String?;
        
        if (songId != null) {
          uniqueSongs.add(songId);
          // Use songId hash to consistently assign genre
          final genreIndex = songId.hashCode.abs() % fallbackGenres.length;
          final genre = fallbackGenres[genreIndex];
          genreCounts[genre] = (genreCounts[genre] ?? 0) + 1;
        }
        if (artistName != null && artistName.isNotEmpty) {
          uniqueArtists.add(artistName.toLowerCase().trim());
        }
      }
      
      // Cập nhật stats chi tiết
      if (mounted) {
        setState(() {
          _listenedCount = uniqueSongs.length;
          _artistCount = uniqueArtists.length;
          _genreCounts = genreCounts;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final firebaseController = Provider.of<FirebaseController>(context, listen: false);
    final user = firebaseController.currentUser;
    
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFFE53E3E)),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const SizedBox(height: 40),
                  
                  // Profile Header
                  ProfileHeader(
                    user: user,
                    userProfile: _userProfile,
                  ),
                  
                  const SizedBox(height: 30),
                  
                  // Statistics Section
                  ProfileStats(
                    playlistCount: _playlistCount,
                    favoritesCount: _favoritesCount,
                    listenedCount: _listenedCount,
                    artistCount: _artistCount,
                    onNavigateToLibrary: _navigateToLibrary,
                  ),
                  
                  const SizedBox(height: 30),
                  
                  // Genre Preferences
                  ProfileGenrePreferences(
                    genreCounts: _genreCounts,
                  ),
                  
                  const SizedBox(height: 30),
                  
                  // Settings Section
                  ProfileSettings(
                    onSignOut: _handleSignOut,
                  ),
                  
                  const SizedBox(height: 100),
                ],
              ),
            ),
    );
  }

  void _navigateToLibrary(int tabIndex) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LibraryScreen(initialTabIndex: tabIndex),
      ),
    );
  }

  Future<void> _handleSignOut() async {
    final firebaseController = Provider.of<FirebaseController>(context, listen: false);
    await firebaseController.auth.signOut();
    if (mounted) {
      final navigator = Navigator.of(context);
      navigator.pushReplacement(
        MaterialPageRoute(builder: (context) => const AuthScreen()),
      );
    }
  }
}

