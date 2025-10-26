import 'package:flutter/material.dart';
import '../../models/song.dart';
import '../../models/album.dart';
import '../../models/artist.dart';
import '../../services/jamendo/jamendo_controller.dart';
import '../../services/music/recommendation_service.dart';
import '../../utils/performance_utils.dart';
import '../offline_banner.dart';
import 'widgets/dashboard_header.dart';
import 'widgets/featured_section.dart';
import 'widgets/recent_songs.dart';
import 'widgets/recommendation_songs.dart';

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
      // Load data với throttling để tránh gọi quá nhiều
      if (!PerformanceUtils.throttle(const Duration(seconds: 2))) {
        return; // Skip nếu gọi quá nhanh
      }

      // LAZY LOADING: Load từng phần thay vì tất cả cùng lúc
      
      // Step 1: Load popular songs trước (quan trọng nhất)
      final popularSongs = await _jamendoController.track.getPopularTracks(limit: 30);
      if (mounted) {
        setState(() {
          _popularSongs = popularSongs;
          _isLoading = false; // Hiển thị UI ngay với popular songs
        });
      }

      // Step 2: Load recommendations đơn giản (trong background)
      final recommendedSongs = await _recommendationService.getListeningRecommendations(popularSongs);
      if (mounted) {
        setState(() {
          _recommendedSongs = recommendedSongs;
        });
      }

      // Step 3: Load albums và artists (ít quan trọng hơn)
      final albumArtistResults = await Future.wait([
        _jamendoController.album.getFeaturedAlbums(limit: 8),
        _jamendoController.artist.getFeaturedArtists(limit: 6),
      ]);

      if (mounted) {
        setState(() {
          _featuredAlbums = albumArtistResults[0] as List<Album>;
          _featuredArtists = albumArtistResults[1] as List<Artist>;
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
                            // Dashboard Header with greeting
                            const DashboardHeader(),

                            const SizedBox(height: 24),
                            
                            // Popular Songs (lên đầu)
                            RecentSongs(
                              songs: _popularSongs,
                              title: "Bài hát phổ biến",
                            ),
                            
                            const SizedBox(height: 24),
                            
                            // Recommended Songs (gợi ý cho bạn)
                            if (_recommendedSongs.isNotEmpty) ...[
                              RecommendationSongs(
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

