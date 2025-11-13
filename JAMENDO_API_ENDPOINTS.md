# Jamendo API Endpoints Documentation

## Base Configuration

- **Base URL:** `https://api.jamendo.com/v3.0`
- **Client ID:** `75f3ac34`
- **Format:** JSON
- **Audio Format:** MP3 (mp32)
- **Timeout:** 10 seconds

---

## 1. Track Service (`track_service.dart`)

### 1.1 Lấy bài hát phổ biến
```
GET /tracks/?client_id=75f3ac34&format=json&limit=20&offset=0&order=popularity_total&include=musicinfo&audioformat=mp32
```
- **Phương thức:** `getPopularTracks({int limit = 20, int offset = 0})`
- **Tham số:** limit, offset
- **Trả về:** List<Song>

### 1.2 Lấy bài hát mới nhất
```
GET /tracks/?client_id=75f3ac34&format=json&limit=20&offset=0&order=releasedate_desc&include=musicinfo&audioformat=mp32
```
- **Phương thức:** `getLatestTracks({int limit = 20, int offset = 0})`
- **Tham số:** limit, offset
- **Trả về:** List<Song>

### 1.3 Lấy bài hát theo Artist ID
```
GET /tracks/?client_id=75f3ac34&format=json&limit=20&artist_id={artistId}&include=musicinfo&audioformat=mp32
```
- **Phương thức:** `getTracksByArtist(String artistId, {int limit = 20})`
- **Tham số:** artistId, limit
- **Trả về:** List<Song>

### 1.4 Lấy bài hát theo Album ID
```
GET /tracks/?client_id=75f3ac34&format=json&limit=20&album_id={albumId}&include=musicinfo&audioformat=mp32
```
- **Phương thức:** `getTracksByAlbum(String albumId, {int limit = 20})`
- **Tham số:** albumId, limit
- **Trả về:** List<Song>

### 1.5 Lấy bài hát ngẫu nhiên
```
GET /tracks/?client_id=75f3ac34&format=json&limit=20&order=random&include=musicinfo&audioformat=mp32
```
- **Phương thức:** `getRandomTracks({int limit = 20})`
- **Tham số:** limit
- **Trả về:** List<Song>

### 1.6 Lấy bài hát theo ID
```
GET /tracks/?client_id=75f3ac34&format=json&id={trackId}&include=musicinfo&audioformat=mp32
```
- **Phương thức:** `getTrackById(String trackId)`
- **Tham số:** trackId
- **Trả về:** Song?

---

## 2. Search Service (`search_service.dart`)

### 2.1 Tìm kiếm bài hát
```
GET /tracks/?client_id=75f3ac34&format=json&limit=20&search={query}&include=musicinfo&audioformat=mp32
```
- **Phương thức:** `searchTracks(String query, {int limit = 20})`
- **Tham số:** query, limit
- **Trả về:** List<Song>

### 2.2 Tìm kiếm artist
```
GET /artists/?client_id=75f3ac34&format=json&limit=20&search={query}
```
- **Phương thức:** `searchArtists(String query, {int limit = 20})`
- **Tham số:** query, limit
- **Trả về:** List<Map<String, dynamic>>

### 2.3 Tìm kiếm album
```
GET /albums/?client_id=75f3ac34&format=json&limit=20&search={query}
```
- **Phương thức:** `searchAlbums(String query, {int limit = 20})`
- **Tham số:** query, limit
- **Trả về:** List<Map<String, dynamic>>

### 2.4 Tìm kiếm tổng hợp (Tracks + Artists + Albums)
```
GET /tracks/?client_id=75f3ac34&format=json&limit=10&search={query}&include=musicinfo&audioformat=mp32
GET /artists/?client_id=75f3ac34&format=json&limit=10&search={query}
GET /albums/?client_id=75f3ac34&format=json&limit=10&search={query}
```
- **Phương thức:** `searchAll(String query, {int limit = 10})`
- **Tham số:** query, limit
- **Trả về:** Map<String, dynamic> {tracks, artists, albums}

### 2.5 Lấy gợi ý tìm kiếm (Autocomplete)
```
GET /tracks/?client_id=75f3ac34&format=json&limit=5&search={query}&include=musicinfo&audioformat=mp32
```
- **Phương thức:** `getSearchSuggestions(String query, {int limit = 5})`
- **Tham số:** query, limit
- **Trả về:** List<String>

### 2.6 Tìm kiếm theo từ khóa phổ biến
```
GET /tracks/?client_id=75f3ac34&format=json&limit=20&search={trendingKeyword}&include=musicinfo&audioformat=mp32
```
- **Phương thức:** `searchByTrending(List<String> trendingKeywords, {int limit = 20})`
- **Tham số:** trendingKeywords, limit
- **Trả về:** List<Song>

---

## 3. Genre Service (`genre_service.dart`)

### 3.1 Lấy danh sách tất cả thể loại
```
GET /tags/?client_id=75f3ac34&format=json
```
- **Phương thức:** `getAllGenres()`
- **Tham số:** (none)
- **Trả về:** List<Map<String, dynamic>>

### 3.2 Lấy thể loại phổ biến
```
GET /tags/?client_id=75f3ac34&format=json (lấy top {limit})
```
- **Phương thức:** `getPopularGenres({int limit = 20})`
- **Tham số:** limit
- **Trả về:** List<String>

### 3.3 Lấy thống kê thể loại
```
GET /tracks/?client_id=75f3ac34&format=json&limit=1&tags={genre}
GET /albums/?client_id=75f3ac34&format=json&limit=1&tags={genre}
GET /artists/?client_id=75f3ac34&format=json&limit=1&tags={genre}
```
- **Phương thức:** `getGenreStats(String genre)`
- **Tham số:** genre
- **Trả về:** Map<String, dynamic> {genre, trackCount, albumCount, artistCount}

### 3.4 Lấy bài hát theo thể loại
```
GET /tracks/?client_id=75f3ac34&format=json&limit=20&tags={genre}&include=musicinfo&audioformat=mp32
```
- **Phương thức:** `getTracksByGenre(String genre, {int limit = 20})`
- **Tham số:** genre, limit
- **Trả về:** List<Song>

---

## 4. Artist Service (`artist_service.dart`)

### 4.1 Lấy artist nổi bật
```
GET /artists/?client_id=75f3ac34&format=json&limit=20&offset=0&order=popularity_total
```
- **Phương thức:** `getFeaturedArtists({int limit = 20, int offset = 0})`
- **Tham số:** limit, offset
- **Trả về:** List<Artist>

### 4.2 Lấy artist mới
```
GET /artists/?client_id=75f3ac34&format=json&limit=20&offset=0&order=joindate_desc
```
- **Phương thức:** `getLatestArtists({int limit = 20, int offset = 0})`
- **Tham số:** limit, offset
- **Trả về:** List<Artist>

### 4.3 Lấy artist theo ID
```
GET /artists/?client_id=75f3ac34&format=json&id={artistId}
```
- **Phương thức:** `getArtistById(String artistId)`
- **Tham số:** artistId
- **Trả về:** Artist?

### 4.4 Lấy artist theo thể loại
```
GET /artists/?client_id=75f3ac34&format=json&limit=20&tags={genre}
```
- **Phương thức:** `getArtistsByGenre(String genre, {int limit = 20})`
- **Tham số:** genre, limit
- **Trả về:** List<Artist>

### 4.5 Lấy artist ngẫu nhiên
```
GET /artists/?client_id=75f3ac34&format=json&limit=20&order=random
```
- **Phương thức:** `getRandomArtists({int limit = 20})`
- **Tham số:** limit
- **Trả về:** List<Artist>

### 4.6 Lấy artist theo quốc gia
```
GET /artists/?client_id=75f3ac34&format=json&limit=20&country={country}&order=popularity_total
```
- **Phương thức:** `getArtistsByCountry(String country, {int limit = 20})`
- **Tham số:** country, limit
- **Trả về:** List<Artist>

---

## 5. Album Service (`album_service.dart`)

### 5.1 Lấy album nổi bật
```
GET /albums/?client_id=75f3ac34&format=json&limit=20&offset=0&order=popularity_total
```
- **Phương thức:** `getFeaturedAlbums({int limit = 20, int offset = 0})`
- **Tham số:** limit, offset
- **Trả về:** List<Album>

### 5.2 Lấy album mới nhất
```
GET /albums/?client_id=75f3ac34&format=json&limit=20&offset=0&order=releasedate_desc
```
- **Phương thức:** `getLatestAlbums({int limit = 20, int offset = 0})`
- **Tham số:** limit, offset
- **Trả về:** List<Album>

### 5.3 Lấy album theo Artist ID
```
GET /albums/?client_id=75f3ac34&format=json&limit=20&artist_id={artistId}
```
- **Phương thức:** `getAlbumsByArtist(String artistId, {int limit = 20})`
- **Tham số:** artistId, limit
- **Trả về:** List<Album>

### 5.4 Lấy album theo thể loại
```
GET /albums/?client_id=75f3ac34&format=json&limit=20&tags={genre}
```
- **Phương thức:** `getAlbumsByGenre(String genre, {int limit = 20})`
- **Tham số:** genre, limit
- **Trả về:** List<Album>

### 5.5 Lấy album theo ID
```
GET /albums/?client_id=75f3ac34&format=json&id={albumId}
```
- **Phương thức:** `getAlbumById(String albumId)`
- **Tham số:** albumId
- **Trả về:** Album?

### 5.6 Lấy album ngẫu nhiên
```
GET /albums/?client_id=75f3ac34&format=json&limit=20&order=random
```
- **Phương thức:** `getRandomAlbums({int limit = 20})`
- **Tham số:** limit
- **Trả về:** List<Album>

---

## Testing Guide - Direct URLs

### Track Service URLs

1. **Get Popular Tracks (top 10)**
   https://api.jamendo.com/v3.0/tracks/?client_id=75f3ac34&format=json&limit=10&order=popularity_total&include=musicinfo&audioformat=mp32

2. **Get Latest Tracks**
   https://api.jamendo.com/v3.0/tracks/?client_id=75f3ac34&format=json&limit=10&order=releasedate_desc&include=musicinfo&audioformat=mp32

3. **Get Track by ID (ID: 1157362)**
   https://api.jamendo.com/v3.0/tracks/?client_id=75f3ac34&format=json&id=1157362&include=musicinfo&audioformat=mp32

4. **Get Tracks by Artist (Artist ID: 123)**
   https://api.jamendo.com/v3.0/tracks/?client_id=75f3ac34&format=json&limit=10&artist_id=123&include=musicinfo&audioformat=mp32

5. **Get Tracks by Album (Album ID: 456)**
   https://api.jamendo.com/v3.0/tracks/?client_id=75f3ac34&format=json&limit=10&album_id=456&include=musicinfo&audioformat=mp32

6. **Get Random Tracks**
   https://api.jamendo.com/v3.0/tracks/?client_id=75f3ac34&format=json&limit=10&order=random&include=musicinfo&audioformat=mp32

---

### Search Service URLs

1. **Search Tracks (query: "love")**
   https://api.jamendo.com/v3.0/tracks/?client_id=75f3ac34&format=json&limit=10&search=love&include=musicinfo&audioformat=mp32

2. **Search Artists (query: "smith")**
   https://api.jamendo.com/v3.0/artists/?client_id=75f3ac34&format=json&limit=10&search=smith

3. **Search Albums (query: "best")**
   https://api.jamendo.com/v3.0/albums/?client_id=75f3ac34&format=json&limit=10&search=best

4. **Search Tracks (query: "jazz")**
   https://api.jamendo.com/v3.0/tracks/?client_id=75f3ac34&format=json&limit=10&search=jazz&include=musicinfo&audioformat=mp32

5. **Search Tracks (query: "relax")**
   https://api.jamendo.com/v3.0/tracks/?client_id=75f3ac34&format=json&limit=10&search=relax&include=musicinfo&audioformat=mp32

---

### Genre Service URLs

1. **Get All Genres/Tags**
   https://api.jamendo.com/v3.0/tags/?client_id=75f3ac34&format=json

2. **Get Tracks by Genre (jazz)**
   https://api.jamendo.com/v3.0/tracks/?client_id=75f3ac34&format=json&limit=10&tags=jazz&include=musicinfo&audioformat=mp32

3. **Get Tracks by Genre (pop)**
   https://api.jamendo.com/v3.0/tracks/?client_id=75f3ac34&format=json&limit=10&tags=pop&include=musicinfo&audioformat=mp32

4. **Get Tracks by Genre (rock)**
   https://api.jamendo.com/v3.0/tracks/?client_id=75f3ac34&format=json&limit=10&tags=rock&include=musicinfo&audioformat=mp32

5. **Get Tracks by Genre (classical)**
   https://api.jamendo.com/v3.0/tracks/?client_id=75f3ac34&format=json&limit=10&tags=classical&include=musicinfo&audioformat=mp32

6. **Count Tracks by Genre (ambient)**
   https://api.jamendo.com/v3.0/tracks/?client_id=75f3ac34&format=json&limit=1&tags=ambient

---

### Artist Service URLs

1. **Get Featured Artists**
   https://api.jamendo.com/v3.0/artists/?client_id=75f3ac34&format=json&limit=10&order=popularity_total

2. **Get Latest Artists**
   https://api.jamendo.com/v3.0/artists/?client_id=75f3ac34&format=json&limit=10&order=joindate_desc

3. **Get Artist by ID (ID: 123)**
   https://api.jamendo.com/v3.0/artists/?client_id=75f3ac34&format=json&id=123

4. **Get Artists by Genre (jazz)**
   https://api.jamendo.com/v3.0/artists/?client_id=75f3ac34&format=json&limit=10&tags=jazz

5. **Get Random Artists**
   https://api.jamendo.com/v3.0/artists/?client_id=75f3ac34&format=json&limit=10&order=random

6. **Get Artists by Country (US)**
   https://api.jamendo.com/v3.0/artists/?client_id=75f3ac34&format=json&limit=10&country=US&order=popularity_total

7. **Get Artists by Country (GB)**
   https://api.jamendo.com/v3.0/artists/?client_id=75f3ac34&format=json&limit=10&country=GB&order=popularity_total

8. **Get Artists by Country (VN)**
   https://api.jamendo.com/v3.0/artists/?client_id=75f3ac34&format=json&limit=10&country=VN&order=popularity_total

---

### Album Service URLs

1. **Get Featured Albums**
   https://api.jamendo.com/v3.0/albums/?client_id=75f3ac34&format=json&limit=10&order=popularity_total

2. **Get Latest Albums**
   https://api.jamendo.com/v3.0/albums/?client_id=75f3ac34&format=json&limit=10&order=releasedate_desc

3. **Get Album by ID (ID: 456)**
   https://api.jamendo.com/v3.0/albums/?client_id=75f3ac34&format=json&id=456

4. **Get Albums by Artist (Artist ID: 123)**
   https://api.jamendo.com/v3.0/albums/?client_id=75f3ac34&format=json&limit=10&artist_id=123

5. **Get Albums by Genre (jazz)**
   https://api.jamendo.com/v3.0/albums/?client_id=75f3ac34&format=json&limit=10&tags=jazz

6. **Get Albums by Genre (pop)**
   https://api.jamendo.com/v3.0/albums/?client_id=75f3ac34&format=json&limit=10&tags=pop

7. **Get Random Albums**
   https://api.jamendo.com/v3.0/albums/?client_id=75f3ac34&format=json&limit=10&order=random

---

### Testing with cURL

Dùng các lệnh sau để test trong terminal:

```bash
# Test Track Service
curl "https://api.jamendo.com/v3.0/tracks/?client_id=75f3ac34&format=json&limit=5&order=popularity_total&include=musicinfo&audioformat=mp32"

# Test Search Service
curl "https://api.jamendo.com/v3.0/tracks/?client_id=75f3ac34&format=json&limit=5&search=love&include=musicinfo&audioformat=mp32"

# Test Genre Service
curl "https://api.jamendo.com/v3.0/tags/?client_id=75f3ac34&format=json"

# Test Artist Service
curl "https://api.jamendo.com/v3.0/artists/?client_id=75f3ac34&format=json&limit=5&order=popularity_total"

# Test Album Service
curl "https://api.jamendo.com/v3.0/albums/?client_id=75f3ac34&format=json&limit=5&order=popularity_total"
```

---

## Common Query Parameters

| Tham số | Mô tả | Ví dụ |
|---------|-------|-------|
| `client_id` | API key (bắt buộc) | `75f3ac34` |
| `format` | Định dạng trả về | `json` |
| `limit` | Số kết quả tối đa | `20`, `50` |
| `offset` | Bỏ qua N kết quả đầu | `0`, `20` |
| `search` | Từ khóa tìm kiếm | `love`, `jazz` |
| `tags` | Lọc theo thể loại | `jazz`, `pop` |
| `order` | Sắp xếp kết quả | `popularity_total`, `releasedate_desc`, `random` |
| `artist_id` | ID nghệ sĩ | `123456` |
| `album_id` | ID album | `789012` |
| `id` | ID bài hát/artist/album | `1157362` |
| `country` | Lọc theo quốc gia | `US`, `VN` |
| `include` | Bao gồm thông tin bổ sung | `musicinfo` |
| `audioformat` | Định dạng âm thanh | `mp32` (MP3) |

---

## Response Format

Tất cả endpoint trả về JSON với cấu trúc:
```json
{
  "headers": {
    "status": 0,
    "code": 200,
    "error_message": "",
    "warnings": "",
    "results_count": 5
  },
  "results": [
    {
      "id": "1157362",
      "name": "Song Title",
      "artist_name": "Artist Name",
      ...
    }
  ]
}
```

---

## Notes

- **Client ID:** `75f3ac34` - Đã được cấu hình trong project
- **Rate Limit:** Jamendo API có giới hạn requests/ngày
- **Audio URL:** Được trả về trong kết quả tracks với key `audio` hoặc `audiodownload`
- **Timeout:** 10 giây cho mỗi request
- **Error Handling:** Tất cả service đều có try-catch để xử lý lỗi

