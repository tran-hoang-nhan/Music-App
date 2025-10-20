import 'package:flutter/foundation.dart';
import '../../models/song.dart';

class QueueManager extends ChangeNotifier {
  final List<Song> _downloadQueue = [];
  final Map<String, int> _retryCount = {};
  final int _maxRetries = 3;

  List<Song> get downloadQueue => List.unmodifiable(_downloadQueue);

  void addToQueue(Song song) {
    if (!_downloadQueue.any((s) => s.id == song.id)) {
      _downloadQueue.add(song);
      notifyListeners();
    }
  }

  void addAllToQueue(List<Song> songs) {
    final uniqueSongs = songs.where((song) => 
        !_downloadQueue.any((s) => s.id == song.id)).toList();
    _downloadQueue.addAll(uniqueSongs);
    notifyListeners();
  }

  void removeFromQueue(String songId) {
    _downloadQueue.removeWhere((song) => song.id == songId);
    _retryCount.remove(songId);
    notifyListeners();
  }

  Song? getNextSong() {
    return _downloadQueue.isNotEmpty ? _downloadQueue.first : null;
  }

  void moveNext() {
    if (_downloadQueue.isNotEmpty) {
      _downloadQueue.removeAt(0);
      notifyListeners();
    }
  }

  bool shouldRetry(String songId) {
    final count = _retryCount[songId] ?? 0;
    return count < _maxRetries;
  }

  void incrementRetry(String songId) {
    _retryCount[songId] = (_retryCount[songId] ?? 0) + 1;
  }

  void clearQueue() {
    _downloadQueue.clear();
    _retryCount.clear();
    notifyListeners();
  }

  void reorderQueue(int oldIndex, int newIndex) {
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    final Song song = _downloadQueue.removeAt(oldIndex);
    _downloadQueue.insert(newIndex, song);
    notifyListeners();
  }

  int get queueLength => _downloadQueue.length;

  bool isInQueue(String songId) {
    return _downloadQueue.any((song) => song.id == songId);
  }
}

