# 🎵 Streaming Music Application 

Ứng dụng nghe nhạc hiện đại được xây dựng bằng Flutter với AI recommendations và Firebase backend.

## ✨ Tính năng chính

### 🎶 Phát nhạc
- Phát nhạc trực tuyến từ Jamendo API (miễn phí)
- Điều khiển đầy đủ: Play/Pause/Next/Previous
- Thanh tiến trình và hiển thị thời gian
- Chế độ lặp và phát ngẫu nhiên
- Mini player luôn hiển thị
- Background playback support

### 🔍 Tìm kiếm & Khám phá
- Tìm kiếm bài hát, album, nghệ sĩ thông minh
- Duyệt theo 10+ thể loại nhạc (Rock, Pop, Jazz, Electronic...)
- Bài hát trending và mới nhất
- Smart search với debounce
- Genre-based discovery

### 🤖 AI Features
- **AI Recommendations**: Gợi ý bài hát dựa trên thể loại phổ biến và lịch sử nghe
- **AI Chat Assistant**: Trợ lý AI hỗ trợ tìm kiếm và khám phá nhạc

### 👤 Quản lý người dùng
- Đăng ký/Đăng nhập với Firebase Authentication
- Quên mật khẩu qua email
- Lưu bài hát yêu thích với sync real-time
- Tạo và quản lý playlist cá nhân
- Lịch sử nghe nhạc với playCount tracking
- Profile management với stats

### 🎨 Giao diện
- Dark theme hiện đại với gradient
- Giao diện tiếng Việt hoàn chỉnh
- Responsive design (Mobile optimized)
- Smooth animations và transitions
- Material Design 3 components

## 🛠️ Tech Stack

### Frontend
- **Flutter 3.9.2+**: Cross-platform UI framework
- **Provider**: State management pattern
- **Material Design 3**: Modern UI components
- **CachedNetworkImage**: Optimized image loading

### Backend & Services
- **Firebase Authentication**: User management
- **Firebase Realtime Database**: Real-time data sync
- **Jamendo API**: Free music streaming service
- **AudioPlayers**: Music playback engine

### AI & Analytics
- **Custom AI Service**: Smart recommendation engine
- **Gemini API**: AI chat assistant
- **Analytics**: User behavior tracking

## 🚀 Cài đặt & Chạy

### Prerequisites
- Flutter SDK 3.9.2+
- Dart 3.0+
- Android Studio / VS Code
- Firebase project (optional)

### Installation
```bash
# Clone repository
git clone https://github.com/tran-hoang-nhan/Music_App.git
cd Music_App

# Install dependencies
flutter pub get

# Run on device/emulator
flutter run

# Build for release
flutter build apk --release
```

## 📁 Cấu trúc project

```
lib/
├── models/          # Data models
│   ├── song.dart    # Song model
│   ├── album.dart   # Album model
│   ├── artist.dart  # Artist model
│   └── playlist.dart # Playlist model
├── services/        # Business logic
│   ├── jamendo_service.dart     # Music API integration
│   ├── firebase_service.dart    # User data & auth
│   ├── music_service.dart       # Playback control
│   ├── ai_service.dart          # AI recommendations
│   ├── gemini_service.dart      # AI chat assistant
│   ├── theme_service.dart       # Theme management
│   ├── connectivity_service.dart # Network status
│   └── download_service.dart    # Offline support
├── screens/         # UI screens
│   ├── auth_screen.dart         # Login/Register/Forgot Password
│   ├── dashboard_screen.dart    # Home + AI recommendations
│   ├── discover_screen.dart     # Browse music by genres
│   ├── library_screen.dart      # Playlists + Favorites + History
│   ├── profile_screen.dart      # User profile & settings
│   ├── player_screen.dart       # Full music player
│   ├── ai_chat_screen.dart      # AI assistant
│   ├── album_detail_screen.dart # Album details
│   ├── artist_detail_screen.dart # Artist details
│   └── playlist_detail_screen.dart # Playlist management
├── widgets/         # Reusable components
│   ├── mini_player.dart         # Bottom mini player
│   └── song_tile.dart          # Song list item
└── main.dart        # App entry point
```

## 🎯 Tính năng AI

### Smart Recommendations
- Phân tích thể loại phổ biến (40%)
- So sánh thời lượng trung bình (20%)
- Yếu tố ngẫu nhiên để đa dạng (40%)
- Lọc và shuffle top results

### AI Chat Assistant
- Tương tác bằng ngôn ngữ tự nhiên
- Hỗ trợ tìm kiếm nhạc theo yêu cầu
- Gợi ý bài hát phù hợp với sở thích

## ⚡ Performance

- **Caching**: 1 giờ cache cho API calls
- **Parallel Loading**: Tải đồng thời thay vì tuần tự
- **Optimized Queries**: Giảm 60% thời gian loading
- **Image Caching**: CachedNetworkImage với memory cache

## 🔧 Setup Firebase (Tùy chọn)

```bash
# Cài Firebase CLI
npm install -g firebase-tools
flutter pub global activate flutterfire_cli

# Cấu hình
flutterfire configure
```

## 🎵 Setup Jamendo API (Tùy chọn)

1. Đăng ký tại [Jamendo Developer](https://developer.jamendo.com/)
2. Lấy Client ID
3. Thay trong `lib/services/jamendo_service.dart`:

```dart
static const String _clientId = 'YOUR_CLIENT_ID';
```

## 📱 Màn hình chính

- 🏠 **Dashboard**: AI recommendations, popular songs, featured albums
- 🔍 **Discover**: Genre browsing, search, trending music
- 📚 **Library**: Personal playlists, favorites, listening history
- 👤 **Profile**: User stats, settings, logout
- 🎵 **Player**: Full-screen player với lyrics support
- 🤖 **AI Chat**: Music discovery assistant
- 💿 **Album/Artist Details**: Comprehensive music information

## 🚀 Deployment

```bash
# Web
flutter build web

# Android APK
flutter build apk --release

# iOS (cần macOS)
flutter build ios --release
```

## 📊 Project Status: 95% Complete

✅ **Hoàn thành**:
- ✅ Music streaming & playback
- ✅ User authentication & profile
- ✅ AI recommendations & chat
- ✅ Search & discovery
- ✅ Playlist management
- ✅ Favorites & history
- ✅ Responsive UI/UX
- ✅ Firebase integration
- ✅ Password reset
- ✅ Mini player

⏳ **Đang phát triển**:
- 🔄 Offline mode
- 🔄 Social features
- 🔄 Lyrics integration
- 🔄 Advanced equalizer

## 📄 License

MIT License - Xem [LICENSE](LICENSE) để biết chi tiết.

---

**🎵 Enjoy your music with AI! 🤖**
