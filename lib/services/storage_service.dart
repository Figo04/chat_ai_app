import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:chat_bot_apps/models/message.dart';

class StorageService {
  static const String _messagesKey = 'chat_messages';

  Future<void> saveMessages(List<Message> messages) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final messagesJson = messages.map((m) => m.toMap()).toList();
      await prefs.setString(_messagesKey, jsonEncode(messagesJson));
    } catch (e) {
      print('Failed to save messages: $e');
    }
  }

  Future<List<Message>> loadMessages() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final messagesString = prefs.getString(_messagesKey);

      if (messagesString == null) return [];

      final List<dynamic> messagesJson = jsonDecode(messagesString);
      return messagesJson.map((json) => Message.fromMap(json)).toList();
    } catch (e) {
      print('Failed to load messages: $e');
      return [];
    }
  }

  Future<void> clearMessages() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_messagesKey);
    } catch (e) {
      print('Failed to clear messages: $e');
    }
  }
}
