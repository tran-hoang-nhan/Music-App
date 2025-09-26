import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/song.dart';
import '../services/music_service.dart';

class SongTile extends StatelessWidget {
  final Song song;
  final List<Song>? playlist;
  final int? index;
  final bool showAIBadge;
  final VoidCallback? onTap;

  const SongTile({
    super.key,
    required this.song,
    this.playlist,
    this.index,
    this.showAIBadge = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: CachedNetworkImage(
              imageUrl: song.albumImage,
              width: 50,
              height: 50,
              fit: BoxFit.cover,
              placeholder: (_, __) => const _SongPlaceholder(),
              errorWidget: (_, __, ___) => const _SongPlaceholder(),
              memCacheWidth: 100,
              memCacheHeight: 100,
            ),
          ),
          if (showAIBadge)
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: const Color(0xFFE53E3E),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Icon(
                  Icons.auto_awesome,
                  color: Colors.white,
                  size: 10,
                ),
              ),
            ),
        ],
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
      trailing: Text(
        song.formattedDuration,
        style: const TextStyle(color: Colors.grey, fontSize: 12),
      ),
      onTap: onTap ?? () => _defaultPlaySong(context),
    );
  }

  void _defaultPlaySong(BuildContext context) {
    final musicService = Provider.of<MusicService>(context, listen: false);
    musicService.playSong(song, playlist: playlist, index: index);
  }
}

class _SongPlaceholder extends StatelessWidget {
  const _SongPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 50,
      height: 50,
      color: const Color(0xFFE53E3E),
      child: const Icon(Icons.music_note, color: Colors.white),
    );
  }
}