import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/config/app_routes.dart';
import '../../../domain/entities/chat_message.dart';
import 'ai_chat_viewmodel.dart';

class AiChatScreen extends ConsumerStatefulWidget {
  const AiChatScreen({super.key});

  @override
  ConsumerState<AiChatScreen> createState() => _AiChatScreenState();
}

class _AiChatScreenState extends ConsumerState<AiChatScreen> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final messages = ref.watch(aiChatViewModelProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Nova AI')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 6),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  ActionChip(
                    label: const Text('Find me something cheap'),
                    onPressed: () =>
                        _quickSend('Find me something cheap under \$50'),
                  ),
                  ActionChip(
                    label: const Text('What is trending?'),
                    onPressed: () => _quickSend('What is trending right now?'),
                  ),
                  ActionChip(
                    label: const Text('Build me an outfit'),
                    onPressed: () => _quickSend('Build me an outfit'),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final m = messages[index];
                return _MessageBubble(message: m);
              },
            ),
          ),
          SafeArea(
            minimum: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => _send(),
                    decoration: InputDecoration(
                      hintText: 'Ask Nova…',
                      filled: true,
                      fillColor: Theme.of(
                        context,
                      ).colorScheme.surfaceContainerHighest,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                IconButton.filled(
                  onPressed: _send,
                  icon: const Icon(Icons.arrow_upward),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _send() {
    final text = _controller.text;
    _controller.clear();
    ref.read(aiChatViewModelProvider.notifier).send(text);
  }

  void _quickSend(String text) {
    _controller.text = text;
    _send();
  }
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({required this.message});

  final ChatMessage message;

  @override
  Widget build(BuildContext context) {
    final isUser = message.role == ChatRole.user;
    final cs = Theme.of(context).colorScheme;
    final intent = message.intent;
    final showActions = !isUser && intent != null;

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 320),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: isUser ? cs.primary : cs.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message.text,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: isUser ? cs.onPrimary : cs.onSurface,
                      height: 1.25,
                    ),
                  ),
                  if (showActions) ...[
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        if (intent == 'recommend')
                          FilledButton.tonal(
                            onPressed: () => context.go(AppRoutes.home),
                            child: const Text('Open picks'),
                          ),
                        if (intent == 'search')
                          FilledButton.tonal(
                            onPressed: () => context.go(AppRoutes.home),
                            child: const Text('Browse results'),
                          ),
                        FilledButton.tonal(
                          onPressed: () => context.go(AppRoutes.home),
                          child: const Text('Back to feed'),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
