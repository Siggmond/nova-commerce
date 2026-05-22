import 'package:hive/hive.dart';
import 'package:nova_commerce/core/runtime/local_storage_runtime.dart';

import 'package:nova_commerce/features/ai_assistant/domain/entities/ai_chat_snapshot.dart';
import 'package:nova_commerce/features/ai_assistant/domain/entities/chat_message.dart';
import 'package:nova_commerce/features/ai_assistant/domain/entities/chat_session.dart';
import 'package:nova_commerce/features/ai_assistant/domain/repositories/ai_chat_store.dart';

class AiChatStorage implements AiChatStore {
  static const String _boxName = 'ai_chat';
  static const String _sessionsKey = 'sessions';
  static const String _activeSessionKey = 'active_session_id';

  Future<Box<dynamic>> _openBox() async {
    await LocalStorageRuntime.ensureInitialized();
    return Hive.openBox<dynamic>(_boxName);
  }

  @override
  Future<AiChatSnapshot?> load() async {
    final box = await _openBox();
    final rawSessions = box.get(_sessionsKey);
    if (rawSessions is! List) return null;
    final sessions = <ChatSession>[];
    for (final raw in rawSessions) {
      if (raw is Map) {
        final session = _sessionFromMap(raw.cast<String, dynamic>());
        if (session != null) sessions.add(session);
      }
    }
    if (sessions.isEmpty) return null;
    final activeId = box.get(_activeSessionKey) as String?;
    return AiChatSnapshot(
      sessions: sessions,
      activeSessionId: activeId ?? sessions.first.id,
    );
  }

  @override
  Future<void> save({
    required List<ChatSession> sessions,
    required String activeSessionId,
  }) async {
    final box = await _openBox();
    final payload = sessions.map(_sessionToMap).toList(growable: false);
    await box.put(_sessionsKey, payload);
    await box.put(_activeSessionKey, activeSessionId);
  }

  Map<String, dynamic> _sessionToMap(ChatSession session) {
    return {
      'id': session.id,
      'title': session.title,
      'updatedAt': session.updatedAt.toIso8601String(),
      'messages': session.messages.map(_messageToMap).toList(growable: false),
    };
  }

  ChatSession? _sessionFromMap(Map<String, dynamic> map) {
    final id = map['id'] as String?;
    final title = map['title'] as String?;
    final updatedAtRaw = map['updatedAt'] as String?;
    final messagesRaw = map['messages'];
    if (id == null || title == null || updatedAtRaw == null) return null;
    final updatedAt = DateTime.tryParse(updatedAtRaw);
    if (updatedAt == null) return null;
    final messages = <ChatMessage>[];
    if (messagesRaw is List) {
      for (final raw in messagesRaw) {
        if (raw is Map) {
          final message = _messageFromMap(raw.cast<String, dynamic>());
          if (message != null) messages.add(message);
        }
      }
    }
    return ChatSession(
      id: id,
      title: title,
      messages: messages,
      updatedAt: updatedAt,
    );
  }

  Map<String, dynamic> _messageToMap(ChatMessage message) {
    return {
      'id': message.id,
      'role': message.role.name,
      'text': message.text,
      'createdAt': message.createdAt.toIso8601String(),
      'intent': message.intent,
    };
  }

  ChatMessage? _messageFromMap(Map<String, dynamic> map) {
    final id = map['id'] as String?;
    final roleRaw = map['role'] as String?;
    final text = map['text'] as String?;
    final createdAtRaw = map['createdAt'] as String?;
    if (id == null || roleRaw == null || text == null || createdAtRaw == null) {
      return null;
    }
    final createdAt = DateTime.tryParse(createdAtRaw);
    if (createdAt == null) return null;
    final role = ChatRole.values.firstWhere(
      (r) => r.name == roleRaw,
      orElse: () => ChatRole.assistant,
    );
    return ChatMessage(
      id: id,
      role: role,
      text: text,
      createdAt: createdAt,
      intent: map['intent'] as String?,
      isStreaming: false,
    );
  }
}
