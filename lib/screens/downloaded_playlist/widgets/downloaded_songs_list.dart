import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/song.dart';
import '../../../services/music/music_controller.dart';
import '../../song_tile.dart';

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
          child: SongTile(
            song: song,
            onTap: () => _playDownloadedSong(context, index),
            playlist: downloadedSongs,
            index: index,
            showDownloadButton: false,
          ),
        );
      },
    );
  }

  void _playDownloadedSong(BuildContext context, int index) {
    final musicController = Provider.of<MusicController>(context, listen: false);
    musicController.playSong(downloadedSongs[index], playlist: downloadedSongs, index: index);
  }
}


