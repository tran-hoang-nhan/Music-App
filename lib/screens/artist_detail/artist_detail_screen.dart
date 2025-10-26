import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/jamendo/jamendo_controller.dart';
import '../../services/music/music_controller.dart';
import '../../models/artist.dart';
import '../../models/song.dart';
import '../../models/album.dart';
import '../mini_player.dart';
import 'widgets/artist_header.dart';
import 'widgets/popular_tracks_tab.dart';
import 'widgets/albums_tab.dart';

class ArtistDetailScreen extends StatefulWidget {
  final Artist artist;

  const ArtistDetailScreen({super.key, required this.artist});

  @override
  State<ArtistDetailScreen> createState() => _ArtistDetailScreenState();
}

class _ArtistDetailScreenState extends State<ArtistDetailScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final JamendoController _jamendoController = JamendoController();
  
  List<Song> _popularTracks = [];
  List<Album> _albums = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadArtistData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadArtistData() async {
    try {
      final results = await Future.wait([
        _jamendoController.track.getTracksByArtist(widget.artist.id),
        _jamendoController.album.getAlbumsByArtist(widget.artist.id),
      ]);

      if (mounted) {
        setState(() {
          _popularTracks = results[0] as List<Song>;
          _albums = results[1] as List<Album>;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Lỗi tải dữ liệu: $e')),
            );
          }
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: Stack(
        children: [
          NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) {
              return [
                SliverAppBar(
                  expandedHeight: 300,
                  pinned: true,
                  backgroundColor: const Color(0xFF121212),
                  leading: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                  flexibleSpace: FlexibleSpaceBar(
                    background: ArtistHeader(
                      artist: widget.artist,
                      onPlayAll: _playAllTracks,
                      onShuffle: _shuffleAndPlay,
                    ),
                  ),
                ),
                SliverPersistentHeader(
                  pinned: true,
                  delegate: _SliverTabBarDelegate(
                    TabBar(
                      controller: _tabController,
                      indicatorColor: const Color(0xFFE53E3E),
                      indicatorSize: TabBarIndicatorSize.tab,
                      labelColor: Colors.white,
                      unselectedLabelColor: Colors.grey,
                      tabs: const [
                        Tab(text: 'Bài hát phổ biến'),
                        Tab(text: 'Albums'),
                      ],
                    ),
                  ),
                ),
              ];
            },
            body: TabBarView(
              controller: _tabController,
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 100),
                  child: PopularTracksTab(
                    tracks: _popularTracks,
                    isLoading: _isLoading,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 100),
                  child: AlbumsTab(
                    albums: _albums,
                    isLoading: _isLoading,
                    onAlbumTap: _navigateToAlbum,
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Consumer<MusicController>(
              builder: (context, musicController, child) {
                return musicController.currentSong != null ? const MiniPlayer() : const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }

  void _playAllTracks() {
    if (_popularTracks.isNotEmpty) {
      final musicController = Provider.of<MusicController>(context, listen: false);
      musicController.playSong(context, _popularTracks.first, playlist: _popularTracks, index: 0);
    }
  }

  void _shuffleAndPlay() {
    if (_popularTracks.isNotEmpty) {
      final musicController = Provider.of<MusicController>(context, listen: false);
      final shuffledTracks = List<Song>.from(_popularTracks)..shuffle();
      musicController.playSong(context, shuffledTracks.first, playlist: shuffledTracks, index: 0);
    }
  }

  void _navigateToAlbum(Album album) {
    Navigator.pushNamed(
      context,
      '/album_detail',
      arguments: album,
    );
  }
}

class _SliverTabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar _tabBar;

  _SliverTabBarDelegate(this._tabBar);

  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: const Color(0xFF121212),
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverTabBarDelegate oldDelegate) {
    return false;
  }
}


