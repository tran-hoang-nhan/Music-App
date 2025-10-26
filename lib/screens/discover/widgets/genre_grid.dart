import 'package:flutter/material.dart';
import '../../genre_detail/genre_detail_screen.dart';

class GenreGrid extends StatelessWidget {
  const GenreGrid({super.key});

  @override
  Widget build(BuildContext context) {
    final genres = [
      {
        'name': 'Pop',
        'displayName': 'Pop Music',
        'color': Color(0xFFE91E63),
        'icon': Icons.favorite,
        'emoji': '🎵',
        'gradientColors': [Color(0xFFE91E63), Color(0xFFAD1457)],
      },
      {
        'name': 'Rock',
        'displayName': 'Rock Music',
        'color': Color(0xFF795548),
        'icon': Icons.music_note,
        'emoji': '🎸',
        'gradientColors': [Color(0xFF795548), Color(0xFF5D4037)],
      },
      {
        'name': 'Jazz',
        'displayName': 'Jazz Music',
        'color': Color(0xFF673AB7),
        'icon': Icons.piano,
        'emoji': '🎷',
        'gradientColors': [Color(0xFF673AB7), Color(0xFF512DA8)],
      },
      {
        'name': 'Electronic',
        'displayName': 'Electronic Music',
        'color': Color(0xFF00BCD4),
        'icon': Icons.graphic_eq,
        'emoji': '🎛️',
        'gradientColors': [Color(0xFF00BCD4), Color(0xFF0097A7)],
      },
      {
        'name': 'Hip Hop',
        'displayName': 'Hip Hop Music',
        'color': Color(0xFFFF9800),
        'icon': Icons.mic,
        'emoji': '🎤',
        'gradientColors': [Color(0xFFFF9800), Color(0xFFF57C00)],
      },
      {
        'name': 'Classical',
        'displayName': 'Classical Music',
        'color': Color(0xFF4CAF50),
        'icon': Icons.library_music,
        'emoji': '🎼',
        'gradientColors': [Color(0xFF4CAF50), Color(0xFF388E3C)],
      },
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
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => GenreDetailScreen(
                          genreName: genre['name'] as String,
                          displayName: genre['displayName'] as String,
                          emoji: genre['emoji'] as String,
                          gradientColors: genre['gradientColors'] as List<Color>,
                        ),
                      ),
                    );
                  },
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

