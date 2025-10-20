import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/song.dart';
import '../../../services/music/music_controller.dart';
import '../../song_tile.dart';

class PlaylistSongsList extends StatelessWidget {
  final List<Song> songs;
  final bool isLoading;
  final Function(String) onRemoveSong;

  const PlaylistSongsList({
    super.key,
    required this.songs,
    required this.isLoading,
    required this.onRemoveSong,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const SliverFillRemaining(
        child: Center(
          child: CircularProgressIndicator(color: Color(0xFFE53E3E)),
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
                'Playlist trống',
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
          return Dismissible(
            key: Key(song.id),
            direction: DismissDirection.endToStart,
            background: Container(
              color: Colors.red,
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 20),
              child: const Icon(Icons.delete, color: Colors.white),
            ),
            onDismissed: (direction) => onRemoveSong(song.id),
            child: SongTile(
              song: song,
              playlist: songs,
              index: index,
              onTap: () => _playSong(context, song, index),
            ),
          );
        },
        childCount: songs.length,
      ),
    );
  }

  void _playSong(BuildContext context, Song song, int index) {
    final musicController = Provider.of<MusicController>(context, listen: false);
    musicController.playSong(song, playlist: songs, index: index);
  }
}