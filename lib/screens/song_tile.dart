import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/song.dart';
import '../services/download/download_controller.dart';
import '../services/music/music_controller.dart';

class SongTile extends StatelessWidget {
  final Song song;
  final List<Song>? playlist;
  final int? index;
  final bool showAIBadge;
  final bool showDownloadButton;
  final VoidCallback? onTap;

  const SongTile({
    super.key,
    required this.song,
    this.playlist,
    this.index,
    this.showAIBadge = false,
    this.showDownloadButton = true,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: song.albumImage.trim().isEmpty
                ? const _SongPlaceholder()
                : CachedNetworkImage(
                    imageUrl: song.albumImage,
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                    placeholder: (_, _) => const _SongPlaceholder(),
                    errorWidget: (_, _, _) => const _SongPlaceholder(),
                    memCacheWidth: 100,
                    memCacheHeight: 100,
                  ),
          ),
          if (showAIBadge)
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: const Color(0xFFE53E3E),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Icon(
                  Icons.auto_awesome,
                  color: Colors.white,
                  size: 10,
                ),
              ),
            ),
        ],
      ),
      title: Text(
        song.name,
        style: const TextStyle(color: Colors.white),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        song.artistName,
        style: const TextStyle(color: Colors.grey),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: SizedBox(
        width: showDownloadButton ? 120 : 60,
        child: showDownloadButton
            ? Consumer<DownloadController>(
                builder: (context, downloadController, child) {
                  try {
                    final isDownloaded = downloadController.storage.isSongDownloaded(song.id);
                    final isDownloading = downloadController.download.isDownloading(song.id);
                    
                    return Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Flexible(
                          child: Text(
                            song.formattedDuration,
                            style: const TextStyle(color: Colors.grey, fontSize: 12),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        SizedBox(
                          width: 32,
                          height: 32,
                          child: isDownloading
                              ? const CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                                )
                              : IconButton(
                                  icon: Icon(
                                    isDownloaded ? Icons.download_done : Icons.download,
                                    color: isDownloaded ? Colors.green : Colors.grey,
                                    size: 20,
                                  ),
                                  onPressed: isDownloaded ? null : () => _downloadSong(context),
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(
                                    minWidth: 32,
                                    minHeight: 32,
                                  ),
                                ),
                        ),
                      ],
                    );
                  } catch (e) {
                    // Fallback safe UI
                    return Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Flexible(
                          child: Text(
                            song.formattedDuration,
                            style: const TextStyle(color: Colors.grey, fontSize: 12),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const SizedBox(
                          width: 32,
                          height: 32,
                          child: Icon(Icons.download, color: Colors.grey, size: 20),
                        ),
                      ],
                    );
                  }
                },
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    song.formattedDuration,
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ],
              ),
      ),
  onTap: onTap ?? () => _defaultPlaySong(context),
    );
  }


  Future<void> _downloadSong(BuildContext context) async {
    if (!context.mounted) return;
    final downloadController = Provider.of<DownloadController>(context, listen: false);
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    
    final success = await downloadController.downloadSong(song);
    
    if (context.mounted) {
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text(
            success ? 'Đã tải xuống "${song.name}"' : 'Lỗi tải xuống',
          ),
          backgroundColor: success ? Colors.green : Colors.red,
        ),
      );
    }
  }

  void _defaultPlaySong(BuildContext context) {
    final musicController = Provider.of<MusicController>(context, listen: false);
    musicController.playSong(context, song, playlist: playlist, index: index);
  }
}

class _SongPlaceholder extends StatelessWidget {
  const _SongPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 50,
      height: 50,
      color: const Color(0xFFE53E3E),
      child: const Icon(Icons.music_note, color: Colors.white),
    );
  }
}


