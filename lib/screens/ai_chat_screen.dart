import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/ai_service.dart';
import '../services/jamendo_service.dart';
import '../services/gemini_service.dart';
import '../services/music_service.dart';
import '../models/song.dart';

class AIChatScreen extends StatefulWidget {
  const AIChatScreen({super.key});

  @override
  State<AIChatScreen> createState() => _AIChatScreenState();
}

class _AIChatScreenState extends State<AIChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<ChatMessage> _messages = [];
  final AIService _aiService = AIService();
  final JamendoService _jamendoService = JamendoService();
  final GeminiService _geminiService = GeminiService();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _addMessage('Xin chào! Tôi là AI assistant của bạn. Hãy hỏi tôi về âm nhạc!', false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.smart_toy, color: Color(0xFFE53E3E)),
            SizedBox(width: 8),
            Text('AI Music Assistant'),
          ],
        ),
        backgroundColor: const Color(0xFF121212),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                return _buildMessage(message);
              },
            ),
          ),
          _buildInputArea(),
        ],
      ),
    );
  }

  Widget _buildMessage(ChatMessage message) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            backgroundColor: message.isUser ? const Color(0xFF1DB954) : const Color(0xFFE53E3E),
            child: Icon(
              message.isUser ? Icons.person : Icons.smart_toy,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E1E),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message.text,
                    style: const TextStyle(color: Colors.white),
                  ),
                  if (message.songs.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    ...message.songs.map((song) => _buildSongItem(song)),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSongItem(Song song) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: const Color(0xFFE53E3E),
          borderRadius: BorderRadius.circular(6),
        ),
        child: const Icon(Icons.music_note, color: Colors.white, size: 20),
      ),
      title: Text(
        song.name,
        style: const TextStyle(color: Colors.white, fontSize: 14),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        song.artistName,
        style: const TextStyle(color: Colors.grey, fontSize: 12),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: IconButton(
        icon: const Icon(Icons.play_arrow, color: Color(0xFFE53E3E)),
        onPressed: () {
          final musicService = Provider.of<MusicService>(context, listen: false);
          musicService.playSong(song);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Đang phát: ${song.name}'),
              backgroundColor: const Color(0xFFE53E3E),
              duration: const Duration(seconds: 2),
            ),
          );
        },
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Color(0xFF1E1E1E),
        border: Border(top: BorderSide(color: Color(0xFF333333))),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                hintText: 'Hỏi tôi về âm nhạc...',
                hintStyle: TextStyle(color: Colors.grey),
                border: InputBorder.none,
              ),
              onSubmitted: _sendMessage,
            ),
          ),
          IconButton(
            onPressed: _isLoading ? null : () => _sendMessage(_controller.text),
            icon: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Color(0xFFE53E3E),
                    ),
                  )
                : const Icon(Icons.send, color: Color(0xFFE53E3E)),
          ),
        ],
      ),
    );
  }

  void _sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    _addMessage(text, true);
    _controller.clear();
    setState(() => _isLoading = true);

    try {
      final response = await _processAIQuery(text);
      _addMessage(response.text, false, songs: response.songs);
    } catch (e) {
      _addMessage('Xin lỗi, tôi không thể xử lý yêu cầu này.', false);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _addMessage(String text, bool isUser, {List<Song> songs = const []}) {
    setState(() {
      _messages.add(ChatMessage(text: text, isUser: isUser, songs: songs));
    });
  }

  Future<AIResponse> _processAIQuery(String query) async {
    final lowerQuery = query.toLowerCase();
    
    // Xử lý các lệnh cụ thể trước
    if (lowerQuery.contains('tìm') || lowerQuery.contains('search')) {
      final songs = await _jamendoService.searchTracks(query);
      final aiResponse = await _geminiService.generateResponse(
        'Tôi tìm thấy ${songs.length} bài hát cho "$query". Hãy giới thiệu ngắn gọn.',
      );
      return AIResponse(
        text: aiResponse,
        songs: songs.take(5).toList(),
      );
    }
    
    if (lowerQuery.contains('playlist') || lowerQuery.contains('danh sách')) {
      String theme = 'general';
      if (lowerQuery.contains('workout') || lowerQuery.contains('tập luyện')) theme = 'workout';
      if (lowerQuery.contains('chill') || lowerQuery.contains('thư giãn')) theme = 'chill';
      
      final allSongs = await _jamendoService.getPopularTracks(limit: 100);
      final playlist = await _aiService.generatePlaylist(theme, allSongs);
      final aiResponse = await _geminiService.generateResponse(
        'Tôi đã tạo playlist $theme. Hãy mô tả ngắn gọn về playlist này.',
      );
      
      return AIResponse(
        text: aiResponse,
        songs: playlist.take(5).toList(),
      );
    }
    
    if (lowerQuery.contains('tâm trạng') || lowerQuery.contains('mood')) {
      final mood = await _aiService.detectMood();
      final aiResponse = await _geminiService.generateResponse(
        'Tâm trạng người dùng hiện tại là: $mood. Hãy giải thích và đưa ra lời khuyên về âm nhạc.',
      );
      return AIResponse(text: aiResponse);
    }
    
    // Sử dụng AI cho câu hỏi tổng quát
    final aiResponse = await _geminiService.generateResponse(
      query,
      context: 'Bạn đang trong ứng dụng nghe nhạc. Có thể tìm kiếm, tạo playlist, phân tích tâm trạng.',
    );
    
    return AIResponse(text: aiResponse);
  }
}

class ChatMessage {
  final String text;
  final bool isUser;
  final List<Song> songs;

  ChatMessage({required this.text, required this.isUser, this.songs = const []});
}

class AIResponse {
  final String text;
  final List<Song> songs;

  AIResponse({required this.text, this.songs = const []});
}