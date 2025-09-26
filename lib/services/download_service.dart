import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/song.dart';

class DownloadService extends ChangeNotifier {
  final List<Song> _downloadedSongs = [];
  final Dio _dio = Dio();

  List<Song> get downloadedSongs => List.unmodifiable(_downloadedSongs);

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
      notifyListeners();
      return true;
    } catch (e) {
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
    final song = _downloadedSongs.firstWhere((s) => s.id == songId);
    final file = File(song.audioUrl);
    
    if (await file.exists()) {
      await file.delete();
    }
    
    _downloadedSongs.removeWhere((s) => s.id == songId);
    await _saveDownloadedSongs();
    notifyListeners();
  }
}