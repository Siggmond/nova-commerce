import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:nova_commerce/app/theme/app_tokens.dart';
import 'package:nova_commerce/features/ai_assistant/presentation/state/ai_chat_viewmodel.dart';
import 'package:nova_commerce/gen_l10n/app_localizations.dart';

class AiClearChatAction extends ConsumerWidget {
  const AiClearChatAction({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;
    return IconButton(
      tooltip: t.aiChatTooltipClearChat,
      color: cs.error,
      style: IconButton.styleFrom(
        backgroundColor: cs.errorContainer.withValues(alpha: 0.18),
        minimumSize: Size(AppHitTargets.comfortable, AppHitTargets.comfortable),
      ),
      onPressed: () {
        ref.read(aiChatViewModelProvider.notifier).clear();
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(t.aiChatSnackbarChatCleared)));
      },
      icon: const Icon(Icons.delete_outline),
    );
  }
}
