import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/song.dart';
import '../../models/album.dart';
import '../../models/artist.dart';
import '../../services/jamendo/jamendo_controller.dart';
import '../../services/firebase/firebase_controller.dart';
import '../../services/music/recommendation_service.dart';
import '../offline_banner.dart';
import 'widgets/dashboard_header.dart';
import 'widgets/featured_section.dart';
import 'widgets/recent_songs.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final JamendoController _jamendoController = JamendoController();
  final RecommendationService _recommendationService = RecommendationService();
  
  List<Song> _popularSongs = [];
  List<Song> _recommendedSongs = [];
  List<Album> _featuredAlbums = [];
  List<Artist> _featuredArtists = [];
  bool _isLoading = true;
  String _userName = 'bạn';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    if (mounted) {
      setState(() => _isLoading = true);
    }
    
    try {
      // Get user name
      final firebaseController = Provider.of<FirebaseController>(context, listen: false);
      final user = firebaseController.currentUser;
      if (user != null) {
        _userName = user.displayName ?? 'bạn';
      }

      // Load all dashboard data in parallel
      final results = await Future.wait([
        _jamendoController.getPopularTracks(limit: 12),
        _jamendoController.getFeaturedAlbums(limit: 8),
        _jamendoController.getFeaturedArtists(limit: 6),
      ]);

      final popularSongs = results[0] as List<Song>;
      final recommendedSongs = await _recommendationService.getAIRecommendations(popularSongs);

      if (mounted) {
        setState(() {
          _popularSongs = popularSongs;
          _recommendedSongs = recommendedSongs;
          _featuredAlbums = results[1] as List<Album>;
          _featuredArtists = results[2] as List<Artist>;
          _isLoading = false;
        });
        
        debugPrint('Dashboard loaded: ${_popularSongs.length} popular songs, ${_recommendedSongs.length} recommendations');
        debugPrint('Dashboard state updated successfully');
      }
    } catch (e) {
      debugPrint('Error loading dashboard data: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: SafeArea(
        child: Column(
          children: [
            const OfflineBanner(),
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(color: Color(0xFFE53E3E)),
                    )
                  : RefreshIndicator(
                      onRefresh: _loadData,
                      color: const Color(0xFFE53E3E),
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Header Section
                            DashboardHeader(userName: _userName),
                            
                            const SizedBox(height: 24),
                            
                            // Popular Songs (lên đầu)
                            RecentSongs(
                              songs: _popularSongs,
                              title: "Bài hát phổ biến",
                            ),
                            
                            const SizedBox(height: 24),
                            
                            // Recommended Songs (gợi ý cho bạn)
                            if (_recommendedSongs.isNotEmpty) ...[
                              RecentSongs(
                                songs: _recommendedSongs,
                                title: "Gợi ý cho bạn",
                              ),
                              const SizedBox(height: 24),
                            ],
                            
                            // Featured Section
                            FeaturedSection(
                              popularSongs: _popularSongs,
                              featuredAlbums: _featuredAlbums,
                              featuredArtists: _featuredArtists,
                            ),
                            
                            const SizedBox(height: 100), // Bottom padding for mini player
                          ],
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

