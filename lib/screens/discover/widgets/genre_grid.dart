import 'package:flutter/material.dart';

class GenreGrid extends StatelessWidget {
  const GenreGrid({super.key});

  @override
  Widget build(BuildContext context) {
    final genres = [
      {'name': 'Pop', 'color': Color(0xFFE91E63), 'icon': Icons.favorite},
      {'name': 'Rock', 'color': Color(0xFF795548), 'icon': Icons.music_note},
      {'name': 'Jazz', 'color': Color(0xFF673AB7), 'icon': Icons.piano},
      {'name': 'Electronic', 'color': Color(0xFF00BCD4), 'icon': Icons.graphic_eq},
      {'name': 'Hip Hop', 'color': Color(0xFFFF9800), 'icon': Icons.mic},
      {'name': 'Classical', 'color': Color(0xFF4CAF50), 'icon': Icons.library_music},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Thể loại', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 2.5,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: genres.length,
          itemBuilder: (context, index) {
            final genre = genres[index];
            return Container(
              decoration: BoxDecoration(
                color: genre['color'] as Color,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () {},
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Icon(genre['icon'] as IconData, color: Colors.white, size: 24),
                        const SizedBox(width: 12),
                        Text(genre['name'] as String, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

