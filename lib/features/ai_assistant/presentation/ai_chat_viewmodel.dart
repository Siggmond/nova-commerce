import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/providers.dart';
import '../../../domain/entities/chat_message.dart';
import '../../../domain/entities/chat_session.dart';
import '../data/ai_chat_storage.dart';

class AiChatState {
  const AiChatState({
    required this.sessions,
    required this.activeSessionId,
    required this.isStreaming,
    required this.searchQuery,
  });

  final List<ChatSession> sessions;
  final String activeSessionId;
  final bool isStreaming;
  final String searchQuery;

  ChatSession get activeSession =>
      sessions.firstWhere((s) => s.id == activeSessionId);

  List<ChatSession> get filteredSessions {
    final q = searchQuery.trim().toLowerCase();
    if (q.isEmpty) return sessions;
    return sessions
        .where((s) => s.title.toLowerCase().contains(q))
        .toList(growable: false);
  }

  AiChatState copyWith({
    List<ChatSession>? sessions,
    String? activeSessionId,
    bool? isStreaming,
    String? searchQuery,
  }) {
    return AiChatState(
      sessions: sessions ?? this.sessions,
      activeSessionId: activeSessionId ?? this.activeSessionId,
      isStreaming: isStreaming ?? this.isStreaming,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

final aiChatViewModelProvider =
    StateNotifierProvider<AiChatViewModel, AiChatState>((ref) {
      return AiChatViewModel(ref);
    });

class AiChatViewModel extends StateNotifier<AiChatState> {
  AiChatViewModel(this._ref)
      : super(
          (() {
            final seed = _seedSession();
            return AiChatState(
              sessions: [seed],
              activeSessionId: seed.id,
              isStreaming: false,
              searchQuery: '',
            );
          })(),
        ) {
    _hydrate();
  }

  final Ref _ref;
  final AiChatStorage _storage = AiChatStorage();

  Future<void> _hydrate() async {
    final snapshot = await _storage.load();
    if (snapshot == null) return;
    state = state.copyWith(
      sessions: snapshot.sessions,
      activeSessionId: snapshot.activeSessionId,
    );
  }

  Future<void> _persist() {
    if (state.isStreaming) {
      return Future.value();
    }
    return _storage.save(
      sessions: state.sessions,
      activeSessionId: state.activeSessionId,
    );
  }

  static ChatSession _seedSession() {
    final now = DateTime.now();
    return ChatSession(
      id: 'session_${now.microsecondsSinceEpoch}',
      title: 'New chat',
      messages: [
        ChatMessage(
          id: 'seed_${now.microsecondsSinceEpoch}',
          role: ChatRole.assistant,
          text:
              'I can help you narrow down fast. Tell me your budget + style + use-case, and I’ll suggest a short set of options.\n\nExample: “black hoodie under \$50, oversized”.',
          createdAt: now,
          intent: 'ask',
        ),
      ],
      updatedAt: now,
    );
  }

  void clear() {
    final now = DateTime.now();
    final reset = state.activeSession.copyWith(
      messages: [
        ChatMessage(
          id: 'seed_${now.microsecondsSinceEpoch}',
          role: ChatRole.assistant,
          text:
              'I can help you narrow down fast. Tell me your budget + style + use-case, and I’ll suggest a short set of options.\n\nExample: “black hoodie under \$50, oversized”.',
          createdAt: now,
          intent: 'ask',
        ),
      ],
      updatedAt: now,
      title: 'New chat',
    );
    _replaceSession(reset);
    _persist();
  }

  void newSession() {
    final session = _seedSession();
    state = state.copyWith(
      sessions: [session, ...state.sessions],
      activeSessionId: session.id,
      searchQuery: '',
    );
    _persist();
  }

  void selectSession(String id) {
    if (id == state.activeSessionId) return;
    state = state.copyWith(activeSessionId: id, searchQuery: '');
    _persist();
  }

  void updateSearchQuery(String value) {
    state = state.copyWith(searchQuery: value);
  }

  Future<void> send(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;

    final now = DateTime.now();
    final user = ChatMessage(
      id: 'u_${now.microsecondsSinceEpoch}',
      role: ChatRole.user,
      text: trimmed,
      createdAt: now,
    );

    final session = state.activeSession;
    final updatedMessages = [...session.messages, user];
    final nextSession = session.copyWith(
      messages: updatedMessages,
      updatedAt: now,
      title: session.title == 'New chat'
          ? trimmed.split(' ').take(4).join(' ')
          : session.title,
    );
    _replaceSession(nextSession);

    await _streamAssistantReply(userText: trimmed);
  }

  Future<void> regenerateLast() async {
    final messages = state.activeSession.messages;
    final lastUser = messages.lastWhere(
      (m) => m.role == ChatRole.user,
      orElse: () => ChatMessage(
        id: 'none',
        role: ChatRole.user,
        text: '',
        createdAt: DateTime.fromMillisecondsSinceEpoch(0),
      ),
    );
    if (lastUser.text.trim().isEmpty) return;
    await _streamAssistantReply(userText: lastUser.text, addUserMessage: false);
  }

  Future<void> _streamAssistantReply({
    required String userText,
    bool addUserMessage = true,
  }) async {
    final repo = _ref.read(aiRepositoryProvider);
    state = state.copyWith(isStreaming: true);

    final placeholder = ChatMessage(
      id: 'a_${DateTime.now().microsecondsSinceEpoch}',
      role: ChatRole.assistant,
      text: '',
      createdAt: DateTime.now(),
      isStreaming: true,
    );

    final session = state.activeSession;
    final baseMessages = addUserMessage ? session.messages : [...session.messages];
    final nextMessages = [...baseMessages, placeholder];
    _replaceSession(session.copyWith(messages: nextMessages, updatedAt: DateTime.now()));

    final reply = await repo.reply(history: nextMessages, userText: userText);
    final content = reply.text;
    final chunk = 10;
    var buffer = '';
    for (var i = 0; i < content.length; i += chunk) {
      buffer = content.substring(0, (i + chunk).clamp(0, content.length));
      _updateStreamingMessage(placeholder.id, buffer, reply.intent);
      await Future<void>.delayed(const Duration(milliseconds: 30));
    }
    _finalizeStreamingMessage(placeholder.id, content, reply.intent);
    state = state.copyWith(isStreaming: false);
    await _persist();
  }

  void _updateStreamingMessage(String id, String text, String? intent) {
    final session = state.activeSession;
    final messages = session.messages
        .map(
          (m) => m.id == id
              ? m.copyWith(text: text, intent: intent, isStreaming: true)
              : m,
        )
        .toList(growable: false);
    _replaceSession(session.copyWith(messages: messages, updatedAt: DateTime.now()));
  }

  void _finalizeStreamingMessage(String id, String text, String? intent) {
    final session = state.activeSession;
    final messages = session.messages
        .map(
          (m) => m.id == id
              ? m.copyWith(text: text, intent: intent, isStreaming: false)
              : m,
        )
        .toList(growable: false);
    _replaceSession(session.copyWith(messages: messages, updatedAt: DateTime.now()));
  }

  void _replaceSession(ChatSession session) {
    final sessions = [
      session,
      for (final s in state.sessions)
        if (s.id != session.id) s,
    ];
    state = state.copyWith(sessions: sessions);
    _persist();
  }

  String newClientMessageId() =>
      'c_${DateTime.now().microsecondsSinceEpoch}_${Random().nextInt(99999)}';
}
