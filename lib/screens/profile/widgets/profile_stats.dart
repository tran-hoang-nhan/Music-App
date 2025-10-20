import 'package:flutter/material.dart';

class ProfileStats extends StatelessWidget {
  final int playlistCount;
  final int favoritesCount;
  final int listenedCount;
  final int artistCount;
  final Function(int) onNavigateToLibrary;

  const ProfileStats({
    super.key,
    required this.playlistCount,
    required this.favoritesCount,
    required this.listenedCount,
    required this.artistCount,
    required this.onNavigateToLibrary,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Thống kê của bạn',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        
        // Stats Grid
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'Yêu thích',
                '$favoritesCount',
                Icons.favorite,
                () => onNavigateToLibrary(1),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildStatCard(
                'Đã nghe',
                '$listenedCount',
                Icons.music_note,
                () => onNavigateToLibrary(2),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'Playlist',
                '$playlistCount',
                Icons.playlist_play,
                () => onNavigateToLibrary(0),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildStatCard(
                'Nghệ sĩ',
                '$artistCount',
                Icons.person,
                () => {},
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E1E),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

