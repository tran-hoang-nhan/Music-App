import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/foundation.dart';
import '../../models/song.dart';

class DownloadManager extends ChangeNotifier {
  final Dio _dio = Dio();
  final Set<String> _downloadingIds = {};
  bool isDownloading(String songId) => _downloadingIds.contains(songId);

  Future<String?> downloadSong(Song song) async {
    if (_downloadingIds.contains(song.id)) {
      return null;
    }

    _downloadingIds.add(song.id);
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
      );

      _downloadingIds.remove(song.id);
      notifyListeners();

      return filePath;
    } catch (e) {
      _downloadingIds.remove(song.id);
      notifyListeners();
      throw Exception('Download failed: $e');
    }
  }

  Future<void> cancelDownload(String songId) async {
    _downloadingIds.remove(songId);
    notifyListeners();
  }

  @override
  void dispose() {
    _dio.close();
    super.dispose();
  }
}

