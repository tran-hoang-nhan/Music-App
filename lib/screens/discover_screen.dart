import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:async';
import '../models/song.dart';
import '../models/album.dart';
import '../models/artist.dart';
import '../services/jamendo_service.dart';
import '../services/music_service.dart';
import '../widgets/offline_banner.dart';
import '../widgets/song_tile.dart';
import 'album_detail_screen.dart';
import 'artist_detail_screen.dart';

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
  
  Map<String, List<Song>> _genreSongs = {};
  List<Album> _featuredAlbums = [];
  List<Artist> _featuredArtists = [];
  List<Song> _searchResults = [];
  bool _isLoading = true;
  bool _isSearching = false;

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
      print('Lỗi tải dữ liệu khám phá: $e');
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
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: _genreSongs.entries.map((entry) {
          final genre = entry.key;
          final songs = entry.value;
          
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                genre.toUpperCase(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 300,
                child: ListView.builder(
                  itemCount: songs.length,
                  itemBuilder: (context, index) {
                    final song = songs[index];
                    return SongTile(
                      song: song,
                      playlist: songs,
                      index: index,
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),
            ],
          );
        }).toList(),
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
                placeholder: (_, __) => Container(
                  color: const Color(0xFF1E1E1E),
                  child: const Center(
                    child: Icon(Icons.album, color: Colors.grey, size: 40),
                  ),
                ),
                errorWidget: (_, __, ___) => Container(
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
              child: CachedNetworkImage(
                imageUrl: artist.image,
                width: double.infinity,
                fit: BoxFit.cover,
                placeholder: (_, __) => Container(
                  color: const Color(0xFF1E1E1E),
                  child: const Center(
                    child: Icon(Icons.person, color: Colors.grey, size: 40),
                  ),
                ),
                errorWidget: (_, __, ___) => Container(
                  color: const Color(0xFF1E1E1E),
                  child: const Center(
                    child: Icon(Icons.person, color: Colors.grey, size: 40),
                  ),
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

  void _playSong(Song song, List<Song> playlist, int index) {
    final musicService = Provider.of<MusicService>(context, listen: false);
    musicService.playSong(song, playlist: playlist, index: index);
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
      print('Lỗi tìm kiếm: $e');
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

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }
}