import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/song.dart';
import '../services/firebase_service.dart';
import '../services/music_service.dart';
import '../services/jamendo_service.dart';
import '../services/download_service.dart';
import '../services/connectivity_service.dart';
import '../widgets/offline_banner.dart';
import 'playlist_detail_screen.dart';
import 'downloaded_playlist_screen.dart';

class LibraryScreen extends StatefulWidget {
  final int? initialTabIndex;
  const LibraryScreen({super.key, this.initialTabIndex});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final FirebaseService _firebaseService = FirebaseService();
  final JamendoService _jamendoService = JamendoService();
  
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
    // Kiểm tra kết nối trước khi load
    final connectivityService = Provider.of<ConnectivityService>(context, listen: false);
    if (connectivityService.isOffline) {
      setState(() => _isLoading = false);
      return;
    }
    
    setState(() => _isLoading = true);
    
    try {
      final results = await Future.wait([
        _firebaseService.getUserPlaylists(),
        _firebaseService.getFavorites(),
        _firebaseService.getListeningHistory(limit: 15), // Giảm xuống 15
      ]);
      
      final playlists = results[0] as List<Map<String, dynamic>>;
      final favoriteIds = results[1] as List<String>;
      final recentlyPlayed = results[2] as List<Map<String, dynamic>>;
      
      // Lấy thông tin chi tiết với batch processing
      List<Song> favoriteSongs = [];
      if (favoriteIds.isNotEmpty) {
        // Chỉ lấy 3 bài mỗi lần để tránh block UI
        for (int i = 0; i < favoriteIds.length; i += 3) {
          final batch = favoriteIds.skip(i).take(3);
          final batchResults = await Future.wait(
            batch.map((songId) => _jamendoService.getSongById(songId).catchError((_) => null)),
          );
          
          final validSongs = batchResults.where((song) => song != null).cast<Song>();
          favoriteSongs.addAll(validSongs);
          
          // Update UI sau mỗi batch
          if (mounted) {
            setState(() {
              _favoriteSongs = List.from(favoriteSongs);
            });
          }
          
          // Delay giữa các batch
          if (i + 3 < favoriteIds.length) {
            await Future.delayed(const Duration(milliseconds: 300));
          }
        }
        debugPrint('Loaded ${favoriteSongs.length}/${favoriteIds.length} favorite songs');
      }
      
      if (mounted) {
        setState(() {
          _playlists = playlists;
          _favoriteSongs = favoriteSongs;
          _recentlyPlayed = recentlyPlayed;
          _isLoading = false;
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
        title: const Text('Thư viện'),
        backgroundColor: const Color(0xFF121212),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _showCreatePlaylistDialog,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: const Color(0xFFE53E3E),
          indicatorSize: TabBarIndicatorSize.tab,
          labelColor: const Color(0xFFE53E3E),
          unselectedLabelColor: Colors.grey,
          tabs: const [
            Tab(text: 'Playlist'),
            Tab(text: 'Yêu thích'),
            Tab(text: 'Gần đây'),
          ],
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            const OfflineBanner(),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildPlaylistsTab(),
                  _buildFavoritesTab(),
                  _buildRecentlyPlayedTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaylistsTab() {
    return Column(
      children: [
        // Download playlist - luôn hiển thị
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          child: Consumer<DownloadService>(
            builder: (context, downloadService, child) {
              return ListTile(
                leading: Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.download, color: Colors.white),
                ),
                title: const Text(
                  'Download',
                  style: TextStyle(color: Colors.white),
                ),
                subtitle: Text(
                  '${downloadService.downloadedSongs.length} bài hát',
                  style: const TextStyle(color: Colors.grey),
                ),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const DownloadedPlaylistScreen(),
                  ),
                ),
              );
            },
          ),
        ),
        const Divider(color: Colors.grey),
        
        // Firebase playlists
        Expanded(
          child: Consumer<ConnectivityService>(
            builder: (context, connectivity, child) {
              if (connectivity.isOffline) {
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
                      SizedBox(height: 8),
                      Text(
                        'Chỉ có thể sử dụng playlist Download',
                        style: TextStyle(color: Colors.grey, fontSize: 14),
                      ),
                    ],
                  ),
                );
              }
              
              return _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(color: Color(0xFFE53E3E)),
                    )
                  : _playlists.isEmpty
                      ? const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.playlist_play, size: 64, color: Colors.grey),
                              SizedBox(height: 16),
                              Text(
                                'Chưa có playlist nào',
                                style: TextStyle(color: Colors.grey, fontSize: 18),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
                          itemCount: _playlists.length,
                          itemBuilder: (context, index) {
                            final playlist = _playlists[index];
                            return ListTile(
                              leading: Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE53E3E),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(Icons.playlist_play, color: Colors.white),
                              ),
                              title: Text(
                                playlist['name'] ?? 'Playlist',
                                style: const TextStyle(color: Colors.white),
                              ),
                              subtitle: Text(
                                'Playlist',
                                style: const TextStyle(color: Colors.grey),
                              ),
                              trailing: IconButton(
                                icon: const Icon(Icons.more_vert, color: Colors.grey),
                                onPressed: () => _showPlaylistOptions(playlist),
                              ),
                              onTap: () => _navigateToPlaylistDetail(playlist),
                            );
                          },
                        );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildFavoritesTab() {
    return Consumer<ConnectivityService>(
      builder: (context, connectivity, child) {
        if (connectivity.isOffline) {
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
        
        if (_isLoading) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFFE53E3E)),
          );
        }
        
        if (_favoriteSongs.isEmpty) {
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

        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
          itemCount: _favoriteSongs.length,
          itemBuilder: (context, index) {
            final song = _favoriteSongs[index];
            return ListTile(
              leading: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: song.albumImage.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: song.albumImage,
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                        placeholder: (_, _) => const _LibraryPlaceholder(),
                        errorWidget: (_, _, _) => const _LibraryPlaceholder(),
                        memCacheWidth: 100,
                        memCacheHeight: 100,
                      )
                    : const _LibraryPlaceholder(),
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
                onPressed: () => _removeFavorite(song.id),
              ),
              onTap: () => _playSong(song),
            );
          },
        );
      },
    );
  }

  Widget _buildRecentlyPlayedTab() {
    return Consumer<ConnectivityService>(
      builder: (context, connectivity, child) {
        if (connectivity.isOffline) {
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
        
        if (_isLoading) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFFE53E3E)),
          );
        }
        
        if (_recentlyPlayed.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.history, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  'Chưa có lịch sử nghe nhạc',
                  style: TextStyle(color: Colors.grey, fontSize: 18),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
          itemCount: _recentlyPlayed.length,
          itemBuilder: (context, index) {
            final item = _recentlyPlayed[index];
            final songId = item['songId']?.toString();
            
            return FutureBuilder<Song?>(
              future: songId != null ? _jamendoService.getSongById(songId) : null,
              builder: (context, snapshot) {
                final song = snapshot.data;
                
                return ListTile(
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: song?.albumImage.isNotEmpty == true
                        ? CachedNetworkImage(
                            imageUrl: song!.albumImage,
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                            placeholder: (_, _) => const _LibraryPlaceholder(),
                            errorWidget: (_, _, _) => const _LibraryPlaceholder(),
                            memCacheWidth: 100,
                            memCacheHeight: 100,
                          )
                        : const _LibraryPlaceholder(),
                  ),
                  title: Text(
                    item['songName'] ?? 'Không rõ',
                    style: const TextStyle(color: Colors.white),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text(
                    item['artistName'] ?? 'Không rõ',
                    style: const TextStyle(color: Colors.grey),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: Text(
                    'Lượt phát: ${item['playCount'] ?? 1}',
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                  onTap: song != null ? () => _playSongFromRecent(song) : null,
                );
              },
            );
          },
        );
      },
    );
  }
  
  void _playSongFromRecent(Song song) {
    final musicService = Provider.of<MusicService>(context, listen: false);
    musicService.playSong(song);
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
                  final navigator = Navigator.of(context);
                  final scaffoldMessenger = ScaffoldMessenger.of(context);
                  
                  final playlistId = await _firebaseService.createPlaylist(
                    nameController.text.trim(),
                    descriptionController.text.trim(),
                  );
                  
                  if (playlistId != null && mounted) {
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

  void _showPlaylistOptions(Map<String, dynamic> playlist) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E1E1E),
      isScrollControlled: true,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.edit, color: Colors.white),
                title: const Text('Chỉnh sửa', style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.pop(context);
                  // TODO: Edit playlist
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text('Xóa playlist', style: TextStyle(color: Colors.red)),
                onTap: () async {
                  final navigator = Navigator.of(context);
                  final scaffoldMessenger = ScaffoldMessenger.of(context);
                  
                  navigator.pop();
                  final success = await _firebaseService.deletePlaylist(playlist['id']);
                  if (success && mounted) {
                    _loadData();
                    scaffoldMessenger.showSnackBar(
                      const SnackBar(
                        content: Text('Đã xóa playlist'),
                        backgroundColor: Color(0xFFE53E3E),
                      ),
                    );
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _navigateToPlaylistDetail(Map<String, dynamic> playlist) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PlaylistDetailScreen(playlist: playlist),
      ),
    );
  }

  void _playSong(Song song) {
    final musicService = Provider.of<MusicService>(context, listen: false);
    musicService.playSong(song, playlist: _favoriteSongs);
  }

  Future<void> _removeFavorite(String songId) async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    
    final success = await _firebaseService.toggleFavorite(songId);
    if (success && mounted) {
      _loadData();
      scaffoldMessenger.showSnackBar(
        const SnackBar(
          content: Text('Đã xóa khỏi danh sách yêu thích'),
          backgroundColor: Color(0xFFE53E3E),
        ),
      );
    }
  }



  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}

class _LibraryPlaceholder extends StatelessWidget {
  const _LibraryPlaceholder();

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