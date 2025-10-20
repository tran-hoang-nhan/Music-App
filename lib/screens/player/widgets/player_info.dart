import 'package:flutter/material.dart';
import '../../../models/song.dart';
import '../../../utils/app_fonts.dart';

class PlayerInfo extends StatelessWidget {
  final Song song;

  const PlayerInfo({
    super.key,
    required this.song,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          song.name,
          style: AppFonts.heading2.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () {
            // Navigate to artist detail
          },
          child: Text(
            song.artistName,
            style: AppFonts.bodyLarge.copyWith(
              color: Colors.white.withValues(alpha: 0.8),
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (song.albumName.isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(
            song.albumName,
            style: AppFonts.bodyMedium.copyWith(
              color: Colors.white.withValues(alpha: 0.6),
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ],
    );
  }
}