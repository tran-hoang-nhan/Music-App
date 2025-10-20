import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../models/song.dart';
import '../../../services/firebase/firebase_controller.dart';
import '../../../services/music/music_controller.dart';
import '../../../services/connectivity_service.dart';

class FavoritesTab extends StatelessWidget {
  final List<Song> favoriteSongs;
  final bool isLoading;
  final VoidCallback onRefresh;

  const FavoritesTab({
    super.key,
    required this.favoriteSongs,
    required this.isLoading,
    required this.onRefresh,
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
        
        if (favoriteSongs.isEmpty) {
          return const _EmptyFavoritesMessage();
        }

        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
          itemCount: favoriteSongs.length,
          itemBuilder: (context, index) {
            final song = favoriteSongs[index];
            return _FavoriteItem(
              song: song,
              onRemoved: onRefresh,
            );
          },
        );
      },
    );
  }
}

class _FavoriteItem extends StatelessWidget {
  final Song song;
  final VoidCallback onRemoved;

  const _FavoriteItem({
    required this.song,
    required this.onRemoved,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: song.albumImage.isNotEmpty
            ? CachedNetworkImage(
                imageUrl: song.albumImage,
                width: 50,
                height: 50,
                fit: BoxFit.cover,
                placeholder: (_, _) => const _FavoritePlaceholder(),
                errorWidget: (_, _, _) => const _FavoritePlaceholder(),
                memCacheWidth: 50,
                memCacheHeight: 50,
                maxWidthDiskCache: 100,
                maxHeightDiskCache: 100,
              )
            : const _FavoritePlaceholder(),
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
      trailing: IconButton(
        icon: const Icon(Icons.favorite, color: Color(0xFFE53E3E)),
        onPressed: () => _removeFavorite(context),
      ),
      onTap: () => _playSong(context),
    );
  }

  void _playSong(BuildContext context) {
    final musicController = Provider.of<MusicController>(context, listen: false);
    musicController.playSong(song);
  }

  Future<void> _removeFavorite(BuildContext context) async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    
    final success = await Provider.of<FirebaseController>(context, listen: false).toggleFavorite(song.id);
    if (success) {
      onRemoved();
      scaffoldMessenger.showSnackBar(
        const SnackBar(
          content: Text('Đã xóa khỏi danh sách yêu thích'),
          backgroundColor: Color(0xFFE53E3E),
        ),
      );
    }
  }
}

class _FavoritePlaceholder extends StatelessWidget {
  const _FavoritePlaceholder();

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

class _EmptyFavoritesMessage extends StatelessWidget {
  const _EmptyFavoritesMessage();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.favorite_border, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'Chưa có bài hát yêu thích',
            style: TextStyle(color: Colors.grey, fontSize: 18),
          ),
        ],
      ),
    );
  }
}


