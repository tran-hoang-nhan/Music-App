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
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Genre icon
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              gradient: const LinearGradient(
                colors: [Color(0xFF6D7B8D), Color(0xFFB2B8C2)],
              ),
            ),
            child: Center(
              child: Text(
                emoji,
                style: const TextStyle(fontSize: 60),
                maxLines: 1,
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Genre name
          Text(
            displayName,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          // Action buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: onPlayAll,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6D7B8D),
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
                    side: const BorderSide(color: Color(0xFF6D7B8D)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                  icon: const Icon(Icons.shuffle, color: Color(0xFF6D7B8D)),
                  label: const Text(
                    'Ngẫu nhiên',
                    style: TextStyle(color: Color(0xFF6D7B8D)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

