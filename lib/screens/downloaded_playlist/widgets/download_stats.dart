import 'package:flutter/material.dart';
import '../../../models/song.dart';

class DownloadStats extends StatelessWidget {
  final List<Song> downloadedSongs;

  const DownloadStats({super.key, required this.downloadedSongs});

  @override
  Widget build(BuildContext context) {
    final totalSize = downloadedSongs.fold<double>(
      0.0, 
      (sum, song) => sum + (song.duration / 60.0 * 3.5), // Estimated MB
    );

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _StatItem(
            icon: Icons.download,
            label: 'Đã tải',
            value: '${downloadedSongs.length}',
          ),
          _StatItem(
            icon: Icons.storage,
            label: 'Dung lượng',
            value: '${totalSize.toStringAsFixed(1)} MB',
          ),
          _StatItem(
            icon: Icons.access_time,
            label: 'Thời gian',
            value: _formatTotalDuration(),
          ),
        ],
      ),
    );
  }

  String _formatTotalDuration() {
    final totalSeconds = downloadedSongs.fold<int>(
      0, 
      (sum, song) => sum + song.duration,
    );
    final hours = totalSeconds ~/ 3600;
    final minutes = (totalSeconds % 3600) ~/ 60;
    
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    }
    return '${minutes}m';
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _StatItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: const Color(0xFFE53E3E), size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}

