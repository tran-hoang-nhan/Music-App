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
      return const SliverFillRemaining(
        child: Center(
          child: CircularProgressIndicator(color: Color(0xFF6D7B8D)),
        ),
      );
    }

    if (songs.isEmpty) {
      return const SliverFillRemaining(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.queue_music, size: 64, color: Colors.grey),
              SizedBox(height: 16),
              Text(
                'Không có bài hát nào',
                style: TextStyle(color: Colors.grey, fontSize: 18),
              ),
            ],
          ),
        ),
      );
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final song = songs[index];
          
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: SongTile(
              song: song,
              onTap: () => _playSong(context, index),
              playlist: songs,
              index: index,
            ),
          );
        },
        childCount: songs.length,
        addAutomaticKeepAlives: false,
        addRepaintBoundaries: false,
      ),
    );
  }

  void _playSong(BuildContext context, int index) {
    final musicController = Provider.of<MusicController>(context, listen: false);
    musicController.playSong(context, songs[index], playlist: songs, index: index);
  }
}


