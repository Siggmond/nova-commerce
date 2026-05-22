import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:nova_commerce/app/di/app_providers.dart';
import 'package:nova_commerce/features/ai_assistant/data/repositories/fake_ai_repository.dart';
import 'package:nova_commerce/features/ai_assistant/domain/entities/ai_chat_snapshot.dart';
import 'package:nova_commerce/features/ai_assistant/domain/entities/chat_message.dart';
import 'package:nova_commerce/features/ai_assistant/domain/entities/chat_session.dart';
import 'package:nova_commerce/features/ai_assistant/domain/repositories/ai_chat_store.dart';
import 'package:nova_commerce/features/ai_assistant/domain/repositories/ai_repository.dart';
import 'package:nova_commerce/features/ai_assistant/ai_assistant.dart';

class _ImmediateAiRepo implements AiRepository {
  @override
  Future<ChatMessage> reply({
    required List<ChatMessage> history,
    required String userText,
  }) async {
    final userCreatedAt = history.isEmpty
        ? DateTime.now()
        : history.last.createdAt;
    return ChatMessage(
      id: 'a1',
      role: ChatRole.assistant,
      text: 'ok',
      createdAt: userCreatedAt,
      intent: 'ask',
    );
  }
}

class _InMemoryAiChatStore implements AiChatStore {
  AiChatSnapshot? snapshot;

  @override
  Future<AiChatSnapshot?> load() async => snapshot;

  @override
  Future<void> save({
    required List<ChatSession> sessions,
    required String activeSessionId,
  }) async {
    snapshot = AiChatSnapshot(
      sessions: List<ChatSession>.of(sessions),
      activeSessionId: activeSessionId,
    );
  }
}

void main() {
  test('AiChatViewModel.clear() resets to seed message only', () {
    final container = ProviderContainer(
      overrides: [
        aiRepositoryProvider.overrideWithValue(FakeAiRepository()),
        aiChatStoreProvider.overrideWithValue(_InMemoryAiChatStore()),
      ],
    );
    addTearDown(container.dispose);

    final vm = container.read(aiChatViewModelProvider.notifier);
    vm.clear();

    final state = container.read(aiChatViewModelProvider);
    final messages = state.activeSession.messages;
    expect(messages.length, 1);
    expect(messages.first.role, ChatRole.assistant);
  });

  test(
    'AiChatViewModel keeps user message before assistant reply when timestamps match',
    () async {
      final container = ProviderContainer(
        overrides: [
          aiRepositoryProvider.overrideWithValue(_ImmediateAiRepo()),
          aiChatStoreProvider.overrideWithValue(_InMemoryAiChatStore()),
        ],
      );
      addTearDown(container.dispose);

      final vm = container.read(aiChatViewModelProvider.notifier);

      // Force same timestamp by seeding a user message at epoch 0, then reply is epoch 0.
      await vm.send('hello');

      final state = container.read(aiChatViewModelProvider);
      final messages = state.activeSession.messages;
      expect(messages.length, 3);

      // seed assistant
      expect(messages[0].role, ChatRole.assistant);
      // then user, then assistant
      expect(messages[1].role, ChatRole.user);
      expect(messages[2].role, ChatRole.assistant);
    },
  );
}
