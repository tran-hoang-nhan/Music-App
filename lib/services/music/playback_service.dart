import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import '../../models/song.dart';

class PlaybackService extends ChangeNotifier {
  final AudioPlayer _audioPlayer = AudioPlayer();
  
  bool _isPlaying = false;
  bool _isLoading = false;
  Duration _currentPosition = Duration.zero;
  Duration _totalDuration = Duration.zero;
  double _volume = 1.0;

  // Getters
  AudioPlayer get audioPlayer => _audioPlayer;
  bool get isPlaying => _isPlaying;
  bool get isLoading => _isLoading;
  Duration get currentPosition => _currentPosition;
  Duration get totalDuration => _totalDuration;
  double get volume => _volume;

  PlaybackService() {
    _initializePlayer();
  }

  void _initializePlayer() {
    _audioPlayer.setVolume(_volume);
    
    _audioPlayer.durationStream.listen((duration) {
      final newDuration = duration ?? Duration.zero;
      if (_totalDuration != newDuration) {
        _totalDuration = newDuration;
        notifyListeners();
      }
    });

    _audioPlayer.positionStream.listen((position) {
      if (_currentPosition != position) {
        _currentPosition = position;
        notifyListeners();
      }
    });

    _audioPlayer.playingStream.listen((playing) {
      if (_isPlaying != playing) {
        _isPlaying = playing;
        notifyListeners();
      }
    });

    _audioPlayer.processingStateStream.listen((state) {
      final loading = state == ProcessingState.loading || state == ProcessingState.buffering;
      if (_isLoading != loading) {
        _isLoading = loading;
        notifyListeners();
      }
    });
  }

  Future<void> loadSong(Song song) async {
    try {
      _isLoading = true;
      notifyListeners();

      await _audioPlayer.setUrl(song.audioUrl);
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> playSong(Song song) async {
    try {
      await loadSong(song);
      await play();
    } catch (e) {
      debugPrint('Error playing song: $e');
      rethrow;
    }
  }

  Future<void> play() async {
    try {
      await _audioPlayer.play();
    } catch (e) {
      debugPrint('Error playing audio: $e');
      rethrow;
    }
  }

  Future<void> pause() async {
    try {
      await _audioPlayer.pause();
    } catch (e) {
      debugPrint('Error pausing audio: $e');
    }
  }

  Future<void> resume() async {
    try {
      await _audioPlayer.play();
    } catch (e) {
      debugPrint('Error resuming audio: $e');
    }
  }

  Future<void> stop() async {
    try {
      await _audioPlayer.stop();
    } catch (e) {
      debugPrint('Error stopping audio: $e');
    }
  }

  Future<void> seekTo(Duration position) async {
    try {
      await _audioPlayer.seek(position);
    } catch (e) {
      debugPrint('Error seeking: $e');
    }
  }

  void setVolume(double volume) {
    _volume = volume.clamp(0.0, 1.0);
    _audioPlayer.setVolume(_volume);
    notifyListeners();
  }

  Stream<PlayerState> get playerStateStream => _audioPlayer.playerStateStream;

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }
}

