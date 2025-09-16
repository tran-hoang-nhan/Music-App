import 'package:just_audio/just_audio.dart';
import 'package:flutter/foundation.dart';
import '../models/song.dart';
import 'firebase_service.dart';
import 'theme_service.dart';

class MusicService extends ChangeNotifier {
  static final MusicService _instance = MusicService._internal();
  factory MusicService() => _instance;
  MusicService._internal() {
    _initializePlayer();
  }

  final AudioPlayer _audioPlayer = AudioPlayer();
  final FirebaseService _firebaseService = FirebaseService();
  final ThemeService _themeService = ThemeService();

  
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

  void _initializePlayer() {
    _audioPlayer.durationStream.listen((duration) {
      _totalDuration = duration ?? Duration.zero;
      notifyListeners();
    });

    _audioPlayer.positionStream.listen((position) {
      _currentPosition = position;
      notifyListeners();
    });

    _audioPlayer.playerStateStream.listen((state) {
      _isPlaying = state.playing;
      _isLoading = state.processingState == ProcessingState.loading;
      notifyListeners();
    });

    _audioPlayer.playerStateStream.listen((state) {
      if (state.processingState == ProcessingState.completed) {
        _onSongComplete();
      }
    });
  }

  Future<void> playSong(Song song, {List<Song>? playlist, int? index}) async {
    try {
      _isLoading = true;
      notifyListeners();

      if (playlist != null) {
        _playlist = playlist;
        _currentIndex = index ?? 0;
      }

      _currentSong = song;
      
      // Lưu lịch sử nghe nhạc
      try {
        await _firebaseService.addToListeningHistory(song.id, song.name, song.artistName);
      } catch (e) {
        print('Không thể lưu lịch sử: $e');
      }
      
      // Extract màu từ album art
      if (song.albumImage.isNotEmpty) {
        _themeService.extractColorsFromImage(song.albumImage);
      }
      
      await _audioPlayer.setAudioSource(AudioSource.uri(Uri.parse(song.audioUrl)));
      await _audioPlayer.play();
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      print('Lỗi phát nhạc: $e');
      _isLoading = false;
      notifyListeners();
    }
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
    _currentPosition = Duration.zero;
    notifyListeners();
  }

  Future<void> seekTo(Duration position) async {
    await _audioPlayer.seek(position);
  }

  Future<void> playNext() async {
    if (_playlist.isEmpty) return;
    
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
    if (_playlist.isEmpty) return;
    
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

  void _onSongComplete() {
    if (_isRepeating) {
      playSong(_currentSong!);
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
      await _firebaseService.toggleFavorite(song.id);
    } catch (e) {
      print('Không thể toggle favorite: $e');
    }
    notifyListeners();
  }

  Future<bool> isFavorite(Song song) async {
    try {
      return await _firebaseService.isFavorite(song.id);
    } catch (e) {
      print('Không thể kiểm tra favorite: $e');
      return false;
    }
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }
}