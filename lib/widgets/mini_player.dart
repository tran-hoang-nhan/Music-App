import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../services/music_service.dart';
import '../screens/player_screen.dart';

class MiniPlayer extends StatelessWidget {
  const MiniPlayer({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<MusicService>(
      builder: (context, musicService, child) {
        final song = musicService.currentSong;
        if (song == null) return const SizedBox.shrink();

        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const PlayerScreen(),
              ),
            );
          },
          child: Container(
            height: 70,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  const Color(0xFF1E1E1E).withValues(alpha: 0.95),
                  const Color(0xFF121212),
                ],
              ),
              border: const Border(
                top: BorderSide(
                  color: Color(0xFF2A2A2A),
                  width: 0.5,
                ),
              ),
            ),
            child: Column(
              children: [
                // Thanh tiến trình
                LinearProgressIndicator(
                  value: musicService.totalDuration.inSeconds > 0
                      ? musicService.currentPosition.inSeconds / musicService.totalDuration.inSeconds
                      : 0.0,
                  backgroundColor: Colors.grey.withValues(alpha: 0.3),
                  valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFE53E3E)),
                  minHeight: 2,
                ),
                
                // Nội dung chính
                Expanded(
                  child: Row(
                    children: [
                      // Ảnh album
                      Container(
                        width: 50,
                        height: 50,
                        margin: const EdgeInsets.all(10),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: CachedNetworkImage(
                            imageUrl: song.albumImage,
                            fit: BoxFit.cover,
                            placeholder: (_, __) => Container(
                              color: const Color(0xFF1E1E1E),
                              child: const Icon(
                                Icons.music_note,
                                color: Colors.grey,
                              ),
                            ),
                            errorWidget: (_, __, ___) => Container(
                              color: const Color(0xFF1E1E1E),
                              child: const Icon(
                                Icons.music_note,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                        ),
                      ),
                      
                      // Thông tin bài hát
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              song.name,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              song.artistName,
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      
                      // Điều khiển
                      if (musicService.playlist.isNotEmpty)
                        IconButton(
                          onPressed: musicService.playPrevious,
                          icon: const Icon(
                            Icons.skip_previous,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                      
                      Container(
                        width: 40,
                        height: 40,
                        decoration: const BoxDecoration(
                          color: Color(0xFFE53E3E),
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          onPressed: () {
                            if (musicService.isPlaying) {
                              musicService.pause();
                            } else {
                              musicService.resume();
                            }
                          },
                          icon: Icon(
                            musicService.isPlaying ? Icons.pause : Icons.play_arrow,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                      
                      if (musicService.playlist.isNotEmpty)
                        IconButton(
                          onPressed: musicService.playNext,
                          icon: const Icon(
                            Icons.skip_next,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                      
                      const SizedBox(width: 8),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}