import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../services/music/music_controller.dart';

class PlayerVolume extends StatelessWidget {
  const PlayerVolume({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<MusicController>(
      builder: (context, musicController, child) {
        return Column(
          children: [
            // Volume Label
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Icon(Icons.volume_mute, color: Colors.white, size: 20),
                  Text(
                    'Âm lượng: ${(musicController.volume * 100).toInt()}%',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                  const Icon(Icons.volume_up, color: Colors.white, size: 20),
                ],
              ),
            ),
            const SizedBox(height: 8),
            
            // Volume Slider
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SliderTheme(
                data: SliderThemeData(
                  trackHeight: 4,
                  thumbShape: const RoundSliderThumbShape(
                    enabledThumbRadius: 6,
                  ),
                  overlayShape: const RoundSliderOverlayShape(
                    overlayRadius: 16,
                  ),
                  activeTrackColor: const Color(0xFFE53E3E),
                  inactiveTrackColor: Colors.grey[700],
                  thumbColor: const Color(0xFFE53E3E),
                  overlayColor: const Color(0xFFE53E3E).withValues(alpha: 0.3),
                ),
                child: Slider(
                  value: musicController.volume,
                  onChanged: (value) {
                    musicController.setVolume(value);
                  },
                  min: 0.0,
                  max: 1.0,
                  divisions: 100,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
