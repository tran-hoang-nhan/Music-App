import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/song.dart';
import '../services/firebase_service.dart';
import '../services/music_service.dart';
import '../services/jamendo_service.dart';

class PlaylistDetailScreen extends StatefulWidget {
  final Map<String, dynamic> playlist;
  
  const PlaylistDetailScreen({super.key, required this.playlist});

  @override
  State<PlaylistDetailScreen> createState() => _PlaylistDetailScreenState();
}

class _PlaylistDetailScreenState extends State<PlaylistDetailScreen> {
  final FirebaseService _firebaseService = FirebaseService();
  List<Song> _songs = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPlaylistSongs();
  }

  Future<void> _loadPlaylistSongs() async {
    setState(() => _isLoading = true);
    
    try {
      final songIds = await _firebaseService.getPlaylistSongIds(widget.playlist['id']);
      
      // Lấy thông tin chi tiết từ Jamendo API
      List<Song> songs = [];
      for (String songId in songIds) {
        try {
          final song = await JamendoService().getSongById(songId);
          if (song != null) {
            songs.add(song);
          }
        } catch (e) {
          print('Lỗi lấy thông tin bài hát $songId: $e');
        }
      }
      
      setState(() {
        _songs = songs;
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
        title: Text(widget.playlist['name'] ?? 'Playlist'),
        backgroundColor: const Color(0xFF121212),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: _showPlaylistOptions,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFFE53E3E)),
            )
          : Column(
              children: [
                // Playlist Header
                Container(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE53E3E),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.playlist_play,
                          color: Colors.white,
                          size: 50,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.playlist['name'] ?? 'Playlist',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '${_songs.length} bài hát',
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Play Button
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      ElevatedButton.icon(
                        onPressed: _songs.isNotEmpty ? () => _playPlaylist() : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFE53E3E),
                          foregroundColor: Colors.white,
                        ),
                        icon: const Icon(Icons.play_arrow),
                        label: const Text('Phát tất cả'),
                      ),
                      const SizedBox(width: 12),
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(Icons.shuffle, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 20),
                
                // Songs List
                Expanded(
                  child: _songs.isEmpty
                      ? const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.music_note,
                                size: 64,
                                color: Colors.grey,
                              ),
                              SizedBox(height: 16),
                              Text(
                                'Playlist trống',
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 18,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          itemCount: _songs.length,
                          itemBuilder: (context, index) {
                            final song = _songs[index];
                            return ListTile(
                              leading: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: song.albumImage.isNotEmpty
                                    ? CachedNetworkImage(
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
                                      )
                                    : Container(
                                        width: 50,
                                        height: 50,
                                        color: const Color(0xFF1E1E1E),
                                        child: const Icon(Icons.music_note, color: Colors.grey),
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
                              trailing: IconButton(
                                icon: const Icon(Icons.more_vert, color: Colors.grey),
                                onPressed: () => _showSongOptions(song),
                              ),
                              onTap: () => _playSong(song, index),
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }

  void _playPlaylist() {
    if (_songs.isNotEmpty) {
      final musicService = Provider.of<MusicService>(context, listen: false);
      musicService.playSong(_songs.first, playlist: _songs);
    }
  }

  void _playSong(Song song, int index) {
    final musicService = Provider.of<MusicService>(context, listen: false);
    musicService.playSong(song, playlist: _songs, index: index);
  }

  void _showPlaylistOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E1E1E),
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit, color: Colors.white),
              title: const Text('Chỉnh sửa', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                // TODO: Edit playlist
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Xóa playlist', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(context);
                _deletePlaylist();
              },
            ),
          ],
        );
      },
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
              leading: const Icon(Icons.remove, color: Colors.red),
              title: const Text('Xóa khỏi playlist', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(context);
                // TODO: Remove song from playlist
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _deletePlaylist() async {
    final success = await _firebaseService.deletePlaylist(widget.playlist['id']);
    if (success && mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Đã xóa playlist'),
          backgroundColor: Color(0xFFE53E3E),
        ),
      );
    }
  }
}