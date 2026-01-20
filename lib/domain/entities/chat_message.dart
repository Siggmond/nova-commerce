enum ChatRole { user, assistant }

class ChatMessage {
  const ChatMessage({
    required this.id,
    required this.role,
    required this.text,
    required this.createdAt,
    this.intent,
  });

  final String id;
  final ChatRole role;
  final String text;
  final DateTime createdAt;

  final String? intent;
}
