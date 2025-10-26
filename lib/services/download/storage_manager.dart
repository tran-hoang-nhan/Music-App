import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/song.dart';

class StorageManager extends ChangeNotifier {
  final List<Song> _downloadedSongs = [];

  List<Song> get downloadedSongs => List.unmodifiable(_downloadedSongs);

  Future<void> loadDownloadedSongs() async {
    final prefs = await SharedPreferences.getInstance();
    final songsJson = prefs.getStringList('downloaded_songs') ?? [];
        
    _downloadedSongs.clear();
    final loadedIds = <String>{};
    
    for (final songJson in songsJson) {
      try {
        final songMap = json.decode(songJson);
        final song = Song.fromJson(songMap);
        
        // Tránh duplicate trong danh sách load
        if (loadedIds.contains(song.id)) {
          continue;
        }
        
        // Kiểm tra file còn tồn tại
        final file = File(song.audioUrl);
        final exists = await file.exists();
        final size = exists ? await file.length() : 0;
        debugPrint('📂 File check: exists=$exists, size=$size bytes, path=${song.audioUrl}');
        
        if (exists) {
          _downloadedSongs.add(song);
          loadedIds.add(song.id);
        } else {
          debugPrint('❌ File NOT found: ${song.audioUrl}');
        }
      } catch (e) {
        debugPrint('   ❌ Error loading song: $e');
      }
    }
    
    notifyListeners();
  }

  Future<void> saveSong(Song song, String filePath) async {
    // Kiểm tra xem bài hát đã tồn tại chưa
    if (isSongDownloaded(song.id)) {
      return;
    }
    
    // Tạo song với local file path
    final downloadedSong = Song(
      id: song.id,
      name: song.name,
      artistName: song.artistName,
      audioUrl: filePath, // Local file path
      albumImage: song.albumImage,
      duration: song.duration,
      artistId: song.artistId,
      albumName: song.albumName,
      audioDownload: song.audioDownload,
      tags: song.tags,
      releaseDate: song.releaseDate,
      position: song.position,
    );

    _downloadedSongs.add(downloadedSong);
    await _saveToPreferences();
    notifyListeners();
  }

  Future<void> removeSong(String songId) async {
    final index = _downloadedSongs.indexWhere((song) => song.id == songId);
    if (index != -1) {
      final song = _downloadedSongs[index];
      
      // Xóa file
      final file = File(song.audioUrl);
      if (await file.exists()) {
        await file.delete();
      }
      
      _downloadedSongs.removeAt(index);
      await _saveToPreferences();
      notifyListeners();
    }
  }

  bool isSongDownloaded(String songId) {
    return _downloadedSongs.any((song) => song.id == songId);
  }

  Song? getDownloadedSong(String songId) {
    try {
      return _downloadedSongs.firstWhere((song) => song.id == songId);
    } catch (e) {
      return null;
    }
  }

  Future<void> _saveToPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final songsJson = _downloadedSongs
        .map((song) => json.encode(song.toJson()))
        .toList();
    await prefs.setStringList('downloaded_songs', songsJson);
  }

  Future<String> getStorageUsage() async {
    final directory = await getApplicationDocumentsDirectory();
    final downloadDir = Directory('${directory.path}/downloads');
    
    if (!await downloadDir.exists()) {
      return '0 MB';
    }

    int totalSize = 0;
    await for (final entity in downloadDir.list()) {
      if (entity is File) {
        final stat = await entity.stat();
        totalSize += stat.size;
      }
    }

    return _formatBytes(totalSize);
  }

  String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  Future<void> clearAllDownloads() async {
    final directory = await getApplicationDocumentsDirectory();
    final downloadDir = Directory('${directory.path}/downloads');
    
    if (await downloadDir.exists()) {
      await downloadDir.delete(recursive: true);
    }

    _downloadedSongs.clear();
    await _saveToPreferences();
    notifyListeners();
  }
}

