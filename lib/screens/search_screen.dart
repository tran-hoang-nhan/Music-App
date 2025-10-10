import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:async';
import '../models/song.dart';
import '../services/jamendo_service.dart';
import '../services/music_service.dart';
import '../widgets/offline_banner.dart';
import 'player_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final JamendoService _jamendoService = JamendoService();
  Timer? _debounceTimer;
  
  List<Song> _searchResults = [];
  List<Song> _trendingSongs = [];
  bool _isLoading = false;
  bool _hasSearched = false;

  final List<String> _genres = [
    'rock', 'pop', 'jazz', 'classical', 'electronic', 
    'folk', 'blues', 'reggae', 'country', 'metal'
  ];

  @override
  void initState() {
    super.initState();
    _loadTrendingSongs();
  }

  Future<void> _loadTrendingSongs() async {
    try {
      final songs = await _jamendoService.getPopularTracks(limit: 20);
      setState(() {
        _trendingSongs = songs;
      });
    } catch (e) {
      print('Lỗi tải bài hát thịnh hành: $e');
    }
  }

  Future<void> _searchSongs(String query) async {
    if (query.trim().isEmpty) return;

    setState(() {
      _isLoading = true;
      _hasSearched = true;
    });

    try {
      final results = await _jamendoService.searchTracks(query.trim());
      setState(() {
        _searchResults = results;
        _isLoading = false;
      });
    } catch (e) {
      print('Lỗi tìm kiếm: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _searchByGenre(String genre) async {
    setState(() {
      _isLoading = true;
      _hasSearched = true;
      _searchController.text = genre;
    });

    try {
      final results = await _jamendoService.getTracksByGenre(genre);
      setState(() {
        _searchResults = results;
        _isLoading = false;
      });
    } catch (e) {
      print('Lỗi tìm kiếm theo thể loại: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: const Text('Tìm kiếm'),
        backgroundColor: const Color(0xFF121212),
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
                hintText: 'Tìm bài hát, nghệ sĩ...',
                hintStyle: const TextStyle(color: Colors.grey),
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: Colors.grey),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _searchResults.clear();
                            _hasSearched = false;
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
              onSubmitted: _searchSongs,
              onChanged: (value) {
                setState(() {});
                _onSearchChanged(value);
              },
            ),
          ),

          // Nội dung
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: Color(0xFF1DB954)),
                  )
                : _hasSearched
                    ? _buildSearchResults()
                    : _buildDefaultContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildDefaultContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Thể loại
          const Text(
            'Duyệt theo thể loại',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _genres.map((genre) {
              return GestureDetector(
                onTap: () => _searchByGenre(genre),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E1E1E),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFF1DB954)),
                  ),
                  child: Text(
                    genre.toUpperCase(),
                    style: const TextStyle(
                      color: Color(0xFF1DB954),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 32),

          // Bài hát thịnh hành
          const Text(
            'Thịnh hành',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _trendingSongs.length,
            itemBuilder: (context, index) {
              final song = _trendingSongs[index];
              return _buildSongTile(song, _trendingSongs, index);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResults() {
    if (_searchResults.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              'Không tìm thấy kết quả',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 18,
              ),
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
        return _buildSongTile(song, _searchResults, index);
      },
    );
  }

  Widget _buildSongTile(Song song, List<Song> playlist, int index) {
    return ListTile(
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: CachedNetworkImage(
          imageUrl: song.albumImage,
          width: 50,
          height: 50,
          fit: BoxFit.cover,
          placeholder: (_, _) => Container(
            width: 50,
            height: 50,
            color: const Color(0xFF1E1E1E),
            child: const Icon(Icons.music_note, color: Colors.grey),
          ),
          errorWidget: (_, _, _) => Container(
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
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            song.formattedDuration,
            style: const TextStyle(color: Colors.grey, fontSize: 12),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.grey),
            onPressed: () => _showSongOptions(song),
          ),
        ],
      ),
      onTap: () => _playSong(song, playlist, index),
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

  void _showSongOptions(Song song) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E1E1E),
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.favorite_border, color: Colors.white),
              title: const Text('Thêm vào yêu thích', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                final musicService = Provider.of<MusicService>(context, listen: false);
                musicService.toggleFavorite(song);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Đã thêm vào yêu thích'),
                    backgroundColor: Color(0xFF1DB954),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.playlist_add, color: Colors.white),
              title: const Text('Thêm vào playlist', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                // TODO: Implement add to playlist
              },
            ),
          ],
        );
      },
    );
  }

  void _onSearchChanged(String query) {
    _debounceTimer?.cancel();
    if (query.trim().isEmpty) {
      setState(() {
        _searchResults.clear();
        _hasSearched = false;
      });
      return;
    }
    
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      _searchSongs(query);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }
}