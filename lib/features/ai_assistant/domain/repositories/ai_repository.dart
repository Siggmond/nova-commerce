import '../entities/chat_message.dart';

abstract class AiRepository {
  Future<ChatMessage> reply({
    required List<ChatMessage> history,
    required String userText,
  });
}
