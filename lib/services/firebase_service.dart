import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/song.dart';

class FirebaseService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseDatabase _database = FirebaseDatabase.instance;

  // Đăng ký tài khoản
  Future<User?> signUp(String email, String password, String name) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      if (credential.user != null) {
        await credential.user!.updateDisplayName(name);
        await _createUserProfile(credential.user!, name);
        return credential.user;
      }
    } catch (e) {
      print('Lỗi đăng ký: $e');
    }
    return null;
  }

  // Đăng nhập
  Future<User?> signIn(String email, String password) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return credential.user;
    } catch (e) {
      print('Lỗi đăng nhập: $e');
    }
    return null;
  }

  // Đăng xuất
  Future<void> signOut() async {
    await _auth.signOut();
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  // Tạo hồ sơ người dùng
  Future<void> _createUserProfile(User user, String name) async {
    await _database.ref('users/${user.uid}').set({
      'name': name,
      'email': user.email,
      'createdAt': ServerValue.timestamp,
      'favoriteGenres': [],
      'playlistCount': 0,
    });
  }

  // Lấy thông tin người dùng
  Future<Map<String, dynamic>?> getUserProfile(String userId) async {
    try {
      final snapshot = await _database.ref('users/$userId').get();
      if (snapshot.exists) {
        return Map<String, dynamic>.from(snapshot.value as Map);
      }
    } catch (e) {
      print('Lỗi lấy thông tin người dùng: $e');
    }
    return null;
  }

  // Tạo playlist
  Future<String?> createPlaylist(String name, String description) async {
    final user = _auth.currentUser;
    if (user == null) return null;

    try {
      final playlistRef = _database.ref('users/${user.uid}/playlists').push();
      final playlistId = playlistRef.key;
      if (playlistId == null) return null;
      
      await playlistRef.set({
        'id': playlistId,
        'name': name,
        'createdAt': ServerValue.timestamp,
        'songs': {},
      });
      
      return playlistId;
    } catch (e) {
      print('Lỗi tạo playlist: $e');
    }
    return null;
  }

  // Lấy danh sách playlist của user
  Future<List<Map<String, dynamic>>> getUserPlaylists() async {
    final user = _auth.currentUser;
    if (user == null) return [];

    try {
      final snapshot = await _database.ref('users/${user.uid}/playlists').get();
          
      if (snapshot.exists) {
        final data = Map<String, dynamic>.from(snapshot.value as Map);
        return data.entries.map((entry) {
          final playlist = Map<String, dynamic>.from(entry.value as Map);
          playlist['id'] = entry.key;
          return playlist;
        }).toList();
      }
    } catch (e) {
      print('Lỗi lấy playlist: $e');
    }
    return [];
  }

  // Thêm bài hát vào playlist (chỉ lưu ID)
  Future<bool> addSongToPlaylist(String playlistId, Song song) async {
    final user = _auth.currentUser;
    if (user == null) return false;
    
    try {
      final songRef = _database.ref('users/${user.uid}/playlists/$playlistId/songs').push();
      await songRef.set({
        'id': song.id,
        'addedAt': ServerValue.timestamp,
      });
      return true;
    } catch (e) {
      print('Lỗi thêm bài hát vào playlist: $e');
    }
    return false;
  }

  // Xóa bài hát khỏi playlist
  Future<bool> removeSongFromPlaylist(String playlistId, String songId) async {
    try {
      await _database.ref('playlists/$playlistId/songs/$songId').remove();
      await _database.ref('playlists/$playlistId/updatedAt').set(ServerValue.timestamp);
      return true;
    } catch (e) {
      print('Lỗi xóa bài hát khỏi playlist: $e');
    }
    return false;
  }

  // Xóa playlist
  Future<bool> deletePlaylist(String playlistId) async {
    final user = _auth.currentUser;
    if (user == null) return false;
    
    try {
      await _database.ref('users/${user.uid}/playlists/$playlistId').remove();
      return true;
    } catch (e) {
      print('Lỗi xóa playlist: $e');
    }
    return false;
  }

  // Lưu bài hát yêu thích (chỉ lưu ID)
  Future<bool> toggleFavorite(String songId, {Song? song}) async {
    final user = _auth.currentUser;
    if (user == null) return false;

    try {
      final ref = _database.ref('users/${user.uid}/favorites/$songId');
      final snapshot = await ref.get();
      
      if (snapshot.exists) {
        await ref.remove();
      } else {
        await ref.set({
          'id': songId,
          'timestamp': ServerValue.timestamp,
        });
      }
      
      return true;
    } catch (e) {
      print('Lỗi toggle favorite: $e');
    }
    return false;
  }

  // Lấy danh sách bài hát yêu thích
  Future<List<String>> getFavorites() async {
    final user = _auth.currentUser;
    if (user == null) return [];

    try {
      final snapshot = await _database.ref('users/${user.uid}/favorites').get();
      if (snapshot.exists) {
        final data = Map<String, dynamic>.from(snapshot.value as Map);
        return data.keys.toList();
      }
    } catch (e) {
      print('Lỗi lấy favorites: $e');
    }
    return [];
  }

  // Lấy danh sách ID bài hát yêu thích
  Future<List<Song>> getFavoriteSongs() async {
    final user = _auth.currentUser;
    if (user == null) return [];

    try {
      final snapshot = await _database.ref('users/${user.uid}/favorites').get();
      if (snapshot.exists) {
        final data = Map<String, dynamic>.from(snapshot.value as Map);
        final songIds = data.keys.toList();
        
        // Trả về danh sách Song với chỉ ID, sẽ được load từ Jamendo API ở UI
        return songIds.map((id) => Song(
          id: id,
          name: '',
          artistName: '',
          artistId: '',
          albumName: '',
          albumImage: '',
          audioUrl: '',
          audioDownload: '',
          duration: 0,
          tags: [],
          releaseDate: '',
          position: 0,
        )).toList();
      }
    } catch (e) {
      print('Lỗi lấy favorite songs: $e');
    }
    return [];
  }

  // Lấy danh sách ID bài hát trong playlist
  Future<List<String>> getPlaylistSongIds(String playlistId) async {
    final user = _auth.currentUser;
    if (user == null) return [];

    try {
      final snapshot = await _database.ref('users/${user.uid}/playlists/$playlistId/songs').get();
      if (snapshot.exists) {
        final data = Map<String, dynamic>.from(snapshot.value as Map);
        return data.entries.map((entry) {
          final songData = Map<String, dynamic>.from(entry.value as Map);
          return songData['id']?.toString() ?? entry.key;
        }).toList();
      }
    } catch (e) {
      print('Lỗi lấy playlist song IDs: $e');
    }
    return [];
  }

  // Kiểm tra bài hát có được yêu thích không
  Future<bool> isFavorite(String songId) async {
    final favorites = await getFavorites();
    return favorites.contains(songId);
  }

  // Lưu lịch sử nghe nhạc
  Future<void> saveListeningHistory(Song song) async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      final ref = _database.ref('users/${user.uid}/listening_songs/${song.id}');
      await ref.set({
        'id': song.id,
        'name': song.name,
        'artistName': song.artistName,
        'imageUrl': song.albumImage,
        'timestamp': ServerValue.timestamp,
      });
    } catch (e) {
      print('Lỗi lưu lịch sử: $e');
    }
  }

  // Thêm vào lịch sử nghe nhạc (với playCount)
  Future<void> addToListeningHistory(String songId, String songName, String artistName) async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      final ref = _database.ref('users/${user.uid}/listening_history/$songId');
      final snapshot = await ref.get();
      
      if (snapshot.exists) {
        final data = Map<String, dynamic>.from(snapshot.value as Map);
        final currentCount = data['playCount'] ?? 0;
        await ref.update({
          'playCount': currentCount + 1,
          'lastPlayed': ServerValue.timestamp,
        });
      } else {
        await ref.set({
          'songId': songId,
          'songName': songName,
          'artistName': artistName,
          'playCount': 1,
          'firstPlayed': ServerValue.timestamp,
          'lastPlayed': ServerValue.timestamp,
        });
      }
    } catch (e) {
      print('Lỗi thêm lịch sử: $e');
    }
  }

  // Lấy lịch sử nghe nhạc
  Future<List<Map<String, dynamic>>> getListeningHistory({int limit = 50}) async {
    final user = _auth.currentUser;
    if (user == null) return [];

    try {
      final snapshot = await _database.ref('users/${user.uid}/listening_history')
          .orderByChild('lastPlayed')
          .limitToLast(limit)
          .get();
          
      if (snapshot.exists) {
        final data = Map<String, dynamic>.from(snapshot.value as Map);
        final history = data.values.map((e) => Map<String, dynamic>.from(e as Map)).toList();
        // Sắp xếp theo thời gian mới nhất
        history.sort((a, b) => (b['lastPlayed'] ?? 0).compareTo(a['lastPlayed'] ?? 0));
        return history;
      }
    } catch (e) {
      print('Lỗi lấy lịch sử: $e');
    }
    return [];
  }

  // Lấy user hiện tại
  User? get currentUser => _auth.currentUser;

  // Stream để theo dõi trạng thái đăng nhập
  Stream<User?> get authStateChanges => _auth.authStateChanges();
}