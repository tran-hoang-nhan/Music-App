import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/jamendo/jamendo_controller.dart';
import '../../services/music/music_controller.dart';
import '../../models/album.dart';
import '../../models/song.dart';
import '../mini_player.dart';
import 'widgets/album_header.dart';
import 'widgets/album_tracks_list.dart';

class AlbumDetailScreen extends StatefulWidget {
  final Album album;

  const AlbumDetailScreen({super.key, required this.album});

  @override
  State<AlbumDetailScreen> createState() => _AlbumDetailScreenState();
}

class _AlbumDetailScreenState extends State<AlbumDetailScreen> {
  List<Song> _albumTracks = [];
  bool _isLoading = true;
  final Map<String, bool> _favoritesStatus = {};

  @override
  void initState() {
    super.initState();
    _loadAlbumTracks();
  }

  Future<void> _loadAlbumTracks() async {
    try {
      final jamendoController = Provider.of<JamendoController>(context, listen: false);
      final tracks = await jamendoController.getTracksByAlbum(widget.album.id);
      if (mounted) {
        setState(() {
          _albumTracks = tracks;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi tải bài hát: $e')),
        );
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
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withValues(alpha: 0.3),
                          Colors.black.withValues(alpha: 0.7),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              AlbumHeader(
                album: widget.album,
                onPlayAll: _playAllTracks,
                onShuffle: _shuffleAndPlay,
              ),
              if (_isLoading)
                const SliverToBoxAdapter(
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.all(40),
                      child: CircularProgressIndicator(color: Color(0xFFE53E3E)),
                    ),
                  ),
                )
              else
                AlbumTracksList(
                  tracks: _albumTracks,
                  favoritesStatus: _favoritesStatus,
                  onToggleFavorite: _toggleFavorite,
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

  void _playAllTracks() {
    if (_albumTracks.isNotEmpty) {
      final musicController = Provider.of<MusicController>(context, listen: false);
      musicController.playSong(_albumTracks.first, playlist: _albumTracks, index: 0);
    }
  }

  void _shuffleAndPlay() {
    if (_albumTracks.isNotEmpty) {
      final musicController = Provider.of<MusicController>(context, listen: false);
      final shuffledTracks = List<Song>.from(_albumTracks)..shuffle();
      musicController.playSong(shuffledTracks.first, playlist: shuffledTracks, index: 0);
    }
  }

  void _toggleFavorite(String songId) {
    setState(() {
      _favoritesStatus[songId] = !(_favoritesStatus[songId] ?? false);
    });
  }
}


