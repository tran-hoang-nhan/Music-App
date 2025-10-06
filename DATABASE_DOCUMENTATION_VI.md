# 🎵 Ứng Dụng Âm Nhạc - Tài Liệu Cơ Sở Dữ Liệu Firebase Realtime

## 🎵 Chức Năng Ứng Dụng

### 🎧 Phát Nhạc
- Phát/Tạm dừng bài hát
- Chuyển bài tiếp theo/trước đó
- Phát ngẫu nhiên (shuffle)
- Lặp lại (repeat)
- Thanh kéo thời gian
- Điều chỉnh âm lượng

### ❤️ Yêu Thích
- Thêm bài hát vào yêu thích
- Xóa khỏi danh sách yêu thích
- Xem danh sách bài hát yêu thích
- Phát tất cả bài yêu thích

### 📝 Playlist
- Tạo playlist mới
- Thêm bài hát vào playlist
- Xóa bài khỏi playlist
- Đổi tên playlist
- Xóa playlist
- Sắp xếp lại thứ tự bài hát
- Tải ảnh bìa playlist
- Offline Mode cho playlist

### 🔍 Tìm Kiếm
- **Smart Search**: Tìm kiếm thông minh với scoring system
- **Genre Discovery**: Duyệt theo 10 thể loại nhạc
- **Trending Content**: Bài hát thịnh hành và mới nhất
- **Mood Detection**: Phát hiện tâm trạng từ lịch sử nghe
- **Auto Playlist Generator**: Tạo playlist theo theme

### 🤖 Gợi ý 
- Gợi ý bài hát dựa trên sở thích

### 👤 Tài Khoản
- Đăng ký tài khoản
- Đăng nhập
- Đăng xuất
- Quên mật khẩu
- Xem thống kê cá nhân
- Chỉnh sửa hồ sơ

## 📊 Tổng Quan Cơ Sở Dữ Liệu

**Loại Database**: Firebase Realtime Database (NoSQL)  
**Cấu trúc**: Single Collection với Nested Objects  
**Real-time**: Có, với đồng bộ hóa trực tiếp  
**Xác thực**: Tích hợp Firebase Auth  

---

## 🏗️ Sơ Đồ Cơ Sở Dữ Liệu

### Cấu Trúc Gốc (Chỉ 1 Collection)
```json
{
  "users": {
    "{userId}": {
      "email": "user@example.com",
      "name": "Tên User",
      "avatarUrl": "https://...",
      "favorites": {
        "{songId}": {
          "id": "26736",
          "name": "Struttin'",
          "artistName": "Tryad",
          "imageUrl": "https://...",
          "timestamp": 1757258545055
        }
      },
      "listening_history": {
        "{songId}": {
          "songId": "1157362",
          "songName": "First",
          "artistName": "JekK",
          "playCount": 8,
          "lastPlayed": 1758361915656
        }
      },
      "playlists": {
        "{playlistId}": {
          "id": "playlist_001",
          "name": "Nhạc Chill",
          "description": "Nhạc thư giãn",
          "imageUrl": "https://...",
          "createdAt": 1757258545055,
          "songs": {
            "{songId}": {
              "id": "26736",
              "name": "Struttin'",
              "artistName": "Tryad",
              "audioUrl": "https://...",
              "imageUrl": "https://...",
              "duration": 242,
              "order": 1,
              "addedAt": 1757258545055
            }
          }
        }
      }
    }
  }
}
```

---

## 📋 Chi Tiết Cấu Trúc Dữ Liệu

### **Chỉ có 1 Collection: `users`**
**Đường dẫn gốc**: `/users/{userId}`

#### **1. Thông tin User**
| Trường | Kiểu | Mô tả | Ví dụ |
|--------|------|-------|-------|
| `email` | `string` | Email người dùng | `"user@example.com"` |
| `name` | `string` | Tên người dùng | `"Nguyễn Văn A"` |
| `avatarUrl` | `string` | URL ảnh đại diện | `"https://cloudinary.com/..."` |
| `createdAt` | `number` | Timestamp tạo tài khoản | `1757258545055` |

#### **2. Nested Object: `favorites`**
**Đường dẫn**: `/users/{userId}/favorites/{songId}`

| Trường | Kiểu | Mô tả | Ví dụ |
|--------|------|-------|-------|
| `id` | `string` | ID bài hát | `"26736"` |
| `name` | `string` | Tên bài hát | `"Struttin'"` |
| `artistName` | `string` | Tên nghệ sĩ | `"Tryad"` |
| `audioUrl` | `string` | URL streaming | `"https://jamendo.com/..."` |
| `imageUrl` | `string` | URL ảnh bìa | `"https://jamendo.com/..."` |
| `duration` | `number` | Thời lượng (giây) | `242` |
| `timestamp` | `number` | Thời điểm thêm yêu thích | `1757258545055` |

#### **3. Nested Object: `listening_history`**
**Đường dẫn**: `/users/{userId}/listening_history/{songId}`

| Trường | Kiểu | Mô tả | Ví dụ |
|--------|------|-------|-------|
| `songId` | `string` | ID bài hát | `"1157362"` |
| `songName` | `string` | Tên bài hát | `"First"` |
| `artistName` | `string` | Tên nghệ sĩ | `"JekK"` |
| `imageUrl` | `string` | URL ảnh bìa | `"https://jamendo.com/..."` |
| `playCount` | `number` | Số lần phát | `8` |
| `firstPlayed` | `number` | Lần đầu phát | `1758013345811` |
| `lastPlayed` | `number` | Lần cuối phát | `1758361915656` |

#### **4. Nested Object: `playlists`**
**Đường dẫn**: `/users/{userId}/playlists/{playlistId}`

| Trường | Kiểu | Mô tả | Ví dụ |
|--------|------|-------|-------|
| `id` | `string` | ID playlist | `"playlist_001"` |
| `name` | `string` | Tên playlist | `"Nhạc Chill"` |
| `description` | `string` | Mô tả playlist | `"Nhạc thư giãn"` |
| `imageUrl` | `string` | URL ảnh bìa playlist | `"https://cloudinary.com/..."` |
| `createdAt` | `number` | Timestamp tạo | `1757258545055` |
| `updatedAt` | `number` | Timestamp cập nhật | `1757258545055` |
| `songs` | `object` | Nested object chứa bài hát | `{ "songId": {...} }` |

#### **5. Nested Object: `playlists/{playlistId}/songs`**
**Đường dẫn**: `/users/{userId}/playlists/{playlistId}/songs/{songId}`

| Trường | Kiểu | Mô tả | Ví dụ |
|--------|------|-------|-------|
| `id` | `string` | ID bài hát | `"26736"` |
| `name` | `string` | Tên bài hát | `"Struttin'"` |
| `artistName` | `string` | Tên nghệ sĩ | `"Tryad"` |
| `audioUrl` | `string` | URL streaming | `"https://jamendo.com/..."` |
| `imageUrl` | `string` | URL ảnh bìa | `"https://jamendo.com/..."` |
| `duration` | `number` | Thời lượng (giây) | `242` |
| `genre` | `string` | Thể loại nhạc | `"Jazz"` |
| `order` | `number` | Thứ tự trong playlist | `1` |
| `addedAt` | `number` | Timestamp thêm vào playlist | `1757258545055` |

---

## 🔗 Cấu Trúc Nested Objects

### **Mối Quan Hệ Trong Single Collection**

1. **User → Favorites** (1:N nested)
   - Path: `/users/{userId}/favorites/{songId}`
   - Mỗi user có nhiều bài hát yêu thích
   - SongId làm key cho nested object

2. **User → Listening History** (1:N nested)
   - Path: `/users/{userId}/listening_history/{songId}`
   - Tracking lịch sử nghe và play count
   - Songid làm key, tự động aggregate data

3. **User → Playlists** (1:N nested)
   - Path: `/users/{userId}/playlists/{playlistId}`
   - Mỗi user có nhiều playlist
   - PlaylistId tự generate hoặc custom

4. **Playlist → Songs** (1:N double nested)
   - Path: `/users/{userId}/playlists/{playlistId}/songs/{songId}`
   - Mỗi playlist chứa nhiều bài hát
   - Double nesting: playlist trong user, songs trong playlist

### **Đặc Điểm Nested Structure**

- **No separate collections**: Tất cả data trong `users`
- **Deep nesting**: Tối đa 4 levels (users/userId/playlists/playlistId/songs/songId)
- **Denormalized**: Song metadata duplicate ở favorites, history, playlist songs
- **Real-time friendly**: Thay đổi bất kỳ nested object nào đều sync ngay
- **Query limitations**: Không thể query cross-user, chỉ query trong user scope

---

## 📈 Mẫu Dữ Liệu

### **Chiến Lược Single Collection với Nested Objects**
- **Chỉ 1 collection**: `users` chứa tất cả dữ liệu
- **Deep nesting**: Tất cả dữ liệu nested trong user object
- **Cấu trúc**: `users/{userId}/{favorites|listening_history|playlists}`
- **Playlist songs**: Nested trong `users/{userId}/playlists/{playlistId}/songs`
- **Phi chuẩn hóa**: Metadata được duplicate để tối ưu performance
- **Real-time sync**: Tất cả thay đổi sync real-time trong 1 collection
- **Offline support**: Toàn bộ user data có thể cache offline

---

## 🔧 Các Thao Tác Cơ Sở Dữ Liệu

### **Thao Tác CRUD**

| Thao Tác | Path | Phương Thức |
|----------|------|-------------|
| **Tạo** | `/users/{uid}/favorites/{songId}` | set() |
| **Tạo** | `/users/{uid}/playlists/{playlistId}` | set() |
| **Đọc** | `/users/{uid}` | on(), once() |
| **Đọc** | `/users/{uid}/favorites` | on(), once() |
| **Cập nhật** | `/users/{uid}/listening_history/{songId}` | update(), transaction() |
| **Xóa** | `/users/{uid}/favorites/{songId}` | remove() |

### **Truy Vấn Phức Tạp**
- Lấy bài hát được phát nhiều nhất của người dùng
- Truy xuất lịch sử nghe gần đây
- Lấy bài hát yêu thích theo thể loại
- Tìm kiếm bài hát trong playlist
- Phân tích cho gợi ý AI

---

## 🚀 Tối Ưu Hiệu Suất

1. **Đánh chỉ mục**: Firebase tự động đánh chỉ mục theo khóa
2. **Phi chuẩn hóa**: Giảm số lần gọi API
3. **Cache**: Nested objects cache metadata
4. **Real-time**: Cập nhật delta hiệu quả
5. **Offline**: Bật tính năng lưu trữ cục bộ

---

## 🔒 Quy Tắc Bảo Mật (Single Collection)

```javascript
{
  "rules": {
    "users": {
      "$uid": {
        // Chỉ user đó mới đọc/ghi được data của mình
        ".read": "$uid === auth.uid",
        ".write": "$uid === auth.uid",
        
        // Tất cả nested objects đều inherit rule này
        "favorites": {
          ".read": "$uid === auth.uid",
          ".write": "$uid === auth.uid"
        },
        "listening_history": {
          ".read": "$uid === auth.uid",
          ".write": "$uid === auth.uid"
        },
        "playlists": {
          ".read": "$uid === auth.uid",
          ".write": "$uid === auth.uid"
        }
      }
    }
  }
}
```

**Đặc điểm bảo mật:**
- **User isolation**: Mỗi user chỉ access được data của mình
- **Nested inheritance**: Tất cả nested objects inherit parent rules
- **No cross-user access**: Không thể đọc data của user khác
- **Authenticated only**: Phải đăng nhập mới access được