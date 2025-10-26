import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../models/song.dart';
import '../../../services/firebase/firebase_controller.dart';
import '../../../services/music/music_controller.dart';
import '../../../services/connectivity_service.dart';


class FavoritesTab extends StatefulWidget {
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
  State<FavoritesTab> createState() => _FavoritesTabState();
}

class _FavoritesTabState extends State<FavoritesTab> {
  int _sortOption = 0; // 0: A-Z, 1: Z-A, 2: Gần đây thêm

  List<Song> get _sortedSongs {
    if (widget.favoriteSongs.isEmpty) return [];
    
    final list = List<Song>.from(widget.favoriteSongs);
    
    switch (_sortOption) {
      case 0: // A-Z
        list.sort((a, b) => a.name.compareTo(b.name));
        break;
      case 1: // Z-A
        list.sort((a, b) => b.name.compareTo(a.name));
        break;
      case 2: // Gần đây thêm (ngược lại thứ tự ban đầu)
        // Giữ nguyên thứ tự ban đầu (gần đây thêm là sau cùng)
        list.sort((a, b) => list.indexOf(b) - list.indexOf(a));
        break;
    }
    
    return list;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ConnectivityService>(
      builder: (context, connectivity, child) {
        if (!connectivity.isConnected) {
          return const _OfflineMessage();
        }
        
        if (widget.isLoading) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFFE53E3E)),
          );
        }
        
        if (widget.favoriteSongs.isEmpty) {
          return const _EmptyFavoritesMessage();
        }

        return Column(
          children: [
            // Sắp xếp options
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _SortButton(
                      label: 'A-Z',
                      isSelected: _sortOption == 0,
                      onPressed: () => setState(() => _sortOption = 0),
                    ),
                    const SizedBox(width: 8),
                    _SortButton(
                      label: 'Z-A',
                      isSelected: _sortOption == 1,
                      onPressed: () => setState(() => _sortOption = 1),
                    ),
                    const SizedBox(width: 8),
                    _SortButton(
                      label: 'Gần đây thêm',
                      isSelected: _sortOption == 2,
                      onPressed: () => setState(() => _sortOption = 2),
                    ),
                  ],
                ),
              ),
            ),

            // Danh sách yêu thích
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
                itemCount: _sortedSongs.length,
                itemBuilder: (context, index) {
                  final song = _sortedSongs[index];
                  return _FavoriteItem(
                    song: song,
                    onRemoved: widget.onRefresh,
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}

class _SortButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onPressed;

  const _SortButton({
    required this.label,
    required this.isSelected,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFE53E3E) : const Color(0xFF1E1E1E),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? const Color(0xFFE53E3E) : const Color(0xFF2A2A2A),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
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
    musicController.playSong(context, song);
  }

  Future<void> _removeFavorite(BuildContext context) async {
    if (!context.mounted) return;
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    
    final success = await Provider.of<FirebaseController>(context, listen: false).favorite.toggleFavorite(song.id);
    if (!context.mounted) return;
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


