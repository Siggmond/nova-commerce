import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

import 'package:nova_commerce/core/config/providers.dart';
import 'package:nova_commerce/data/repositories/fake_ai_repository.dart';
import 'package:nova_commerce/domain/entities/chat_message.dart';
import 'package:nova_commerce/domain/repositories/ai_repository.dart';
import 'package:nova_commerce/features/ai_assistant/presentation/ai_chat_viewmodel.dart';
import 'test_helper.dart';

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

void main() {
  setUpAll(initHiveForTests);

  tearDownAll(disposeHiveForTests);

  setUp(() async {
    final box = await Hive.openBox<dynamic>('ai_chat');
    await box.clear();
    await box.close();
  });

  tearDown(() async {
    await Hive.close();
  });

  test('AiChatViewModel.clear() resets to seed message only', () {
    final container = ProviderContainer(
      overrides: [aiRepositoryProvider.overrideWithValue(FakeAiRepository())],
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
        overrides: [aiRepositoryProvider.overrideWithValue(_ImmediateAiRepo())],
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
