import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../services/music/music_controller.dart';

class PlayerProgress extends StatelessWidget {
  const PlayerProgress({super.key});

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MusicController>(
      builder: (context, musicController, child) {
        final totalDuration = musicController.totalDuration.inMilliseconds;
        final currentPosition = musicController.currentPosition.inMilliseconds;
        final progress = totalDuration > 0 ? currentPosition / totalDuration : 0.0;

        return Column(
          children: [
            SliderTheme(
              data: SliderTheme.of(context).copyWith(
                trackHeight: 4,
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
                overlayShape: const RoundSliderOverlayShape(overlayRadius: 16),
                activeTrackColor: const Color(0xFFE53E3E),
                inactiveTrackColor: Colors.white.withValues(alpha: 0.3),
                thumbColor: const Color(0xFFE53E3E),
                overlayColor: const Color(0xFFE53E3E).withValues(alpha: 0.3),
              ),
              child: Slider(
                value: progress.clamp(0.0, 1.0),
                onChanged: (value) {
                  final newPosition = Duration(milliseconds: (value * totalDuration).round());
                  musicController.seekTo(newPosition);
                },
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _formatDuration(musicController.currentPosition),
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.7),
                    fontSize: 12,
                  ),
                ),
                Text(
                  _formatDuration(musicController.totalDuration),
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.7),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}