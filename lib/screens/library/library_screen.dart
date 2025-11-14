import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/song.dart';
import '../../services/firebase/firebase_controller.dart';
import '../../services/connectivity_service.dart';
import '../offline_banner.dart';
import 'widgets/library_tabs.dart';
import 'widgets/playlist_tab.dart';
import 'widgets/favorites_tab.dart';
import 'widgets/recent_tab.dart';

class LibraryScreen extends StatefulWidget {
  final int? initialTabIndex;
  const LibraryScreen({super.key, this.initialTabIndex});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  List<Map<String, dynamic>> _playlists = [];
  List<Song> _favoriteSongs = [];
  List<Map<String, dynamic>> _recentlyPlayed = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 3, 
      vsync: this,
      initialIndex: widget.initialTabIndex ?? 0,
    );
    _loadData();
  }

  Future<void> _loadData() async {
    final connectivityService = Provider.of<ConnectivityService>(context, listen: false);
    if (!connectivityService.isConnected) {
      setState(() => _isLoading = false);
      return;
    }
    
    setState(() => _isLoading = true);
    
    try {
      final firebaseController = Provider.of<FirebaseController>(context, listen: false);
      final playlists = await firebaseController.playlist.getUserPlaylists();
      if (mounted) {
        setState(() {
          _playlists = playlists;
          _isLoading = false; // Hiển thị UI ngay với playlists
        });
      }

      final favoriteSongs = await firebaseController.favorite.getFavoriteSongs();
      if (mounted) {
        setState(() {
          _favoriteSongs = favoriteSongs;
        });
      }

      final recentHistory = await firebaseController.history.getListeningHistory(limit: 20);
      if (mounted) {
        setState(() {
          _recentlyPlayed = recentHistory;
        });
      }

    } catch (e) {
      debugPrint('Lỗi khi load data: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: const Text('Thư Viện'),
        backgroundColor: const Color(0xFF121212),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _showCreatePlaylistDialog,
          ),
        ],
        bottom: LibraryTabs(controller: _tabController),
      ),
      body: SafeArea(
        child: Column(
          children: [
            const OfflineBanner(),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  PlaylistTab(
                    playlists: _playlists,
                    isLoading: _isLoading,
                    onRefresh: _loadData,
                    onPlaylistDeleted: _loadData,
                  ),
                  FavoritesTab(
                    favoriteSongs: _favoriteSongs,
                    isLoading: _isLoading,
                    onRefresh: _loadData,
                  ),
                  RecentTab(
                    recentlyPlayed: _recentlyPlayed,
                    isLoading: _isLoading,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCreatePlaylistDialog() {
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1E1E1E),
          title: const Text('Tạo playlist mới', style: TextStyle(color: Colors.white)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: 'Tên playlist',
                    labelStyle: TextStyle(color: Colors.grey),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFFE53E3E)),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: descriptionController,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: 'Mô tả (tùy chọn)',
                    labelStyle: TextStyle(color: Colors.grey),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFFE53E3E)),
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Hủy', style: TextStyle(color: Colors.grey)),
            ),
            TextButton(
              onPressed: () async {
                if (nameController.text.trim().isNotEmpty) {
                  if (!context.mounted) return;
                  final navigator = Navigator.of(context);
                  final scaffoldMessenger = ScaffoldMessenger.of(context);
                  
                  final firebaseController = Provider.of<FirebaseController>(context, listen: false);
                  final playlistId = await firebaseController.playlist.createPlaylist(
                    nameController.text.trim(),
                    descriptionController.text.trim(),
                  );
                  
                  if (!context.mounted) return;
                  if (playlistId != null) {
                    navigator.pop();
                    _loadData();
                    scaffoldMessenger.showSnackBar(
                      const SnackBar(
                        content: Text('Đã tạo playlist thành công'),
                        backgroundColor: Color(0xFFE53E3E),
                      ),
                    );
                  }
                }
              },
              child: const Text('Tạo', style: TextStyle(color: Color(0xFFE53E3E))),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}

