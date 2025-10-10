import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/song.dart';
import '../models/album.dart';
import '../models/artist.dart';
import '../services/jamendo_service.dart';
import '../services/recommendation_service.dart';
import '../services/firebase_service.dart';
import '../widgets/offline_banner.dart';
import '../widgets/song_tile.dart';
import 'ai_chat_screen.dart';
import 'album_detail_screen.dart';
import 'artist_detail_screen.dart';


class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final JamendoService _jamendoService = JamendoService();
  final RecommendationService _recommendationService = RecommendationService();
  final FirebaseService _firebaseService = FirebaseService();
  List<Song> _popularSongs = [];
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
      // Lấy tên người dùng
      final user = _firebaseService.currentUser;
      if (user != null) {
        final profile = await _firebaseService.getUserProfile(user.uid);
        _userName = profile?['name'] ?? user.displayName ?? 'bạn';
      }
      
      // Load tất cả dữ liệu song song để tăng tốc với timeout
      final results = await Future.wait([
        _jamendoService.getPopularTracks(limit: 12),
        _jamendoService.getFeaturedAlbums(limit: 8),
        _jamendoService.getFeaturedArtists(limit: 8),
      ]).timeout(
        const Duration(seconds: 15),
        onTimeout: () {
          debugPrint('Dashboard load timeout!');
          return [<Song>[], <Album>[], <Artist>[]];
        },
      );
      
      debugPrint('Dashboard loaded: ${results[0].length} songs, ${results[1].length} albums, ${results[2].length} artists');
      
      if (mounted) {
        setState(() {
          _popularSongs = results[0] as List<Song>;
          _featuredAlbums = results[1] as List<Album>;
          _featuredArtists = results[2] as List<Artist>;
          _isLoading = false;
        });
        
        debugPrint('Dashboard state updated successfully');
      }
      
    } catch (e) {
      debugPrint('Lỗi load dashboard: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFFE53E3E)),
            )
          : RefreshIndicator(
              onRefresh: _loadData,
              color: const Color(0xFFE53E3E),
              child: CustomScrollView(
                slivers: [
                  _buildAppBar(),
                  const SliverToBoxAdapter(child: OfflineBanner()),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                        const SizedBox(height: 20),
                        _buildSuggestedSongs(),
                        const SizedBox(height: 30),
                        _buildTrendingNow(),
                        const SizedBox(height: 30),
                        _buildFeaturedAlbums(),
                        const SizedBox(height: 30),
                        _buildPopularArtists(),
                        const SizedBox(height: 100),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 80.0,
      floating: false,
      pinned: true,
      backgroundColor: const Color(0xFF0A0A0A),
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFFE53E3E), Color(0xFF0A0A0A)],
            ),
          ),
        ),
      ),
      title: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: const Color(0xFFE53E3E),
            child: Text(
              _userName.isNotEmpty ? _userName[0].toUpperCase() : 'U',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            'Chào $_userName!',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AIChatScreen()),
            );
          },
          icon: const Icon(Icons.smart_toy, color: Color(0xFFE53E3E)),
          tooltip: 'AI Assistant',
        ),
      ],
    );
  }

  Widget _buildSuggestedSongs() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Gợi ý cho bạn',
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFE53E3E).withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE53E3E).withValues(alpha: 0.3)),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.smart_toy, color: Color(0xFFE53E3E), size: 14),
                  SizedBox(width: 4),
                  Text(
                    'AI',
                    style: TextStyle(
                      color: Color(0xFFE53E3E),
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        FutureBuilder<List<Song>>(
          future: _recommendationService.getAIRecommendations(_popularSongs),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Column(
                children: List.generate(3, (index) => Container(
                  height: 80,
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFFE53E3E),
                      strokeWidth: 2,
                    ),
                  ),
                )),
              );
            }

            final recommendedSongs = snapshot.data ?? _popularSongs.take(6).toList();

            return SizedBox(
              height: 300,
              child: ListView.builder(
                itemCount: recommendedSongs.length,
                itemBuilder: (context, index) {
                  final song = recommendedSongs[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: SongTile(
                      song: song,
                      playlist: recommendedSongs,
                      showAIBadge: true,
                    ),
                  );
                },
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildTrendingNow() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Xu hướng hiện tại',
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        // Debug info  
        if (_popularSongs.isEmpty)
          Container(
            height: 100,
            child: const Center(
              child: Text(
                'Đang tải bài hát...',
                style: TextStyle(color: Colors.grey),
              ),
            ),
          )
        else
          SizedBox(
            height: 300,
            child: ListView.builder(
              itemCount: _popularSongs.take(8).length,
              itemBuilder: (context, index) {
                final song = _popularSongs[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: SongTile(
                    song: song,
                    playlist: _popularSongs,
                  ),
                );
              },
          ),
        ),
      ],
    );
  }

  Widget _buildFeaturedAlbums() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Album nổi bật',
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        // Debug info
        if (_featuredAlbums.isEmpty)
          Container(
            height: 100,
            child: const Center(
              child: Text(
                'Đang tải album...',
                style: TextStyle(color: Colors.grey),
              ),
            ),
          )
        else
          SizedBox(
            height: 220,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _featuredAlbums.length,
              itemBuilder: (context, index) {
                final album = _featuredAlbums[index];
                return _buildFeaturedAlbumCard(album);
              },
            ),
          ),
      ],
    );
  }

  Widget _buildFeaturedAlbumCard(Album album) {
    return GestureDetector(
      onTap: () => _navigateToAlbum(album),
      child: Container(
        width: 160,
        margin: const EdgeInsets.only(right: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Hero(
              tag: 'album_${album.id}',
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Stack(
                  children: [
                    CachedNetworkImage(
                      imageUrl: album.image,
                      width: 160,
                      height: 160,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        width: 160,
                        height: 160,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE53E3E),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(Icons.album, color: Colors.white, size: 40),
                      ),
                    ),
                    Container(
                      width: 160,
                      height: 160,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withValues(alpha: 0.7),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 12,
                      right: 12,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(
                          color: Color(0xFFE53E3E),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.play_arrow, color: Colors.white, size: 20),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              album.name,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              album.artistName,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.7),
                fontSize: 12,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPopularArtists() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Nghệ sĩ nổi bật',
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 180,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _featuredArtists.length,
            itemBuilder: (context, index) {
              final artist = _featuredArtists[index];
              return _buildArtistCard(artist);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildArtistCard(Artist artist) {
    return GestureDetector(
      onTap: () => _navigateToArtist(artist),
      child: Container(
        width: 140,
        margin: const EdgeInsets.only(right: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFFE53E3E).withValues(alpha: 0.8),
                    const Color(0xFFE53E3E),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFE53E3E).withValues(alpha: 0.4),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: ClipOval(
                child: artist.image.isNotEmpty && artist.image.contains('jamendo.com')
                    ? CachedNetworkImage(
                        imageUrl: artist.image,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          decoration: const BoxDecoration(
                            color: Color(0xFFE53E3E),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.person, color: Colors.white, size: 40),
                        ),
                        errorWidget: (context, url, error) => Container(
                          decoration: const BoxDecoration(
                            color: Color(0xFFE53E3E),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.person, color: Colors.white, size: 40),
                        ),
                      )
                    : Container(
                        decoration: const BoxDecoration(
                          color: Color(0xFFE53E3E),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.person, color: Colors.white, size: 40),
                      ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              artist.name,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              'Nghệ sĩ',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.7),
                fontSize: 12,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }


  void _navigateToAlbum(Album album) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AlbumDetailScreen(album: album),
      ),
    );
  }

  void _navigateToArtist(Artist artist) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ArtistDetailScreen(artist: artist),
      ),
    );
  }


}
