import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/foundation.dart';
import '../../models/song.dart';

class DownloadManager extends ChangeNotifier {
  final Dio _dio = Dio();
  final Set<String> _downloadingIds = {};
  final Map<String, double> _downloadProgress = {};

  bool isDownloading(String songId) => _downloadingIds.contains(songId);
  double getDownloadProgress(String songId) => _downloadProgress[songId] ?? 0.0;

  Future<String?> downloadSong(Song song) async {
    if (_downloadingIds.contains(song.id)) {
      return null;
    }

    _downloadingIds.add(song.id);
    _downloadProgress[song.id] = 0.0;
    notifyListeners();

    try {
      final directory = await getApplicationDocumentsDirectory();
      final downloadDir = Directory('${directory.path}/downloads');
      
      if (!await downloadDir.exists()) {
        await downloadDir.create(recursive: true);
      }

      final fileName = '${song.id}.mp3';
      final filePath = '${downloadDir.path}/$fileName';

      await _dio.download(
        song.audioUrl,
        filePath,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            final progress = received / total;
            _downloadProgress[song.id] = progress;
            notifyListeners();
          }
        },
      );

      _downloadingIds.remove(song.id);
      _downloadProgress.remove(song.id);
      notifyListeners();

      return filePath;
    } catch (e) {
      _downloadingIds.remove(song.id);
      _downloadProgress.remove(song.id);
      notifyListeners();
      throw Exception('Download failed: $e');
    }
  }

  Future<void> cancelDownload(String songId) async {
    _downloadingIds.remove(songId);
    _downloadProgress.remove(songId);
    notifyListeners();
  }

  @override
  void dispose() {
    _dio.close();
    super.dispose();
  }
}

