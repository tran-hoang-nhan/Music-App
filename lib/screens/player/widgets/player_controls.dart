import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../services/music/music_controller.dart';

class PlayerControls extends StatelessWidget {
  const PlayerControls({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<MusicController>(
      builder: (context, musicController, child) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // Shuffle
            IconButton(
              onPressed: () => musicController.toggleShuffle(),
              icon: Icon(
                Icons.shuffle,
                color: musicController.isShuffled ? const Color(0xFFE53E3E) : Colors.white.withValues(alpha: 0.7),
                size: 28,
              ),
            ),
            
            // Previous
            IconButton(
              onPressed: () => musicController.playPrevious(context),
              icon: const Icon(
                Icons.skip_previous,
                color: Colors.white,
                size: 40,
              ),
            ),
            
            // Play/Pause
            Container(
              width: 80,
              height: 80,
              decoration: const BoxDecoration(
                color: Color(0xFFE53E3E),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                onPressed: () {
                  if (musicController.isPlaying) {
                    musicController.pause();
                  } else {
                    musicController.resume();
                  }
                },
                icon: Icon(
                  musicController.isPlaying ? Icons.pause : Icons.play_arrow,
                  color: Colors.white,
                  size: 36,
                ),
              ),
            ),
            
            // Next
            IconButton(
              onPressed: () => musicController.playNext(context),
              icon: const Icon(
                Icons.skip_next,
                color: Colors.white,
                size: 40,
              ),
            ),
            
            // Repeat
            IconButton(
              onPressed: () => musicController.toggleRepeat(),
              icon: Icon(
                Icons.repeat,
                color: musicController.isRepeating ? const Color(0xFFE53E3E) : Colors.white.withValues(alpha: 0.7),
                size: 28,
              ),
            ),
          ],
        );
      },
    );
  }
}