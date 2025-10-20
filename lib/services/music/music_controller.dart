import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import '../../models/song.dart';
import 'playback_service.dart';
import 'queue_service.dart';
import 'shuffle_service.dart';
import 'repeat_service.dart';

class MusicController extends ChangeNotifier {
  static final MusicController _instance = MusicController._internal();
  factory MusicController() => _instance;
  MusicController._internal() {
    _initializeListeners();
  }

  final PlaybackService playback = PlaybackService();
  final QueueService queue = QueueService();
  final ShuffleService shuffle = ShuffleService();
  final RepeatService repeat = RepeatService();

  // Getters that delegate to services
  Song? get currentSong => queue.currentSong;
  List<Song> get playlist => queue.queue;
  int get currentIndex => queue.currentIndex;
  bool get isPlaying => playback.isPlaying;
  bool get isLoading => playback.isLoading;
  Duration get currentPosition => playback.currentPosition;
  Duration get totalDuration => playback.totalDuration;
  bool get isShuffled => shuffle.isEnabled;
  bool get isRepeating => repeat.isEnabled;
  double get volume => playback.volume;

  void _initializeListeners() {
    // Listen to all services and propagate changes
    playback.addListener(notifyListeners);
    queue.addListener(notifyListeners);
    shuffle.addListener(notifyListeners);
    repeat.addListener(notifyListeners);

    // Handle song completion
    playback.playerStateStream.listen((state) {
      if (state.processingState == ProcessingState.completed) {
        _handleSongComplete();
      }
    });
  }

  Future<void> _handleSongComplete() async {
    if (repeat.shouldRepeatCurrentSong()) {
      await playback.seekTo(Duration.zero);
      await playback.play();
    } else if (shuffle.isEnabled) {
      await playNext();
    } else if (queue.hasNext()) {
      await playNext();
    } else if (repeat.shouldRepeatPlaylist(queue.currentIndex, queue.queue.length)) {
      queue.setCurrentIndex(0);
      shuffle.updateCurrentIndex(0);
      await playback.playSong(queue.queue[0]);
    }
  }

  // Main playback methods
  Future<void> playSong(Song song, {List<Song>? playlist, int? index}) async {
    debugPrint('MusicController.playSong() called: ${song.name} by ${song.artistName}');

    // Set up queue first
    if (playlist != null && index != null) {
      queue.setQueue(playlist, startIndex: index);
      shuffle.updateQueue(playlist, index);
    } else if (playlist != null) {
      final songIndex = playlist.indexWhere((s) => s.id == song.id);
      final startIndex = songIndex >= 0 ? songIndex : 0;
      queue.setQueue(playlist, startIndex: startIndex);
      shuffle.updateQueue(playlist, startIndex);
    } else {
      queue.setQueue([song], startIndex: 0);
      shuffle.updateQueue([song], 0);
    }

    debugPrint('Current song after queue set: ${queue.currentSong?.name} - index: ${queue.currentIndex}');
    
    // Notify UI immediately
    notifyListeners();

    // Play with retry logic
    int retryCount = 0;
    const maxRetries = 2;
    
    while (retryCount <= maxRetries) {
      try {
        await playback.playSong(song);
        
        // Success - notify and break
        notifyListeners();
        debugPrint('MusicController.playSong() completed - currentSong: ${currentSong?.name}');
        break;
        
      } catch (e) {
        retryCount++;
        debugPrint('Error playing song (attempt $retryCount): $e');
        
        if (retryCount > maxRetries) {
          debugPrint('Failed to play song after $maxRetries attempts');
          rethrow;
        } else {
          await Future.delayed(Duration(seconds: retryCount));
        }
      }
    }
  }

  Future<void> play() => playback.play();
  Future<void> pause() => playback.pause();
  Future<void> resume() => playback.resume();
  Future<void> stop() => playback.stop();
  Future<void> seekTo(Duration position) => playback.seekTo(position);

  Future<void> playNext() async {
    int nextIndex;
    if (shuffle.isEnabled) {
      nextIndex = shuffle.getNextIndex();
    } else {
      nextIndex = queue.getNextIndex();
    }
    
    if (nextIndex < queue.queue.length) {
      queue.setCurrentIndex(nextIndex);
      shuffle.updateCurrentIndex(nextIndex);
      
      final nextSong = queue.queue[nextIndex];
      debugPrint('Playing next: ${nextSong.name} at index $nextIndex');
      
      // Notify UI immediately when song changes
      notifyListeners();
      
      await playback.playSong(nextSong);
      
      // Notify again after playback starts
      notifyListeners();
    }
  }

  Future<void> playPrevious() async {
    int prevIndex;
    if (shuffle.isEnabled) {
      prevIndex = shuffle.getPreviousIndex();
    } else {
      prevIndex = queue.getPreviousIndex();
    }
    
    if (prevIndex >= 0 && prevIndex < queue.queue.length) {
      queue.setCurrentIndex(prevIndex);
      shuffle.updateCurrentIndex(prevIndex);
      
      final prevSong = queue.queue[prevIndex];
      debugPrint('Playing previous: ${prevSong.name} at index $prevIndex');
      
      // Notify UI immediately when song changes
      notifyListeners();
      
      await playback.playSong(prevSong);
      
      // Notify again after playback starts
      notifyListeners();
    }
  }

  // Control methods
  void toggleShuffle() {
    shuffle.toggle();
    shuffle.updateQueue(queue.queue, queue.currentIndex);
  }

  void toggleRepeat() {
    repeat.toggle();
  }

  void setVolume(double volume) {
    playback.setVolume(volume);
  }

  // Queue management
  void addToQueue(Song song) => queue.addToQueue(song);
  void addAllToQueue(List<Song> songs) => queue.addAllToQueue(songs);
  void insertNext(Song song) => queue.insertNext(song);
  void removeSongFromQueue(int index) => queue.removeSong(index);
  void moveSongInQueue(int oldIndex, int newIndex) => queue.moveSong(oldIndex, newIndex);
  void clearQueue() => queue.clearQueue();

  @override
  @override
  void dispose() {
    playback.dispose();
    super.dispose();
  }
}

