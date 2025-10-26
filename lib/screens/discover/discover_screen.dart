import 'package:flutter/material.dart';
import '../../services/jamendo/jamendo_controller.dart';
import '../../models/album.dart';
import '../../models/artist.dart';
import 'widgets/genre_grid.dart';
import 'widgets/trending_section.dart';
import 'widgets/new_releases.dart';

class DiscoverScreen extends StatefulWidget {
  const DiscoverScreen({super.key});

  @override
  State<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends State<DiscoverScreen> {
  final JamendoController _jamendoController = JamendoController();
  List<Album> _newReleases = [];
  List<Artist> _trendingArtists = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      // LAZY LOADING: Load albums trước (quan trọng hơn)
      final albums = await _jamendoController.album.getFeaturedAlbums(limit: 12);
      if (mounted) {
        setState(() {
          _newReleases = albums;
          _isLoading = false; // Hiển thị UI ngay với albums
        });
      }

      // Load artists sau (trong background)
      final artists = await _jamendoController.artist.getFeaturedArtists(limit: 12);
      if (mounted) {
        setState(() {
          _trendingArtists = artists;
        });
      }
      
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: const Color(0xFF121212),
        title: const Text('Khám phá'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFE53E3E)))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const GenreGrid(),
                  const SizedBox(height: 32),
                  TrendingSection(artists: _trendingArtists),
                  const SizedBox(height: 32),
                  NewReleases(albums: _newReleases),
                  const SizedBox(height: 100),
                ],
              ),
            ),
    );
  }
}

