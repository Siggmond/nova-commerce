import 'chat_session.dart';

class AiChatSnapshot {
  const AiChatSnapshot({required this.sessions, required this.activeSessionId});

  final List<ChatSession> sessions;
  final String activeSessionId;
}
