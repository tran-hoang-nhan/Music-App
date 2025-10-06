import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/song.dart';
import '../services/download_service.dart';
import '../services/music_service.dart';
import '../widgets/mini_player.dart';

class DownloadedPlaylistScreen extends StatelessWidget {
  const DownloadedPlaylistScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: const Text('Download'),
        backgroundColor: const Color(0xFF121212),
      ),
      body: Consumer<DownloadService>(
        builder: (context, downloadService, child) {
          final songs = downloadService.downloadedSongs;
          
          return Column(
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
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.download,
                        color: Colors.white,
                        size: 50,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Download',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${songs.length} bài hát • ${downloadService.downloadedSizeText}',
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
              
              // Action Buttons
              if (songs.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      ElevatedButton.icon(
                        onPressed: () => _playAllSongs(context, songs),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                        ),
                        icon: const Icon(Icons.play_arrow),
                        label: const Text('Phát tất cả'),
                      ),
                      const SizedBox(width: 12),
                      IconButton(
                        onPressed: () => _shufflePlay(context, songs),
                        icon: const Icon(Icons.shuffle, color: Colors.grey),
                      ),
                      const Spacer(),
                      PopupMenuButton<String>(
                        icon: const Icon(Icons.more_vert, color: Colors.grey),
                        color: const Color(0xFF1E1E1E),
                        onSelected: (value) {
                          if (value == 'clear') {
                            _clearAllDownloads(context);
                          }
                        },
                        itemBuilder: (context) => [
                          const PopupMenuItem(
                            value: 'clear',
                            child: Row(
                              children: [
                                Icon(Icons.delete_sweep, color: Colors.red),
                                SizedBox(width: 8),
                                Text('Xóa tất cả', style: TextStyle(color: Colors.white)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              
              const SizedBox(height: 20),
              
              // Songs List
              Expanded(
                child: songs.isEmpty
                    ? const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.download_outlined,
                              size: 64,
                              color: Colors.grey,
                            ),
                            SizedBox(height: 16),
                            Text(
                              'Chưa có bài hát nào được tải',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 18,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        itemCount: songs.length,
                        itemBuilder: (context, index) {
                          final song = songs[index];
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
                                const Icon(Icons.download_done, color: Colors.green, size: 16),
                                const SizedBox(width: 8),
                                IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                  onPressed: () => _deleteSong(context, song.id),
                                ),
                              ],
                            ),
                            onTap: () => _playSong(context, song, songs, index),
                          );
                        },
                      ),
              ),
              // Mini Player
              Consumer<MusicService>(
                builder: (context, musicService, child) {
                  if (musicService.currentSong != null) {
                    return const MiniPlayer();
                  }
                  return const SizedBox.shrink();
                },
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showDebugInfo(context),
        backgroundColor: Colors.blue,
        child: const Icon(Icons.info),
      ),
    );
  }

  void _playAllSongs(BuildContext context, List<Song> songs) {
    if (songs.isNotEmpty) {
      final musicService = Provider.of<MusicService>(context, listen: false);
      musicService.playSong(songs.first, playlist: songs);
    }
  }

  void _shufflePlay(BuildContext context, List<Song> songs) {
    if (songs.isNotEmpty) {
      final shuffledSongs = List<Song>.from(songs)..shuffle();
      final musicService = Provider.of<MusicService>(context, listen: false);
      musicService.playSong(shuffledSongs.first, playlist: shuffledSongs);
    }
  }

  void _playSong(BuildContext context, Song song, List<Song> playlist, int index) {
    final musicService = Provider.of<MusicService>(context, listen: false);
    musicService.playSong(song, playlist: playlist, index: index);
  }

  Future<void> _deleteSong(BuildContext context, String songId) async {
    final downloadService = Provider.of<DownloadService>(context, listen: false);
    await downloadService.deleteSong(songId);
    
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Đã xóa bài hát khỏi thiết bị'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
  
  Future<void> _clearAllDownloads(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        title: const Text('Xóa tất cả download?', style: TextStyle(color: Colors.white)),
        content: const Text(
          'Bạn có chắc muốn xóa tất cả bài hát đã tải?',
          style: TextStyle(color: Colors.grey),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Xóa', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    
    if (confirmed == true && context.mounted) {
      final downloadService = Provider.of<DownloadService>(context, listen: false);
      await downloadService.clearAllDownloads();
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đã xóa tất cả bài hát đã tải'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
  
  void _showDebugInfo(BuildContext context) {
    final downloadService = Provider.of<DownloadService>(context, listen: false);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        title: const Text('Debug Info', style: TextStyle(color: Colors.white)),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Downloaded songs: ${downloadService.downloadedSongs.length}', 
                   style: const TextStyle(color: Colors.white)),
              const SizedBox(height: 8),
              ...downloadService.downloadedSongs.map((song) => 
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text('- ${song.name} (${song.id})', 
                       style: const TextStyle(color: Colors.grey, fontSize: 12)),
                )
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK', style: TextStyle(color: Colors.blue)),
          ),
        ],
      ),
    );
  }
}