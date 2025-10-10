import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/song.dart';
import '../services/jamendo_service.dart';
import '../services/music_service.dart';
import '../widgets/song_tile.dart';
import '../widgets/offline_banner.dart';

class GenreDetailScreen extends StatefulWidget {
  final String genreName;
  final String displayName;
  final String emoji;
  final List<Color> gradientColors;

  const GenreDetailScreen({
    super.key,
    required this.genreName,
    required this.displayName,
    required this.emoji,
    required this.gradientColors,
  });

  @override
  State<GenreDetailScreen> createState() => _GenreDetailScreenState();
}

class _GenreDetailScreenState extends State<GenreDetailScreen> {
  final JamendoService _jamendoService = JamendoService();
  List<Song> _songs = [];
  bool _isLoading = true;
  final int _limit = 20;
  bool _hasMoreData = true;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadSongs();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
      if (!_isLoading && _hasMoreData) {
        _loadMoreSongs();
      }
    }
  }

  Future<void> _loadSongs() async {
    if (!mounted) return;
    
    setState(() => _isLoading = true);
    
    try {
      final songs = await _jamendoService.getTracksByGenre(
        widget.genreName, 
        limit: _limit,
      );
      
      if (mounted) {
        setState(() {
          _songs = songs;
          _isLoading = false;
          _hasMoreData = songs.length == _limit;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi khi tải nhạc: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _loadMoreSongs() async {
    if (_isLoading || !_hasMoreData) return;
    
    setState(() => _isLoading = true);
    
    try {
      final newSongs = await _jamendoService.getTracksByGenre(
        widget.genreName,
        limit: _limit,
      );
      
      if (mounted) {
        setState(() {
          _songs.addAll(newSongs);
          _isLoading = false;
          _hasMoreData = newSongs.length == _limit;
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
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          // Custom app bar với gradient
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            backgroundColor: widget.gradientColors.first,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: widget.gradientColors,
                  ),
                ),
                child: SafeArea(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        widget.emoji,
                        style: const TextStyle(fontSize: 64),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        widget.displayName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${_songs.length} bài hát',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          
          // Offline banner
          const SliverToBoxAdapter(
            child: OfflineBanner(),
          ),
          
          // Play buttons
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _songs.isNotEmpty ? () => _playAll() : null,
                      icon: const Icon(Icons.play_arrow),
                      label: const Text('Phát tất cả'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: widget.gradientColors.first,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _songs.isNotEmpty ? () => _playAllShuffle() : null,
                      icon: const Icon(Icons.shuffle),
                      label: const Text('Phát ngẫu nhiên'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        foregroundColor: widget.gradientColors.first,
                        side: BorderSide(color: widget.gradientColors.first),
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Songs list
          if (_isLoading && _songs.isEmpty)
            const SliverFillRemaining(
              child: Center(
                child: CircularProgressIndicator(color: Color(0xFFE53E3E)),
              ),
            )
          else if (_songs.isEmpty)
            const SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.music_note, size: 64, color: Colors.grey),
                    SizedBox(height: 16),
                    Text(
                      'Không có bài hát nào',
                      style: TextStyle(color: Colors.grey, fontSize: 18),
                    ),
                  ],
                ),
              ),
            )
          else
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  if (index < _songs.length) {
                    final song = _songs[index];
                    return SongTile(
                      song: song,
                      playlist: _songs,
                      index: index,
                    );
                  } else if (_hasMoreData) {
                    return const Padding(
                      padding: EdgeInsets.all(16),
                      child: Center(
                        child: CircularProgressIndicator(color: Color(0xFFE53E3E)),
                      ),
                    );
                  }
                  return null;
                },
                childCount: _songs.length + (_hasMoreData ? 1 : 0),
              ),
            ),
        ],
      ),
    );
  }

  void _playAll() async {
    if (_songs.isNotEmpty) {
      try {
        // Get MusicService to handle playback
        final musicService = Provider.of<MusicService>(context, listen: false);
        
        // Set the playlist and start playing from the first song
        musicService.setPlaylist(_songs, startIndex: 0);
        await musicService.playSong(_songs[0], playlist: _songs, index: 0);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Đang phát tất cả bài hát ${widget.displayName}...'),
              backgroundColor: widget.gradientColors.first,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Lỗi khi phát nhạc: $e'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      }
    }
  }

  void _playAllShuffle() async {
    if (_songs.isNotEmpty) {
      try {
        // Get MusicService to handle playback
        final musicService = Provider.of<MusicService>(context, listen: false);
        
        // Create a shuffled copy of the songs list
        final shuffledSongs = List<Song>.from(_songs);
        shuffledSongs.shuffle();
        
        // Set the shuffled playlist and start playing from the first song
        musicService.setPlaylist(shuffledSongs, startIndex: 0);
        await musicService.playSong(shuffledSongs[0], playlist: shuffledSongs, index: 0);
        
        // Enable shuffle mode
        if (!musicService.isShuffled) {
          musicService.toggleShuffle();
        }
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Đang phát ngẫu nhiên ${widget.displayName}...'),
              backgroundColor: widget.gradientColors.first,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Lỗi khi phát nhạc: $e'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      }
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}