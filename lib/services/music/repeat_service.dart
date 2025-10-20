import 'package:flutter/foundation.dart';

enum RepeatMode { none, all, one }

class RepeatService extends ChangeNotifier {
  RepeatMode _mode = RepeatMode.none;

  RepeatMode get mode => _mode;
  bool get isEnabled => _mode != RepeatMode.none;
  bool get isRepeatOne => _mode == RepeatMode.one;
  bool get isRepeatAll => _mode == RepeatMode.all;

  void toggle() {
    switch (_mode) {
      case RepeatMode.none:
        _mode = RepeatMode.all;
        break;
      case RepeatMode.all:
        _mode = RepeatMode.one;
        break;
      case RepeatMode.one:
        _mode = RepeatMode.none;
        break;
    }
    notifyListeners();
  }

  void setMode(RepeatMode mode) {
    if (_mode != mode) {
      _mode = mode;
      notifyListeners();
    }
  }

  bool shouldRepeatCurrentSong() {
    return _mode == RepeatMode.one;
  }

  bool shouldRepeatPlaylist(int currentIndex, int playlistLength) {
    return _mode == RepeatMode.all && currentIndex >= playlistLength - 1;
  }
}

