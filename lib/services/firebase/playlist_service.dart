import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import '../../models/song.dart';
import '../jamendo/jamendo_controller.dart';

class PlaylistService extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseDatabase _database = FirebaseDatabase.instance;

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
        'description': description,
        'createdAt': ServerValue.timestamp,
        'songCount': 0,
      });
      
      notifyListeners();
      return playlistId;
    } catch (e) {
      debugPrint('Lỗi tạo playlist: $e');
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
      debugPrint('Lỗi lấy playlist: $e');
    }
    return [];
  }

  // Thêm bài hát vào playlist (lưu đầy đủ thông tin)
  Future<bool> addSongToPlaylist(String playlistId, Song song) async {
    final user = _auth.currentUser;
    if (user == null) return false;
    
    try {
      final songRef = _database.ref('users/${user.uid}/playlists/$playlistId/songs').push();
      await songRef.set({
        ...song.toJson(),
        'addedAt': ServerValue.timestamp,
      });
      
      // Cập nhật số lượng bài hát trong playlist
      await _updatePlaylistSongCount(playlistId);
      
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Lỗi thêm bài hát vào playlist: $e');
    }
    return false;
  }

  // Xóa bài hát khỏi playlist
  Future<bool> removeSongFromPlaylist(String playlistId, String songId) async {
    final user = _auth.currentUser;
    if (user == null) return false;
    
    try {
      final songsRef = _database.ref('users/${user.uid}/playlists/$playlistId/songs');
      final snapshot = await songsRef.get();
      
      if (snapshot.exists) {
        final data = Map<String, dynamic>.from(snapshot.value as Map);
        String? keyToRemove;
        
        // Tìm key của song cần xóa
        for (final entry in data.entries) {
          final songData = Map<String, dynamic>.from(entry.value as Map);
          if (songData['id']?.toString() == songId) {
            keyToRemove = entry.key;
            break;
          }
        }
        
        if (keyToRemove != null) {
          await _database.ref('users/${user.uid}/playlists/$playlistId/songs/$keyToRemove').remove();
          
          // Cập nhật số lượng bài hát
          await _updatePlaylistSongCount(playlistId);
          
          notifyListeners();
          return true;
        }
      }
    } catch (e) {
      debugPrint('Lỗi xóa bài hát khỏi playlist: $e');
    }
    return false;
  }

  // Xóa playlist
  Future<bool> deletePlaylist(String playlistId) async {
    final user = _auth.currentUser;
    if (user == null) return false;
    
    try {
      await _database.ref('users/${user.uid}/playlists/$playlistId').remove();
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Lỗi xóa playlist: $e');
    }
    return false;
  }

  // Lấy danh sách bài hát trong playlist
  Future<List<Song>> getPlaylistSongs(String playlistId) async {
    final user = _auth.currentUser;
    if (user == null) return [];
    
    try {
      final songsRef = _database.ref('users/${user.uid}/playlists/$playlistId/songs');
      final snapshot = await songsRef.get();
      
      if (!snapshot.exists) return [];
      
      final data = Map<String, dynamic>.from(snapshot.value as Map);
      final List<Song> songs = [];
      
      // Lấy thông tin bài hát
      for (final entry in data.entries) {
        try {
          final songData = Map<String, dynamic>.from(entry.value as Map);
          
          // Nếu có đầy đủ thông tin, dùng luôn
          if (songData.containsKey('name') && songData.containsKey('artistName')) {
            songs.add(Song.fromJson(songData));
          } else if (songData.containsKey('id')) {
            // Nếu chỉ có ID, lấy thông tin từ Jamendo API
            final songId = songData['id'].toString();
            try {
              final jamendoController = JamendoController();
              final fullSong = await jamendoController.getTrackById(songId);
              if (fullSong != null) {
                songs.add(fullSong);
              } else {
                // Fallback nếu không lấy được
                songs.add(Song(
                  id: songId,
                  name: 'Bài hát $songId',
                  artistName: 'Nghệ sĩ không xác định',
                  artistId: '',
                  albumName: '',
                  albumImage: '',
                  audioUrl: 'https://prod-1.storage.jamendo.com/?trackid=$songId&format=mp31',
                  audioDownload: '',
                  duration: 0,
                  tags: [],
                  releaseDate: '',
                  position: 0,
                ));
              }
            } catch (e) {
              debugPrint('Lỗi lấy thông tin bài hát $songId: $e');
            }
          }
        } catch (e) {
          debugPrint('Lỗi parse song: $e');
        }
      }
      
      return songs;
    } catch (e) {
      debugPrint('Lỗi lấy bài hát playlist: $e');
      return [];
    }
  }

  // Cập nhật playlist info
  Future<bool> updatePlaylist(String playlistId, {String? name, String? description}) async {
    final user = _auth.currentUser;
    if (user == null) return false;
    
    try {
      final updates = <String, dynamic>{};
      if (name != null) updates['name'] = name;
      if (description != null) updates['description'] = description;
      
      if (updates.isNotEmpty) {
        await _database.ref('users/${user.uid}/playlists/$playlistId').update(updates);
        notifyListeners();
        return true;
      }
    } catch (e) {
      debugPrint('Lỗi cập nhật playlist: $e');
    }
    return false;
  }

  // Helper method để cập nhật số lượng bài hát
  Future<void> _updatePlaylistSongCount(String playlistId) async {
    final user = _auth.currentUser;
    if (user == null) return;
    
    try {
      final songsSnapshot = await _database.ref('users/${user.uid}/playlists/$playlistId/songs').get();
      final songCount = songsSnapshot.exists ? 
        (songsSnapshot.value as Map).length : 0;
      
      await _database.ref('users/${user.uid}/playlists/$playlistId').update({
        'songCount': songCount,
      });
    } catch (e) {
      debugPrint('Lỗi cập nhật song count: $e');
    }
  }
}

