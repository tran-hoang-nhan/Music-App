import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import '../../models/song.dart';

class FavoriteService extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseDatabase _database = FirebaseDatabase.instance;

  // Lưu bài hát yêu thích (đầy đủ thông tin)
  Future<bool> toggleFavorite(String songId, {Song? song}) async {
    final user = _auth.currentUser;
    if (user == null) return false;

    try {
      final favoriteRef = _database.ref('users/${user.uid}/favorites/$songId');
      final snapshot = await favoriteRef.get();

      if (snapshot.exists) {
        // Xóa khỏi yêu thích
        await favoriteRef.remove();
      } else {
        // Thêm vào yêu thích
        if (song != null) {
          await favoriteRef.set({
            ...song.toJson(),
            'addedAt': ServerValue.timestamp,
          });
        }
      }
      
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Lỗi toggle favorite: $e');
    }
    return false;
  }

  // Kiểm tra bài hát có phải yêu thích không
  Future<bool> isFavorite(String songId) async {
    final user = _auth.currentUser;
    if (user == null) return false;

    try {
      final snapshot = await _database.ref('users/${user.uid}/favorites/$songId').get();
      return snapshot.exists;
    } catch (e) {
      debugPrint('Lỗi kiểm tra favorite: $e');
      return false;
    }
  }

  // Lấy danh sách bài hát yêu thích
  Future<List<Song>> getFavoriteSongs() async {
    final user = _auth.currentUser;
    if (user == null) return [];

    try {
      final snapshot = await _database.ref('users/${user.uid}/favorites').get();
      if (snapshot.exists) {
        final data = Map<String, dynamic>.from(snapshot.value as Map);
        return data.values.map((item) {
          final songData = Map<String, dynamic>.from(item as Map);
          return Song.fromJson(songData);
        }).toList();
      }
    } catch (e) {
      debugPrint('Lỗi lấy favorites: $e');
    }
    return [];
  }

  // Xóa tất cả favorites
  Future<bool> clearAllFavorites() async {
    final user = _auth.currentUser;
    if (user == null) return false;

    try {
      await _database.ref('users/${user.uid}/favorites').remove();
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Lỗi xóa tất cả favorites: $e');
      return false;
    }
  }

  // Lấy số lượng bài hát yêu thích
  Future<int> getFavoriteCount() async {
    final user = _auth.currentUser;
    if (user == null) return 0;

    try {
      final snapshot = await _database.ref('users/${user.uid}/favorites').get();
      if (snapshot.exists) {
        return (snapshot.value as Map).length;
      }
    } catch (e) {
      debugPrint('Lỗi đếm favorites: $e');
    }
    return 0;
  }
}

