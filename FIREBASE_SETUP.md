# Hướng dẫn cài đặt Firebase cho Music App

## 1. Tạo Firebase Project

1. Truy cập [Firebase Console](https://console.firebase.google.com/)
2. Tạo project mới với tên "Music App"
3. Bật Google Analytics (tùy chọn)

## 2. Cài đặt Firebase CLI

```bash
npm install -g firebase-tools
firebase login
```

## 3. Cài đặt FlutterFire CLI

```bash
dart pub global activate flutterfire_cli
```

## 4. Cấu hình Firebase cho Flutter

Trong thư mục project, chạy:

```bash
flutterfire configure
```

Chọn project Firebase đã tạo và các platform cần hỗ trợ (Android, iOS, Web).

## 5. Cấu hình Authentication

1. Trong Firebase Console, vào **Authentication**
2. Chọn tab **Sign-in method**
3. Bật **Email/Password**

## 6. Cấu hình Firestore Database

1. Trong Firebase Console, vào **Firestore Database**
2. Tạo database với mode **Start in test mode**
3. Chọn location gần nhất

## 7. Cấu hình Storage

1. Trong Firebase Console, vào **Storage**
2. Tạo bucket với rules mặc định

## 8. Cập nhật Jamendo API Key

Trong file `lib/services/jamendo_service.dart`, thay thế:

```dart
static const String _clientId = 'YOUR_CLIENT_ID';
```

Bằng Client ID thực tế từ [Jamendo API](https://developer.jamendo.com/).

## 9. Chạy ứng dụng

```bash
flutter run -d web-server
```

## Lưu ý

- Đảm bảo có kết nối internet để tải nhạc từ Jamendo
- Firebase rules có thể cần điều chỉnh cho production
- Jamendo API có giới hạn request, cần đăng ký để có API key