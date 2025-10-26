import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/song.dart';
import '../../../services/music/music_controller.dart';
import '../../song_tile.dart';

class PopularTracksTab extends StatelessWidget {
  final List<Song> tracks;
  final bool isLoading;

  const PopularTracksTab({
    super.key,
    required this.tracks,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFFE53E3E)),
      );
    }

    if (tracks.isEmpty) {
      return const Center(
        child: Text(
          'Không có bài hát phổ biến nào',
          style: TextStyle(color: Colors.grey, fontSize: 16),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: tracks.length,
      itemBuilder: (context, index) {
        final song = tracks[index];
        final isCurrentSong = Provider.of<MusicController>(context, listen: false).currentSong?.id == song.id;
        
        return Container(
          margin: const EdgeInsets.symmetric(vertical: 4),
          decoration: BoxDecoration(
            color: isCurrentSong ? const Color(0xFF2E2E2E) : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: SongTile(
            song: song,
            onTap: () => _playTrackAt(context, index),
            playlist: tracks,
            index: index,
          ),
        );
      },
    );
  }

  void _playTrackAt(BuildContext context, int index) {
    final musicController = Provider.of<MusicController>(context, listen: false);
    musicController.playSong(context, tracks[index], playlist: tracks, index: index);
  }
}


