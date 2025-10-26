import 'dart:io';
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
      
      debugPrint('PlaybackService.loadSong() - loading: ${song.name} from ${song.audioUrl}');

      // Kiểm tra xem có phải local file path không
      // Local paths thường: /data/user/0/..., /storage/emulated/0/..., C:\Users\..., /tmp/..., v.v.
      final isLocalFile = song.audioUrl.startsWith('/') || 
                          song.audioUrl.contains(RegExp(r'^[a-zA-Z]:\\')) ||
                          song.audioUrl.contains('/downloads/') ||
                          song.audioUrl.contains('\\downloads\\');
      
      debugPrint('PlaybackService.loadSong() - isLocalFile: $isLocalFile');
      
      if (isLocalFile) {
        // Check nếu file thực sự tồn tại
        final file = File(song.audioUrl);
        final fileExists = await file.exists();
        debugPrint('PlaybackService.loadSong() - file exists: $fileExists at ${song.audioUrl}');
        
        if (fileExists) {
          // File tồn tại - dùng setFilePath() ONLY (không cần fallback)
          debugPrint('✅ Loading local file via setFilePath(): ${song.audioUrl}');
          await _audioPlayer.setFilePath(song.audioUrl);
          debugPrint('✅ Successfully loaded local file via setFilePath()');
        } else {
          // File không tồn tại - cảnh báo
          debugPrint('❌ Local file NOT found: ${song.audioUrl}');
          throw Exception('Local file not found: ${song.audioUrl}');
        }
      } else {
        // Remote URL - sử dụng setUrl
        debugPrint('Loading remote URL: ${song.audioUrl}');
        await _audioPlayer.setUrl(song.audioUrl);
        debugPrint('✓ Successfully loaded remote URL');
      }
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      debugPrint('❌ Error loading song: $e');
      rethrow;
    }
  }

  Future<void> playSong(Song song) async {
    try {
      debugPrint('PlaybackService.playSong() called: ${song.name}');
      await loadSong(song);
      debugPrint('PlaybackService.playSong() - song loaded, now playing');
      await play();
      debugPrint('PlaybackService.playSong() completed');
    } catch (e) {
      debugPrint('Error playing song: $e');
      rethrow;
    }
  }
  
  Future<void> playSongWithQueue(Song song, {List<Song>? playlist, int? index}) async {
    debugPrint('PlaybackService.playSongWithQueue() called: ${song.name} by ${song.artistName}');

    // Play with retry logic
    int retryCount = 0;
    const maxRetries = 2;
    
    while (retryCount <= maxRetries) {
      try {
        await playSong(song);
        
        // Success - notify and break
        notifyListeners();
        debugPrint('PlaybackService.playSongWithQueue() completed - currentSong: ${song.name}');
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

  Future<void> play() async {
    try {
      debugPrint('🎵 PlaybackService.play() - starting playback');
      await _audioPlayer.play();
      debugPrint('🎵 PlaybackService.play() - playback started successfully');
    } catch (e) {
      debugPrint('❌ Error playing audio: $e');
      rethrow;
    }
  }

  Future<void> pause() async {
    try {
      debugPrint('⏸️ PlaybackService.pause() - pausing playback');
      await _audioPlayer.pause();
      debugPrint('⏸️ PlaybackService.pause() - paused successfully');
    } catch (e) {
      debugPrint('❌ Error pausing audio: $e');
    }
  }

  Future<void> resume() async {
    try {
      debugPrint('▶️ PlaybackService.resume() - resuming playback');
      await _audioPlayer.play();
      debugPrint('▶️ PlaybackService.resume() - resumed successfully');
    } catch (e) {
      debugPrint('❌ Error resuming audio: $e');
    }
  }

  Future<void> stop() async {
    try {
      debugPrint('⏹️ PlaybackService.stop() - stopping audio player');
      await _audioPlayer.stop();
      debugPrint('⏹️ PlaybackService.stop() - stopped successfully');
    } catch (e) {
      debugPrint('❌ Error stopping audio: $e');
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

