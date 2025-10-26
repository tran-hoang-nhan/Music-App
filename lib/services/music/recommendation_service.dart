import 'package:flutter/foundation.dart';
import '../../models/song.dart';
import '../firebase/firebase_controller.dart';
import '../jamendo/jamendo_controller.dart';

class RecommendationService {
  static final RecommendationService _instance = RecommendationService._internal();
  factory RecommendationService() => _instance;
  RecommendationService._internal();

  final FirebaseController _firebaseController = FirebaseController();
  final JamendoController _jamendoController = JamendoController();

  Future<List<Song>> getListeningRecommendations(List<Song> popularSongs) async {
    try {
      final recentHistory = await _firebaseController.history.getListeningHistory(limit: 50);

      // Nếu không có lịch sử, lấy bài hát ngẫu nhiên từ API
      if (recentHistory.isEmpty) {
        final randomSongs = await _jamendoController.track.getPopularTracks(limit: 50, offset: 30);
        randomSongs.shuffle();
        return randomSongs.take(20).toList();
      }

      // Phân tích sở thích từ lịch sử nghe
      final genrePreference = <String, int>{};
      final artistPreference = <String, int>{};
      
      for (final item in recentHistory) {
        final playCount = (item['playCount'] ?? 1) as int;
        final genre = item['genre'] as String?;
        final artist = item['artist'] as String?;
        
        if (genre != null) {
          genrePreference[genre] = (genrePreference[genre] ?? 0) + playCount;
        }
        if (artist != null) {
          artistPreference[artist] = (artistPreference[artist] ?? 0) + playCount;
        }
      }

      // Lấy bài hát từ các genre phổ biến nhất của user
      final topGenres = genrePreference.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));
      
      final recommendations = <Song>{};
      
      // Lấy từ các genre phổ biến nhất
      for (int i = 0; i < topGenres.length && recommendations.length < 20; i++) {
        final genre = topGenres[i].key;
        final songs = await _jamendoController.genre.getTracksByGenre(genre, limit: 10);
        recommendations.addAll(songs);
      }
      
      // Nếu vẫn chưa đủ, lấy thêm từ các artist phổ biến
      if (recommendations.length < 20) {
        final topArtists = artistPreference.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value));
        
        for (int i = 0; i < topArtists.length && recommendations.length < 20; i++) {
          // Lấy bài hát phổ biến với offset khác nhau
          final songs = await _jamendoController.track.getPopularTracks(limit: 10, offset: i * 10);
          recommendations.addAll(songs);
        }
      }
      
      // Nếu vẫn không đủ, lấy từ popular tracks
      if (recommendations.length < 20) {
        final songs = await _jamendoController.track.getPopularTracks(limit: 50, offset: 30);
        recommendations.addAll(songs);
      }
      
      // Loại bỏ các bài đã nghe và trả về top 20
      final playedSongIds = recentHistory
        .map((item) => item['songId']?.toString())
        .where((id) => id != null)
        .toSet();
      
      final freshRecommendations = recommendations
        .where((song) => !playedSongIds.contains(song.id))
        .toList();
      
      freshRecommendations.shuffle();
      return freshRecommendations.take(20).toList();
      
    } catch (e) {
      debugPrint('Lỗi AI recommendations: $e');
      // Fallback: lấy bài hát ngẫu nhiên từ API
      try {
        final songs = await _jamendoController.track.getPopularTracks(limit: 50, offset: 30);
        songs.shuffle();
        return songs.take(20).toList();
      } catch (e2) {
        debugPrint('Lỗi fallback recommendations: $e2');
        return [];
      }
    }
  }
  
  List<Song> getBasicRecommendations(List<Song> popularSongs) {
    if (popularSongs.isEmpty) return [];
    
    // Nếu có ít bài, trả về tất cả (không filter)
    if (popularSongs.length <= 20) {
      final recommendations = List<Song>.from(popularSongs);
      recommendations.shuffle();
      return recommendations;
    }
    
    final recommendations = <Song>[];
    for (final song in popularSongs) {
      double score = (song.id.hashCode % 100) / 100;
      if (score > 0.3) {
        recommendations.add(song);
      }
    }
    
    recommendations.shuffle();
    return recommendations.take(20).toList();
  }

  /// Mood-based Recommendations
  List<Song> getMoodRecommendations(List<Song> popularSongs, String mood) {
    final moodGenres = <String, List<String>>{
      'energetic': ['rock', 'electronic', 'pop', 'dance'],
      'relaxed': ['jazz', 'acoustic', 'ambient', 'classical'],
      'happy': ['pop', 'reggae', 'funk', 'disco'],
      'melancholic': ['blues', 'indie', 'alternative', 'folk'],
    };

    final targetGenres = moodGenres[mood.toLowerCase()] ?? [];
    if (targetGenres.isEmpty) return getBasicRecommendations(popularSongs);

    final recommendations = <Song>[];
    
    for (final song in popularSongs) {
      final matchingGenres = song.tags.where((tag) => 
        targetGenres.any((genre) => tag.toLowerCase().contains(genre))
      ).length;
      
      if (matchingGenres > 0) {
        recommendations.add(song);
      }
    }
    
    recommendations.shuffle();
    return recommendations.take(10).toList();
  }

  /// Genre-based Recommendations
  List<Song> getGenreRecommendations(List<Song> popularSongs, String genre) {
    final recommendations = popularSongs.where((song) =>
      song.tags.any((tag) => tag.toLowerCase().contains(genre.toLowerCase()))
    ).toList();
    
    recommendations.shuffle();
    return recommendations.take(15).toList();
  }
}