import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../models/artist.dart';

class ArtistHeader extends StatelessWidget {
  final Artist artist;
  final VoidCallback onPlayAll;
  final VoidCallback onShuffle;

  const ArtistHeader({
    super.key,
    required this.artist,
    required this.onPlayAll,
    required this.onShuffle,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Hero(
              tag: 'artist_${artist.id}',
              child: CircleAvatar(
                radius: 60,
                backgroundImage: artist.image.isNotEmpty
                    ? CachedNetworkImageProvider(artist.image)
                    : null,
                backgroundColor: const Color(0xFF2E2E2E),
                child: artist.image.isEmpty
                    ? const Icon(Icons.person, color: Colors.grey, size: 40)
                    : null,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              artist.name,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 6),
            Text(
              artist.website.isNotEmpty ? 'Nghệ sĩ được xác minh' : 'Nghệ sĩ',
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: onPlayAll,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE53E3E),
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    icon: const Icon(Icons.play_arrow, color: Colors.white, size: 16),
                    label: const Text(
                      'Phát',
                      style: TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onShuffle,
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFFE53E3E)),
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    icon: const Icon(Icons.shuffle, color: Color(0xFFE53E3E), size: 16),
                    label: const Text(
                      'Trộn',
                      style: TextStyle(color: Color(0xFFE53E3E), fontSize: 12),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

