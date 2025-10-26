import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../models/artist.dart';
import '../../artist_detail/artist_detail_screen.dart';

class TrendingSection extends StatelessWidget {
  final List<Artist> artists;

  const TrendingSection({super.key, required this.artists});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Nghệ sĩ thịnh hành', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        SizedBox(
          height: 120,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: artists.length,
            itemBuilder: (context, index) {
              final artist = artists[index];
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ArtistDetailScreen(artist: artist),
                    ),
                  );
                },
                child: Container(
                  width: 100,
                  margin: const EdgeInsets.only(right: 16),
                  child: Column(
                    children: [
                      ClipOval(
                        child: artist.image.trim().isEmpty
                            ? Container(
                                width: 80,
                                height: 80,
                                color: const Color(0xFF1E1E1E),
                                child: const Icon(Icons.person, color: Colors.grey),
                              )
                            : CachedNetworkImage(
                                imageUrl: artist.image,
                                width: 80,
                                height: 80,
                                fit: BoxFit.cover,
                                placeholder: (_, _) => Container(
                                  width: 80,
                                  height: 80,
                                  color: const Color(0xFF1E1E1E),
                                  child: const Icon(Icons.person, color: Colors.grey),
                                ),
                                errorWidget: (_, _, _) => Container(
                                  width: 80,
                                  height: 80,
                                  color: const Color(0xFF1E1E1E),
                                  child: const Icon(Icons.person, color: Colors.grey),
                                ),
                              ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        artist.name,
                        style: const TextStyle(color: Colors.white, fontSize: 12),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

