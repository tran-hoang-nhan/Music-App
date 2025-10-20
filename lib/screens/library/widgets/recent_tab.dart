import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../models/song.dart';
import '../../../services/jamendo/jamendo_controller.dart';
import '../../../services/music/music_controller.dart';
import '../../../services/connectivity_service.dart';

class RecentTab extends StatelessWidget {
  final List<Map<String, dynamic>> recentlyPlayed;
  final bool isLoading;

  const RecentTab({
    super.key,
    required this.recentlyPlayed,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<ConnectivityService>(
      builder: (context, connectivity, child) {
        if (!connectivity.isConnected) {
          return const _OfflineMessage();
        }
        
        if (isLoading) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFFE53E3E)),
          );
        }
        
        if (recentlyPlayed.isEmpty) {
          return const _EmptyRecentMessage();
        }

        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
          itemCount: recentlyPlayed.length,
          itemBuilder: (context, index) {
            final item = recentlyPlayed[index];
            return _RecentItem(
              item: item,
            );
          },
        );
      },
    );
  }
}

class _RecentItem extends StatelessWidget {
  final Map<String, dynamic> item;

  const _RecentItem({
    required this.item,
  });

  @override
  Widget build(BuildContext context) {
    final songId = item['songId']?.toString();
    final jamendoController = Provider.of<JamendoController>(context, listen: false);
    
    return FutureBuilder<Song?>(
      future: songId != null ? jamendoController.getTrackById(songId) : null,
      builder: (context, snapshot) {
        final song = snapshot.data;
        
        return ListTile(
          leading: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: song?.albumImage.isNotEmpty == true
                ? CachedNetworkImage(
                    imageUrl: song!.albumImage,
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                    placeholder: (_, _) => const _RecentPlaceholder(),
                    errorWidget: (_, _, _) => const _RecentPlaceholder(),
                    memCacheWidth: 50,
                    memCacheHeight: 50,
                    maxWidthDiskCache: 100,
                    maxHeightDiskCache: 100,
                  )
                : const _RecentPlaceholder(),
          ),
          title: Text(
            item['songName'] ?? 'Không rõ',
            style: const TextStyle(color: Colors.white),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Text(
            item['artistName'] ?? 'Không rõ',
            style: const TextStyle(color: Colors.grey),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          trailing: Text(
            'Lượt phát: ${item['playCount'] ?? 1}',
            style: const TextStyle(color: Colors.grey, fontSize: 12),
          ),
          onTap: song != null ? () => _playSongFromRecent(context, song) : null,
        );
      },
    );
  }

  void _playSongFromRecent(BuildContext context, Song song) {
    final musicController = Provider.of<MusicController>(context, listen: false);
    musicController.playSong(song);
  }
}

class _RecentPlaceholder extends StatelessWidget {
  const _RecentPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 50,
      height: 50,
      color: const Color(0xFF1E1E1E),
      child: const Icon(Icons.music_note, color: Colors.grey),
    );
  }
}

class _OfflineMessage extends StatelessWidget {
  const _OfflineMessage();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.cloud_off, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'Không có kết nối mạng',
            style: TextStyle(color: Colors.grey, fontSize: 18),
          ),
        ],
      ),
    );
  }
}

class _EmptyRecentMessage extends StatelessWidget {
  const _EmptyRecentMessage();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'Chưa có lịch sử nghe nhạc',
            style: TextStyle(color: Colors.grey, fontSize: 18),
          ),
        ],
      ),
    );
  }
}


