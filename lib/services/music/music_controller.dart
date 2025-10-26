import 'package:flutter/material.dart';
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

    // Inject dependencies into services
    queue.setServices(playback, shuffle);

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
      await queue.playNextInternal();
    } else if (queue.hasNext()) {
      await queue.playNextInternal();
    } else if (repeat.shouldRepeatPlaylist(queue.currentIndex, queue.queue.length)) {
      queue.setCurrentIndex(0);
      shuffle.updateCurrentIndex(0);
      await playback.playSong(queue.queue[0]);
    }
  }

  // Main playback methods - delegate to services
  Future<void> playSong(BuildContext context, Song song, {List<Song>? playlist, int? index}) async {
    return await queue.playSong(context, song, playlist: playlist, index: index);
  }

  Future<void> play() => playback.play();
  Future<void> pause() => playback.pause();
  Future<void> resume() => playback.resume();
  Future<void> stop() => playback.stop();
  Future<void> seekTo(Duration position) => playback.seekTo(position);

  Future<void> playNext(BuildContext context) async {
    return await queue.playNext(context);
  }

  Future<void> playPrevious(BuildContext context) async {
    return await queue.playPrevious(context);
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
  void dispose() {
    playback.dispose();
    super.dispose();
  }
}

