import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'ai_chat_viewmodel.dart';

class AiClearChatAction extends ConsumerWidget {
  const AiClearChatAction({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return IconButton(
      tooltip: 'Clear chat',
      onPressed: () {
        ref.read(aiChatViewModelProvider.notifier).clear();
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Chat cleared')));
      },
      icon: const Icon(Icons.delete_outline),
    );
  }
}
