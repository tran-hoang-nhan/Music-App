# 🎵 Ứng Dụng Âm Nhạc - Tài Liệu Cơ Sở Dữ Liệu Firebase Realtime

## 📊 Tổng Quan Cơ Sở Dữ Liệu

**Loại Database**: Firebase Realtime Database (NoSQL)  
**Cấu trúc**: Dữ liệu phân cấp dựa trên JSON  
**Real-time**: Có, với đồng bộ hóa trực tiếp  
**Xác thực**: Tích hợp Firebase Auth  

---

## 🏗️ Sơ Đồ Cơ Sở Dữ Liệu

### Cấu Trúc Gốc
```
{
  "users": {
    "{userId}": { ... }
  }
}
```

---

## 📋 Chi Tiết Các Bảng (Collections)

### 1. **Bảng Người Dùng**
**Đường dẫn**: `/users/{userId}`

| Trường | Kiểu | Mô tả | Ví dụ |
|--------|------|-------|-------|
| `connection_test` | `number` | Timestamp kết nối cuối | `1757738600749` |
| `email` | `string` | Địa chỉ email người dùng | `"a123@gmail.com"` |
| `favorites` | `object` | Bài hát yêu thích của người dùng | `{ "26736": {...} }` |
| `listening_history` | `object` | Dữ liệu phân tích | `{ "82239": {...} }` |
| `listening_songs` | `object` | Dữ liệu bài hát được cache | `{ "26736": {...} }` |

---

### 2. **Bảng Yêu Thích**
**Đường dẫn**: `/users/{userId}/favorites/{songId}`

| Trường | Kiểu | Mô tả | Ví dụ |
|--------|------|-------|-------|
| `id` | `string` | ID bài hát (Khóa chính) | `"26736"` |
| `name` | `string` | Tên bài hát | `"Struttin'"` |
| `artistId` | `string` | ID nghệ sĩ | `"104"` |
| `artistName` | `string` | Tên nghệ sĩ | `"Tryad"` |
| `audioUrl` | `string` | URL streaming | `"https://prod-1.storage.jamendo.com/..."` |
| `imageUrl` | `string` | URL ảnh bìa album | `"https://usercontent.jamendo.com/..."` |
| `duration` | `number` | Thời lượng bài hát (giây) | `242` |
| `timestamp` | `number` | Thời điểm thêm vào yêu thích | `1757258545055` |

**Mục đích**: Lưu trữ bài hát yêu thích của người dùng với metadata đầy đủ

---

### 3. **Bảng Lịch Sử Nghe**
**Đường dẫn**: `/users/{userId}/listening_history/{songId}`

| Trường | Kiểu | Mô tả | Ví dụ |
|--------|------|-------|-------|
| `songId` | `string` | ID bài hát (Khóa chính) | `"1157362"` |
| `songName` | `string` | Tên bài hát | `"First"` |
| `artistName` | `string` | Tên nghệ sĩ | `"JekK"` |
| `playCount` | `number` | Tổng số lần phát | `8` |
| `firstPlayed` | `number` | Timestamp lần đầu phát | `1758013345811` |
| `lastPlayed` | `number` | Timestamp lần cuối phát | `1758361915656` |

**Mục đích**: Phân tích và theo dõi hành vi người dùng

---

### 4. **Bảng Bài Hát Đã Nghe (Cache)**
**Đường dẫn**: `/users/{userId}/listening_songs/{songId}`

| Trường | Kiểu | Mô tả | Ví dụ |
|--------|------|-------|-------|
| `id` | `string` | ID bài hát (Khóa chính) | `"26736"` |
| `name` | `string` | Tên bài hát | `"Struttin'"` |
| `artistName` | `string` | Tên nghệ sĩ | `"Tryad"` |
| `imageUrl` | `string` | URL ảnh bìa album | `"https://usercontent.jamendo.com/..."` |
| `timestamp` | `number` | Timestamp cache | `1757924943769` |

**Mục đích**: Tối ưu hiệu suất - cache các bài hát được phát gần đây

---

## 🔗 Phân Tích Mối Quan Hệ

### **Mối Quan Hệ Chính**

1. **Người Dùng → Yêu Thích** (Một-nhiều)
   - Một người dùng có thể có nhiều bài hát yêu thích
   - Khóa: `songId` liên kết đến Jamendo API bên ngoài

2. **Người Dùng → Lịch Sử Nghe** (Một-nhiều)
   - Một người dùng có thể có nhiều bản ghi nghe nhạc
   - Khóa: `songId` liên kết đến Jamendo API bên ngoài

3. **Người Dùng → Bài Hát Đã Nghe** (Một-nhiều)
   - Một người dùng có thể có nhiều bài hát được cache
   - Khóa: `songId` liên kết đến Jamendo API bên ngoài

### **Mối Quan Hệ Ngầm Định**

4. **Yêu Thích ↔ Lịch Sử Nghe** (Nhiều-nhiều)
   - Bài hát có thể tồn tại trong cả hai bảng
   - Mối quan hệ thông qua `songId`

5. **Lịch Sử Nghe ↔ Bài Hát Đã Nghe** (Nhiều-nhiều)
   - Bài hát được cache thường xuất hiện trong lịch sử
   - Mối quan hệ thông qua `songId`

6. **Mối Quan Hệ API Bên Ngoài**
   - Tất cả `songId`, `artistId` tham chiếu đến Jamendo API
   - Dữ liệu được phi chuẩn hóa để tăng hiệu suất

---

## 📈 Mẫu Dữ Liệu

### **Chiến Lược Phi Chuẩn Hóa**
- Metadata bài hát được sao chép qua các bảng
- Giảm số lần gọi API và cải thiện hiệu suất
- Đánh đổi: Dung lượng lưu trữ vs Tốc độ

### **Chiến Lược Cache**
- `listening_songs`: Cache bài hát gần đây
- `favorites`: Lưu trữ metadata bài hát đầy đủ
- Giảm phụ thuộc vào API bên ngoài

### **Mẫu Phân Tích**
- `listening_history`: Hành vi người dùng toàn diện
- Theo dõi: số lần phát, lần đầu/cuối phát
- Hỗ trợ gợi ý AI

---

## 🔧 Các Thao Tác Cơ Sở Dữ Liệu

### **Thao Tác CRUD**

| Thao Tác | Bảng | Phương Thức |
|----------|------|-------------|
| **Tạo** | Yêu Thích | Thêm bài hát vào yêu thích |
| **Đọc** | Tất cả | Real-time listeners |
| **Cập nhật** | Lịch Sử Nghe | Tăng số lần phát |
| **Xóa** | Yêu Thích | Xóa khỏi yêu thích |

### **Truy Vấn Phức Tạp**
- Lấy bài hát được phát nhiều nhất của người dùng
- Truy xuất lịch sử nghe gần đây
- Lấy bài hát yêu thích theo thể loại
- Phân tích cho gợi ý AI

---

## 🚀 Tối Ưu Hiệu Suất

1. **Đánh chỉ mục**: Firebase tự động đánh chỉ mục theo khóa
2. **Phi chuẩn hóa**: Giảm số lần gọi API
3. **Cache**: Bảng `listening_songs`
4. **Real-time**: Cập nhật delta hiệu quả
5. **Offline**: Bật tính năng lưu trữ cục bộ

---

## 🔒 Quy Tắc Bảo Mật

```javascript
{
  "rules": {
    "users": {
      "$uid": {
        ".read": "$uid === auth.uid",
        ".write": "$uid === auth.uid"
      }
    },
    "playlists": {
      ".read": "auth != null",
      ".write": "auth != null"
    },
    "favorites": {
      "$uid": {
        ".read": "$uid === auth.uid",
        ".write": "$uid === auth.uid"
      }
    },
    "listening_history": {
      "$uid": {
        ".read": "$uid === auth.uid",
        ".write": "$uid === auth.uid"
      }
    },
    ".read": false,
    ".write": false
  }
}
```

**Tính Năng Bảo Mật**:
- Người dùng chỉ có thể truy cập dữ liệu của chính họ
- Yêu cầu xác thực
- Không có quyền đọc/ghi công khai

---

## 📊 Thống Kê Cơ Sở Dữ Liệu

**Từ Dữ Liệu Hiện Tại**:
- **Người dùng**: 1 người dùng hoạt động
- **Yêu thích**: 3 bài hát
- **Lịch sử nghe**: 17 bài hát duy nhất
- **Tổng lượt phát**: 45 lượt được theo dõi
- **Phát nhiều nhất**: "Rot" của REGINA (9 lượt)
- **Kích thước cache**: 12+ bài hát

---

## 🎯 Kết Luận

Thiết kế Firebase Realtime Database này thể hiện:

✅ **Kiến Trúc NoSQL Có Thể Mở Rộng**  
✅ **Đồng Bộ Hóa Real-time**  
✅ **Tối Ưu Hiệu Suất**  
✅ **Bảo Mật Dữ Liệu Người Dùng**  
✅ **Khả Năng Phân Tích**  
✅ **Sẵn Sàng Hỗ Trợ Offline**  

**Tóm Tắt Mối Quan Hệ**: Cơ sở dữ liệu sử dụng **thiết kế phi chuẩn hóa, tập trung vào người dùng** với các mối quan hệ ngầm định thông qua khóa `songId`, được tối ưu cho hiệu suất ứng dụng di động và trải nghiệm người dùng real-time.