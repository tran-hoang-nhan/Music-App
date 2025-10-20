import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../models/song.dart';
import '../../../models/album.dart';
import '../../../models/artist.dart';
import '../../../utils/app_fonts.dart';
import '../../album_detail/album_detail_screen.dart';
import '../../artist_detail/artist_detail_screen.dart';

class FeaturedSection extends StatelessWidget {
  final List<Song> popularSongs;
  final List<Album> featuredAlbums;
  final List<Artist> featuredArtists;

  const FeaturedSection({
    super.key,
    required this.popularSongs,
    required this.featuredAlbums,
    required this.featuredArtists,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Featured Albums
        if (featuredAlbums.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              'Album nổi bật',
              style: AppFonts.heading3.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: featuredAlbums.length,
              itemBuilder: (context, index) {
                final album = featuredAlbums[index];
                return _AlbumCard(album: album);
              },
            ),
          ),
          const SizedBox(height: 32),
        ],

        // Featured Artists
        if (featuredArtists.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              'Nghệ sĩ nổi bật',
              style: AppFonts.heading3.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 130,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: featuredArtists.length,
              itemBuilder: (context, index) {
                final artist = featuredArtists[index];
                return _ArtistCard(artist: artist);
              },
            ),
          ),
        ],
      ],
    );
  }
}

class _AlbumCard extends StatelessWidget {
  final Album album;

  const _AlbumCard({required this.album});

  @override
  Widget build(BuildContext context) {
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
        width: 140,
        margin: const EdgeInsets.only(right: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: album.image.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: album.image,
                      width: 140,
                      height: 140,
                      fit: BoxFit.cover,
                      placeholder: (_, _) => const _AlbumPlaceholder(),
                      errorWidget: (_, _, _) => const _AlbumPlaceholder(),
                    )
                  : const _AlbumPlaceholder(),
            ),
            const SizedBox(height: 8),
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    album.name,
                    style: AppFonts.bodyMedium.copyWith(fontWeight: FontWeight.w600),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    album.artistName,
                    style: AppFonts.bodySmall.copyWith(color: Colors.grey[400]),
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
  }
}

class _ArtistCard extends StatelessWidget {
  final Artist artist;

  const _ArtistCard({required this.artist});

  @override
  Widget build(BuildContext context) {
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
              child: artist.image.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: artist.image,
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                      placeholder: (_, _) => const _ArtistPlaceholder(),
                      errorWidget: (_, _, _) => const _ArtistPlaceholder(),
                    )
                  : const _ArtistPlaceholder(),
            ),
            const SizedBox(height: 8),
            Flexible(
              child: Text(
                artist.name,
                style: AppFonts.bodyMedium.copyWith(fontWeight: FontWeight.w600),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AlbumPlaceholder extends StatelessWidget {
  const _AlbumPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 140,
      height: 140,
      color: const Color(0xFF1E1E1E),
      child: const Icon(Icons.album, color: Colors.grey, size: 40),
    );
  }
}

class _ArtistPlaceholder extends StatelessWidget {
  const _ArtistPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 80,
      height: 80,
      decoration: const BoxDecoration(
        color: Color(0xFF1E1E1E),
        shape: BoxShape.circle,
      ),
      child: const Icon(Icons.person, color: Colors.grey, size: 30),
    );
  }
}

