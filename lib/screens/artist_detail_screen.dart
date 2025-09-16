import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/song.dart';
import '../services/jamendo_service.dart';
import '../services/music_service.dart';
import 'album_detail_screen.dart';

class ArtistDetailScreen extends StatefulWidget {
  final Artist artist;

  const ArtistDetailScreen({super.key, required this.artist});

  @override
  State<ArtistDetailScreen> createState() => _ArtistDetailScreenState();
}

class _ArtistDetailScreenState extends State<ArtistDetailScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final JamendoService _jamendoService = JamendoService();
  
  List<Song> _popularTracks = [];
  List<Album> _albums = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadArtistData();
  }

  Future<void> _loadArtistData() async {
    try {
      final results = await Future.wait([
        _jamendoService.getArtistTracks(widget.artist.id, limit: 20),
        _jamendoService.getArtistAlbums(widget.artist.id, limit: 10),
      ]);
      
      setState(() {
        _popularTracks = results[0] as List<Song>;
        _albums = results[1] as List<Album>;
        _isLoading = false;
      });
    } catch (e) {
      print('Lỗi tải dữ liệu nghệ sĩ: $e');
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(),
          SliverToBoxAdapter(child: _buildArtistInfo()),
          SliverToBoxAdapter(child: _buildPlayButton()),
          SliverToBoxAdapter(child: _buildTabBar()),
          _buildTabContent(),
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 250,
      pinned: true,
      backgroundColor: const Color(0xFF121212),
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.purple.shade800,
                const Color(0xFF121212),
              ],
            ),
          ),
          child: Center(
            child: Hero(
              tag: 'artist_${widget.artist.id}',
              child: Container(
                width: 150,
                height: 150,
                margin: const EdgeInsets.only(top: 60),
                child: ClipOval(
                  child: CachedNetworkImage(
                    imageUrl: widget.artist.image,
                    fit: BoxFit.cover,
                    placeholder: (_, __) => Container(
                      color: const Color(0xFFE53E3E),
                      child: const Icon(Icons.person, color: Colors.white, size: 60),
                    ),
                    errorWidget: (_, __, ___) => Container(
                      color: const Color(0xFFE53E3E),
                      child: const Icon(Icons.person, color: Colors.white, size: 60),
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

  Widget _buildArtistInfo() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.artist.name,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Nghệ sĩ',
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 16,
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
              onPressed: _isLoading ? null : () => _playArtist(),
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

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: TabBar(
        controller: _tabController,
        indicatorColor: const Color(0xFFE53E3E),
        labelColor: const Color(0xFFE53E3E),
        unselectedLabelColor: Colors.grey,
        tabs: const [
          Tab(text: 'Bài hát phổ biến'),
          Tab(text: 'Album'),
        ],
      ),
    );
  }

  Widget _buildTabContent() {
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

    return SliverToBoxAdapter(
      child: SizedBox(
        height: 400,
        child: TabBarView(
          controller: _tabController,
          children: [
            _buildPopularTracks(),
            _buildAlbums(),
          ],
        ),
      ),
    );
  }

  Widget _buildPopularTracks() {
    if (_popularTracks.isEmpty) {
      return const Center(
        child: Text(
          'Không có bài hát nào',
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: _popularTracks.length,
      itemBuilder: (context, index) {
        final song = _popularTracks[index];
        return ListTile(
          contentPadding: EdgeInsets.zero,
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
            song.albumName,
            style: const TextStyle(color: Colors.grey),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          trailing: Text(
            song.formattedDuration,
            style: const TextStyle(color: Colors.grey, fontSize: 12),
          ),
          onTap: () => _playSong(song, index),
        );
      },
    );
  }

  Widget _buildAlbums() {
    if (_albums.isEmpty) {
      return const Center(
        child: Text(
          'Không có album nào',
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.8,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: _albums.length,
      itemBuilder: (context, index) {
        final album = _albums[index];
        return GestureDetector(
          onTap: () => _navigateToAlbum(album),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: CachedNetworkImage(
                    imageUrl: album.image,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    placeholder: (_, __) => Container(
                      color: const Color(0xFFE53E3E),
                      child: const Icon(Icons.album, color: Colors.white),
                    ),
                    errorWidget: (_, __, ___) => Container(
                      color: const Color(0xFFE53E3E),
                      child: const Icon(Icons.album, color: Colors.white),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                album.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                album.releaseDate,
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        );
      },
    );
  }

  void _playArtist() {
    if (_popularTracks.isNotEmpty) {
      final musicService = Provider.of<MusicService>(context, listen: false);
      musicService.playSong(_popularTracks.first, playlist: _popularTracks);
    }
  }

  void _playSong(Song song, int index) {
    final musicService = Provider.of<MusicService>(context, listen: false);
    musicService.playSong(song, playlist: _popularTracks, index: index);
  }

  void _navigateToAlbum(Album album) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AlbumDetailScreen(album: album),
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}