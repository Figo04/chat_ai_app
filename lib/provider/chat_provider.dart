import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:chat_bot_apps/services/gemini_api_service.dart';
import 'package:chat_bot_apps/services/storage_service.dart';
import 'package:chat_bot_apps/models/message.dart';

// Provider untuk Gemini API Service
final geminiApiServiceProvider = Provider<GeminiApiService>((ref) {
  return GeminiApiService();
});

// Provider untuk Storage Service
final storageServiceProvider = Provider<StorageService>((ref) {
  return StorageService();
});

// State untuk chat
class ChatState {
  final List<Message> messages;
  final bool isLoading;
  final String? error;

  ChatState({required this.messages, this.isLoading = false, this.error});

  ChatState copyWith({
    List<Message>? messages,
    bool? isLoading,
    String? error,
  }) {
    return ChatState(
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

// Chat provider (StateNotifier)
class ChatNotifier extends StateNotifier<ChatState> {
  final GeminiApiService _apiService;
  final StorageService _storageService;

  ChatNotifier(this._apiService, this._storageService)
    : super(ChatState(messages: [])) {
    _loadMessages();
  }

  Future<void> _loadMessages() async {
    final messages = await _storageService.loadMessages();
    state = state.copyWith(messages: messages);
  }

  Future<void> sendMessage(String content) async {
    if (content.trim().isEmpty) return;

    final userMessage = Message(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: content,
      role: MessageRole.user,
      timestamp: DateTime.now(),
    );

    state = state.copyWith(
      messages: [...state.messages, userMessage],
      isLoading: true,
      error: null
    );

    try {
      final response = await _apiService.sendMessage(state.messages);

      final assistantMessage = Message(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        content: response,
        role: MessageRole.assistant,
        timestamp: DateTime.now(),
      );

      state = state.copyWith(
        messages: [...state.messages, assistantMessage],
        isLoading: false,
      );
      
      await _storageService.saveMessages(state.messages);
    } catch (e) {
      final errorMessage = Message(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        content: 'Error: ${e.toString()}',
        role: MessageRole.assistant,
        timestamp: DateTime.now(),
        isError: true,
      );

      state = state.copyWith(
        messages: [...state.messages, errorMessage],
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> clearChat() async {
    await _storageService.clearMessages();
    state = ChatState(messages: []);
  }

  void deleteMessage(String messageId) {
    final updatedMessages = state.messages.where((msg) => msg.id != messageId).toList();

    state = state.copyWith(messages: updatedMessages);
    _storageService.saveMessages(updatedMessages);
  }
}

// Provider untuk ChatNotifier
final chatProvider = StateNotifierProvider<ChatNotifier, ChatState>((ref) {
  final apiService = ref.watch(geminiApiServiceProvider);
  final storageService = ref.watch(storageServiceProvider);
  return ChatNotifier(apiService, storageService);
});
