import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/song.dart';
import '../../../services/download/download_controller.dart';
import '../../../services/firebase/firebase_controller.dart';

class PlayerActions extends StatelessWidget {
  final bool isFavorite;
  final VoidCallback onToggleFavorite;
  final Song song;

  const PlayerActions({
    super.key,
    required this.isFavorite,
    required this.onToggleFavorite,
    required this.song,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        // Download
        IconButton(
          onPressed: () => _downloadSong(context),
          icon: Icon(
            Icons.download,
            color: Colors.white.withValues(alpha: 0.7),
            size: 28,
          ),
        ),
        
        // Add to playlist
        IconButton(
          onPressed: () => _addToPlaylist(context),
          icon: Icon(
            Icons.playlist_add,
            color: Colors.white.withValues(alpha: 0.7),
            size: 28,
          ),
        ),
        
        // Favorite
        IconButton(
          onPressed: onToggleFavorite,
          icon: Icon(
            isFavorite ? Icons.favorite : Icons.favorite_border,
            color: isFavorite ? const Color(0xFFE53E3E) : Colors.white.withValues(alpha: 0.7),
            size: 28,
          ),
        ),
      ],
    );
  }

  void _downloadSong(BuildContext context) {
    final downloadController = Provider.of<DownloadController>(context, listen: false);
    
    if (downloadController.storage.isSongDownloaded(song.id)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bài hát đã được tải xuống')),
      );
      return;
    }

    downloadController.downloadSong(song);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Đang tải xuống bài hát...'),
        backgroundColor: Color(0xFFE53E3E),
      ),
    );
  }

  void _addToPlaylist(BuildContext context) async {
    final firebaseController = Provider.of<FirebaseController>(context, listen: false);
    final playlists = await firebaseController.playlist.getUserPlaylists();
    
    if (!context.mounted) return;
    
    if (playlists.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bạn chưa có playlist nào. Hãy tạo playlist trước.')),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E1E1E),
      builder: (context) => _PlaylistSelectionSheet(song: song, playlists: playlists),
    );
  }
}

class _PlaylistSelectionSheet extends StatelessWidget {
  final Song song;
  final List<Map<String, dynamic>> playlists;

  const _PlaylistSelectionSheet({
    required this.song,
    required this.playlists,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Thêm "${song.name}" vào playlist',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const Divider(color: Colors.grey),
          ListView.builder(
            shrinkWrap: true,
            itemCount: playlists.length,
            itemBuilder: (context, index) {
              final playlist = playlists[index];
              return ListTile(
                leading: const Icon(Icons.playlist_play, color: Color(0xFFE53E3E)),
                title: Text(
                  playlist['name'] ?? 'Playlist',
                  style: const TextStyle(color: Colors.white),
                ),
                subtitle: Text(
                  playlist['description'] ?? '',
                  style: const TextStyle(color: Colors.grey),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                onTap: () => _addToPlaylist(context, playlist['id']),
              );
            },
          ),
        ],
      ),
    );
  }

  void _addToPlaylist(BuildContext context, String playlistId) async {
    final firebaseController = Provider.of<FirebaseController>(context, listen: false);
    
    try {
      await firebaseController.playlist.addSongToPlaylist(playlistId, song);
      if (context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đã thêm bài hát vào playlist'),
            backgroundColor: Color(0xFFE53E3E),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi thêm bài hát: $e')),
        );
      }
    }
  }
}