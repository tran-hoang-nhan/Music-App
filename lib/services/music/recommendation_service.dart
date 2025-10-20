import 'package:flutter/foundation.dart';
import '../../models/song.dart';
import '../firebase/firebase_controller.dart';

class RecommendationService {
  static final RecommendationService _instance = RecommendationService._internal();
  factory RecommendationService() => _instance;
  RecommendationService._internal();

  final FirebaseController _firebaseController = FirebaseController();

  Future<List<Song>> getAIRecommendations(List<Song> popularSongs) async {
    if (popularSongs.isEmpty) return [];
    
    try {
      final recentHistory = await _firebaseController.history.getListeningHistory(limit: 20);

      // Lấy các bài hát đã nghe
      final playedSongIds = recentHistory.map((item) => item['songId']?.toString()).where((id) => id != null).toSet();
      
      // Lọc bỏ các bài đã nghe gần đây
      final freshSongs = popularSongs.where((song) => !playedSongIds.contains(song.id)).toList();
      
      if (freshSongs.isEmpty) {
        return getBasicRecommendations(popularSongs);
      }
      
      // Phân tích sở thích
      final genrePreference = <String, int>{};
      final artistPreference = <String, int>{};
      
      for (final item in recentHistory) {
        final playCount = (item['playCount'] ?? 1) as int;
        final songId = item['songId']?.toString();
        if (songId != null) {
          final song = popularSongs.where((s) => s.id == songId).firstOrNull;
          if (song != null) {
            for (final tag in song.tags) {
              genrePreference[tag] = (genrePreference[tag] ?? 0) + playCount;
            }
            artistPreference[song.artistName] = (artistPreference[song.artistName] ?? 0) + playCount;
          }
        }
      }
      
      // Tính điểm cho các bài mới
      final scoredSongs = <MapEntry<Song, double>>[];
      
      for (final song in freshSongs) {
        double score = 0;
        
        // Điểm thể loại (40%)
        for (final tag in song.tags) {
          score += (genrePreference[tag] ?? 0) * 0.4;
        }
        
        // Điểm nghệ sĩ (30%)
        score += (artistPreference[song.artistName] ?? 0) * 0.3;
        
        // Điểm độ phổ biến ngược (20%)
        final popularityIndex = popularSongs.indexOf(song);
        if (popularityIndex >= 0) {
          score += (20 - popularityIndex) * 0.2;
        }
        
        // Điểm ngẫu nhiên (10%)
        score += (song.id.hashCode % 100) / 100 * 0.1;
        
        scoredSongs.add(MapEntry(song, score));
      }
      
      // Sắp xếp theo điểm và lấy top
      scoredSongs.sort((a, b) => b.value.compareTo(a.value));
      
      final recommendations = scoredSongs.take(8).map((entry) => entry.key).toList();
      recommendations.shuffle();
      
      return recommendations;
      
    } catch (e) {
      debugPrint('Lỗi AI recommendations: $e');
      return getBasicRecommendations(popularSongs);
    }
  }
  
  List<Song> getBasicRecommendations(List<Song> popularSongs) {
    final recommendations = <Song>[];
    
    for (final song in popularSongs) {
      double score = (song.id.hashCode % 100) / 100;
      if (score > 0.5) {
        recommendations.add(song);
      }
    }
    
    recommendations.shuffle();
    return recommendations.take(8).toList();
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