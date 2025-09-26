import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/song.dart';
import '../models/album.dart';
import '../models/artist.dart';
import '../services/jamendo_service.dart';
import '../services/music_service.dart';
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
    try {
      // Lấy tên người dùng
      final user = _firebaseService.currentUser;
      if (user != null) {
        final profile = await _firebaseService.getUserProfile(user.uid);
        _userName = profile?['name'] ?? user.displayName ?? 'bạn';
      }
      
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
          : Column(
              children: [
                const OfflineBanner(),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                  Text(
                    'Chào $_userName!',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  _buildSection('Gợi ý cho bạn', _buildSuggestedSongs()),
                  const SizedBox(height: 24),
                  
                  _buildSection('Bài nhạc phổ biến', _buildPopularSongs()),
                  const SizedBox(height: 24),
                  
                  _buildSection('Album nổi bật', _buildFeaturedAlbums()),
                  const SizedBox(height: 24),
                  
                        _buildSection('Nghệ sĩ nổi bật', _buildFeaturedArtists()),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildSection(String title, Widget content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        content,
      ],
    );
  }

  Widget _buildSuggestedSongs() {
    return FutureBuilder<List<Song>>(
      future: _recommendationService.getAIRecommendations(_popularSongs),
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
    return SongTile(
      song: song,
      playlist: _popularSongs,
      showAIBadge: true,
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
    return SongTile(
      song: song,
      playlist: _popularSongs,
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



  void _playSong(Song song) {
    final musicService = Provider.of<MusicService>(context, listen: false);
    musicService.playSong(song, playlist: _popularSongs);
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

