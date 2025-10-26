import 'package:flutter/material.dart';
import '../../../models/song.dart';
import '../../../utils/app_fonts.dart';
import '../../song_tile.dart';

class RecommendationSongs extends StatelessWidget {
  final List<Song> songs;
  final String? title;

  const RecommendationSongs({
    super.key,
    required this.songs,
    this.title,
  });

  @override
  Widget build(BuildContext context) {
    if (songs.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            title ?? 'Gợi ý cho bạn',
            style: AppFonts.heading3.copyWith(fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 16),
        ...songs.take(6).map((song) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
          child: SongTile(
            song: song,
            playlist: songs,
          ),
        )),
        
        if (songs.length > 6) 
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: TextButton(
              onPressed: () => _showAllSongs(context),
              child: Text(
                'Xem tất cả ${songs.length} bài hát',
                style: AppFonts.bodyMedium.copyWith(
                  color: const Color(0xFFE53E3E),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
      ],
    );
  }

  void _showAllSongs(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF121212),
      isScrollControlled: true,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          maxChildSize: 0.9,
          minChildSize: 0.3,
          builder: (context, scrollController) {
            return Container(
              decoration: const BoxDecoration(
                color: Color(0xFF121212),
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Column(
                children: [
                  Container(
                    margin: const EdgeInsets.symmetric(vertical: 12),
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[600],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Text(
                      'Tất cả ${title ?? 'gợi ý cho bạn'}',
                      style: AppFonts.heading3.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      controller: scrollController,
                      itemCount: songs.length,
                      itemBuilder: (context, index) {
                        final song = songs[index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                          child: SongTile(
                            song: song,
                            playlist: songs,
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
