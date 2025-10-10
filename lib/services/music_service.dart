import 'dart:async';
import 'package:just_audio/just_audio.dart';
import 'package:flutter/foundation.dart';
import '../models/song.dart';
import 'firebase_service.dart';
import 'dynamic_theme_manager.dart';

class MusicService extends ChangeNotifier {
  static final MusicService _instance = MusicService._internal();
  factory MusicService() => _instance;
  MusicService._internal() {
    _initializePlayer();
  }

  final AudioPlayer _audioPlayer = AudioPlayer();
  final FirebaseService _firebaseService = FirebaseService();
  final DynamicThemeManager _themeManager = DynamicThemeManager();

  
  Song? _currentSong;
  List<Song> _playlist = [];
  List<Song> _originalPlaylist = [];
  List<int> _shuffledIndices = [];
  int _currentIndex = 0;
  int _shuffleIndex = 0;
  bool _isPlaying = false;
  bool _isLoading = false;
  Duration _currentPosition = Duration.zero;
  Duration _totalDuration = Duration.zero;
  bool _isShuffled = false;
  bool _isRepeating = false;
  double _volume = 1.0;
  bool _isLoadingInProgress = false;

  // Getters
  Song? get currentSong => _currentSong;
  List<Song> get playlist => _playlist;
  int get currentIndex => _currentIndex;
  bool get isPlaying => _isPlaying;
  bool get isLoading => _isLoading;
  Duration get currentPosition => _currentPosition;
  Duration get totalDuration => _totalDuration;
  bool get isShuffled => _isShuffled;
  bool get isRepeating => _isRepeating;
  double get volume => _volume;

  void _initializePlayer() {
    _audioPlayer.setVolume(1.0);
    
    _audioPlayer.durationStream.listen((duration) {
      final newDuration = duration ?? Duration.zero;
      if (_totalDuration != newDuration) {
        _totalDuration = newDuration;
        notifyListeners();
      }
    });

    // Giảm tần suất update position
    _audioPlayer.createPositionStream(
      minPeriod: const Duration(seconds: 1),
      maxPeriod: const Duration(seconds: 2),
    ).listen((position) {
      _currentPosition = position;
      notifyListeners();
    });

    _audioPlayer.playerStateStream.listen((state) {
      final wasPlaying = _isPlaying;
      final wasLoading = _isLoading;
      
      _isPlaying = state.playing;
      _isLoading = state.processingState == ProcessingState.loading;
      
      // Chỉ notify khi có thay đổi
      if (wasPlaying != _isPlaying || wasLoading != _isLoading) {
        notifyListeners();
      }
      
      if (state.processingState == ProcessingState.completed) {
        _onSongComplete();
      }
    });
  }

  Future<void> playSong(Song song, {List<Song>? playlist, int? index}) async {
    // Prevent concurrent loading
    if (_isLoadingInProgress) {
      debugPrint('Audio loading already in progress, ignoring new request');
      return;
    }
    
    int retryCount = 0;
    const maxRetries = 2;
    
    while (retryCount <= maxRetries) {
      try {
        _isLoadingInProgress = true;
        
        // Cancel any ongoing loading first
        await _audioPlayer.stop();
        
        _isLoading = true;
        notifyListeners();

        if (playlist != null) {
          _playlist = playlist;
          _currentIndex = index ?? 0;
        }

        _currentSong = song;
        
        // Background tasks - delay để không block UI
        Future.delayed(const Duration(seconds: 1), () {
          _firebaseService.addToListeningHistory(song.id, song.name, song.artistName);
          _themeManager.updateThemeFromSong(song);
        });
        
        // Tối ưu audio source với better error handling
        AudioSource audioSource;
        if (song.audioUrl.startsWith('/')) {
          audioSource = AudioSource.uri(Uri.file(song.audioUrl));
        } else {
          audioSource = AudioSource.uri(Uri.parse(song.audioUrl));
        }
        
        // Set audio source with timeout to prevent hanging
        await Future.any([
          _audioPlayer.setAudioSource(audioSource, preload: false),
          Future.delayed(const Duration(seconds: 15), () => throw TimeoutException('Audio load timeout', const Duration(seconds: 15))),
        ]);
        
        await _audioPlayer.play();
        
        _isLoading = false;
        _isLoadingInProgress = false;
        notifyListeners();
        
        // Success - break out of retry loop
        break;
        
      } catch (e) {
        retryCount++;
        debugPrint('Lỗi phát nhạc (lần thử $retryCount): $e');
        
        if (retryCount > maxRetries) {
          _isLoading = false;
          _isLoadingInProgress = false;
          _currentSong = null;
          notifyListeners();
          
          // Show user-friendly error message
          rethrow;
        } else {
          // Wait before retry
          await Future.delayed(Duration(seconds: retryCount));
        }
      }
    }
  }
  
  void unawaited(Future<void> future) {
    future.catchError((e) => debugPrint('Background task error: $e'));
  }

  Future<void> pause() async {
    await _audioPlayer.pause();
  }

  Future<void> resume() async {
    await _audioPlayer.play();
  }

  Future<void> stop() async {
    await _audioPlayer.stop();
    _isPlaying = false;
    _isLoading = false;
    _isLoadingInProgress = false;
    _currentPosition = Duration.zero;
    _currentSong = null;
    _themeManager.resetTheme();
    notifyListeners();
  }

  Future<void> seekTo(Duration position) async {
    await _audioPlayer.seek(position);
  }

  Future<void> playNext() async {
    if (_playlist.isEmpty || _isLoadingInProgress) return;
    
    int nextIndex;
    
    if (_isShuffled) {
      _shuffleIndex = (_shuffleIndex + 1) % _shuffledIndices.length;
      nextIndex = _shuffledIndices[_shuffleIndex];
    } else {
      nextIndex = (_currentIndex + 1) % _playlist.length;
    }
    
    _currentIndex = nextIndex;
    await playSong(_playlist[nextIndex], playlist: _playlist, index: nextIndex);
  }

  Future<void> playPrevious() async {
    if (_playlist.isEmpty || _isLoadingInProgress) return;
    
    int prevIndex;
    
    if (_isShuffled) {
      _shuffleIndex = _shuffleIndex > 0 ? _shuffleIndex - 1 : _shuffledIndices.length - 1;
      prevIndex = _shuffledIndices[_shuffleIndex];
    } else {
      prevIndex = _currentIndex > 0 ? _currentIndex - 1 : _playlist.length - 1;
    }
    
    _currentIndex = prevIndex;
    await playSong(_playlist[prevIndex], playlist: _playlist, index: prevIndex);
  }

  void toggleShuffle() {
    _isShuffled = !_isShuffled;
    
    if (_isShuffled) {
      // Tạo danh sách shuffle
      _originalPlaylist = List.from(_playlist);
      _shuffledIndices = List.generate(_playlist.length, (index) => index);
      _shuffledIndices.shuffle();
      
      // Tìm vị trí bài hiện tại trong shuffle
      _shuffleIndex = _shuffledIndices.indexOf(_currentIndex);
    } else {
      // Khôi phục playlist gốc
      _playlist = List.from(_originalPlaylist);
      _shuffledIndices.clear();
      _shuffleIndex = 0;
    }
    
    notifyListeners();
  }

  void toggleRepeat() {
    _isRepeating = !_isRepeating;
    notifyListeners();
  }

  Future<void> setVolume(double volume) async {
    _volume = volume.clamp(0.0, 1.0);
    await _audioPlayer.setVolume(_volume);
    notifyListeners();
  }

  void _onSongComplete() {
    if (_isRepeating && _currentSong != null) {
      // Repeat current song
      _audioPlayer.seek(Duration.zero);
      _audioPlayer.play();
    } else {
      playNext();
    }
  }

  void setPlaylist(List<Song> songs, {int startIndex = 0}) {
    _playlist = songs;
    _originalPlaylist = List.from(songs);
    _currentIndex = startIndex;
    
    // Reset shuffle nếu đang bật
    if (_isShuffled) {
      _shuffledIndices = List.generate(_playlist.length, (index) => index);
      _shuffledIndices.shuffle();
      _shuffleIndex = _shuffledIndices.indexOf(startIndex);
    }
    
    notifyListeners();
  }

  Future<void> toggleFavorite(Song song) async {
    try {
      await _firebaseService.toggleFavorite(song.id, song: song);
    } catch (e) {
      debugPrint('Không thể toggle favorite: $e');
    }
    notifyListeners();
  }

  Future<bool> isFavorite(Song song) async {
    try {
      return await _firebaseService.isFavorite(song.id);
    } catch (e) {
      debugPrint('Không thể kiểm tra favorite: $e');
      return false;
    }
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }
}