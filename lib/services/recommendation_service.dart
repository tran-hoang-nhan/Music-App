import 'package:flutter/foundation.dart';
import '../models/song.dart';
import 'firebase_service.dart';

class RecommendationService {
  static final RecommendationService _instance = RecommendationService._internal();
  factory RecommendationService() => _instance;
  RecommendationService._internal();

  final FirebaseService _firebaseService = FirebaseService();

  Future<List<Song>> getAIRecommendations(List<Song> popularSongs) async {
    if (popularSongs.isEmpty) return [];
    
    try {
      // Lấy lịch sử nghe gần đây
      final recentHistory = await _firebaseService.getListeningHistory(limit: 20);
      
      final recommendations = <Song>[];
      final recentGenres = <String>{};
      final recentArtists = <String>{};
      
      // Phân tích lịch sử nghe để tìm pattern
      for (final item in recentHistory) {
        final songId = item['songId']?.toString();
        if (songId != null) {
          // Tìm bài hát trong popular để lấy thông tin
          final recentSong = popularSongs.where((s) => s.id == songId).firstOrNull;
          if (recentSong != null) {
            recentGenres.addAll(recentSong.tags);
            recentArtists.add(recentSong.artistName);
          }
        }
      }
      
      // Nếu không có lịch sử, dùng thuật toán cơ bản
      if (recentGenres.isEmpty) {
        return getBasicRecommendations(popularSongs);
      }
      
      // Chọn bài hát dựa trên AI scoring với lịch sử
      for (final song in popularSongs) {
        double score = 0;
        
        // Điểm thể loại từ lịch sử (50%)
        final matchingGenres = song.tags.where((tag) => recentGenres.contains(tag)).length;
        if (recentGenres.isNotEmpty) {
          score += (matchingGenres / recentGenres.length) * 0.5;
        }
        
        // Điểm nghệ sĩ từ lịch sử (30%)
        if (recentArtists.contains(song.artistName)) {
          score += 0.3;
        }
        
        // Điểm đa dạng (20%)
        score += (song.id.hashCode % 100) / 100 * 0.2;
        
        if (score > 0.4) {
          recommendations.add(song);
        }
      }
      
      recommendations.shuffle();
      return recommendations.take(8).toList();
      
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