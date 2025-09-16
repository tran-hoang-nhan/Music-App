import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/song.dart';
import '../services/jamendo_service.dart';
import '../services/music_service.dart';
import '../services/firebase_service.dart';
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
  List<Song> _popularSongs = [];
  List<Album> _featuredAlbums = [];
  List<Artist> _featuredArtists = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final results = await Future.wait([
        _jamendoService.getPopularTracks(limit: 20),
        _jamendoService.getFeaturedAlbums(limit: 15),
        _jamendoService.getFeaturedArtists(limit: 15),
      ]);
      
      setState(() {
        _popularSongs = results[0] as List<Song>;
        _featuredAlbums = results[1] as List<Album>;
        _featuredArtists = results[2] as List<Artist>;
        _isLoading = false;
      });
      

    } catch (e) {
      print('Lỗi tải dữ liệu: $e');
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: const Text('Ứng dụng Âm nhạc'),
        backgroundColor: const Color(0xFF121212),
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
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFFE53E3E)),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Chào buổi tối!',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  _buildSection('Gợi ý cho bạn', _buildSuggestedSongs(), onSeeAll: () => _navigateToDiscover(0)),
                  const SizedBox(height: 24),
                  
                  _buildSection('Bài nhạc phổ biến', _buildPopularSongs()),
                  const SizedBox(height: 24),
                  
                  _buildSection('Album nổi bật', _buildFeaturedAlbums(), onSeeAll: () => _navigateToDiscover(1)),
                  const SizedBox(height: 24),
                  
                  _buildSection('Nghệ sĩ nổi bật', _buildFeaturedArtists(), onSeeAll: () => _navigateToDiscover(2)),
                ],
              ),
            ),
    );
  }

  Widget _buildSection(String title, Widget content, {VoidCallback? onSeeAll}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (onSeeAll != null)
              TextButton(
                onPressed: onSeeAll,
                child: const Text(
                  'Xem tất cả',
                  style: TextStyle(color: Color(0xFFE53E3E)),
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),
        content,
      ],
    );
  }

  Widget _buildSuggestedSongs() {
    return FutureBuilder<List<Song>>(
      future: _getAIRecommendations(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(
            height: 300,
            child: Center(child: CircularProgressIndicator(color: Color(0xFFE53E3E))),
          );
        }
        
        final suggested = snapshot.data ?? [];
        if (suggested.isEmpty) {
          return SizedBox(
            height: 300,
            child: ListView.builder(
              itemCount: _popularSongs.take(5).length,
              itemBuilder: (context, index) {
                final song = _popularSongs[index];
                return _buildSuggestedTile(song);
              },
            ),
          );
        }
        
        return SizedBox(
          height: 300,
          child: ListView.builder(
            itemCount: suggested.length,
            itemBuilder: (context, index) {
              final song = suggested[index];
              return _buildSuggestedTile(song);
            },
          ),
        );
      },
    );
  }

  Widget _buildSuggestedTile(Song song) {
    return ListTile(
      leading: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: CachedNetworkImage(
              imageUrl: song.albumImage,
              width: 50,
              height: 50,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                width: 50,
                height: 50,
                color: const Color(0xFFE53E3E),
                child: const Icon(Icons.music_note, color: Colors.white),
              ),
              errorWidget: (context, url, error) => Container(
                width: 50,
                height: 50,
                color: const Color(0xFFE53E3E),
                child: const Icon(Icons.music_note, color: Colors.white),
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: const Color(0xFFE53E3E),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Icon(
                Icons.auto_awesome,
                color: Colors.white,
                size: 10,
              ),
            ),
          ),
        ],
      ),
      title: Text(
        song.name,
        style: const TextStyle(color: Colors.white),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        song.artistName,
        style: const TextStyle(color: Colors.grey),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Text(
        song.formattedDuration,
        style: const TextStyle(color: Colors.grey, fontSize: 12),
      ),
      onTap: () => _playSong(song),
    );
  }

  Widget _buildPopularSongs() {
    return SizedBox(
      height: 300,
      child: ListView.builder(
        itemCount: _popularSongs.length,
        itemBuilder: (context, index) {
          final song = _popularSongs[index];
          return _buildSongTile(song);
        },
      ),
    );
  }

  Widget _buildSongTile(Song song) {
    return ListTile(
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: song.albumImage.isNotEmpty
            ? CachedNetworkImage(
                imageUrl: song.albumImage,
                width: 50,
                height: 50,
                fit: BoxFit.cover,
                placeholder: (_, __) => const _PlaceholderImage(),
                errorWidget: (_, __, ___) => const _PlaceholderImage(),
                memCacheWidth: 100,
                memCacheHeight: 100,
              )
            : const _PlaceholderImage(),
      ),
      title: Text(
        song.name,
        style: const TextStyle(color: Colors.white),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        song.artistName,
        style: const TextStyle(color: Colors.grey),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Text(
        song.formattedDuration,
        style: const TextStyle(color: Colors.grey, fontSize: 12),
      ),
      onTap: () => _playSong(song),
    );
  }

  Widget _buildFeaturedAlbums() {
    return SizedBox(
      height: 160,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _featuredAlbums.length,
        itemBuilder: (context, index) {
          final album = _featuredAlbums[index];
          return GestureDetector(
            onTap: () => _navigateToAlbum(album),
            child: Container(
              width: 120,
              margin: const EdgeInsets.only(right: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Hero(
                    tag: 'album_${album.id}',
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: CachedNetworkImage(
                        imageUrl: album.image,
                        width: 120,
                        height: 120,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          width: 120,
                          height: 120,
                          color: const Color(0xFFE53E3E),
                          child: const Icon(Icons.album, color: Colors.white, size: 30),
                        ),
                        errorWidget: (context, url, error) => Container(
                          width: 120,
                          height: 120,
                          color: const Color(0xFFE53E3E),
                          child: const Icon(Icons.album, color: Colors.white, size: 30),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Flexible(
                    child: Text(
                      album.name,
                      style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Flexible(
                    child: Text(
                      album.artistName,
                      style: const TextStyle(color: Colors.grey, fontSize: 10),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFeaturedArtists() {
    return SizedBox(
      height: 160,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _featuredArtists.length,
        itemBuilder: (context, index) {
          final artist = _featuredArtists[index];
          return GestureDetector(
            onTap: () => _navigateToArtist(artist),
            child: Container(
              width: 120,
              margin: const EdgeInsets.only(right: 12),
              child: Column(
                children: [
                  Hero(
                    tag: 'artist_${artist.id}',
                    child: ClipOval(
                      child: CachedNetworkImage(
                        imageUrl: artist.image,
                        width: 120,
                        height: 120,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          width: 120,
                          height: 120,
                          color: const Color(0xFFE53E3E),
                          child: const Icon(Icons.person, color: Colors.white, size: 30),
                        ),
                        errorWidget: (context, url, error) => Container(
                          width: 120,
                          height: 120,
                          color: const Color(0xFFE53E3E),
                          child: const Icon(Icons.person, color: Colors.white, size: 30),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Flexible(
                    child: Text(
                      artist.name,
                      style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // AI Recommendation Algorithm dựa trên lịch sử nghe
  Future<List<Song>> _getAIRecommendations() async {
    if (_popularSongs.isEmpty) return [];
    
    try {
      // Lấy lịch sử nghe gần đây
      final firebaseService = FirebaseService();
      final recentHistory = await firebaseService.getListeningHistory(limit: 20);
      
      final recommendations = <Song>[];
      final recentGenres = <String>{};
      final recentArtists = <String>{};
      
      // Phân tích lịch sử nghe để tìm pattern
      for (final item in recentHistory) {
        final songId = item['songId']?.toString();
        if (songId != null) {
          // Tìm bài hát trong popular để lấy thông tin
          final recentSong = _popularSongs.where((s) => s.id == songId).firstOrNull;
          if (recentSong != null) {
            recentGenres.addAll(recentSong.tags);
            recentArtists.add(recentSong.artistName);
          }
        }
      }
      
      // Nếu không có lịch sử, dùng thuật toán cũ
      if (recentGenres.isEmpty) {
        return _getBasicRecommendations();
      }
      
      // Chọn bài hát dựa trên AI scoring với lịch sử
      for (final song in _popularSongs) {
        double score = 0;
        
        // Điểm thể loại từ lịch sử (50%)
        final matchingGenres = song.tags.where((tag) => recentGenres.contains(tag)).length;
        if (recentGenres.isNotEmpty) {
          score += (matchingGenres / recentGenres.length) * 0.5;
        }
        
        // Điểm nghệ sĩ từ lịch sử (30%)
        if (recentArtists.contains(song.artistName)) {
          score += 0.3;
        }
        
        // Điểm đa dạng (20%)
        score += (song.id.hashCode % 100) / 100 * 0.2;
        
        if (score > 0.4) {
          recommendations.add(song);
        }
      }
      
      recommendations.shuffle();
      return recommendations.take(8).toList();
      
    } catch (e) {
      print('Lỗi AI recommendations: $e');
      return _getBasicRecommendations();
    }
  }
  
  List<Song> _getBasicRecommendations() {
    final recommendations = <Song>[];
    final genres = <String>{};
    
    for (final song in _popularSongs) {
      genres.addAll(song.tags);
    }
    
    for (final song in _popularSongs) {
      double score = (song.id.hashCode % 100) / 100;
      if (score > 0.5) {
        recommendations.add(song);
      }
    }
    
    recommendations.shuffle();
    return recommendations.take(8).toList();
  }

  void _playSong(Song song) {
    final musicService = Provider.of<MusicService>(context, listen: false);
    musicService.playSong(song, playlist: _popularSongs);
  }

  void _navigateToDiscover(int tabIndex) {
    // Find the MainScreen and switch to discover tab
    final mainScreenState = context.findAncestorStateOfType();
    if (mainScreenState != null) {
      (mainScreenState as dynamic).switchToTab(1);
    }
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

class _PlaceholderImage extends StatelessWidget {
  const _PlaceholderImage();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 50,
      height: 50,
      color: const Color(0xFFE53E3E),
      child: const Icon(Icons.music_note, color: Colors.white),
    );
  }
}