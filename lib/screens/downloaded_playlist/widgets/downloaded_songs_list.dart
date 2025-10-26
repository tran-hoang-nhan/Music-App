import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/song.dart';
import '../../../services/music/music_controller.dart';
import '../../../services/download/download_controller.dart';

class DownloadedSongsList extends StatelessWidget {
  final List<Song> downloadedSongs;

  const DownloadedSongsList({super.key, required this.downloadedSongs});

  @override
  Widget build(BuildContext context) {
    if (downloadedSongs.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.download_outlined,
              size: 80,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              'Chưa có bài hát nào được tải',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Tải xuống các bài hát yêu thích để nghe offline',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: downloadedSongs.length,
      itemBuilder: (context, index) {
        final song = downloadedSongs[index];
        final isCurrentSong = Provider.of<MusicController>(context, listen: false).currentSong?.id == song.id;
        
        return Container(
          margin: const EdgeInsets.symmetric(vertical: 4),
          decoration: BoxDecoration(
            color: isCurrentSong ? const Color(0xFF2E2E2E) : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: ListTile(
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: song.albumImage.isNotEmpty
                  ? Image.network(
                      song.albumImage,
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => Container(
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
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => _showDeleteDialog(context, song),
            ),
            onTap: () => _playDownloadedSong(context, index),
          ),
        );
      },
    );
  }

  void _showDeleteDialog(BuildContext context, Song song) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        title: const Text('Xóa bài hát', style: TextStyle(color: Colors.white)),
        content: Text(
          'Xóa "${song.name}" khỏi danh sách tải?',
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
              final downloadController = Provider.of<DownloadController>(context, listen: false);
              await downloadController.storage.removeSong(song.id);
              if (!context.mounted) return;
              Navigator.pop(context);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Đã xóa "${song.name}"')),
                );
              }
            },
            child: const Text('Xóa', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _playDownloadedSong(BuildContext context, int index) {
    final musicController = Provider.of<MusicController>(context, listen: false);
    musicController.playSong(context, downloadedSongs[index], playlist: downloadedSongs, index: index);
  }
}


