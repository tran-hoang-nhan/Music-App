import 'package:flutter/foundation.dart';
import '../../models/song.dart';

class ShuffleService extends ChangeNotifier {
  bool _isEnabled = false;
  List<Song> _originalQueue = [];
  List<int> _shuffledIndices = [];
  int _currentIndex = 0;
  int _shuffleIndex = 0;

  // Getters
  bool get isEnabled => _isEnabled;
  List<int> get shuffledIndices => _shuffledIndices;
  int get shuffleIndex => _shuffleIndex;

  void toggle() {
    _isEnabled = !_isEnabled;
    if (_isEnabled) {
      _enableShuffle();
    } else {
      _disableShuffle();
    }
    notifyListeners();
  }

  void updateQueue(List<Song> queue, int currentIndex) {
    _originalQueue = List.from(queue);
    _currentIndex = currentIndex;
    
    if (_isEnabled) {
      _generateShuffledIndices();
    }
  }

  void _enableShuffle() {
    if (_originalQueue.isNotEmpty) {
      _generateShuffledIndices();
    }
  }

  void _disableShuffle() {
    _shuffledIndices.clear();
    _shuffleIndex = 0;
  }

  void _generateShuffledIndices() {
    _shuffledIndices = List.generate(_originalQueue.length, (index) => index);
    
    // Ensure current song stays at current position
    if (_currentIndex < _shuffledIndices.length) {
      _shuffledIndices.removeAt(_currentIndex);
      _shuffledIndices.shuffle();
      _shuffledIndices.insert(0, _currentIndex);
      _shuffleIndex = 0;
    } else {
      _shuffledIndices.shuffle();
    }
  }

  int getNextIndex() {
    if (!_isEnabled || _shuffledIndices.isEmpty) {
      return (_currentIndex + 1) % _originalQueue.length;
    }
    
    _shuffleIndex = (_shuffleIndex + 1) % _shuffledIndices.length;
    return _shuffledIndices[_shuffleIndex];
  }

  int getPreviousIndex() {
    if (!_isEnabled || _shuffledIndices.isEmpty) {
      return _currentIndex > 0 ? _currentIndex - 1 : _originalQueue.length - 1;
    }
    
    _shuffleIndex = _shuffleIndex > 0 ? _shuffleIndex - 1 : _shuffledIndices.length - 1;
    return _shuffledIndices[_shuffleIndex];
  }

  void updateCurrentIndex(int newIndex) {
    _currentIndex = newIndex;
    
    if (_isEnabled && _shuffledIndices.isNotEmpty) {
      // Find the shuffle index that corresponds to the new current index
      for (int i = 0; i < _shuffledIndices.length; i++) {
        if (_shuffledIndices[i] == newIndex) {
          _shuffleIndex = i;
          break;
        }
      }
    }
  }
}

