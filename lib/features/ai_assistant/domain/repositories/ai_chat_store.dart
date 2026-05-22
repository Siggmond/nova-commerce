import '../entities/ai_chat_snapshot.dart';
import '../entities/chat_session.dart';

abstract class AiChatStore {
  Future<AiChatSnapshot?> load();

  Future<void> save({
    required List<ChatSession> sessions,
    required String activeSessionId,
  });
}
