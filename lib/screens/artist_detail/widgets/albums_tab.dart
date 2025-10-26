import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../models/album.dart';

class AlbumsTab extends StatelessWidget {
  final List<Album> albums;
  final bool isLoading;
  final Function(Album) onAlbumTap;

  const AlbumsTab({
    super.key,
    required this.albums,
    required this.isLoading,
    required this.onAlbumTap,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFFE53E3E)),
      );
    }

    if (albums.isEmpty) {
      return const Center(
        child: Text(
          'Không có album nào',
          style: TextStyle(color: Colors.grey, fontSize: 16),
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.8,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: albums.length,
      itemBuilder: (context, index) {
        final album = albums[index];
        return GestureDetector(
          onTap: () => onAlbumTap(album),
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E1E),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                    child: album.image.trim().isEmpty
                        ? Container(
                            color: const Color(0xFF2E2E2E),
                            child: const Icon(Icons.album, color: Colors.grey),
                          )
                        : CachedNetworkImage(
                            imageUrl: album.image,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            placeholder: (_, _) => Container(
                              color: const Color(0xFF2E2E2E),
                              child: const Icon(Icons.album, color: Colors.grey),
                            ),
                            errorWidget: (_, _, _) => Container(
                              color: const Color(0xFF2E2E2E),
                              child: const Icon(Icons.album, color: Colors.grey),
                            ),
                          ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        album.name,
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      if (album.releaseDate.isNotEmpty)
                        Text(
                          album.releaseDate,
                          style: const TextStyle(color: Colors.grey, fontSize: 12),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
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

