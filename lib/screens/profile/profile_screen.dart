import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/firebase/firebase_controller.dart';
import '../library/library_screen.dart';
import '../auth/auth_screen.dart';
import 'widgets/profile_header.dart';
import 'widgets/profile_stats.dart';
import 'widgets/profile_genre_preferences.dart';
import 'widgets/profile_settings.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic>? _userProfile;
  bool _isLoading = true;
  int _playlistCount = 0;
  int _favoritesCount = 0;
  int _listenedCount = 0;
  int _artistCount = 0;
  Map<String, int> _genreCounts = {};

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    try {
      final firebaseController = Provider.of<FirebaseController>(
        context,
        listen: false,
      );
      final user = firebaseController.auth.currentUser;
      if (user != null) {
        final profile = await firebaseController.auth.getUserProfile();
        if (!mounted) return;

        setState(() {
          _userProfile = profile;
        });

        _loadCounts(user.uid);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _loadCounts(String userId) async {
    try {
      final firebaseController = Provider.of<FirebaseController>(
        context,
        listen: false,
      );

      final playlistsFuture = firebaseController.playlist.getUserPlaylists();
      final favoritesFuture = firebaseController.favorite.getFavoriteSongs();

      final playlists = await playlistsFuture;
      final favorites = await favoritesFuture;

      // Cập nhật UI ngay với data cơ bản
      if (mounted) {
        setState(() {
          _playlistCount = playlists.length;
          _favoritesCount = favorites.length;
          _isLoading = false; // Hiển thị stats cơ bản trước
        });
      }

      // Load listening history sau (chậm hơn, có thể mất vài giây)
      final listeningHistory = await firebaseController.history
          .getListeningHistory(limit: 20);

      final Set<String> uniqueSongs = {};
      final Set<String> uniqueArtists = {};
      final Map<String, int> genreCounts = {};

      // Simulate genre data based on listening history
      final fallbackGenres = [
        'Pop',
        'Electronic',
        'Hip Hop',
        'Jazz',
        'Rock',
        'Indie',
      ];
      for (final track in listeningHistory) {
        final songId = track['songId'] as String?;
        final artistName = track['artistName'] as String?;

        if (songId != null) {
          uniqueSongs.add(songId);
          // Use songId hash to consistently assign genre
          final genreIndex = songId.hashCode.abs() % fallbackGenres.length;
          final genre = fallbackGenres[genreIndex];
          genreCounts[genre] = (genreCounts[genre] ?? 0) + 1;
        }
        if (artistName != null && artistName.isNotEmpty) {
          uniqueArtists.add(artistName.toLowerCase().trim());
        }
      }

      // Cập nhật stats chi tiết
      if (mounted) {
        setState(() {
          _listenedCount = uniqueSongs.length;
          _artistCount = uniqueArtists.length;
          _genreCounts = genreCounts;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final firebaseController = Provider.of<FirebaseController>(
      context,
      listen: false,
    );
    final user = firebaseController.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: _isLoading
          ? const Center(
        child: CircularProgressIndicator(color: Color(0xFFE53E3E)),
      )
          : SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 40),

            // Profile Header
            ProfileHeader(user: user, userProfile: _userProfile),

            const SizedBox(height: 30),

            // Statistics Section
            ProfileStats(
              playlistCount: _playlistCount,
              favoritesCount: _favoritesCount,
              listenedCount: _listenedCount,
              artistCount: _artistCount,
              onNavigateToLibrary: _navigateToLibrary,
            ),

            const SizedBox(height: 30),

            // Genre Preferences
            ProfileGenrePreferences(genreCounts: _genreCounts),

            const SizedBox(height: 30),

            // Settings Section
            ProfileSettings(
              onSignOut: _handleSignOut,
              onEditProfile: _showEditProfileDialog,
              onChangePassword: _showChangePasswordDialog,
            ),

            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  void _navigateToLibrary(int tabIndex) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LibraryScreen(initialTabIndex: tabIndex),
      ),
    );
  }

  Future<void> _handleSignOut() async {
    final firebaseController = Provider.of<FirebaseController>(
      context,
      listen: false,
    );
    await firebaseController.auth.signOut();
    if (mounted) {
      final navigator = Navigator.of(context);
      navigator.pushReplacement(
        MaterialPageRoute(builder: (context) => const AuthScreen()),
      );
    }
  }

  void _showEditProfileDialog() {
    final firebaseController = Provider.of<FirebaseController>(
      context,
      listen: false,
    );
    final user = firebaseController.currentUser;
    final nameController = TextEditingController(text: user?.displayName ?? '');
    final emailController = TextEditingController(text: user?.email ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        title: const Text(
          'Chỉnh sửa thông tin',
          style: TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Tên hiển thị',
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
              controller: emailController,
              style: const TextStyle(color: Colors.white),
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'Email',
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
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () => _updateProfile(
              nameController.text.trim(),
              emailController.text.trim(),
            ),
            child: const Text(
              'Lưu',
              style: TextStyle(color: Color(0xFFE53E3E)),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _updateProfile(String newName, String newEmail) async {
    final firebaseController = Provider.of<FirebaseController>(
      context,
      listen: false,
    );
    final user = firebaseController.currentUser;

    // Validation
    if (newName.isEmpty || newName.length < 2) {
      _showSnackBar('Tên phải có ít nhất 2 ký tự');
      return;
    }

    if (newEmail.isEmpty) {
      _showSnackBar('Email không được để trống');
      return;
    }

    // Email format validation
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(newEmail)) {
      _showSnackBar('Email không hợp lệ');
      return;
    }

    // Check if email is different
    if (newEmail == user?.email && newName == user?.displayName) {
      _showSnackBar('Không có thay đổi nào để lưu');
      return;
    }

    // If email changed, require password
    if (newEmail != user?.email) {
      _showPasswordConfirmDialog(newName, newEmail);
    } else {
      // Only name changed
      final success = await firebaseController.auth.updateProfile(
        name: newName,
      );
      if (mounted) {
        Navigator.pop(context);
        if (success) {
          _showSnackBar('Cập nhật thông tin thành công');
          _loadUserProfile();
        } else {
          _showSnackBar('Có lỗi xảy ra, vui lòng thử lại');
        }
      }
    }
  }

  void _showPasswordConfirmDialog(String newName, String newEmail) {
    final passwordController = TextEditingController();
    bool obscurePassword = true;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            backgroundColor: const Color(0xFF1E1E1E),
            title: const Text(
              'Xác nhận mật khẩu',
              style: TextStyle(color: Colors.white),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Để đổi email, vui lòng nhập mật khẩu hiện tại:',
                  style: TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: passwordController,
                  obscureText: obscurePassword,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Mật khẩu hiện tại',
                    labelStyle: const TextStyle(color: Colors.grey),
                    enabledBorder: const UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey),
                    ),
                    focusedBorder: const UnderlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFFE53E3E)),
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        obscurePassword
                            ? Icons.visibility
                            : Icons.visibility_off,
                        color: Colors.grey,
                      ),
                      onPressed: () {
                        setState(() {
                          obscurePassword = !obscurePassword;
                        });
                      },
                    ),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Hủy', style: TextStyle(color: Colors.grey)),
              ),
              TextButton(
                onPressed: () => _confirmUpdateWithPassword(
                  newName,
                  newEmail,
                  passwordController.text,
                ),
                child: const Text(
                  'Xác nhận',
                  style: TextStyle(color: Color(0xFFE53E3E)),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _confirmUpdateWithPassword(
      String newName,
      String newEmail,
      String password,
      ) async {
    if (password.isEmpty) {
      _showSnackBar('Vui lòng nhập mật khẩu');
      return;
    }

    final firebaseController = Provider.of<FirebaseController>(
      context,
      listen: false,
    );
    final user = firebaseController.currentUser;

    // Update name first if changed
    bool nameSuccess = true;
    if (newName != user?.displayName) {
      nameSuccess = await firebaseController.auth.updateProfile(name: newName);
    }

    // Update email with password
    final emailSuccess = await firebaseController.auth.updateEmailWithPassword(
      newEmail,
      password,
    );

    if (mounted) {
      Navigator.pop(context); // Close password dialog
      Navigator.pop(context); // Close edit profile dialog

      if (nameSuccess && emailSuccess) {
        _showSnackBar('Hãy xác thực email mới qua email mới của bạn nhé');
        _loadUserProfile();
      } else {
        _showSnackBar('Mật khẩu không đúng hoặc có lỗi xảy ra');
      }
    }
  }

  void _showChangePasswordDialog() {
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();
    bool obscureCurrentPassword = true;
    bool obscureNewPassword = true;
    bool obscureConfirmPassword = true;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            backgroundColor: const Color(0xFF1E1E1E),
            title: const Text(
              'Đổi mật khẩu',
              style: TextStyle(color: Colors.white),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: currentPasswordController,
                  obscureText: obscureCurrentPassword,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Mật khẩu hiện tại',
                    labelStyle: const TextStyle(color: Colors.grey),
                    enabledBorder: const UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey),
                    ),
                    focusedBorder: const UnderlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFFE53E3E)),
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        obscureCurrentPassword
                            ? Icons.visibility
                            : Icons.visibility_off,
                        color: Colors.grey,
                      ),
                      onPressed: () {
                        setState(() {
                          obscureCurrentPassword = !obscureCurrentPassword;
                        });
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: newPasswordController,
                  obscureText: obscureNewPassword,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Mật khẩu mới',
                    labelStyle: const TextStyle(color: Colors.grey),
                    enabledBorder: const UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey),
                    ),
                    focusedBorder: const UnderlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFFE53E3E)),
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        obscureNewPassword
                            ? Icons.visibility
                            : Icons.visibility_off,
                        color: Colors.grey,
                      ),
                      onPressed: () {
                        setState(() {
                          obscureNewPassword = !obscureNewPassword;
                        });
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: confirmPasswordController,
                  obscureText: obscureConfirmPassword,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Xác nhận mật khẩu mới',
                    labelStyle: const TextStyle(color: Colors.grey),
                    enabledBorder: const UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey),
                    ),
                    focusedBorder: const UnderlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFFE53E3E)),
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        obscureConfirmPassword
                            ? Icons.visibility
                            : Icons.visibility_off,
                        color: Colors.grey,
                      ),
                      onPressed: () {
                        setState(() {
                          obscureConfirmPassword = !obscureConfirmPassword;
                        });
                      },
                    ),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Hủy', style: TextStyle(color: Colors.grey)),
              ),
              TextButton(
                onPressed: () => _changePassword(
                  currentPasswordController.text,
                  newPasswordController.text,
                  confirmPasswordController.text,
                ),
                child: const Text(
                  'Đổi mật khẩu',
                  style: TextStyle(color: Color(0xFFE53E3E)),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _changePassword(
      String currentPassword,
      String newPassword,
      String confirmPassword,
      ) async {
    if (currentPassword.isEmpty) {
      _showSnackBar('Vui lòng nhập mật khẩu hiện tại');
      return;
    }

    if (newPassword.length < 6) {
      _showSnackBar('Mật khẩu mới phải có ít nhất 6 ký tự');
      return;
    }

    if (newPassword != confirmPassword) {
      _showSnackBar('Xác nhận mật khẩu không khớp');
      return;
    }

    if (currentPassword == newPassword) {
      _showSnackBar('Mật khẩu mới phải khác mật khẩu cũ');
      return;
    }

    final firebaseController = Provider.of<FirebaseController>(
      context,
      listen: false,
    );
    final success = await firebaseController.auth.changePassword(
      currentPassword,
      newPassword,
    );

    if (mounted) {
      Navigator.pop(context);
      if (success) {
        _showSnackBar('Đổi mật khẩu thành công');
      } else {
        _showSnackBar('Mật khẩu hiện tại không đúng hoặc có lỗi xảy ra');
      }
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFFE53E3E),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
