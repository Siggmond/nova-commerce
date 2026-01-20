import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/providers.dart';
import '../../../domain/entities/chat_message.dart';

final aiChatViewModelProvider =
    StateNotifierProvider<AiChatViewModel, List<ChatMessage>>((ref) {
      return AiChatViewModel(ref);
    });

class AiChatViewModel extends StateNotifier<List<ChatMessage>> {
  AiChatViewModel(this._ref) : super(const []) {
    _seed();
  }

  final Ref _ref;

  void _seed() {
    state = [
      ChatMessage(
        id: 'seed',
        role: ChatRole.assistant,
        text: 'Tell me what you want. Example: “black hoodie under \$50”.',
        createdAt: DateTime.now(),
        intent: 'ask',
      ),
    ];
  }

  Future<void> send(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;

    final user = ChatMessage(
      id: 'u_${DateTime.now().microsecondsSinceEpoch}',
      role: ChatRole.user,
      text: trimmed,
      createdAt: DateTime.now(),
    );

    state = [...state, user];

    final repo = _ref.read(aiRepositoryProvider);
    final reply = await repo.reply(history: state, userText: trimmed);

    // Ensure stable ordering even if timestamps match
    final messages = [...state, reply]
      ..sort((a, b) {
        final c = a.createdAt.compareTo(b.createdAt);
        if (c != 0) return c;
        return a.id.compareTo(b.id);
      });

    state = messages;
  }

  String newClientMessageId() =>
      'c_${DateTime.now().microsecondsSinceEpoch}_${Random().nextInt(99999)}';
}
