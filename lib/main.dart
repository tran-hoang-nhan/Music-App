import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'firebase_options.dart';
import 'screens/dashboard/dashboard_screen.dart';
import 'screens/discover/discover_screen.dart';
import 'screens/library/library_screen.dart';
import 'screens/profile/profile_screen.dart';
import 'screens/search/search_screen.dart';
import 'screens/auth/auth_screen.dart';
import 'screens/playlist_edit/playlist_edit_screen.dart';
import 'screens/mini_player.dart';
import 'services/music/music_controller.dart';
import 'services/firebase/firebase_controller.dart';
import 'services/jamendo/jamendo_controller.dart';
import 'services/download/download_controller.dart';
import 'services/theme/theme_controller.dart';
import 'services/connectivity_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // Tối ưu memory bằng cách clear cache cũ
  try {
    // Clear cached images cũ nếu cần
    await Future.delayed(const Duration(milliseconds: 100));
  } catch (e) {
    debugPrint('Cache cleanup failed: $e');
  }
  
  runApp(const MusicApp());
}

class MusicApp extends StatelessWidget {
  const MusicApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MusicController()),
        ChangeNotifierProvider(create: (_) => FirebaseController()),
        ChangeNotifierProvider(create: (_) => JamendoController()),
        ChangeNotifierProvider(create: (_) => DownloadController()),
        ChangeNotifierProvider(create: (_) => ThemeController()),
        ChangeNotifierProvider(create: (_) => ConnectivityService()),
      ],
      child: Consumer<ThemeController>(
        builder: (context, themeController, _) {
          return MaterialApp(
            title: 'Ứng dụng Âm nhạc',
            debugShowCheckedModeBanner: false,
            routes: {
              '/discover': (context) {
                return const DiscoverScreen();
              },
              '/playlist_edit': (context) {
                final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
                if (args == null) {
                  return Scaffold(
                    body: Center(
                      child: Text('Lỗi: Thông tin playlist không xác định'),
                    ),
                  );
                }
                return PlaylistEditScreen(
                  playlistId: args['id'] as String,
                  playlistName: args['name'] as String,
                  playlistDescription: args['description'] as String?,
                  currentImageUrl: args['imageUrl'] as String?,
                );
              },
            },
            // Apply Material 3 themes provided by ThemeController
            theme: themeController.lightTheme,
            darkTheme: themeController.darkTheme,
            themeMode: themeController.themeMode,
            home: const SplashScreen(),
          );
        },
      ),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const DashboardScreen(),
    const DiscoverScreen(),
    const SearchScreen(),
    const LibraryScreen(),
    const ProfileScreen(),
  ];

  void switchToTab(int index) {
    setState(() => _currentIndex = index);
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(child: _screens[_currentIndex]),
          Consumer<MusicController>(
            builder: (context, musicController, _) {
              if (musicController.currentSong != null) {
                return const MiniPlayer();
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Color(0xFF121212),
          border: Border(
            top: BorderSide(
              color: Color(0xFF2A2A2A),
              width: 0.5,
            ),
          ),
        ),
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          backgroundColor: const Color(0xFF121212),
          elevation: 0,
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          selectedItemColor: Colors.redAccent,
          unselectedItemColor: const Color(0xFF888888),
          selectedLabelStyle: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
          unselectedLabelStyle: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: FontWeight.normal,
          ),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'Trang chủ',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.explore_outlined),
              activeIcon: Icon(Icons.explore),
              label: 'Khám phá',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.search_outlined),
              activeIcon: Icon(Icons.search),
              label: 'Tìm kiếm',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.library_music_outlined),
              activeIcon: Icon(Icons.library_music),
              label: 'Thư viện',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: 'Cá nhân',
            ),
          ],
        ),
      ),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuthState();
  }

  Future<void> _checkAuthState() async {
    // Đợi ít nhất 1 giây để hiển thị splash
    await Future.delayed(const Duration(seconds: 1));
    
    if (!mounted) return;
    
    // Get controllers before any async operations
    final firebaseController = Provider.of<FirebaseController>(context, listen: false);
    
    // DownloadController tự động load downloaded songs trong constructor
    // Không cần gọi lại ở đây
    
    if (!mounted) return;
    
    final navigator = Navigator.of(context);
    if (firebaseController.isLoggedIn) {
      navigator.pushReplacement(
        MaterialPageRoute(builder: (context) => const MainScreen()),
      );
    } else {
      navigator.pushReplacement(
        MaterialPageRoute(builder: (context) => const AuthScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo
            Container(
              width: 120,
              height: 120,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [Color(0xFFE53E3E), Color(0xFFFF6B6B)],
                ),
              ),
              child: const Icon(
                Icons.music_note,
                size: 60,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 24),
            
            // App name
            Text(
              'Ứng dụng Âm nhạc',
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            
            Text(
              'Khám phá âm nhạc với AI',
              style: GoogleFonts.poppins(
                color: Colors.grey,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 48),
            
            // Loading indicator
            const CircularProgressIndicator(
              color: Color(0xFFE53E3E),
              strokeWidth: 3,
            ),
          ],
        ),
      ),
    );
  }
}


