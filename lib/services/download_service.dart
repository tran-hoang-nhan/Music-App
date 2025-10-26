import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/song.dart';

class DownloadService extends ChangeNotifier {
  final List<Song> _downloadedSongs = [];
  final Set<String> _downloadingIds = {};
  final Dio _dio = Dio();

  List<Song> get downloadedSongs => List.unmodifiable(_downloadedSongs);
  
  bool isDownloading(String songId) => _downloadingIds.contains(songId);

  // Sync downloaded songs từ StorageManager để tránh duplicate
  Future<void> syncDownloadedSongs(List<Song> songs) async {
    _downloadedSongs.clear();
    _downloadedSongs.addAll(songs);
    notifyListeners();
  }

  Future<void> loadDownloadedSongs() async {
    final prefs = await SharedPreferences.getInstance();
    final songsJson = prefs.getStringList('downloaded_songs') ?? [];
    
    _downloadedSongs.clear();
    for (final songJson in songsJson) {
      final songMap = json.decode(songJson);
      final song = Song.fromJson(songMap);
      
      // Kiểm tra file còn tồn tại
      final file = File(song.audioUrl);
      if (await file.exists()) {
        _downloadedSongs.add(song);
      }
    }
    notifyListeners();
  }

  Future<bool> downloadSong(Song song) async {
    if (_downloadingIds.contains(song.id) || isSongDownloaded(song.id)) {
      return false;
    }
    
    _downloadingIds.add(song.id);
    notifyListeners();
    
    try {
      final directory = await getApplicationDocumentsDirectory();
      final downloadDir = Directory('${directory.path}/downloads');
      
      if (!await downloadDir.exists()) {
        await downloadDir.create(recursive: true);
      }

      final filePath = '${downloadDir.path}/${song.id}.mp3';
      await _dio.download(song.audioUrl, filePath);
      
      final downloadedSong = Song(
        id: song.id,
        name: song.name,
        artistName: song.artistName,
        albumImage: song.albumImage,
        audioUrl: filePath,
        duration: song.duration,
        tags: song.tags,
      );
      
      _downloadedSongs.add(downloadedSong);
      await _saveDownloadedSongs();
      
      _downloadingIds.remove(song.id);
      notifyListeners();
      return true;
    } catch (e) {
      _downloadingIds.remove(song.id);
      notifyListeners();
      return false;
    }
  }

  Future<void> _saveDownloadedSongs() async {
    final prefs = await SharedPreferences.getInstance();
    final songsJson = _downloadedSongs.map((song) => json.encode(song.toJson())).toList();
    await prefs.setStringList('downloaded_songs', songsJson);
  }

  bool isSongDownloaded(String songId) {
    return _downloadedSongs.any((song) => song.id == songId);
  }

  Future<void> deleteSong(String songId) async {
    try {
      final songIndex = _downloadedSongs.indexWhere((s) => s.id == songId);
      if (songIndex == -1) return;
      
      final song = _downloadedSongs[songIndex];
      final file = File(song.audioUrl);
      
      if (await file.exists()) {
        await file.delete();
      }
      
      _downloadedSongs.removeAt(songIndex);
      await _saveDownloadedSongs();
      notifyListeners();
    } catch (e) {
      debugPrint('Lỗi xóa file: $e');
    }
  }
  
  Future<void> clearAllDownloads() async {
    try {
      for (final song in _downloadedSongs) {
        final file = File(song.audioUrl);
        if (await file.exists()) {
          await file.delete();
        }
      }
      
      _downloadedSongs.clear();
      await _saveDownloadedSongs();
      notifyListeners();
    } catch (e) {
      debugPrint('Lỗi xóa tất cả download: $e');
    }
  }
  
  String get downloadedSizeText {
    // Ước tính kích thước (3-4MB per song)
    final estimatedSize = _downloadedSongs.length * 3.5;
    if (estimatedSize < 1000) {
      return '${estimatedSize.toStringAsFixed(1)} MB';
    } else {
      return '${(estimatedSize / 1000).toStringAsFixed(1)} GB';
    }
  }
}

