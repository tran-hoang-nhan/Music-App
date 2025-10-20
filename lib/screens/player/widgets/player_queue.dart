import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../services/music/music_controller.dart';
import '../../../utils/app_fonts.dart';

class PlayerQueue extends StatelessWidget {
  const PlayerQueue({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<MusicController>(
      builder: (context, musicController, child) {
        final playlist = musicController.playlist;
        
        if (playlist.isEmpty) {
          return const SizedBox.shrink();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Danh sách phát (${playlist.length} bài)',
              style: AppFonts.heading3.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              constraints: const BoxConstraints(maxHeight: 300),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: playlist.length > 5 ? 5 : playlist.length,
                itemBuilder: (context, index) {
                  final song = playlist[index];
                  final isCurrentSong = song.id == musicController.currentSong?.id;
                  
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isCurrentSong 
                          ? const Color(0xFFE53E3E).withValues(alpha: 0.2)
                          : Colors.white.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: isCurrentSong 
                          ? Border.all(color: const Color(0xFFE53E3E), width: 1)
                          : null,
                    ),
                    child: Row(
                      children: [
                        Text(
                          '${index + 1}',
                          style: TextStyle(
                            color: isCurrentSong 
                                ? const Color(0xFFE53E3E)
                                : Colors.white.withValues(alpha: 0.7),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                song.name,
                                style: TextStyle(
                                  color: isCurrentSong 
                                      ? Colors.white
                                      : Colors.white.withValues(alpha: 0.9),
                                  fontWeight: isCurrentSong 
                                      ? FontWeight.bold 
                                      : FontWeight.normal,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                song.artistName,
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.6),
                                  fontSize: 12,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        if (isCurrentSong)
                          const Icon(
                            Icons.music_note,
                            color: Color(0xFFE53E3E),
                            size: 20,
                          ),
                      ],
                    ),
                  );
                },
              ),
            ),
            if (playlist.length > 5)
              TextButton(
                onPressed: () => _showFullQueue(context, playlist),
                child: Text(
                  'Xem tất cả ${playlist.length} bài',
                  style: const TextStyle(
                    color: Color(0xFFE53E3E),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  void _showFullQueue(BuildContext context, List playlist) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF121212),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
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
                      'Danh sách phát',
                      style: AppFonts.heading3.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      controller: scrollController,
                      itemCount: playlist.length,
                      itemBuilder: (context, index) {
                        final song = playlist[index];
                        return ListTile(
                          title: Text(
                            song.name,
                            style: const TextStyle(color: Colors.white),
                          ),
                          subtitle: Text(
                            song.artistName,
                            style: const TextStyle(color: Colors.grey),
                          ),
                          onTap: () {
                            Navigator.pop(context);
                            // Play this song
                          },
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