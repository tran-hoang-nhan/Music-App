import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../services/music_service.dart';
import '../services/theme_service.dart';
import '../services/firebase_service.dart';
import '../models/artist.dart';
import '../models/song.dart';
import '../widgets/dynamic_background.dart';
import 'artist_detail_screen.dart';

class PlayerScreen extends StatefulWidget {
  const PlayerScreen({super.key});

  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> {
  bool _isFavorite = false;
  String? _currentSongId;
  late MusicService _musicService;

  @override
  void initState() {
    super.initState();
    _musicService = context.read<MusicService>();
    _musicService.addListener(_onMusicServiceChanged);
    _checkFavoriteStatus();
  }

  @override
  void dispose() {
    _musicService.removeListener(_onMusicServiceChanged);
    super.dispose();
  }

  void _onMusicServiceChanged() {
    final currentSong = _musicService.currentSong;
    if (currentSong?.id != _currentSongId) {
      _updateFavoriteStatus(currentSong?.id);
    }
  }

  Future<void> _checkFavoriteStatus() async {
    if (_musicService.currentSong != null) {
      final isFav = await _musicService.isFavorite(_musicService.currentSong!);
      if (mounted) {
        setState(() {
          _isFavorite = isFav;
          _currentSongId = _musicService.currentSong!.id;
        });
      }
    }
  }

  Future<void> _updateFavoriteStatus(String? newSongId) async {
    if (newSongId != null && _musicService.currentSong != null) {
      final isFav = await _musicService.isFavorite(_musicService.currentSong!);
      if (mounted) {
        setState(() {
          _isFavorite = isFav;
          _currentSongId = newSongId;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.keyboard_arrow_down, size: 32),
          onPressed: () => Navigator.pop(context),
          tooltip: 'Đóng',
        ),
        title: const Text(
          'Đang phát',
          style: TextStyle(fontSize: 16),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: _showMoreOptions,
            tooltip: 'Tùy chọn khác',
          ),
        ],
      ),
      body: DynamicBackground(
        usePlayerGradient: true,
        child: Consumer<MusicService>(
          builder: (context, musicService, child) {
          final song = musicService.currentSong;
          if (song == null) {
            return const Center(
              child: Text(
                'Không có bài hát nào đang phát',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            );
          }



          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: MediaQuery.of(context).size.height - 
                           MediaQuery.of(context).padding.top - 
                           kToolbarHeight - 48,
              ),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  
                  // Ảnh album
                Container(
                  width: 300,
                  height: 300,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: CachedNetworkImage(
                      imageUrl: song.albumImage,
                      fit: BoxFit.cover,
                      placeholder: (_, _) => Container(
                        color: const Color(0xFF1E1E1E),
                        child: const Center(
                          child: Icon(
                            Icons.music_note,
                            size: 80,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                      errorWidget: (_, _, _) => Container(
                        color: const Color(0xFF1E1E1E),
                        child: const Center(
                          child: Icon(
                            Icons.music_note,
                            size: 80,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(height: 40),
                
                // Thông tin bài hát
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            song.name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 8),
                          GestureDetector(
                            onTap: () => _navigateToArtist(song),
                            child: Text(
                              song.artistName,
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 18,
                                decoration: TextDecoration.underline,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Consumer<ThemeService>(
                      builder: (context, themeService, child) {
                        return IconButton(
                          icon: Icon(
                            _isFavorite ? Icons.favorite : Icons.favorite_border,
                            color: _isFavorite ? themeService.primaryColor : Colors.grey,
                            size: 32,
                          ),
                          onPressed: _toggleFavorite,
                          tooltip: _isFavorite ? 'Bỏ yêu thích' : 'Yêu thích',
                        );
                      },
                    ),
                  ],
                ),
                
                const SizedBox(height: 40),
                
                // Thanh tiến trình
                Column(
                  children: [
                    Consumer<ThemeService>(
                      builder: (context, themeService, child) {
                        return SliderTheme(
                          data: SliderTheme.of(context).copyWith(
                            activeTrackColor: themeService.primaryColor,
                            inactiveTrackColor: Colors.grey.withValues(alpha: 0.3),
                            thumbColor: themeService.primaryColor,
                            overlayColor: themeService.primaryColor.withValues(alpha: 0.2),
                            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                            trackHeight: 4,
                          ),
                          child: Slider(
                            value: musicService.currentPosition.inSeconds.toDouble(),
                            max: musicService.totalDuration.inSeconds > 0 ? musicService.totalDuration.inSeconds.toDouble() : 1.0,
                            onChanged: (value) {
                              musicService.seekTo(Duration(seconds: value.toInt()));
                            },
                          ),
                        );
                      },
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _formatDuration(musicService.currentPosition),
                            style: const TextStyle(color: Colors.grey, fontSize: 12),
                          ),
                          Text(
                            _formatDuration(musicService.totalDuration),
                            style: const TextStyle(color: Colors.grey, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 40),
                
                // Điều chỉnh âm lượng
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      const Icon(Icons.volume_down, color: Colors.grey, size: 20),
                      Expanded(
                        child: Consumer<ThemeService>(
                          builder: (context, themeService, child) {
                            return SliderTheme(
                              data: SliderTheme.of(context).copyWith(
                                activeTrackColor: themeService.primaryColor,
                                inactiveTrackColor: Colors.grey.withValues(alpha: 0.3),
                                thumbColor: themeService.primaryColor,
                                overlayColor: themeService.primaryColor.withValues(alpha: 0.2),
                                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 5),
                                trackHeight: 3,
                              ),
                              child: Slider(
                                value: musicService.volume,
                                onChanged: (value) {
                                  musicService.setVolume(value);
                                },
                              ),
                            );
                          },
                        ),
                      ),
                      const Icon(Icons.volume_up, color: Colors.grey, size: 20),
                    ],
                  ),
                ),
                
                const SizedBox(height: 30),
                
                // Điều khiển phát nhạc
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Consumer<ThemeService>(
                      builder: (context, themeService, child) {
                        return IconButton(
                          icon: Icon(
                            musicService.isShuffled ? Icons.shuffle : Icons.shuffle,
                            color: musicService.isShuffled ? themeService.primaryColor : Colors.grey,
                            size: 28,
                          ),
                          onPressed: () {
                            musicService.toggleShuffle();
                          },
                          tooltip: musicService.isShuffled ? 'Tắt phát ngẫu nhiên' : 'Bật phát ngẫu nhiên',
                        );
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.skip_previous, color: Colors.white, size: 40),
                      onPressed: musicService.playlist.isNotEmpty ? musicService.playPrevious : null,
                      tooltip: 'Bài trước',
                    ),
                    Consumer<ThemeService>(
                      builder: (context, themeService, child) {
                        return Container(
                          width: 70,
                          height: 70,
                          decoration: BoxDecoration(
                            color: themeService.primaryColor,
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            icon: Icon(
                              musicService.isPlaying ? Icons.pause : Icons.play_arrow,
                              color: Colors.white,
                              size: 36,
                            ),
                            onPressed: () {
                              if (musicService.isPlaying) {
                                musicService.pause();
                              } else {
                                musicService.resume();
                              }
                            },
                            tooltip: musicService.isPlaying ? 'Tạm dừng' : 'Phát',
                            splashRadius: 35,
                          ),
                        );
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.skip_next, color: Colors.white, size: 40),
                      onPressed: musicService.playlist.isNotEmpty ? musicService.playNext : null,
                      tooltip: 'Bài tiếp theo',
                    ),
                    Consumer<ThemeService>(
                      builder: (context, themeService, child) {
                        return IconButton(
                          icon: Icon(
                            musicService.isRepeating ? Icons.repeat_one : Icons.repeat,
                            color: musicService.isRepeating ? themeService.primaryColor : Colors.grey,
                            size: 28,
                          ),
                          onPressed: () {
                            musicService.toggleRepeat();
                          },
                          tooltip: musicService.isRepeating ? 'Tắt lặp lại' : 'Bật lặp lại',
                        );
                      },
                    ),
                  ],
                ),
                
                const SizedBox(height: 40),
                ],
              ),
            ),
            );
          },
        ),
      ),
    );
  }

  Future<void> _toggleFavorite() async {
    final musicService = Provider.of<MusicService>(context, listen: false);
    if (musicService.currentSong != null) {
      await musicService.toggleFavorite(musicService.currentSong!);
      if (mounted) {
        setState(() {
          _isFavorite = !_isFavorite;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _isFavorite ? 'Đã thêm vào yêu thích' : 'Đã xóa khỏi yêu thích',
            ),
            backgroundColor: const Color(0xFFE53E3E),
          ),
        );
      }
    }
  }

  void _showMoreOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E1E1E),
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.playlist_add, color: Colors.white),
              title: const Text('Thêm vào playlist', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                _showAddToPlaylistDialog();
              },
            ),
            ListTile(
              leading: const Icon(Icons.share, color: Colors.white),
              title: const Text('Chia sẻ', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                // TODO: Implement share
              },
            ),
            ListTile(
              leading: const Icon(Icons.info_outline, color: Colors.white),
              title: const Text('Thông tin bài hát', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                _showSongInfo();
              },
            ),
          ],
        );
      },
    );
  }

  void _showSongInfo() {
    final musicService = Provider.of<MusicService>(context, listen: false);
    final song = musicService.currentSong;
    if (song == null) return;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1E1E1E),
          title: const Text('Thông tin bài hát', style: TextStyle(color: Colors.white)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildInfoRow('Tên bài hát:', song.name),
              _buildInfoRow('Nghệ sĩ:', song.artistName),
              _buildInfoRow('Album:', song.albumName),
              _buildInfoRow('Thời lượng:', song.formattedDuration),
              if (song.tags.isNotEmpty)
                _buildInfoRow('Thể loại:', song.tags.join(', ')),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Đóng', style: TextStyle(color: Color(0xFFE53E3E))),
            ),
          ],
        );
      },
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: const TextStyle(color: Colors.grey, fontSize: 14),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: Colors.white, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  void _showAddToPlaylistDialog() async {
    try {
      debugPrint('Bắt đầu load playlists...');
      final firebaseService = FirebaseService();
      final playlists = await firebaseService.getUserPlaylists();
      debugPrint('Load được ${playlists.length} playlists');
      
      if (!mounted) return;
      
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            backgroundColor: const Color(0xFF1E1E1E),
            title: const Text('Chọn playlist', style: TextStyle(color: Colors.white)),
            content: playlists.isEmpty
                ? const Text('Chưa có playlist nào', style: TextStyle(color: Colors.grey))
                : SizedBox(
                    width: double.maxFinite,
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: playlists.length,
                      itemBuilder: (context, index) {
                        final playlist = playlists[index];
                        return ListTile(
                          leading: const Icon(Icons.playlist_play, color: Color(0xFFE53E3E)),
                          title: Text(
                            playlist['name'] ?? 'Playlist',
                            style: const TextStyle(color: Colors.white),
                          ),
                          onTap: () => _addToPlaylist(playlist['id'], playlist['name']),
                        );
                      },
                    ),
                  ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Hủy', style: TextStyle(color: Colors.grey)),
              ),
            ],
          );
        },
      );
    } catch (e) {
      debugPrint('Lỗi khi load playlists: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Lỗi khi tải danh sách playlist'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
  
  Future<void> _addToPlaylist(String playlistId, String playlistName) async {
    final song = _musicService.currentSong;
    
    if (song == null) return;
    
    Navigator.pop(context);
    
    final firebaseService = FirebaseService();
    final success = await firebaseService.addSongToPlaylist(playlistId, song);
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success 
                ? 'Đã thêm "${song.name}" vào $playlistName'
                : 'Lỗi khi thêm vào playlist',
          ),
          backgroundColor: success ? const Color(0xFFE53E3E) : Colors.red,
        ),
      );
    }
  }

  Future<void> _navigateToArtist(Song song) async {
    try {
      final artist = Artist(
        id: song.artistId,
        name: song.artistName,
        image: song.albumImage,
        website: '',
        joinDate: '',
      );
      
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ArtistDetailScreen(artist: artist),
        ),
      );
    } catch (e) {
      debugPrint('Lỗi điều hướng tới nghệ sĩ: $e');
    }
  }
}