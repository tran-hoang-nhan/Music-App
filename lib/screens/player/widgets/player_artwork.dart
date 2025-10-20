import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../models/song.dart';

class PlayerArtwork extends StatelessWidget {
  final Song song;

  const PlayerArtwork({
    super.key,
    required this.song,
  });

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: 'song_${song.id}',
      child: Container(
        width: 300,
        height: 300,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: song.albumImage.isNotEmpty
              ? CachedNetworkImage(
                  imageUrl: song.albumImage,
                  fit: BoxFit.cover,
                  placeholder: (_, _) => const _ArtworkPlaceholder(),
                  errorWidget: (_, _, _) => const _ArtworkPlaceholder(),
                )
              : const _ArtworkPlaceholder(),
        ),
      ),
    );
  }
}

class _ArtworkPlaceholder extends StatelessWidget {
  const _ArtworkPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFFE53E3E).withValues(alpha: 0.8),
            const Color(0xFFE53E3E),
          ],
        ),
      ),
      child: const Icon(
        Icons.music_note,
        color: Colors.white,
        size: 100,
      ),
    );
  }
}