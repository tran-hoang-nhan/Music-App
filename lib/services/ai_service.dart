import '../models/song.dart';
import 'firebase_service.dart';

class AIService {
  final FirebaseService _firebaseService = FirebaseService();
  
  // AI Smart Search - tìm kiếm thông minh
  Future<List<Song>> smartSearch(String query, List<Song> allSongs) async {
    final searchTerms = query.toLowerCase().split(' ');
    final results = <Song>[];
    
    for (final song in allSongs) {
      double score = 0;
      
      // Tìm trong tên bài hát (50%)
      for (final term in searchTerms) {
        if (song.name.toLowerCase().contains(term)) {
          score += 0.5;
        }
      }
      
      // Tìm trong tên nghệ sĩ (30%)
      for (final term in searchTerms) {
        if (song.artistName.toLowerCase().contains(term)) {
          score += 0.3;
        }
      }
      
      // Tìm trong tags/thể loại (20%)
      for (final term in searchTerms) {
        for (final tag in song.tags) {
          if (tag.toLowerCase().contains(term)) {
            score += 0.2;
            break;
          }
        }
      }
      
      if (score > 0) {
        results.add(song);
      }
    }
    
    // Sắp xếp theo độ liên quan
    results.sort((a, b) => b.name.toLowerCase().contains(query.toLowerCase()) ? 1 : -1);
    return results;
  }
  
  // AI Mood Detection - phát hiện tâm trạng từ lịch sử nghe
  Future<String> detectMood() async {
    final history = await _firebaseService.getListeningHistory(limit: 50);
    final genres = <String, int>{};
    
    for (final item in history) {
      final genre = item['genre'] ?? 'unknown';
      genres[genre] = (genres[genre] ?? 0) + 1;
    }
    
    if (genres.isEmpty) return 'energetic';
    
    final topGenre = genres.entries.reduce((a, b) => a.value > b.value ? a : b).key;
    
    // Map thể loại sang tâm trạng
    switch (topGenre.toLowerCase()) {
      case 'rock': case 'metal': return 'energetic';
      case 'jazz': case 'classical': return 'relaxed';
      case 'pop': case 'dance': return 'happy';
      case 'blues': case 'folk': return 'melancholic';
      default: return 'neutral';
    }
  }
  
  // AI Playlist Generator - tạo playlist tự động
  Future<List<Song>> generatePlaylist(String theme, List<Song> allSongs) async {
    final mood = await detectMood();
    final playlist = <Song>[];
    
    for (final song in allSongs) {
      double score = 0;
      
      // Điểm dựa trên theme
      if (theme.toLowerCase() == 'workout' && 
          (song.tags.any((tag) => ['rock', 'electronic', 'pop'].contains(tag.toLowerCase())))) {
        score += 0.4;
      }
      
      if (theme.toLowerCase() == 'chill' && 
          (song.tags.any((tag) => ['jazz', 'acoustic', 'ambient'].contains(tag.toLowerCase())))) {
        score += 0.4;
      }
      
      // Điểm dựa trên mood hiện tại
      score += _getMoodScore(song, mood) * 0.3;
      
      // Điểm ngẫu nhiên để đa dạng
      score += (song.id.hashCode % 100) / 100 * 0.3;
      
      if (score > 0.5) {
        playlist.add(song);
      }
    }
    
    playlist.shuffle();
    return playlist.take(20).toList();
  }
  
  double _getMoodScore(Song song, String mood) {
    switch (mood) {
      case 'energetic':
        return song.tags.any((tag) => ['rock', 'electronic', 'dance'].contains(tag.toLowerCase())) ? 1.0 : 0.0;
      case 'relaxed':
        return song.tags.any((tag) => ['jazz', 'classical', 'ambient'].contains(tag.toLowerCase())) ? 1.0 : 0.0;
      case 'happy':
        return song.tags.any((tag) => ['pop', 'reggae', 'funk'].contains(tag.toLowerCase())) ? 1.0 : 0.0;
      case 'melancholic':
        return song.tags.any((tag) => ['blues', 'folk', 'indie'].contains(tag.toLowerCase())) ? 1.0 : 0.0;
      default:
        return 0.5;
    }
  }
}