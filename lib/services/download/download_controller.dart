import 'package:flutter/foundation.dart';
import '../../models/song.dart';
import 'download_manager.dart';
import 'storage_manager.dart';
import 'queue_manager.dart';

class DownloadController extends ChangeNotifier {
  final DownloadManager _downloadManager = DownloadManager();
  final StorageManager _storageManager = StorageManager();
  final QueueManager _queueManager = QueueManager();

  // Getters để truy cập các manager
  DownloadManager get download => _downloadManager;
  StorageManager get storage => _storageManager;
  QueueManager get queue => _queueManager;

  DownloadController() {
    // Listen to changes from all managers
    _downloadManager.addListener(_onManagerChanged);
    _storageManager.addListener(_onManagerChanged);
    _queueManager.addListener(_onManagerChanged);
    
    // Load downloaded songs on init
    _storageManager.loadDownloadedSongs();
  }

  void _onManagerChanged() {
    notifyListeners();
  }

  // Combined download method (high-level operation)
  Future<bool> downloadSong(Song song) async {
    try {
      // Kiểm tra đã download chưa
      if (_storageManager.isSongDownloaded(song.id)) {
        return false;
      }

      // Kiểm tra đang download chưa
      if (_downloadManager.isDownloading(song.id)) {
        return false;
      }

      // Download song
      final filePath = await _downloadManager.downloadSong(song);
      if (filePath != null) {
        // Save to storage
        await _storageManager.saveSong(song, filePath);
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error downloading song: $e');
      return false;
    }
  }

  @override
  void dispose() {
    _downloadManager.removeListener(_onManagerChanged);
    _storageManager.removeListener(_onManagerChanged);
    _queueManager.removeListener(_onManagerChanged);
    
    _downloadManager.dispose();
    super.dispose();
  }
}

