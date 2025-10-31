import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/song.dart';
import '../../services/firebase/firebase_controller.dart';
import '../../services/music/music_controller.dart';
import '../mini_player.dart';
import 'widgets/playlist_header.dart';
import 'widgets/playlist_songs_list.dart';

class PlaylistDetailScreen extends StatefulWidget {
  final Map<String, dynamic> playlist;
  
  const PlaylistDetailScreen({super.key, required this.playlist});

  @override
  State<PlaylistDetailScreen> createState() => _PlaylistDetailScreenState();
}

class _PlaylistDetailScreenState extends State<PlaylistDetailScreen> {
  List<Song> _songs = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPlaylistSongs();
  }

  Future<void> _loadPlaylistSongs() async {
    try {
      final firebaseController = Provider.of<FirebaseController>(context, listen: false);
      final songs = await firebaseController.playlist.getPlaylistSongs(widget.playlist['id']);
      if (mounted) {
        setState(() {
          _songs = songs;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi tải playlist: $e')),
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
                pinned: true,
                backgroundColor: const Color(0xFF121212),
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
                actions: [
                  PopupMenuButton<String>(
                    onSelected: _handleMenuAction,
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'add_songs',
                        child: Row(
                          children: [
                            Icon(Icons.add, color: Colors.white),
                            SizedBox(width: 8),
                            Text('Thêm bài hát'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, color: Colors.red),
                            SizedBox(width: 8),
                            Text('Xóa playlist', style: TextStyle(color: Colors.red)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              PlaylistHeader(
                playlist: widget.playlist,
                onPlayAll: _playAllSongs,
                onShuffle: _shuffleAndPlay,
                onEdit: _editPlaylist,
              ),
              PlaylistSongsList(
                songs: _songs,
                isLoading: _isLoading,
                onRemoveSong: _removeSongFromPlaylist,
              ),
              Consumer<MusicController>(
                builder: (context, musicController, child) {
                  return SliverToBoxAdapter(
                    child: SizedBox(height: musicController.currentSong != null ? 100 : 0),
                  );
                },
              ),
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

  void _editPlaylist() {
    Navigator.pushNamed(
      context,
      '/playlist_edit',
      arguments: {
        'id': widget.playlist['id'],
        'name': widget.playlist['name'],
        'description': widget.playlist['description'],
        'imageUrl': widget.playlist['imageUrl'],
      },
    );
  }

  void _handleMenuAction(String action) {
    switch (action) {
      case 'add_songs':
        _showAddSongsDialog();
        break;
      case 'delete':
        _showDeletePlaylistDialog();
        break;
    }
  }

  void _showAddSongsDialog() {
    Navigator.pushNamed(
      context,
      '/search',
      arguments: {'addToPlaylist': widget.playlist['id']},
    );
  }

  void _showDeletePlaylistDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        title: const Text('Xóa playlist', style: TextStyle(color: Colors.white)),
        content: Text(
          'Bạn có chắc chắn muốn xóa playlist "${widget.playlist['name']}"?',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () async {
              if (!context.mounted) return;
              final navigator = Navigator.of(context);
              final scaffoldMessenger = ScaffoldMessenger.of(context);
              final firebaseController = Provider.of<FirebaseController>(context, listen: false);
              
              await firebaseController.playlist.deletePlaylist(widget.playlist['id']);
              
              if (!context.mounted) return;
              navigator.pop(); // Close dialog
              navigator.pop(); // Close screen
              scaffoldMessenger.showSnackBar(
                const SnackBar(content: Text('Đã xóa playlist')),
              );
            },
            child: const Text('Xóa', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Future<void> _removeSongFromPlaylist(String songId) async {
    if (!mounted) return;
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    try {
      final firebaseController = Provider.of<FirebaseController>(context, listen: false);
      await firebaseController.playlist.removeSongFromPlaylist(widget.playlist['id'], songId);
      if (mounted) {
        setState(() {
          _songs.removeWhere((song) => song.id == songId);
        });
        scaffoldMessenger.showSnackBar(
          const SnackBar(content: Text('Đã xóa bài hát khỏi playlist')),
        );
      }
    } catch (e) {
      if (mounted) {
        scaffoldMessenger.showSnackBar(
          SnackBar(content: Text('Lỗi xóa bài hát: $e')),
        );
      }
    }
  }
}


