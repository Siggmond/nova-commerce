enum ChatRole { user, assistant }

class ChatMessage {
  const ChatMessage({
    required this.id,
    required this.role,
    required this.text,
    required this.createdAt,
    this.intent,
    this.isStreaming = false,
  });

  final String id;
  final ChatRole role;
  final String text;
  final DateTime createdAt;

  final String? intent;
  final bool isStreaming;

  ChatMessage copyWith({
    String? text,
    String? intent,
    bool? isStreaming,
  }) {
    return ChatMessage(
      id: id,
      role: role,
      text: text ?? this.text,
      createdAt: createdAt,
      intent: intent ?? this.intent,
      isStreaming: isStreaming ?? this.isStreaming,
    );
  }
}
