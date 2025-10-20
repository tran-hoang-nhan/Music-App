import 'package:flutter/foundation.dart';
import '../../models/song.dart';
import 'download_manager.dart';
import 'storage_manager.dart';
import 'queue_manager.dart';

class DownloadController extends ChangeNotifier {
  final DownloadManager _downloadManager = DownloadManager();
  final StorageManager _storageManager = StorageManager();
  final QueueManager _queueManager = QueueManager();

  bool _isProcessingQueue = false;

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

  // Combined methods
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

  Future<void> downloadMultipleSongs(List<Song> songs) async {
    // Add to queue
    _queueManager.addAllToQueue(songs);
    
    // Start processing if not already
    if (!_isProcessingQueue) {
      _processQueue();
    }
  }

  Future<void> _processQueue() async {
    if (_isProcessingQueue) return;
    
    _isProcessingQueue = true;
    
    while (_queueManager.queueLength > 0) {
      final song = _queueManager.getNextSong();
      if (song == null) break;

      try {
        final success = await downloadSong(song);
        if (success) {
          _queueManager.moveNext();
        } else {
          // Retry logic
          if (_queueManager.shouldRetry(song.id)) {
            _queueManager.incrementRetry(song.id);
            // Move to end of queue for retry
            _queueManager.moveNext();
            _queueManager.addToQueue(song);
          } else {
            // Max retries reached, remove from queue
            _queueManager.removeFromQueue(song.id);
          }
        }
      } catch (e) {
        debugPrint('Error processing queue item ${song.id}: $e');
        _queueManager.removeFromQueue(song.id);
      }
    }
    
    _isProcessingQueue = false;
  }

  Future<void> cancelDownload(String songId) async {
    await _downloadManager.cancelDownload(songId);
    _queueManager.removeFromQueue(songId);
  }

  Future<void> deleteSong(String songId) async {
    await _storageManager.removeSong(songId);
  }

  // Convenience getters
  List<Song> get downloadedSongs => _storageManager.downloadedSongs;
  List<Song> get downloadQueue => _queueManager.downloadQueue;
  
  bool isDownloading(String songId) => _downloadManager.isDownloading(songId);
  bool isSongDownloaded(String songId) => _storageManager.isSongDownloaded(songId);
  bool isInQueue(String songId) => _queueManager.isInQueue(songId);
  
  double getDownloadProgress(String songId) => _downloadManager.getDownloadProgress(songId);
  Song? getDownloadedSong(String songId) => _storageManager.getDownloadedSong(songId);

  Future<String> getStorageUsage() => _storageManager.getStorageUsage();
  
  Future<void> clearAllDownloads() async {
    _queueManager.clearQueue();
    await _storageManager.clearAllDownloads();
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

