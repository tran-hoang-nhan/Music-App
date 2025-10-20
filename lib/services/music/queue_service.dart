import 'package:flutter/foundation.dart';
import '../../models/song.dart';

class QueueService extends ChangeNotifier {
  List<Song> _queue = [];
  int _currentIndex = 0;

  // Getters
  List<Song> get queue => _queue;
  int get currentIndex => _currentIndex;
  Song? get currentSong => _queue.isNotEmpty && _currentIndex < _queue.length 
      ? _queue[_currentIndex] 
      : null;

  void setQueue(List<Song> songs, {int startIndex = 0}) {
    _queue = List.from(songs);
    _currentIndex = startIndex.clamp(0, _queue.length - 1);
    notifyListeners();
  }

  void addToQueue(Song song) {
    _queue.add(song);
    notifyListeners();
  }

  void addAllToQueue(List<Song> songs) {
    _queue.addAll(songs);
    notifyListeners();
  }

  void insertNext(Song song) {
    if (_queue.isEmpty) {
      _queue.add(song);
      _currentIndex = 0;
    } else {
      _queue.insert(_currentIndex + 1, song);
    }
    notifyListeners();
  }

  void removeSong(int index) {
    if (index >= 0 && index < _queue.length) {
      _queue.removeAt(index);
      
      if (index < _currentIndex) {
        _currentIndex--;
      } else if (index == _currentIndex && _currentIndex >= _queue.length) {
        _currentIndex = _queue.length - 1;
      }
      
      _currentIndex = _currentIndex.clamp(0, _queue.length - 1);
      notifyListeners();
    }
  }

  void moveSong(int oldIndex, int newIndex) {
    if (oldIndex >= 0 && oldIndex < _queue.length && 
        newIndex >= 0 && newIndex < _queue.length) {
      final song = _queue.removeAt(oldIndex);
      _queue.insert(newIndex, song);
      
      // Update current index if needed
      if (oldIndex == _currentIndex) {
        _currentIndex = newIndex;
      } else if (oldIndex < _currentIndex && newIndex >= _currentIndex) {
        _currentIndex--;
      } else if (oldIndex > _currentIndex && newIndex <= _currentIndex) {
        _currentIndex++;
      }
      
      notifyListeners();
    }
  }

  void clearQueue() {
    _queue.clear();
    _currentIndex = 0;
    notifyListeners();
  }

  void setCurrentIndex(int index) {
    if (index >= 0 && index < _queue.length) {
      _currentIndex = index;
      notifyListeners();
    }
  }

  bool hasNext() {
    return _currentIndex < _queue.length - 1;
  }

  bool hasPrevious() {
    return _currentIndex > 0;
  }

  int getNextIndex() {
    return hasNext() ? _currentIndex + 1 : 0;
  }

  int getPreviousIndex() {
    return hasPrevious() ? _currentIndex - 1 : _queue.length - 1;
  }
}

