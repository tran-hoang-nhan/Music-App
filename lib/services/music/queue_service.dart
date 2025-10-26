import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/song.dart';
import '../firebase/firebase_controller.dart';
import 'playback_service.dart';
import 'shuffle_service.dart';

class QueueService extends ChangeNotifier {
  List<Song> _queue = [];
  int _currentIndex = 0;
  PlaybackService? _playbackService;
  ShuffleService? _shuffleService;

  // Getters
  List<Song> get queue => _queue;
  int get currentIndex => _currentIndex;
  Song? get currentSong => _queue.isNotEmpty && _currentIndex < _queue.length 
      ? _queue[_currentIndex] 
      : null;

  // Inject services
  void setServices(PlaybackService playbackService, ShuffleService shuffleService) {
    _playbackService = playbackService;
    _shuffleService = shuffleService;
  }

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

  // Navigation methods with automatic playback
  Future<void> playNext(BuildContext context) async {
    int nextIndex;
    if (_shuffleService?.isEnabled == true) {
      nextIndex = _shuffleService!.getNextIndex();
    } else {
      nextIndex = getNextIndex();
    }
    
    if (nextIndex < _queue.length) {
      setCurrentIndex(nextIndex);
      _shuffleService?.updateCurrentIndex(nextIndex);
      
      final nextSong = _queue[nextIndex];
      debugPrint('Playing next: ${nextSong.name} at index $nextIndex');
      
      // Lưu lịch sử nghe khi chuyển bài next - RUN IN BACKGROUND
      final firebaseController = Provider.of<FirebaseController>(context, listen: false);
      firebaseController.history.addToListeningHistory(
        nextSong.id,
        nextSong.name,
        nextSong.artistName,
        song: nextSong,
      ).then((_) {
        debugPrint('✅ Next song history saved in background');
      }).catchError((e) {
        debugPrint('⚠️ Next song history save failed: $e');
      });
      
      // Notify UI immediately when song changes
      notifyListeners();
      
      if (_playbackService != null) {
        await _playbackService!.playSong(nextSong);
        // Notify again after playback starts
        notifyListeners();
      }
    }
  }

  // Gọi playNext mà không lưu lịch sử (dùng cho tự động chuyển bài khi hết)
  Future<void> playNextInternal() async {
    int nextIndex;
    if (_shuffleService?.isEnabled == true) {
      nextIndex = _shuffleService!.getNextIndex();
    } else {
      nextIndex = getNextIndex();
    }
    
    if (nextIndex < _queue.length) {
      setCurrentIndex(nextIndex);
      _shuffleService?.updateCurrentIndex(nextIndex);
      
      final nextSong = _queue[nextIndex];
      debugPrint('Playing next (internal): ${nextSong.name} at index $nextIndex');
      
      // Notify UI immediately when song changes
      notifyListeners();
      
      if (_playbackService != null) {
        await _playbackService!.playSong(nextSong);
        // Notify again after playback starts
        notifyListeners();
      }
    }
  }

  Future<void> playPrevious(BuildContext context) async {
    int prevIndex;
    if (_shuffleService?.isEnabled == true) {
      prevIndex = _shuffleService!.getPreviousIndex();
    } else {
      prevIndex = getPreviousIndex();
    }
    
    if (prevIndex >= 0 && prevIndex < _queue.length) {
      setCurrentIndex(prevIndex);
      _shuffleService?.updateCurrentIndex(prevIndex);
      
      final prevSong = _queue[prevIndex];
      debugPrint('Playing previous: ${prevSong.name} at index $prevIndex');
      
      // Lưu lịch sử nghe khi chuyển bài previous - RUN IN BACKGROUND
      final firebaseController = Provider.of<FirebaseController>(context, listen: false);
      firebaseController.history.addToListeningHistory(
        prevSong.id,
        prevSong.name,
        prevSong.artistName,
        song: prevSong,
      ).then((_) {
        debugPrint('✅ Previous song history saved in background');
      }).catchError((e) {
        debugPrint('⚠️ Previous song history save failed: $e');
      });
      
      // Notify UI immediately when song changes
      notifyListeners();
      
      if (_playbackService != null) {
        await _playbackService!.playSong(prevSong);
        // Notify again after playback starts
        notifyListeners();
      }
    }
  }

  // Gọi playPrevious mà không lưu lịch sử (dùng cho tự động chuyển bài khi hết)
  Future<void> playPreviousInternal() async {
    int prevIndex;
    if (_shuffleService?.isEnabled == true) {
      prevIndex = _shuffleService!.getPreviousIndex();
    } else {
      prevIndex = getPreviousIndex();
    }
    
    if (prevIndex >= 0 && prevIndex < _queue.length) {
      setCurrentIndex(prevIndex);
      _shuffleService?.updateCurrentIndex(prevIndex);
      
      final prevSong = _queue[prevIndex];
      debugPrint('Playing previous (internal): ${prevSong.name} at index $prevIndex');
      
      // Notify UI immediately when song changes
      notifyListeners();
      
      if (_playbackService != null) {
        await _playbackService!.playSong(prevSong);
        // Notify again after playback starts
        notifyListeners();
      }
    }
  }

  // Enhanced playSong with queue management
  Future<void> playSong(BuildContext context, Song song, {List<Song>? playlist, int? index}) async {
    debugPrint('QueueService.playSong() called: ${song.name} by ${song.artistName}');

    // Lưu lịch sử nghe vào Firebase - RUN IN BACKGROUND (không await)
    try {
      final firebaseController = Provider.of<FirebaseController>(context, listen: false);
      // Fire and forget - không chờ
      firebaseController.history.addToListeningHistory(
        song.id,
        song.name,
        song.artistName,
        song: song,
      ).then((_) {
        debugPrint('✅ Listening history saved in background');
      }).catchError((e) {
        debugPrint('⚠️ Listening history save failed (background): $e');
      });
    } catch (e) {
      debugPrint('⚠️ Error starting history save: $e');
    }

    // Stop current playback before playing new song
    if (_playbackService != null) {
      await _playbackService!.stop();
      debugPrint('⏹️ Stopped current playback');
    }

    // Set up queue first
    if (playlist != null && index != null) {
      setQueue(playlist, startIndex: index);
      _shuffleService?.updateQueue(playlist, index);
    } else if (playlist != null) {
      final songIndex = playlist.indexWhere((s) => s.id == song.id);
      final startIndex = songIndex >= 0 ? songIndex : 0;
      setQueue(playlist, startIndex: startIndex);
      _shuffleService?.updateQueue(playlist, startIndex);
    } else {
      setQueue([song], startIndex: 0);
      _shuffleService?.updateQueue([song], 0);
    }

    debugPrint('Current song after queue set: ${currentSong?.name} - index: $currentIndex');
    
    // Notify UI immediately
    notifyListeners();

    // Use playback service with retry logic
    if (_playbackService != null) {
      try {
        debugPrint('🎶 Calling playSongWithQueue()');
        await _playbackService!.playSongWithQueue(song, playlist: playlist, index: index);
        debugPrint('🎶 playSongWithQueue() completed successfully');
        // Notify again after playback
        notifyListeners();
      } catch (e) {
        debugPrint('❌ Error in playSongWithQueue(): $e');
        rethrow;
      }
    } else {
      debugPrint('❌ _playbackService is null!');
    }
  }
}

