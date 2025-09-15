# Ứng dụng Âm nhạc - Music App

Ứng dụng nghe nhạc được xây dựng bằng Flutter với Jamendo API và Firebase.

## Tính năng

### 🎵 Phát nhạc
- Phát nhạc trực tuyến từ Jamendo API
- Điều khiển phát/tạm dừng, chuyển bài
- Thanh tiến trình và hiển thị thời gian
- Chế độ lặp và phát ngẫu nhiên
- Mini player ở dưới màn hình

### 🔍 Khám phá và Tìm kiếm
- Duyệt theo thể loại nhạc
- Tìm kiếm bài hát, nghệ sĩ
- Bài hát phổ biến và mới nhất
- Album và nghệ sĩ nổi bật

### 👤 Tài khoản người dùng
- Đăng ký/Đăng nhập với Firebase Auth
- Lưu bài hát yêu thích
- Tạo và quản lý playlist
- Lịch sử nghe nhạc

### 📱 Giao diện
- Thiết kế tối (Dark theme)
- Giao diện tiếng Việt
- Responsive cho web và mobile
- Hiệu ứng và animation mượt mà

## Công nghệ sử dụng

- **Flutter**: Framework UI đa nền tảng
- **Firebase**: Authentication, Firestore, Storage
- **Jamendo API**: Nguồn nhạc miễn phí
- **Provider**: State management
- **AudioPlayers**: Phát nhạc
- **CachedNetworkImage**: Cache ảnh

## Cài đặt

### Yêu cầu
- Flutter SDK >= 3.9.2
- Dart SDK >= 3.0.0
- Firebase CLI
- Jamendo API Key

### Các bước cài đặt

1. **Clone repository**
```bash
git clone https://github.com/tran-hoang-nhan/Music-App-Flutter.git
cd Music_App
```

2. **Cài đặt dependencies**
```bash
flutter pub get
```

3. **Cấu hình Firebase**
- Xem hướng dẫn chi tiết trong `FIREBASE_SETUP.md`
- Chạy `flutterfire configure`

4. **Cấu hình Jamendo API**
- Đăng ký tại [Jamendo Developer](https://developer.jamendo.com/)
- Thay thế `YOUR_CLIENT_ID` trong `lib/services/jamendo_service.dart`

5. **Chạy ứng dụng**
```bash
flutter run -d web-server
```

## Cấu trúc thư mục

```
lib/
├── models/          # Data models (Song, Album, Artist, Playlist)
├── services/        # API services (Jamendo, Firebase, Music)
├── screens/         # Màn hình chính
│   ├── auth_screen.dart
│   ├── dashboard_screen.dart
│   ├── discover_screen.dart
│   ├── library_screen.dart
│   ├── profile_screen.dart
│   ├── search_screen.dart
│   └── player_screen.dart
├── widgets/         # Widget tái sử dụng
│   └── mini_player.dart
└── main.dart        # Entry point
```

## API và Services

### Jamendo API
- Lấy bài hát phổ biến và mới nhất
- Tìm kiếm theo tên và thể loại
- Thông tin album và nghệ sĩ
- Stream nhạc chất lượng cao

### Firebase Services
- **Authentication**: Đăng ký/đăng nhập
- **Firestore**: Lưu playlist, favorites, user data
- **Storage**: Lưu trữ file (nếu cần)

## Tính năng nâng cao

- **Offline Mode**: Cache bài hát đã nghe
- **Social Features**: Chia sẻ playlist
- **Recommendations**: Gợi ý dựa trên lịch sử
- **Equalizer**: Điều chỉnh âm thanh
- **Sleep Timer**: Hẹn giờ tắt nhạc

## Đóng góp

1. Fork repository
2. Tạo feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to branch (`git push origin feature/AmazingFeature`)
5. Tạo Pull Request

## License

Project này được phân phối dưới MIT License. Xem `LICENSE` để biết thêm thông tin.

## Liên hệ

Nếu có câu hỏi hoặc góp ý, vui lòng tạo issue hoặc liên hệ qua email.

---

**Lưu ý**: Đây là ứng dụng demo sử dụng Jamendo API cho nhạc miễn phí. Để sử dụng thương mại, cần tuân thủ các điều khoản của Jamendo.