import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../models/song.dart';
import '../services/firebase_service.dart';
import '../services/music_service.dart';
import '../services/jamendo_service.dart';
import '../services/cloudinary_service.dart';
import '../widgets/mini_player.dart';

class PlaylistDetailScreen extends StatefulWidget {
  final Map<String, dynamic> playlist;
  
  const PlaylistDetailScreen({super.key, required this.playlist});

  @override
  State<PlaylistDetailScreen> createState() => _PlaylistDetailScreenState();
}

class _PlaylistDetailScreenState extends State<PlaylistDetailScreen> {
  final FirebaseService _firebaseService = FirebaseService();
  final ImagePicker _picker = ImagePicker();
  List<Song> _songs = [];
  bool _isLoading = true;
  Map<String, dynamic> _playlist = {};

  @override
  void initState() {
    super.initState();
    _playlist = Map<String, dynamic>.from(widget.playlist);
    _loadPlaylistSongs();
  }

  Future<void> _loadPlaylistSongs() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    
    try {
      final songIds = await _firebaseService.getPlaylistSongIds(widget.playlist['id']);
      if (!mounted) return;
      
      // Batch load songs to avoid blocking
      List<Song> songs = [];
      
      for (int i = 0; i < songIds.length; i += 2) {
        final batch = songIds.skip(i).take(2);
        final batchResults = await Future.wait(
          batch.map((songId) => JamendoService().getSongById(songId).catchError((_) => null)),
        );
        
        final validSongs = batchResults.where((song) => song != null).cast<Song>();
        songs.addAll(validSongs);
        
        if (mounted) {
          setState(() {
            _songs = List.from(songs);
          });
        }
        
        // Delay giữa các batch
        if (i + 2 < songIds.length) {
          await Future.delayed(const Duration(milliseconds: 200));
        }
      }
      
      if (mounted) {
        setState(() {
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
      body: Column(
        children: [
          Expanded(
            child: _isLoading
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
                      GestureDetector(
                        onTap: _changePlaylistImage,
                        child: Stack(
                          children: [
                            Container(
                              width: 100,
                              height: 100,
                              decoration: BoxDecoration(
                                color: const Color(0xFFE53E3E),
                                borderRadius: BorderRadius.circular(12),
                                image: _playlist['imageUrl'] != null
                                    ? DecorationImage(
                                        image: NetworkImage(_playlist['imageUrl']),
                                        fit: BoxFit.cover,
                                      )
                                    : null,
                              ),
                              child: _playlist['imageUrl'] == null
                                  ? const Icon(
                                      Icons.playlist_play,
                                      color: Colors.white,
                                      size: 50,
                                    )
                                  : null,
                            ),
                            Positioned(
                              bottom: 4,
                              right: 4,
                              child: Container(
                                width: 24,
                                height: 24,
                                decoration: const BoxDecoration(
                                  color: Color(0xFFE53E3E),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.camera_alt,
                                  size: 12,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            GestureDetector(
                              onTap: _editPlaylistName,
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      _playlist['name'] ?? 'Playlist',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  const Icon(
                                    Icons.edit,
                                    color: Colors.grey,
                                    size: 16,
                                  ),
                                ],
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
                          padding: const EdgeInsets.only(bottom: 80),
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
          ),
          Consumer<MusicService>(
            builder: (context, musicService, child) {
              if (musicService.currentSong != null) {
                return const MiniPlayer();
              }
              return const SizedBox.shrink();
            },
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
              leading: const Icon(Icons.image, color: Colors.white),
              title: const Text('Đổi hình nền', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                _changePlaylistImage();
              },
            ),
            ListTile(
              leading: const Icon(Icons.edit, color: Colors.white),
              title: const Text('Đổi tên', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                _editPlaylistName();
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
                _removeSongFromPlaylist(song);
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _removeSongFromPlaylist(Song song) async {
    try {
      final success = await _firebaseService.removeSongFromPlaylist(
        widget.playlist['id'], 
        song.id
      );
      
      if (success) {
        setState(() {
          _songs.removeWhere((s) => s.id == song.id);
        });
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Đã xóa "${song.name}" khỏi playlist'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Lỗi khi xóa bài hát'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _deletePlaylist() async {
    final success = await _firebaseService.deletePlaylist(_playlist['id']);
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

  Future<void> _changePlaylistImage() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 512,
      maxHeight: 512,
      imageQuality: 80,
    );
    
    if (image != null) {
      setState(() => _isLoading = true);
      
      final imageUrl = await CloudinaryService.uploadImage(
        File(image.path),
        folder: 'music_app/playlists/${_playlist['id']}',
      );
      
      if (imageUrl != null) {
        // Cập nhật UI ngay lập tức
        setState(() {
          _playlist['imageUrl'] = imageUrl;
          _isLoading = false;
        });
        
        // Cập nhật Firebase trong background
        _firebaseService.updatePlaylist(
          _playlist['id'], 
          {'imageUrl': imageUrl}
        ).then((_) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Đã cập nhật hình nền playlist'),
                backgroundColor: Colors.green,
                duration: Duration(seconds: 1),
              ),
            );
          }
        }).catchError((e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Lỗi lưu: ${e.toString()}'),
                backgroundColor: Colors.red,
              ),
            );
          }
        });
      } else {
        setState(() => _isLoading = false);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Lỗi upload ảnh'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _editPlaylistName() async {
    final controller = TextEditingController(text: _playlist['name']);
    
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1E1E1E),
          title: const Text('Đổi tên playlist', style: TextStyle(color: Colors.white)),
          content: TextField(
            controller: controller,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              hintText: 'Nhập tên playlist',
              hintStyle: TextStyle(color: Colors.grey),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.grey),
              ),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Color(0xFFE53E3E)),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Hủy', style: TextStyle(color: Colors.grey)),
            ),
            TextButton(
              onPressed: () async {
                final newName = controller.text.trim();
                if (newName.isNotEmpty && newName != _playlist['name']) {
                  Navigator.pop(context);
                  // Cập nhật UI ngay lập tức
                  setState(() {
                    _playlist['name'] = newName;
                  });
                  // Rồi mới cập nhật Firebase
                  _updatePlaylistName(newName);
                } else {
                  Navigator.pop(context);
                }
              },
              child: const Text('Lưu', style: TextStyle(color: Color(0xFFE53E3E))),
            ),
          ],
        );
      },
    );
  }

  Future<void> _updatePlaylistName(String newName) async {
    try {
      await _firebaseService.updatePlaylist(
        _playlist['id'], 
        {'name': newName}
      );
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đã cập nhật tên playlist'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 1),
          ),
        );
      }
    } catch (e) {
      // Nếu lỗi thì revert lại
      setState(() {
        _playlist['name'] = widget.playlist['name'];
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}