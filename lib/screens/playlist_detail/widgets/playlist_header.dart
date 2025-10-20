import 'package:flutter/material.dart';

class PlaylistHeader extends StatelessWidget {
  final Map<String, dynamic> playlist;
  final VoidCallback onPlayAll;
  final VoidCallback onShuffle;
  final VoidCallback onEdit;

  const PlaylistHeader({
    super.key,
    required this.playlist,
    required this.onPlayAll,
    required this.onShuffle,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Playlist icon
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                gradient: const LinearGradient(
                  colors: [Color(0xFFE53E3E), Color(0xFFFF6B6B)],
                ),
              ),
              child: const Icon(
                Icons.queue_music,
                size: 60,
                color: Colors.white,
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Playlist name
            Text(
              playlist['name'] ?? 'Playlist',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 8),
            
            // Description
            if (playlist['description'] != null && playlist['description'].isNotEmpty)
              Text(
                playlist['description'],
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
            
            const SizedBox(height: 16),
            
            // Action buttons
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
                      style: TextStyle(color: Colors.white),
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
                      'Ngẫu nhiên',
                      style: TextStyle(color: Color(0xFFE53E3E)),
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