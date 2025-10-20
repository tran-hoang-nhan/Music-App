import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/song.dart';
import '../../../services/music/music_controller.dart';
import '../../song_tile.dart';

class GenreSongsList extends StatelessWidget {
  final List<Song> songs;
  final bool isLoading;

  const GenreSongsList({
    super.key,
    required this.songs,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const SliverToBoxAdapter(
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(40),
            child: CircularProgressIndicator(color: Color(0xFFE53E3E)),
          ),
        ),
      );
    }

    if (songs.isEmpty) {
      return const SliverToBoxAdapter(
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(40),
            child: Text(
              'Không tìm thấy bài hát nào cho thể loại này',
              style: TextStyle(color: Colors.grey, fontSize: 16),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final song = songs[index];
          final isCurrentSong = Provider.of<MusicController>(context, listen: false).currentSong?.id == song.id;
          
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            decoration: BoxDecoration(
              color: isCurrentSong ? const Color(0xFF2E2E2E) : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
            ),
            child: SongTile(
              song: song,
              onTap: () => _playSong(context, index),
              playlist: songs,
              index: index,
            ),
          );
        },
        childCount: songs.length,
      ),
    );
  }

  void _playSong(BuildContext context, int index) {
    final musicController = Provider.of<MusicController>(context, listen: false);
    musicController.playSong(songs[index], playlist: songs, index: index);
  }
}


