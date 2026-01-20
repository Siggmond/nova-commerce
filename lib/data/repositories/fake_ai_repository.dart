import '../../domain/entities/chat_message.dart';
import '../../domain/repositories/ai_repository.dart';

class FakeAiRepository implements AiRepository {
  @override
  Future<ChatMessage> reply({
    required List<ChatMessage> history,
    required String userText,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 550));

    final normalized = userText.toLowerCase();

    String intent;
    String text;

    if (normalized.contains('cheap') || normalized.contains('under')) {
      intent = 'recommend';
      text =
          'Got it. Budget mode on. Want hoodies, sneakers, or pants under a specific price?';
    } else if (normalized.contains('black') && normalized.contains('hoodie')) {
      intent = 'search';
      text =
          'Searching for black hoodies under your budget. Do you prefer oversized or regular fit?';
    } else if (normalized.contains('trending') ||
        normalized.contains('popular')) {
      intent = 'recommend';
      text =
          'Trending right now: oversized hoodies, minimal sneakers, and cargos. Want a full outfit suggestion?';
    } else {
      intent = 'ask';
      text =
          'Tell me what you are shopping for (style, color, max price). I can recommend fast.';
    }

    return ChatMessage(
      id: 'a_${DateTime.now().microsecondsSinceEpoch}',
      role: ChatRole.assistant,
      text: text,
      createdAt: DateTime.now(),
      intent: intent,
    );
  }
}
