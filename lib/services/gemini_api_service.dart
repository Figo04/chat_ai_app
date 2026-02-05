import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:chat_bot_apps/models/message.dart';

class GeminiApiService {
  static const String _apiKey = 'AIzaSyBJp6yHPAfv8RpdKaA9YyEVrqUnlScpnjY';

  late final GenerativeModel _model;

  GeminiApiService() {
    _model = GenerativeModel(
      model: "gemini-2.5-flash",
      apiKey: _apiKey,
      generationConfig: GenerationConfig(
        temperature: 0.7,
        maxOutputTokens: 1000,
      ),
    );
  }

  Future<String> sendMessage(List<Message> conversationHistory) async {
    try {
      // Convert conversation history to gemini format
      final chatHistory = conversationHistory
          .where((msg) => msg.role != MessageRole.system)
          .map((msg) {
            return Content.text(msg.content);
          })
          .toList();

      // Create chat session with history
      final chat = _model.startChat(
        history: chatHistory.take(chatHistory.length - 1).toList(),
      );

      // send the lastest message
      final lastMessage = conversationHistory.last.content;
      final response = await chat.sendMessage(Content.text(lastMessage));

      return response.text ?? 'No response form AI';
    } catch (e) {
      throw Exception('Failed to generate response: $e');
    }
  }

  // Alternatative: Simple single message (no history)
  Future<String> sendSingleMessage(String message) async {
    try {
      final response = await _model.generateContent([Content.text(message)]);
      return response.text ?? 'No response form AI';
    } catch (e) {
      throw Exception('Failed to generate response: $e');
    }
  }
}
