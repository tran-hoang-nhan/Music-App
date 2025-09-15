import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:async';
import '../models/song.dart';
import '../services/jamendo_service.dart';
import '../services/music_service.dart';
import '../services/cache_service.dart';
import 'player_screen.dart';

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

  final List<String> _genres = [
    'rock', 'pop', 'jazz', 'classical', 'electronic', 
    'folk', 'blues', 'reggae', 'country', 'metal'
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
    setState(() => _isLoading = true);
    
    try {
      // Kiểm tra cache trước
      final cachedGenres = await CacheService.getCachedSongs('discover_genres');
      if (cachedGenres != null) {
        // Chia cache theo genre
        for (String genre in _genres.take(3)) {
          _genreSongs[genre] = cachedGenres.where((s) => 
            s.tags.any((tag) => tag.toLowerCase() == genre.toLowerCase())
          ).take(8).toList();
        }
        setState(() => _isLoading = false);
        return;
      }
      
      // Tải song song (parallel)
      final futures = <Future>[];
      
      // Tải 3 genre đầu tiên thay vì 5
      for (String genre in _genres.take(3)) {
        futures.add(_jamendoService.getTracksByGenre(genre, limit: 8));
      }
      
      futures.addAll([
        _jamendoService.getAlbums(limit: 8),
        _jamendoService.getArtists(limit: 8),
      ]);
      
      final results = await Future.wait(futures);
      
      // Xử lý kết quả
      for (int i = 0; i < 3; i++) {
        _genreSongs[_genres[i]] = results[i] as List<Song>;
      }
      
      _featuredAlbums = results[3] as List<Album>;
      _featuredArtists = results[4] as List<Artist>;
      
      // Cache kết quả
      final allSongs = _genreSongs.values.expand((songs) => songs).toList();
      await CacheService.cacheSongs('discover_genres', allSongs);
      
      setState(() => _isLoading = false);
    } catch (e) {
      print('Lỗi tải dữ liệu khám phá: $e');
      setState(() => _isLoading = false);
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    genre.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton(
                    onPressed: () => _showAllSongs(genre, songs),
                    child: const Text(
                      'Xem tất cả',
                      style: TextStyle(color: Color(0xFFE53E3E)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 180,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: songs.length,
                  itemBuilder: (context, index) {
                    final song = songs[index];
                    return _buildSongCard(song, songs, index);
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
    return GridView.builder(
      padding: const EdgeInsets.all(12),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
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
    return GridView.builder(
      padding: const EdgeInsets.all(12),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
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

  Widget _buildSongCard(Song song, List<Song> playlist, int index) {
    return GestureDetector(
      onTap: () => _playSong(song, playlist, index),
      child: Container(
        width: 160,
        margin: const EdgeInsets.only(right: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: CachedNetworkImage(
                imageUrl: song.albumImage,
                width: 160,
                height: 120,
                fit: BoxFit.cover,
                placeholder: (_, __) => Container(
                  width: 160,
                  height: 120,
                  color: const Color(0xFF1E1E1E),
                  child: const Center(
                    child: Icon(Icons.music_note, color: Colors.grey, size: 40),
                  ),
                ),
                errorWidget: (_, __, ___) => Container(
                  width: 160,
                  height: 120,
                  color: const Color(0xFF1E1E1E),
                  child: const Center(
                    child: Icon(Icons.music_note, color: Colors.grey, size: 40),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Flexible(
              child: Text(
                song.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Flexible(
              child: Text(
                song.artistName,
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAlbumCard(Album album) {
    return GestureDetector(
      onTap: () => _showAlbumDetails(album),
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
              fontSize: 10,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            album.artistName,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 8,
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
      onTap: () => _showArtistDetails(artist),
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
              fontSize: 10,
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
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const PlayerScreen(),
      ),
    );
  }

  void _showAllSongs(String genre, List<Song> songs) {
    // TODO: Navigate to genre songs screen
  }

  void _showAlbumDetails(Album album) {
    // TODO: Navigate to album details screen
  }

  void _showArtistDetails(Artist artist) {
    // TODO: Navigate to artist details screen
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
      setState(() {
        _searchResults = results;
      });
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
        return ListTile(
          leading: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: CachedNetworkImage(
              imageUrl: song.albumImage,
              width: 50,
              height: 50,
              fit: BoxFit.cover,
              placeholder: (_, __) => Container(
                width: 50,
                height: 50,
                color: const Color(0xFF1E1E1E),
                child: const Icon(Icons.music_note, color: Colors.grey),
              ),
              errorWidget: (_, __, ___) => Container(
                width: 50,
                height: 50,
                color: const Color(0xFF1E1E1E),
                child: const Icon(Icons.music_note, color: Colors.grey),
              ),
            ),
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
          onTap: () => _playSong(song, _searchResults, index),
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