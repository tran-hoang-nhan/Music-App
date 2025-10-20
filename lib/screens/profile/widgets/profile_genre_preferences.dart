import 'package:flutter/material.dart';

class ProfileGenrePreferences extends StatelessWidget {
  final Map<String, int> genreCounts;

  const ProfileGenrePreferences({
    super.key,
    required this.genreCounts,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Thể loại yêu thích',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        _buildGenreContent(),
      ],
    );
  }

  Widget _buildGenreContent() {
    if (genreCounts.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E1E),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Column(
          children: [
            Icon(Icons.music_note, color: Colors.grey, size: 48),
            SizedBox(height: 12),
            Text(
              'Chưa có dữ liệu thể loại',
              style: TextStyle(color: Colors.grey, fontSize: 16),
            ),
            SizedBox(height: 8),
            Text(
              'Nghe thêm nhạc để xem thống kê thể loại yêu thích',
              style: TextStyle(color: Colors.grey, fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    // Calculate total plays
    final totalPlays = genreCounts.values.fold(0, (sum, count) => sum + count);
    
    // Sort genres by count (descending) and take top 5
    final sortedGenres = genreCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final topGenres = sortedGenres.take(5).toList();

    // Predefined colors for genres
    final genreColors = [
      const Color(0xFFE91E63), // Pink
      const Color(0xFF00BCD4), // Cyan
      const Color(0xFFFF9800), // Orange
      const Color(0xFF9C27B0), // Purple
      const Color(0xFF4CAF50), // Green
    ];

    return Column(
      children: topGenres.asMap().entries.map((entry) {
        final index = entry.key;
        final genre = entry.value;
        final genreName = genre.key;
        final count = genre.value;
        final percentage = ((count / totalPlays) * 100).round();
        final color = genreColors[index % genreColors.length];

        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    width: 4,
                    height: 30,
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              genreName,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              '$percentage% ($count lượt)',
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        // Progress bar
                        Container(
                          height: 6,
                          decoration: BoxDecoration(
                            color: Colors.grey[800],
                            borderRadius: BorderRadius.circular(3),
                          ),
                          child: FractionallySizedBox(
                            alignment: Alignment.centerLeft,
                            widthFactor: percentage / 100,
                            child: Container(
                              decoration: BoxDecoration(
                                color: color,
                                borderRadius: BorderRadius.circular(3),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

