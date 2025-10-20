import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/song.dart';
import '../../../services/music/music_controller.dart';
import '../../song_tile.dart';

class AlbumTracksList extends StatelessWidget {
  final List<Song> tracks;
  final Map<String, bool> favoritesStatus;
  final Function(String) onToggleFavorite;

  const AlbumTracksList({
    super.key,
    required this.tracks,
    required this.favoritesStatus,
    required this.onToggleFavorite,
  });

  @override
  Widget build(BuildContext context) {
    if (tracks.isEmpty) {
      return const SliverToBoxAdapter(
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(40),
            child: Text(
              'Không có bài hát nào trong album này',
              style: TextStyle(color: Colors.grey, fontSize: 16),
            ),
          ),
        ),
      );
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final song = tracks[index];
          final isCurrentSong = Provider.of<MusicController>(context, listen: false).currentSong?.id == song.id;
          
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
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
        childCount: tracks.length,
      ),
    );
  }

  void _playTrackAt(BuildContext context, int index) {
    final musicController = Provider.of<MusicController>(context, listen: false);
    musicController.playSong(tracks[index], playlist: tracks, index: index);
  }
}


