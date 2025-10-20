import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../models/album.dart';

class AlbumHeader extends StatelessWidget {
  final Album album;
  final VoidCallback onPlayAll;
  final VoidCallback onShuffle;

  const AlbumHeader({
    super.key,
    required this.album,
    required this.onPlayAll,
    required this.onShuffle,
  });

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Hero(
              tag: 'album_${album.id}',
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: CachedNetworkImage(
                  imageUrl: album.image,
                  width: 200,
                  height: 200,
                  fit: BoxFit.cover,
                  placeholder: (_, _) => Container(
                    width: 200,
                    height: 200,
                    color: const Color(0xFF2E2E2E),
                    child: const Icon(Icons.album, color: Colors.grey, size: 50),
                  ),
                  errorWidget: (_, _, _) => Container(
                    width: 200,
                    height: 200,
                    color: const Color(0xFF2E2E2E),
                    child: const Icon(Icons.album, color: Colors.grey, size: 50),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              album.name,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              album.artistName,
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
            if (album.releaseDate.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                album.releaseDate,
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: onPlayAll,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE53E3E),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                    icon: const Icon(Icons.play_arrow, color: Colors.white),
                    label: const Text(
                      'Phát tất cả',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onShuffle,
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFFE53E3E)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                    icon: const Icon(Icons.shuffle, color: Color(0xFFE53E3E)),
                    label: const Text(
                      'Phát ngẫu nhiên',
                      style: TextStyle(color: Color(0xFFE53E3E), fontSize: 16),
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

