import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/config/app_routes.dart';
import '../../../core/config/app_env.dart';
import '../../../core/config/providers.dart';
import '../../../core/widgets/app_cached_network_image.dart';
import '../../../domain/entities/product.dart';
import '../../../domain/entities/chat_message.dart';
import '../../cart/presentation/cart_viewmodel.dart';
import '../../wishlist/presentation/wishlist_viewmodel.dart';
import 'ai_clear_chat_action.dart';
import 'ai_privacy_note.dart';
import 'ai_chat_viewmodel.dart';

final aiSuggestedProductsProvider = FutureProvider<List<Product>>((ref) async {
  final repo = ref.watch(productRepositoryProvider);
  final page = await repo.getFeaturedProducts(limit: 4);
  return page.items;
});

class AiChatScreen extends ConsumerStatefulWidget {
  const AiChatScreen({super.key});

  @override
  ConsumerState<AiChatScreen> createState() => _AiChatScreenState();
}

class _AiChatScreenState extends ConsumerState<AiChatScreen> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(aiChatViewModelProvider);
    final messages = state.activeSession.messages;
    final cartItems = ref.watch(cartItemsProvider);
    final wishlistIds = ref.watch(wishlistIdsProvider);
    final hasUserMessages = messages.any((m) => m.role == ChatRole.user);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Nova AI'),
        actions: [
          IconButton(
            tooltip: 'Sessions',
            onPressed: () => _showSessionsSheet(context, state),
            icon: const Icon(Icons.chat_bubble_outline),
          ),
          const AiClearChatAction(),
        ],
      ),
      body: Column(
        children: [
          const AiPrivacyNote(),
          AnimatedSize(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOutCubic,
            child: hasUserMessages
                ? const SizedBox.shrink()
                : Column(
                    children: [
                      _ConciergeIntroCard(
                        cartCount: cartItems.length,
                        wishlistCount: wishlistIds.length,
                      ),
                      _ChatContextPanel(
                        cartCount: cartItems.length,
                        wishlistCount: wishlistIds.length,
                      ),
                      _PromptChips(onSend: _quickSend),
                    ],
                  ),
          ),
          Expanded(
            child: ListView(
              controller: _scrollController,
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
              children: _buildMessageList(context, messages),
            ),
          ),
          SafeArea(
            minimum: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: _InputBar(
              controller: _controller,
              isStreaming: state.isStreaming,
              onSend: _send,
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
    _scrollToBottom();
  }

  void _quickSend(String text) {
    _controller.text = text;
    _send();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
      );
    });
  }

  void _showSessionsSheet(BuildContext context, AiChatState state) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) => _ChatSessionsSheet(state: state),
    );
  }

  List<Widget> _buildMessageList(
    BuildContext context,
    List<ChatMessage> messages,
  ) {
    final widgets = <Widget>[];
    DateTime? lastDay;
    String? lastUserText;
    ChatRole? lastRole;
    for (final m in messages) {
      final day = DateTime(
        m.createdAt.year,
        m.createdAt.month,
        m.createdAt.day,
      );
      if (lastDay == null || day.isAfter(lastDay)) {
        widgets.add(_DaySeparator(date: day));
        lastDay = day;
      }

      if (lastRole != null) {
        final change = lastRole != m.role;
        widgets.add(SizedBox(height: change ? 16 : 8));
      }

      if (m.role == ChatRole.user) {
        lastUserText = m.text;
      }
      widgets.add(_MessageBubble(message: m, lastUserText: lastUserText));

      lastRole = m.role;
    }
    return widgets;
  }
}

class _MessageBubble extends ConsumerWidget {
  const _MessageBubble({required this.message, required this.lastUserText});

  final ChatMessage message;
  final String? lastUserText;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isUser = message.role == ChatRole.user;
    final cs = Theme.of(context).colorScheme;
    final intent = message.intent;
    final showActions = !isUser;
    final timeLabel = _formatTime(message.createdAt);
    final showPlaceholders = AppEnv.enableAiPlaceholders;
    final showInlineResults =
        !isUser &&
        !message.isStreaming &&
        (intent == 'recommend' || intent == 'search') &&
        _isConciergeQuerySpecificEnough(lastUserText);

    final assistantPhase = switch (intent) {
      'search' || 'recommend' => showInlineResults ? 'Results' : 'Clarifying',
      _ => 'Clarifying',
    };

    final bubbleBg = isUser
        ? cs.primary.withValues(alpha: 0.10)
        : cs.surfaceContainerHighest;
    final bubbleFg = isUser ? cs.onSurface : cs.onSurface;
    final bubbleBorder = Border.all(
      color: cs.outlineVariant.withValues(alpha: 0.55),
    );
    final bubbleRadius = BorderRadius.circular(18);

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Column(
        crossAxisAlignment: isUser
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: [
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 340),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: bubbleBg,
                borderRadius: bubbleRadius,
                border: bubbleBorder,
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (!isUser)
                      Row(
                        children: [
                          Icon(
                            Icons.auto_awesome,
                            size: 16,
                            color: cs.primary.withValues(alpha: 0.85),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Concierge • $assistantPhase',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.labelMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.w800,
                                    color: cs.onSurface.withValues(alpha: 0.78),
                                  ),
                            ),
                          ),
                        ],
                      ),
                    if (!isUser) const SizedBox(height: 8),
                    if (showPlaceholders &&
                        message.isStreaming &&
                        message.text.isEmpty)
                      const _MessageSkeleton()
                    else
                      Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(text: message.text),
                            if (message.isStreaming)
                              TextSpan(
                                text: ' ▍',
                                style: TextStyle(
                                  color: cs.onSurface.withValues(alpha: 0.7),
                                ),
                              ),
                          ],
                        ),
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: bubbleFg,
                          height: 1.28,
                        ),
                      ),
                    if (showActions) ...[
                      const SizedBox(height: 10),
                      _MessageActions(message: message),
                      if (showPlaceholders) ...[
                        const SizedBox(height: 8),
                        const _MessageReactions(),
                      ],
                    ],
                    if (showPlaceholders && !isUser && !message.isStreaming)
                      _SuggestedReplies(
                        onSend: (text) => ref
                            .read(aiChatViewModelProvider.notifier)
                            .send(text),
                      ),
                  ],
                ),
              ),
            ),
          ),
          if (showInlineResults) ...[
            const SizedBox(height: 10),
            _InlineResultsSection(intent: intent),
          ],
          const SizedBox(height: 6),
          Text(
            timeLabel,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: cs.onSurface.withValues(alpha: 0.55),
            ),
          ),
        ],
      ),
    );
  }
}

class _ChatContextPanel extends StatelessWidget {
  const _ChatContextPanel({
    required this.cartCount,
    required this.wishlistCount,
  });

  final int cartCount;
  final int wishlistCount;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: cs.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.5)),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
          child: Row(
            children: [
              _ContextChip(label: 'Cart', value: '$cartCount items'),
              const SizedBox(width: 8),
              _ContextChip(label: 'Wishlist', value: '$wishlistCount saved'),
            ],
          ),
        ),
      ),
    );
  }
}

class _ContextChip extends StatelessWidget {
  const _ContextChip({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: RichText(
          text: TextSpan(
            style: Theme.of(
              context,
            ).textTheme.labelMedium?.copyWith(color: cs.onSurface),
            children: [
              TextSpan(
                text: '$label: ',
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              TextSpan(text: value),
            ],
          ),
        ),
      ),
    );
  }
}

class _PromptChips extends StatelessWidget {
  const _PromptChips({required this.onSend});

  final ValueChanged<String> onSend;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 6),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            ActionChip(
              label: const Text('Under \$50'),
              onPressed: () => onSend(
                'Under \$50 — what should I buy? I like minimal style.',
              ),
            ),
            ActionChip(
              label: const Text('Work / office'),
              onPressed: () =>
                  onSend('Build me a minimal outfit for work under \$120.'),
            ),
            ActionChip(
              label: const Text('Weekend fit'),
              onPressed: () => onSend(
                'Build me a weekend outfit. Budget \$150. Clean / minimal.',
              ),
            ),
            ActionChip(
              label: const Text('One specific item'),
              onPressed: () => onSend(
                'Black hoodie under \$50, oversized. Show me a few options.',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InputBar extends StatelessWidget {
  const _InputBar({
    required this.controller,
    required this.isStreaming,
    required this.onSend,
  });

  final TextEditingController controller;
  final bool isStreaming;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: controller,
            textInputAction: TextInputAction.send,
            onSubmitted: (_) => onSend(),
            decoration: InputDecoration(
              hintText: 'Budget, vibe, use-case…',
              filled: true,
              fillColor: cs.surfaceContainerHighest,
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 10,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        IconButton.filled(
          onPressed: isStreaming ? null : onSend,
          icon: const Icon(Icons.arrow_upward, size: 18),
          padding: EdgeInsets.zero,
          visualDensity: VisualDensity.compact,
          constraints: const BoxConstraints.tightFor(width: 34, height: 34),
        ),
      ],
    );
  }
}

class _ChatSessionsSheet extends ConsumerWidget {
  const _ChatSessionsSheet({required this.state});

  final AiChatState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessions = state.filteredSessions;
    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Conversations',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
                ),
              ),
              TextButton.icon(
                onPressed: () {
                  ref.read(aiChatViewModelProvider.notifier).newSession();
                  Navigator.of(context).pop();
                },
                icon: const Icon(Icons.add),
                label: const Text('New'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            onChanged: (value) => ref
                .read(aiChatViewModelProvider.notifier)
                .updateSearchQuery(value),
            decoration: InputDecoration(
              hintText: 'Search conversations',
              prefixIcon: const Icon(Icons.search),
              filled: true,
              fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Flexible(
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: sessions.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final session = sessions[index];
                return ListTile(
                  title: Text(session.title),
                  subtitle: Text(_formatDate(session.updatedAt)),
                  trailing: session.id == state.activeSessionId
                      ? const Icon(Icons.check_circle)
                      : null,
                  onTap: () {
                    ref
                        .read(aiChatViewModelProvider.notifier)
                        .selectSession(session.id);
                    Navigator.of(context).pop();
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _MessageActions extends ConsumerWidget {
  const _MessageActions({required this.message});

  final ChatMessage message;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final showPlaceholders = AppEnv.enableAiPlaceholders;
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        OutlinedButton.icon(
          onPressed: () {
            Clipboard.setData(ClipboardData(text: message.text));
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text('Copied')));
          },
          icon: const Icon(Icons.copy, size: 16),
          label: const Text('Copy'),
        ),
        OutlinedButton.icon(
          onPressed: () =>
              ref.read(aiChatViewModelProvider.notifier).regenerateLast(),
          icon: const Icon(Icons.refresh, size: 16),
          label: const Text('Regenerate'),
        ),
        if (showPlaceholders)
          OutlinedButton.icon(
            onPressed: () => ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text('Saved to notes'))),
            icon: const Icon(Icons.bookmark_border, size: 16),
            label: const Text('Save'),
          ),
        if (showPlaceholders)
          OutlinedButton.icon(
            onPressed: () => ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text('Shared'))),
            icon: const Icon(Icons.share_outlined, size: 16),
            label: const Text('Share'),
          ),
      ],
    );
  }
}

class _MessageSkeleton extends StatelessWidget {
  const _MessageSkeleton();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(height: 24);
  }
}

class _MessageReactions extends StatelessWidget {
  const _MessageReactions();

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }
}

class _SuggestedReplies extends StatelessWidget {
  const _SuggestedReplies({required this.onSend});

  final ValueChanged<String> onSend;

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }
}

class _InlineResultsSection extends ConsumerWidget {
  const _InlineResultsSection({required this.intent});

  final String? intent;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final products = ref.watch(aiSuggestedProductsProvider);
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: EdgeInsets.zero,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.55)),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
          child: products.when(
            data: (items) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.tune,
                      size: 16,
                      color: cs.onSurface.withValues(alpha: 0.75),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Suggested matches',
                        style: Theme.of(context).textTheme.labelMedium
                            ?.copyWith(fontWeight: FontWeight.w800),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                SizedBox(
                  height: 126,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: items.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 10),
                    itemBuilder: (context, index) {
                      final p = items[index];
                      return _InlineProductCard(product: p);
                    },
                  ),
                ),
              ],
            ),
            loading: () => const SizedBox(
              height: 126,
              child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
            ),
            error: (_, __) => const SizedBox.shrink(),
          ),
        ),
      ),
    );
  }
}

class _ConciergeIntroCard extends StatelessWidget {
  const _ConciergeIntroCard({
    required this.cartCount,
    required this.wishlistCount,
  });

  final int cartCount;
  final int wishlistCount;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: cs.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.5)),
        ),
        child: const Padding(
          padding: EdgeInsets.fromLTRB(12, 12, 12, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Use this tab to narrow down and decide.',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
              SizedBox(height: 6),
              Text(
                'Tell me your budget, vibe, and use-case — I’ll suggest a short set of options instead of an endless feed.',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

bool _isConciergeQuerySpecificEnough(String? text) {
  final t = text?.trim() ?? '';
  if (t.isEmpty) return false;
  if (t.length < 12) return false;
  if (RegExp(r'\d').hasMatch(t)) return true;
  final lower = t.toLowerCase();
  if (lower.contains('\$')) return true;
  if (lower.contains('under ') || lower.contains('less than')) return true;
  if (lower.contains('budget')) return true;
  if (lower.contains('hoodie') ||
      lower.contains('sneaker') ||
      lower.contains('shoes') ||
      lower.contains('pants') ||
      lower.contains('jacket') ||
      lower.contains('dress')) {
    return true;
  }
  return false;
}

class _InlineProductCard extends StatelessWidget {
  const _InlineProductCard({required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return InkWell(
      onTap: () => context.push('${AppRoutes.product}?id=${product.id}'),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 160,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.6)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: AppCachedNetworkImage(
                    url: product.imageUrl,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              product.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(
                context,
              ).textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            Text(
              '${product.currency} ${product.price.toStringAsFixed(0)}',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: cs.onSurface.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TypingIndicator extends StatefulWidget {
  const _TypingIndicator();

  @override
  State<_TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<_TypingIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return SizedBox(
      height: 18,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          final t = _controller.value;
          String dots = '.';
          if (t > 0.66) {
            dots = '...';
          } else if (t > 0.33) {
            dots = '..';
          }
          return Text(
            'Typing$dots',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: cs.onSurface.withValues(alpha: 0.7),
            ),
          );
        },
      ),
    );
  }
}

class _DaySeparator extends StatelessWidget {
  const _DaySeparator({required this.date});

  final DateTime date;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Center(
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: cs.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(999),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: Text(
              _formatDate(date),
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: cs.onSurface.withValues(alpha: 0.7),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

String _formatTime(DateTime dt) {
  final h = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
  final m = dt.minute.toString().padLeft(2, '0');
  final suffix = dt.hour >= 12 ? 'PM' : 'AM';
  return '$h:$m $suffix';
}

String _formatDate(DateTime dt) {
  return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
}
