import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/song.dart';
import '../../services/jamendo/jamendo_controller.dart';
import '../../services/music/music_controller.dart';
import '../mini_player.dart';
import 'widgets/genre_header.dart';
import 'widgets/genre_songs_list.dart';

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
  List<Song> _songs = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadGenreSongs());
  }

  Future<void> _loadGenreSongs() async {
    try {
      final jamendoController = Provider.of<JamendoController>(context, listen: false);
      final songs = await jamendoController.genre.getTracksByGenre(
        widget.genreName.toLowerCase(),
        limit: 20,
      );
      
      if (mounted) {
        setState(() {
          _songs = songs;
          _isLoading = false;
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
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 200,
                pinned: true,
                backgroundColor: const Color(0xFF121212),
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
              SliverToBoxAdapter(
                child: GenreHeader(
                  displayName: widget.displayName,
                  emoji: widget.emoji,
                  gradientColors: widget.gradientColors,
                  onPlayAll: _playAllSongs,
                  onShuffle: _shuffleAndPlay,
                ),
              ),
              GenreSongsList(
                songs: _songs,
                isLoading: _isLoading,
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Consumer<MusicController>(
              builder: (context, musicController, child) {
                return musicController.currentSong != null ? const MiniPlayer() : const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }

  void _playAllSongs() {
    if (_songs.isNotEmpty) {
      final musicController = Provider.of<MusicController>(context, listen: false);
      musicController.playSong(context, _songs.first, playlist: _songs, index: 0);
    }
  }

  void _shuffleAndPlay() {
    if (_songs.isNotEmpty) {
      final musicController = Provider.of<MusicController>(context, listen: false);
      final shuffledSongs = List<Song>.from(_songs)..shuffle();
      musicController.playSong(context, shuffledSongs.first, playlist: shuffledSongs, index: 0);
    }
  }
}


