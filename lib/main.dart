import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'screens/dashboard_screen.dart';
import 'screens/discover_screen.dart';
import 'screens/library_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/auth_screen.dart';
import 'widgets/mini_player.dart';
import 'services/music_service.dart';
import 'services/firebase_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MusicApp());
}

class MusicApp extends StatelessWidget {
  const MusicApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MusicService()),
      ],
      child: MaterialApp(
        title: 'Ứng dụng Âm nhạc',
        debugShowCheckedModeBanner: false,
        routes: {
          '/discover': (context) {
            final args = ModalRoute.of(context)?.settings.arguments as int?;
            return DiscoverScreen(initialTabIndex: args);
          },
        },
        theme: ThemeData(
          scaffoldBackgroundColor: const Color(0xFF121212),
          primaryColor: const Color(0xFFE53E3E),
          colorScheme: const ColorScheme.dark(
            primary: Color(0xFFE53E3E),
            secondary: Color(0xFFE53E3E),
            surface: Color(0xFF121212),
          ),
          bottomNavigationBarTheme: const BottomNavigationBarThemeData(
            backgroundColor: Color(0xFF1E1E1E),
            selectedItemColor: Color(0xFFE53E3E),
            unselectedItemColor: Colors.grey,
          ),
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFF121212),
            elevation: 0,
            titleTextStyle: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        home: StreamBuilder(
          stream: FirebaseService().authStateChanges,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                backgroundColor: Color(0xFF121212),
                body: Center(
                  child: CircularProgressIndicator(color: Color(0xFFE53E3E)),
                ),
              );
            }
            
            if (snapshot.hasData) {
              return const MainScreen();
            }
            
            return const AuthScreen();
          },
        ),
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
    const LibraryScreen(),
    const ProfileScreen(),
  ];

  void switchToTab(int index) {
    setState(() => _currentIndex = index);
  }

  void _navigateToDiscover(int tabIndex) {
    setState(() => _currentIndex = 1);
    // The discover screen will handle the tab index internally
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(child: _screens[_currentIndex]),
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
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFF1E1E1E).withValues(alpha: 0.9),
              const Color(0xFF121212),
            ],
          ),
        ),
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.transparent,
          elevation: 0,
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Trang chủ',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.explore),
              label: 'Khám phá',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.library_music),
              label: 'Thư viện',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'Cá nhân',
            ),
          ],
        ),
      ),
    );
  }
}