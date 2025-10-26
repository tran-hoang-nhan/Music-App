import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/download/download_controller.dart';
import '../../services/music/music_controller.dart';
import '../../models/song.dart';
import '../mini_player.dart';
import 'widgets/download_stats.dart';
import 'widgets/downloaded_songs_list.dart';

class DownloadedPlaylistScreen extends StatelessWidget {
  const DownloadedPlaylistScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: const Text('Download'),
        backgroundColor: const Color(0xFF121212),
        actions: [
          Consumer<DownloadController>(
            builder: (context, downloadController, child) {
              final downloadedSongs = downloadController.storage.downloadedSongs;
              if (downloadedSongs.isNotEmpty) {
                return PopupMenuButton<String>(
                  onSelected: (value) => _handleMenuAction(context, value, downloadedSongs, downloadController),
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'play_all',
                      child: Row(
                        children: [
                          Icon(Icons.play_arrow, color: Colors.white),
                          SizedBox(width: 8),
                          Text('Phát tất cả'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'shuffle',
                      child: Row(
                        children: [
                          Icon(Icons.shuffle, color: Colors.white),
                          SizedBox(width: 8),
                          Text('Phát ngẫu nhiên'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'clear_all',
                      child: Row(
                        children: [
                          Icon(Icons.delete, color: Colors.red),
                          SizedBox(width: 8),
                          Text('Xóa tất cả', style: TextStyle(color: Colors.red)),
                        ],
                      ),
                    ),
                  ],
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          Consumer<DownloadController>(
            builder: (context, downloadController, child) {
              final downloadedSongs = downloadController.storage.downloadedSongs;
              
              return Column(
                children: [
                  DownloadStats(downloadedSongs: downloadedSongs),
                  Expanded(
                    child: DownloadedSongsList(downloadedSongs: downloadedSongs),
                  ),
                ],
              );
            },
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

  void _handleMenuAction(BuildContext context, String action, List<Song> songs, DownloadController downloadController) {
    final musicController = Provider.of<MusicController>(context, listen: false);
    
    switch (action) {
      case 'play_all':
        if (songs.isNotEmpty) {
          musicController.playSong(context, songs.first, playlist: songs, index: 0);
        }
        break;
      case 'shuffle':
        if (songs.isNotEmpty) {
          final shuffledSongs = List<Song>.from(songs)..shuffle();
          musicController.playSong(context, shuffledSongs.first, playlist: shuffledSongs, index: 0);
        }
        break;
      case 'clear_all':
        _showClearAllDialog(context, downloadController);
        break;
    }
  }

  void _showClearAllDialog(BuildContext context, DownloadController downloadController) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        title: const Text('Xóa tất cả download', style: TextStyle(color: Colors.white)),
        content: const Text(
          'Bạn có chắc chắn muốn xóa tất cả bài hát đã tải?',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () {
              downloadController.storage.clearAllDownloads();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Đã xóa tất cả bài hát đã tải')),
              );
            },
            child: const Text('Xóa', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}


