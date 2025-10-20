import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../models/album.dart';
import '../../album_detail/album_detail_screen.dart';

class NewReleases extends StatelessWidget {
  final List<Album> albums;

  const NewReleases({super.key, required this.albums});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Album mới', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.8,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: albums.length > 6 ? 6 : albums.length,
          itemBuilder: (context, index) {
            final album = albums[index];
            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AlbumDetailScreen(album: album),
                  ),
                );
              },
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
                        child: CachedNetworkImage(
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
                          Text(
                            album.artistName,
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
        ),
      ],
    );
  }
}

