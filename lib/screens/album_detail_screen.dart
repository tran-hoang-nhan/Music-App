import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/song.dart';
import '../models/album.dart';
import '../services/jamendo_service.dart';
import '../services/music_service.dart';
import '../widgets/mini_player.dart';

class AlbumDetailScreen extends StatefulWidget {
  final Album album;

  const AlbumDetailScreen({super.key, required this.album});

  @override
  State<AlbumDetailScreen> createState() => _AlbumDetailScreenState();
}

class _AlbumDetailScreenState extends State<AlbumDetailScreen> {
  final JamendoService _jamendoService = JamendoService();
  List<Song> _albumTracks = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAlbumTracks();
  }

  Future<void> _loadAlbumTracks() async {
    try {
      debugPrint('Loading tracks for album ID: ${widget.album.id}');
      final tracks = await _jamendoService.getAlbumTracks(widget.album.id);
      debugPrint('Found ${tracks.length} tracks for album: ${widget.album.name}');
      setState(() {
        _albumTracks = tracks;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Lỗi tải tracks: $e');
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: Column(
        children: [
          Expanded(
            child: CustomScrollView(
              slivers: [
                _buildSliverAppBar(),
                SliverToBoxAdapter(child: _buildAlbumInfo()),
                SliverToBoxAdapter(child: _buildPlayButton()),
                _buildTracksList(),
                const SliverToBoxAdapter(child: SizedBox(height: 100)),
              ],
            ),
          ),
          Consumer<MusicService>(
            builder: (context, musicService, child) {
              if (musicService.currentSong != null) {
                return const MiniPlayer();
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 300,
      pinned: true,
      backgroundColor: const Color(0xFF121212),
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.grey.shade800,
                const Color(0xFF121212),
              ],
            ),
          ),
          child: Center(
            child: Hero(
              tag: 'album_${widget.album.id}',
              child: Container(
                width: 200,
                height: 200,
                margin: const EdgeInsets.only(top: 60),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: CachedNetworkImage(
                    imageUrl: widget.album.image,
                    fit: BoxFit.cover,
                    placeholder: (_, _) => Container(
                      color: const Color(0xFFE53E3E),
                      child: const Icon(Icons.album, color: Colors.white, size: 60),
                    ),
                    errorWidget: (_, _, _) => Container(
                      color: const Color(0xFFE53E3E),
                      child: const Icon(Icons.album, color: Colors.white, size: 60),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAlbumInfo() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.album.name,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            widget.album.artistName,
            style: const TextStyle(
              color: Color(0xFFE53E3E),
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            widget.album.releaseDate.isNotEmpty 
                ? 'Album • ${widget.album.releaseDate}'
                : 'Album',
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlayButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: _isLoading ? null : () => _playAlbum(),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE53E3E),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
              icon: const Icon(Icons.play_arrow),
              label: const Text('Phát', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(25),
            ),
            child: IconButton(
              onPressed: () {},
              icon: const Icon(Icons.shuffle, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTracksList() {
    if (_isLoading) {
      return const SliverToBoxAdapter(
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(40),
            child: CircularProgressIndicator(color: Color(0xFFE53E3E)),
          ),
        ),
      );
    }

    if (_albumTracks.isEmpty) {
      return SliverToBoxAdapter(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(40),
            child: Column(
              children: [
                const Icon(Icons.music_off, size: 48, color: Colors.grey),
                const SizedBox(height: 16),
                const Text(
                  'Album này hiện không có bài hát nào',
                  style: TextStyle(color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Album ID: ${widget.album.id}',
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      );
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final song = _albumTracks[index];
          return ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
            leading: Container(
              width: 30,
              alignment: Alignment.center,
              child: Text(
                '${index + 1}',
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
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
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  song.formattedDuration,
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
                IconButton(
                  icon: const Icon(Icons.more_horiz, color: Colors.grey),
                  onPressed: () => _showSongOptions(song),
                ),
              ],
            ),
            onTap: () => _playSong(song, index),
          );
        },
        childCount: _albumTracks.length,
      ),
    );
  }

  void _playAlbum() {
    if (_albumTracks.isNotEmpty) {
      final musicService = Provider.of<MusicService>(context, listen: false);
      musicService.playSong(_albumTracks.first, playlist: _albumTracks);
    }
  }

  void _playSong(Song song, int index) {
    final musicService = Provider.of<MusicService>(context, listen: false);
    musicService.playSong(song, playlist: _albumTracks, index: index);
  }

  void _showSongOptions(Song song) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E1E1E),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.play_arrow, color: Colors.white),
              title: const Text('Phát ngay', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                _playSong(song, _albumTracks.indexOf(song));
              },
            ),
            ListTile(
              leading: const Icon(Icons.favorite_border, color: Colors.white),
              title: const Text('Thêm vào yêu thích', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                // TODO: Add to favorites
              },
            ),
          ],
        ),
      ),
    );
  }
}