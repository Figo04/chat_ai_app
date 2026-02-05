enum MessageRole { user, assistant, system }

class Message {
  final String id;
  final String content;
  final MessageRole role;
  final DateTime timestamp;
  final bool isError;

  Message({
    required this.id,
    required this.content,
    required this.role,
    required this.timestamp,
    this.isError = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'content': content,
      'role': role.index,
      'timestamp': timestamp.toIso8601String(),
      'isError': isError,
    };
  }

  factory Message.fromMap(Map<String, dynamic> json) {
    return Message(
      id: json['id'],
      content: json['content'],
      role: MessageRole.values.firstWhere((e) => e.name == json['role']),
      timestamp: DateTime.parse(json['timestamp']),
      isError: json['isError'] ?? false,
    );
  }

  Message copyWith({
    String? id,
    String? content,
    MessageRole? role,
    DateTime? timestamp,
    bool? isError,
  }) {
    return Message(
      id: id ?? this.id,
      content: content ?? this.content,
      role: role ?? this.role,
      timestamp: timestamp ?? this.timestamp,
      isError: isError ?? this.isError,
    );
  }
}
