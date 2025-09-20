import 'dart:convert';
import 'package:http/http.dart' as http;

class GeminiService {
  static const String _apiKey = 'YOUR_GEMINI_API_KEY'; // Thay bằng API key thật
  static const String _baseUrl = 'https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent';
  
  Future<String> generateResponse(String prompt, {String? context}) async {
    try {
      final fullPrompt = '''
Bạn là AI assistant chuyên về âm nhạc. Trả lời ngắn gọn, thân thiện bằng tiếng Việt.
${context != null ? 'Context: $context' : ''}
User: $prompt
''';

      final response = await http.post(
        Uri.parse('$_baseUrl?key=$_apiKey'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'contents': [{
            'parts': [{'text': fullPrompt}]
          }],
          'generationConfig': {
            'temperature': 0.7,
            'maxOutputTokens': 200,
          }
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['candidates'][0]['content']['parts'][0]['text'] ?? 'Xin lỗi, tôi không hiểu.';
      }
      
      return 'Có lỗi xảy ra khi kết nối AI.';
    } catch (e) {
      return 'Không thể kết nối với AI assistant.';
    }
  }
}