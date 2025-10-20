import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import '../../models/song.dart';

class HistoryService extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseDatabase _database = FirebaseDatabase.instance;

  // Thêm bài hát vào lịch sử nghe
  Future<void> addToListeningHistory(String songId, String songName, String artistName, {Song? song}) async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      final historyRef = _database.ref('users/${user.uid}/listening_history/$songId');
      
      if (song != null) {
        // Lưu đầy đủ thông tin bài hát
        await historyRef.set({
          ...song.toJson(),
          'lastPlayed': ServerValue.timestamp,
          'playCount': ServerValue.increment(1),
        });
      } else {
        // Chỉ lưu thông tin cơ bản
        await historyRef.set({
          'id': songId,
          'name': songName,
          'artist_name': artistName,
          'lastPlayed': ServerValue.timestamp,
          'playCount': ServerValue.increment(1),
        });
      }
      
      notifyListeners();
    } catch (e) {
      debugPrint('Lỗi thêm vào lịch sử: $e');
    }
  }

  // Lấy lịch sử nghe gần đây
  Future<List<Map<String, dynamic>>> getListeningHistory({int limit = 50}) async {
    final user = _auth.currentUser;
    if (user == null) return [];

    try {
      final snapshot = await _database.ref('users/${user.uid}/listening_history').get();
          
      if (snapshot.exists) {
        final data = Map<String, dynamic>.from(snapshot.value as Map);
        final history = data.values.map((e) => Map<String, dynamic>.from(e as Map)).toList();
        // Sắp xếp theo thời gian mới nhất
        history.sort((a, b) => (b['lastPlayed'] ?? 0).compareTo(a['lastPlayed'] ?? 0));
        return history.take(limit).toList();
      }
    } catch (e) {
      debugPrint('Lỗi lấy lịch sử: $e');
    }
    return [];
  }

}

