import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../services/firebase/firebase_controller.dart';
import '../../../services/download/download_controller.dart';
import '../../../services/connectivity_service.dart';
import '../../../utils/app_fonts.dart';
import '../../downloaded_playlist/downloaded_playlist_screen.dart';
import '../../playlist_detail/playlist_detail_screen.dart';

class PlaylistTab extends StatelessWidget {
  final List<Map<String, dynamic>> playlists;
  final bool isLoading;
  final VoidCallback onRefresh;
  final VoidCallback onPlaylistDeleted;

  const PlaylistTab({
    super.key,
    required this.playlists,
    required this.isLoading,
    required this.onRefresh,
    required this.onPlaylistDeleted,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Download playlist - luôn hiển thị
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          child: Consumer<DownloadController>(
            builder: (context, downloadController, child) {
              return ListTile(
                leading: Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.download, color: Colors.white),
                ),
                title: Text(
                  'Download',
                  style: AppFonts.songTitle,
                ),
                subtitle: Text(
                  '${downloadController.storage.downloadedSongs.length} bài hát',
                  style: AppFonts.bodySmall,
                ),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const DownloadedPlaylistScreen(),
                  ),
                ),
              );
            },
          ),
        ),
        const Divider(color: Colors.grey),
        
        // Firebase playlists
        Expanded(
          child: Consumer<ConnectivityService>(
            builder: (context, connectivity, child) {
              if (!connectivity.isConnected) {
                return const _OfflineMessage();
              }
              
              return isLoading
                  ? const Center(
                      child: CircularProgressIndicator(color: Color(0xFFE53E3E)),
                    )
                  : playlists.isEmpty
                      ? const _EmptyPlaylistMessage()
                      : ListView.builder(
                          itemCount: playlists.length,
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
                          itemBuilder: (context, index) {
                            final playlist = playlists[index];
                            return _PlaylistItem(
                              playlist: playlist,
                              onDeleted: onPlaylistDeleted,
                            );
                          },
                        );
            },
          ),
        ),
      ],
    );
  }
}

class _PlaylistItem extends StatelessWidget {
  final Map<String, dynamic> playlist;
  final VoidCallback onDeleted;

  const _PlaylistItem({
    required this.playlist,
    required this.onDeleted,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: const Color(0xFFE53E3E),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(Icons.playlist_play, color: Colors.white),
      ),
      title: Text(
        playlist['name'] ?? 'Playlist',
        style: const TextStyle(color: Colors.white),
      ),
      subtitle: Text(
        'Playlist',
        style: const TextStyle(color: Colors.grey),
      ),
      trailing: IconButton(
        icon: const Icon(Icons.more_vert, color: Colors.grey),
        onPressed: () => _showPlaylistOptions(context),
      ),
      onTap: () => _navigateToPlaylistDetail(context),
    );
  }

  void _showPlaylistOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E1E1E),
      isScrollControlled: true,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text('Xóa playlist', style: TextStyle(color: Colors.red)),
                onTap: () async {
                  if (!context.mounted) return;
                  final navigator = Navigator.of(context);
                  final scaffoldMessenger = ScaffoldMessenger.of(context);
                  
                  navigator.pop();
                  if (!context.mounted) return;
                  final success = await Provider.of<FirebaseController>(context, listen: false).playlist.deletePlaylist(playlist['id']);
                  if (!context.mounted) return;
                  if (success) {
                    onDeleted();
                    scaffoldMessenger.showSnackBar(
                      const SnackBar(
                        content: Text('Đã xóa playlist'),
                        backgroundColor: Color(0xFFE53E3E),
                      ),
                    );
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _navigateToPlaylistDetail(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PlaylistDetailScreen(playlist: playlist),
      ),
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
          SizedBox(height: 8),
          Text(
            'Chỉ có thể sử dụng playlist Download',
            style: TextStyle(color: Colors.grey, fontSize: 14),
          ),
        ],
      ),
    );
  }
}

class _EmptyPlaylistMessage extends StatelessWidget {
  const _EmptyPlaylistMessage();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.playlist_play, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'Chưa có playlist nào',
            style: TextStyle(color: Colors.grey, fontSize: 18),
          ),
        ],
      ),
    );
  }
}

