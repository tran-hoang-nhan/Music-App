import 'package:flutter/material.dart';

class GenreHeader extends StatelessWidget {
  final String displayName;
  final String emoji;
  final List<Color> gradientColors;
  final VoidCallback onPlayAll;
  final VoidCallback onShuffle;

  const GenreHeader({
    super.key,
    required this.displayName,
    required this.emoji,
    required this.gradientColors,
    required this.onPlayAll,
    required this.onShuffle,
  });

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Container(
        height: 300,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: gradientColors,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  emoji,
                  style: const TextStyle(fontSize: 80),
                ),
                const SizedBox(height: 16),
                Text(
                  displayName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: onPlayAll,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                        ),
                        icon: const Icon(Icons.play_arrow),
                        label: const Text('Phát nhạc', style: TextStyle(fontSize: 16)),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: onShuffle,
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.white),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                        ),
                        icon: const Icon(Icons.shuffle, color: Colors.white),
                        label: const Text(
                          'Ngẫu nhiên',
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

