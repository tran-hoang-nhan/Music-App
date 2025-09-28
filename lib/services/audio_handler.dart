import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';
import '../models/song.dart';

class MusicAudioHandler extends BaseAudioHandler {
  final AudioPlayer _player = AudioPlayer();
  
  MusicAudioHandler() {
    _init();
  }

  void _init() {
    _player.playbackEventStream.map(_transformEvent).pipe(playbackState);
    _player.sequenceStateStream.listen((sequenceState) {
      final currentItem = sequenceState.currentSource?.tag as MediaItem?;
      if (currentItem != null) {
        mediaItem.add(currentItem);
      }
    });
  }

  PlaybackState _transformEvent(PlaybackEvent event) {
    return PlaybackState(
      controls: [
        MediaControl.skipToPrevious,
        _player.playing ? MediaControl.pause : MediaControl.play,
        MediaControl.skipToNext,
      ],
      systemActions: const {
        MediaAction.seek,
        MediaAction.seekForward,
        MediaAction.seekBackward,
      },
      androidCompactActionIndices: const [0, 1, 2],
      processingState: const {
        ProcessingState.idle: AudioProcessingState.idle,
        ProcessingState.loading: AudioProcessingState.loading,
        ProcessingState.buffering: AudioProcessingState.buffering,
        ProcessingState.ready: AudioProcessingState.ready,
        ProcessingState.completed: AudioProcessingState.completed,
      }[_player.processingState]!,
      playing: _player.playing,
      updatePosition: _player.position,
      bufferedPosition: _player.bufferedPosition,
      speed: _player.speed,
      queueIndex: _player.currentIndex,
    );
  }

  @override
  Future<void> play() => _player.play();

  @override
  Future<void> pause() => _player.pause();

  @override
  Future<void> seek(Duration position) => _player.seek(position);

  @override
  Future<void> skipToNext() => _player.seekToNext();

  @override
  Future<void> skipToPrevious() => _player.seekToPrevious();

  Future<void> playSong(Song song) async {
    final mediaItem = MediaItem(
      id: song.id,
      album: song.albumName,
      title: song.name,
      artist: song.artistName,
      duration: Duration(seconds: song.duration),
      artUri: Uri.parse(song.albumImage),
    );

    this.mediaItem.add(mediaItem);
    await _player.setAudioSource(AudioSource.uri(Uri.parse(song.audioUrl)));
    await play();
  }

  Future<void> setPlaylist(List<Song> songs, {int index = 0}) async {
    final audioSources = songs.map((song) => AudioSource.uri(
      Uri.parse(song.audioUrl),
      tag: MediaItem(
        id: song.id,
        album: song.albumName,
        title: song.name,
        artist: song.artistName,
        duration: Duration(seconds: song.duration),
        artUri: Uri.parse(song.albumImage),
      ),
    )).toList();

    await _player.setAudioSources(
      audioSources,
      initialIndex: index,
    );
  }

  @override
  Future<void> stop() async {
    await _player.stop();
    return super.stop();
  }
}