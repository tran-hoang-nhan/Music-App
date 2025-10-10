import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:async';
import '../models/song.dart';
import '../models/album.dart';
import '../models/artist.dart';
import '../services/jamendo_service.dart';
import '../widgets/offline_banner.dart';
import '../widgets/song_tile.dart';
import 'album_detail_screen.dart';
import 'artist_detail_screen.dart';
import 'genre_detail_screen.dart';

// Genre Data Model for beautiful cards
class GenreData {
  final String name;
  final String displayName;
  final String emoji;
  final List<Color> gradientColors;

  const GenreData({
    required this.name,
    required this.displayName,
    required this.emoji,
    required this.gradientColors,
  });
}

class DiscoverScreen extends StatefulWidget {
  final int? initialTabIndex;
  const DiscoverScreen({super.key, this.initialTabIndex});

  @override
  State<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends State<DiscoverScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final JamendoService _jamendoService = JamendoService();
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounceTimer;
  
  final Map<String, List<Song>> _genreSongs = {};
  List<Album> _featuredAlbums = [];
  List<Artist> _featuredArtists = [];
  List<Song> _searchResults = [];
  bool _isLoading = true;
  bool _isSearching = false;

  // Genre definitions với colors và emojis như trong hình
  static const List<GenreData> _genres = [
    GenreData(
      name: 'pop',
      displayName: 'Pop',
      emoji: '🎵',
      gradientColors: [Color(0xFFFF1744), Color(0xFFE91E63)],
    ),
    GenreData(
      name: 'rock',
      displayName: 'Rock', 
      emoji: '🎸',
      gradientColors: [Color(0xFFE53E3E), Color(0xFFD32F2F)],
    ),
    GenreData(
      name: 'hiphop',
      displayName: 'Hip Hop',
      emoji: '🎤',
      gradientColors: [Color(0xFFFF9800), Color(0xFFF57C00)],
    ),
    GenreData(
      name: 'electronic',
      displayName: 'Electronic',
      emoji: '🎹',
      gradientColors: [Color(0xFF00BCD4), Color(0xFF0097A7)],
    ),
    GenreData(
      name: 'jazz',
      displayName: 'Jazz',
      emoji: '🎺',
      gradientColors: [Color(0xFF9C27B0), Color(0xFF7B1FA2)],
    ),
    GenreData(
      name: 'classical',
      displayName: 'Classical',
      emoji: '🎻',
      gradientColors: [Color(0xFF4CAF50), Color(0xFF388E3C)],
    ),
    GenreData(
      name: 'rnb',
      displayName: 'R&B',
      emoji: '🎙️',
      gradientColors: [Color(0xFFE91E63), Color(0xFFAD1457)],
    ),
    GenreData(
      name: 'country',
      displayName: 'Country',
      emoji: '🤠',
      gradientColors: [Color(0xFFFF5722), Color(0xFFE64A19)],
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 3, 
      vsync: this,
      initialIndex: widget.initialTabIndex ?? 0,
    );
    _loadData();
  }

  Future<void> _loadData() async {
    if (mounted) {
      setState(() => _isLoading = true);
    }
    
    try {
      final results = await Future.wait([
        _jamendoService.getTracksByGenre('rock', limit: 8),
        _jamendoService.getTracksByGenre('pop', limit: 8), 
        _jamendoService.getTracksByGenre('jazz', limit: 8),
        _jamendoService.getFeaturedAlbums(limit: 12),
        _jamendoService.getFeaturedArtists(limit: 12),
      ]);
      
      if (mounted) {
        _genreSongs['rock'] = results[0] as List<Song>;
        _genreSongs['pop'] = results[1] as List<Song>;
        _genreSongs['jazz'] = results[2] as List<Song>;
        _featuredAlbums = results[3] as List<Album>;
        _featuredArtists = results[4] as List<Artist>;
        
        setState(() => _isLoading = false);
      }
    } catch (e) {
      debugPrint('Lỗi tải dữ liệu khám phá: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: const Text('Khám phá'),
        backgroundColor: const Color(0xFF121212),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: const Color(0xFFE53E3E),
          indicatorSize: TabBarIndicatorSize.tab,
          labelColor: const Color(0xFFE53E3E),
          unselectedLabelColor: Colors.grey,
          tabs: const [
            Tab(text: 'Thể loại'),
            Tab(text: 'Album'),
            Tab(text: 'Nghệ sĩ'),
          ],
        ),
      ),
      body: Column(
        children: [
          const OfflineBanner(),
          // Thanh tìm kiếm
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Tìm bài hát, album, nghệ sĩ...',
                hintStyle: const TextStyle(color: Colors.grey),
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: Colors.grey),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _searchResults.clear();
                            _isSearching = false;
                          });
                        },
                      )
                    : null,
                filled: true,
                fillColor: const Color(0xFF1E1E1E),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: _onSearchChanged,
            ),
          ),
          
          // Nội dung
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: Color(0xFFE53E3E)),
                  )
                : _isSearching
                    ? _buildSearchResults()
                    : TabBarView(
                        controller: _tabController,
                        // Cải thiện hiệu suất với lazy loading
                        physics: const BouncingScrollPhysics(),
                        children: [
                          _buildGenresTab(),
                          _buildAlbumsTab(),
                          _buildArtistsTab(),
                        ],
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildGenresTab() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: GridView.builder(
        // Cải thiện hiệu suất
        cacheExtent: 500,
        physics: const BouncingScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1.5,
        ),
        itemCount: _genres.length,
        itemBuilder: (context, index) {
          final genre = _genres[index];
          return _buildGenreCard(genre);
        },
      ),
    );
  }

  Widget _buildGenreCard(GenreData genre) {
    return GestureDetector(
      onTap: () => _playGenre(genre.name),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: genre.gradientColors,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: genre.gradientColors.first.withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    genre.emoji,
                    style: const TextStyle(fontSize: 28),
                  ),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(
                      Icons.play_arrow,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Text(
                genre.displayName,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAlbumsTab() {
    if (_featuredAlbums.isEmpty) {
      return const Center(
        child: Text('Không có album nào', style: TextStyle(color: Colors.grey)),
      );
    }
    
    return GridView.builder(
      // Cải thiện hiệu suất
      cacheExtent: 500,
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(12),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.8,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: _featuredAlbums.length,
      itemBuilder: (context, index) {
        final album = _featuredAlbums[index];
        return _buildAlbumCard(album);
      },
    );
  }

  Widget _buildArtistsTab() {
    if (_featuredArtists.isEmpty) {
      return const Center(
        child: Text('Không có nghệ sĩ nào', style: TextStyle(color: Colors.grey)),
      );
    }
    
    return GridView.builder(
      // Cải thiện hiệu suất
      cacheExtent: 500,
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(12),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.9,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: _featuredArtists.length,
      itemBuilder: (context, index) {
        final artist = _featuredArtists[index];
        return _buildArtistCard(artist);
      },
    );
  }



  Widget _buildAlbumCard(Album album) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => AlbumDetailScreen(album: album)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: CachedNetworkImage(
                imageUrl: album.image,
                width: double.infinity,
                fit: BoxFit.cover,
                // Tối ưu hiệu suất
                memCacheWidth: 200,
                memCacheHeight: 200,
                fadeInDuration: const Duration(milliseconds: 200),
                placeholder: (_, _) => Container(
                  color: const Color(0xFF1E1E1E),
                  child: const Center(
                    child: Icon(Icons.album, color: Colors.grey, size: 40),
                  ),
                ),
                errorWidget: (_, _, _) => Container(
                  color: const Color(0xFF1E1E1E),
                  child: const Center(
                    child: Icon(Icons.album, color: Colors.grey, size: 40),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            album.name,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            album.artistName,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 10,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildArtistCard(Artist artist) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => ArtistDetailScreen(artist: artist)),
      ),
      child: Column(
        children: [
          Expanded(
            child: ClipOval(
              child: artist.image.isNotEmpty && artist.image.contains('jamendo.com')
                  ? CachedNetworkImage(
                      imageUrl: artist.image,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      // Tối ưu hiệu suất
                      memCacheWidth: 150,
                      memCacheHeight: 150,
                      fadeInDuration: const Duration(milliseconds: 200),
                      placeholder: (_, _) => Container(
                        color: const Color(0xFF1E1E1E),
                        child: const Center(
                          child: Icon(Icons.person, color: Colors.grey, size: 40),
                        ),
                      ),
                      errorWidget: (_, _, _) => Container(
                        color: const Color(0xFF1E1E1E),
                        child: const Center(
                          child: Icon(Icons.person, color: Colors.grey, size: 40),
                        ),
                      ),
                    )
                  : Container(
                      color: const Color(0xFF1E1E1E),
                      child: const Center(
                        child: Icon(Icons.person, color: Colors.grey, size: 40),
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            artist.name,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }



  void _onSearchChanged(String query) {
    setState(() {});
    _debounceTimer?.cancel();
    
    if (query.trim().isEmpty) {
      setState(() {
        _searchResults.clear();
        _isSearching = false;
      });
      return;
    }
    
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      _searchSongs(query);
    });
  }

  Future<void> _searchSongs(String query) async {
    setState(() => _isSearching = true);
    
    try {
      final results = await _jamendoService.searchTracks(query.trim());
      if (mounted) {
        setState(() {
          _searchResults = results;
        });
      }
    } catch (e) {
      debugPrint('Lỗi tìm kiếm: $e');
      if (mounted) {
        setState(() => _isSearching = false);
      }
    }
  }

  Widget _buildSearchResults() {
    if (_searchResults.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Không tìm thấy kết quả',
              style: TextStyle(color: Colors.grey, fontSize: 18),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        final song = _searchResults[index];
        return SongTile(
          song: song,
          playlist: _searchResults,
          index: index,
        );
      },
    );
  }

  void _playGenre(String genreName) {
    // Tìm genre data
    final genre = _genres.firstWhere((g) => g.name == genreName);
    
    // Điều hướng đến trang chi tiết thể loại
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GenreDetailScreen(
          genreName: genre.name,
          displayName: genre.displayName,
          emoji: genre.emoji,
          gradientColors: genre.gradientColors,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }
}