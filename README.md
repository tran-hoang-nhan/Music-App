# 🎵 Streaming Music Application 

Ứng dụng nghe nhạc hiện đại được xây dựng bằng Flutter với AI recommendations và Firebase backend.

## ✨ Tính năng chính

### 🎶 Phát nhạc
- Phát nhạc trực tuyến từ Jamendo API (miễn phí)
- Điều khiển đầy đủ: Play/Pause/Next/Previous
- Thanh tiến trình và hiển thị thời gian
- Chế độ lặp và phát ngẫu nhiên
- Mini player luôn hiển thị

### 🔍 Tìm kiếm thông minh
- Tìm kiếm bài hát, nghệ sĩ với AI
- Duyệt theo 10+ thể loại nhạc
- Bài hát trending và mới nhất
- Smart search với debounce

### 🤖 AI Features
- **AI Recommendations**: Gợi ý bài hát thông minh
- **Mood Detection**: Phát hiện tâm trạng từ lịch sử nghe
- **Auto Playlist**: Tạo playlist tự động theo chủ đề
- **AI Chat Assistant**: Trợ lý AI tương tác

### 👤 Quản lý người dùng
- Đăng ký/Đăng nhập với Firebase
- Lưu bài hát yêu thích
- Tạo và quản lý playlist cá nhân
- Lịch sử nghe nhạc với playCount

### 🎨 Giao diện
- Dark theme hiện đại
- Giao diện tiếng Việt
- Responsive (Web + Mobile)
- Smooth animations
- Material Design 3

## 🛠️ Công nghệ

- **Flutter 3.9.2+**: Cross-platform UI framework
- **Firebase**: Auth + Realtime Database
- **Jamendo API**: Free music streaming
- **Provider**: State management
- **AudioPlayers**: Music playback
- **CachedNetworkImage**: Image caching
- **AI Service**: Custom recommendation engine

## 🚀 Cài đặt nhanh

```bash
# Clone project
git clone https://github.com/username/Music_App.git
cd Music_App

# Cài dependencies
flutter pub get

# Chạy app
flutter run
```

## 📁 Cấu trúc project

```
lib/
├── models/          # Data models
│   └── song.dart    # Song, Album, Artist, Playlist
├── services/        # Business logic
│   ├── jamendo_service.dart    # Music API
│   ├── firebase_service.dart   # User data
│   ├── music_service.dart      # Playback
│   ├── ai_service.dart         # AI features
│   ├── gemini_service.dart     # AI chat
│   └── cache_service.dart      # Performance
├── screens/         # UI screens
│   ├── auth_screen.dart        # Login/Register
│   ├── dashboard_screen.dart   # Home + AI recommendations
│   ├── discover_screen.dart    # Browse music
│   ├── search_screen.dart      # Search + trending
│   ├── library_screen.dart     # Playlists + favorites
│   ├── player_screen.dart      # Full player
│   └── ai_chat_screen.dart     # AI assistant
└── main.dart        # App entry point
```

## 🎯 Tính năng AI

### Smart Recommendations
- Phân tích thể loại phổ biến (40%)
- So sánh thời lượng trung bình (20%)
- Yếu tố ngẫu nhiên để đa dạng (40%)
- Lọc và shuffle top results

### Mood Detection
- Phân tích lịch sử nghe nhạc
- Map genres → moods (energetic, relaxed, happy, melancholic)
- Đưa ra gợi ý phù hợp

### Auto Playlist Generator
- Workout playlist: Rock, Electronic, Pop
- Chill playlist: Jazz, Acoustic, Ambient
- Dựa trên mood hiện tại + theme

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

## 📱 Screenshots

- 🏠 **Dashboard**: AI recommendations + trending
- 🔍 **Search**: Smart search + genres
- 📚 **Library**: Playlists + favorites + history
- 🎵 **Player**: Full controls + mini player
- 🤖 **AI Chat**: Music assistant

## 🚀 Deployment

```bash
# Web
flutter build web

# Android APK
flutter build apk --release

# iOS (cần macOS)
flutter build ios --release
```

## 📊 Project Status: 87% Complete

✅ **Hoàn thành**: Music playback, Search, AI features, User management  
⏳ **Đang phát triển**: Offline mode, Background playback, Social features

## 📄 License

MIT License - Xem [LICENSE](LICENSE) để biết chi tiết.

---

**🎵 Enjoy your music with AI! 🤖**
