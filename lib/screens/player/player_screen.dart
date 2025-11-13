import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/music/music_controller.dart';
import '../../services/theme/theme_controller.dart';
import '../../services/firebase/firebase_controller.dart';
import '../dynamic_background.dart';
import 'widgets/player_artwork.dart';
import 'widgets/player_info.dart';
import 'widgets/player_controls.dart';
import 'widgets/player_progress.dart';
import 'widgets/player_actions.dart';
import 'widgets/player_queue.dart';
import 'widgets/player_volume.dart';

class PlayerScreen extends StatefulWidget {
  const PlayerScreen({super.key});

  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> {
  bool _isFavorite = false;
  String? _currentSongId;
  late MusicController _musicController;

  @override
  void initState() {
    super.initState();
    _musicController = context.read<MusicController>();
    _musicController.addListener(_onMusicControllerChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkFavoriteStatus();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkFavoriteStatus();
    });
  }

  @override
  void dispose() {
    _musicController.removeListener(_onMusicControllerChanged);
    super.dispose();
  }

  void _onMusicControllerChanged() {
    final currentSong = _musicController.currentSong;
    if (currentSong?.id != _currentSongId) {
      _updateFavoriteStatus(currentSong?.id);
    }
  }

  void _updateFavoriteStatus(String? songId) {
    if (songId != null) {
      _currentSongId = songId;
      _checkFavoriteStatus();
    }
  }

  Future<void> _checkFavoriteStatus() async {
    final currentSong = _musicController.currentSong;
    if (currentSong != null && mounted) {
      try {
        final firebaseController = Provider.of<FirebaseController>(context, listen: false);
        final isFavorite = await firebaseController.favorite.isFavorite(currentSong.id);
        if (mounted) {
          setState(() {
            _isFavorite = isFavorite;
          });
        }
      } catch (e) {
        debugPrint('Error checking favorite status: $e');
      }
    }
  }

  Future<void> _toggleFavorite() async {
    final currentSong = _musicController.currentSong;
    if (currentSong != null) {
      final firebaseController = Provider.of<FirebaseController>(context, listen: false);
      final success = await firebaseController.favorite.toggleFavorite(currentSong.id, song: currentSong);
      if (success && mounted) {
        setState(() {
          _isFavorite = !_isFavorite;
        });
        
        final scaffoldMessenger = ScaffoldMessenger.of(context);
        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Text(
              _isFavorite 
                ? 'Đã thêm vào yêu thích' 
                : 'Đã xóa khỏi yêu thích'
            ),
            backgroundColor: const Color(0xFFE53E3E),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MusicController>(
      builder: (context, musicController, child) {
        final currentSong = musicController.currentSong;
        
        if (currentSong == null) {
          return _buildEmptyPlayer();
        }

        return Consumer<ThemeController>(
          builder: (context, themeService, child) {
            return Scaffold(
              body: DynamicBackground(
                child: SafeArea(
                  child: Column(
                    children: [
                      // Header with back button and menu
                      _buildHeader(),
                      
                      // Main content
                      Expanded(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Column(
                            children: [
                              const SizedBox(height: 20),
                              
                              // Album Artwork
                              PlayerArtwork(song: currentSong),
                              
                              const SizedBox(height: 32),
                              
                              // Song Info
                              PlayerInfo(song: currentSong),
                              
                              const SizedBox(height: 24),
                              
                              // Progress Bar
                              const PlayerProgress(),
                              
                              const SizedBox(height: 32),
                              
                              // Player Controls
                              const PlayerControls(),
                              
                              const SizedBox(height: 24),

                              // Volume Control
                              const PlayerVolume(),
                              
                              const SizedBox(height: 24),
                              
                              // Action Buttons
                              PlayerActions(
                                isFavorite: _isFavorite,
                                onToggleFavorite: _toggleFavorite,
                                song: currentSong,
                              ),
                              
                              const SizedBox(height: 32),
                              
                              // Queue
                              const PlayerQueue(),
                              
                              const SizedBox(height: 100),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.keyboard_arrow_down, 
              color: Colors.white, size: 32),
          ),
          const Text(
            'Đang phát',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          IconButton(
            onPressed: () => _showPlayerMenu(),
            icon: const Icon(Icons.more_vert, 
              color: Colors.white, size: 24),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyPlayer() {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.music_note, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Không có bài hát nào đang phát',
              style: TextStyle(color: Colors.grey, fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }

  void _showPlayerMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E1E1E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                margin: const EdgeInsets.symmetric(vertical: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[600],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.queue_music, color: Colors.white),
                title: const Text('Danh sách phát', style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.pop(context);
                  // Show queue
                },
              ),
              ListTile(
                leading: const Icon(Icons.share, color: Colors.white),
                title: const Text('Chia sẻ', style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.pop(context);
                  // Share song
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }
}


