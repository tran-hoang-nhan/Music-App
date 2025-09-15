import 'package:flutter/material.dart';
import '../services/firebase_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final FirebaseService _firebaseService = FirebaseService();
  Map<String, dynamic>? _userProfile;
  bool _isLoading = true;
  int _playlistCount = 0;
  int _favoritesCount = 0;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    setState(() => _isLoading = true);
    
    try {
      final user = _firebaseService.currentUser;
      if (user != null) {
        final results = await Future.wait([
          _firebaseService.getUserProfile(user.uid),
          _firebaseService.getUserPlaylists(),
          _firebaseService.getFavorites(),
        ]);
        
        final profile = results[0] as Map<String, dynamic>?;
        final playlists = results[1] as List<Map<String, dynamic>>;
        final favorites = results[2] as List<String>;
        
        setState(() {
          _userProfile = profile;
          _playlistCount = playlists.length;
          _favoritesCount = favorites.length;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Lỗi tải thông tin người dùng: $e');
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = _firebaseService.currentUser;
    
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: const Text('Cá nhân'),
        backgroundColor: const Color(0xFF121212),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFFE53E3E)),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // Profile Header
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        colors: [Color(0xFFE53E3E), Color(0xFFFF6B6B)],
                      ),
                    ),
                    child: const Icon(
                      Icons.person,
                      size: 50,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  Text(
                    _userProfile?['name'] ?? user?.displayName ?? 'Người dùng',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 5),
                  
                  Text(
                    user?.email ?? 'user@example.com',
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 16,
                    ),
                  ),
                  
                  const SizedBox(height: 30),
                  
                  // Stats
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildStatItem(
                        'Playlist',
                        '$_playlistCount',
                      ),
                      _buildStatItem(
                        'Yêu thích',
                        '$_favoritesCount',
                      ),
                      _buildStatItem(
                        'Đã nghe',
                        '0', // TODO: Get listening count
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 40),
                  
                  // Profile Options
                  _buildProfileOption(
                    'Cài đặt tài khoản',
                    Icons.settings,
                    () {
                      // TODO: Navigate to account settings
                    },
                  ),
                  _buildProfileOption(
                    'Quyền riêng tư',
                    Icons.privacy_tip,
                    () {
                      // TODO: Navigate to privacy settings
                    },
                  ),
                  _buildProfileOption(
                    'Thông báo',
                    Icons.notifications,
                    () {
                      // TODO: Navigate to notification settings
                    },
                  ),
                  _buildProfileOption(
                    'Trợ giúp & Hỗ trợ',
                    Icons.help,
                    () {
                      // TODO: Navigate to help
                    },
                  ),
                  _buildProfileOption(
                    'Giới thiệu',
                    Icons.info,
                    () {
                      _showAboutDialog();
                    },
                  ),
                  
                  const SizedBox(height: 40),
                  
                  // Logout Button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _signOut,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE53E3E),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                      child: const Text(
                        'Đăng xuất',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildProfileOption(String title, IconData icon, VoidCallback onTap) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      child: InkWell(
        onTap: onTap,
        child: Row(
          children: [
            Icon(icon, color: Colors.grey, size: 24),
            const SizedBox(width: 15),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
            const Spacer(),
            const Icon(
              Icons.arrow_forward_ios,
              color: Colors.grey,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1E1E1E),
          title: const Text('Giới thiệu', style: TextStyle(color: Colors.white)),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Ứng dụng Âm nhạc',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Phiên bản 1.0.0',
                style: TextStyle(color: Colors.grey),
              ),
              SizedBox(height: 16),
              Text(
                'Ứng dụng nghe nhạc miễn phí với Jamendo API và Firebase.',
                style: TextStyle(color: Colors.white),
              ),
              SizedBox(height: 16),
              Text(
                '© 2024 Music App. Tất cả quyền được bảo lưu.',
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Đóng', style: TextStyle(color: Color(0xFFE53E3E))),
            ),
          ],
        );
      },
    );
  }

  Future<void> _signOut() async {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1E1E1E),
          title: const Text('Đăng xuất', style: TextStyle(color: Colors.white)),
          content: const Text(
            'Bạn có chắc chắn muốn đăng xuất?',
            style: TextStyle(color: Colors.white),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Hủy', style: TextStyle(color: Colors.grey)),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                await _firebaseService.signOut();
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Đã đăng xuất thành công'),
                      backgroundColor: Color(0xFFE53E3E),
                    ),
                  );
                }
              },
              child: const Text('Đăng xuất', style: TextStyle(color: Color(0xFFE53E3E))),
            ),
          ],
        );
      },
    );
  }
}