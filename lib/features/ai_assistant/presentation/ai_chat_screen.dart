import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/config/app_routes.dart';
import '../../../core/config/providers.dart';
import '../../../core/theme/app_shadows.dart';
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

class _LuxuryInputBar extends StatelessWidget {
  const _LuxuryInputBar({
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
    final canSend = !isStreaming;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.55)),
        boxShadow: AppShadows.md(color: Colors.black.withValues(alpha: 0.12)),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
        child: Row(
          children: [
            IconButton(
              tooltip: 'Add',
              onPressed: null,
              icon: Icon(Icons.add, color: cs.onSurface.withValues(alpha: 0.6)),
            ),
            Expanded(
              child: TextField(
                controller: controller,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) {
                  if (!canSend) return;
                  onSend();
                },
                decoration: InputDecoration(
                  hintText: 'Budget, vibe, use-case…',
                  border: InputBorder.none,
                  isDense: true,
                  hintStyle: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: cs.onSurface.withValues(alpha: 0.65),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 6),
            DecoratedBox(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    cs.primary.withValues(alpha: 0.95),
                    cs.tertiary.withValues(alpha: 0.85),
                  ],
                ),
                boxShadow: AppShadows.sm(
                  color: cs.primary.withValues(alpha: 0.30),
                ),
              ),
              child: IconButton(
                tooltip: 'Send',
                onPressed: canSend ? onSend : null,
                icon: const Icon(Icons.arrow_upward, size: 18),
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
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
    final state = ref.watch(aiChatViewModelProvider);
    final messages = state.activeSession.messages;
    final cartItems = ref.watch(cartItemsProvider);
    final wishlistIds = ref.watch(wishlistIdsProvider);
    final hasUserMessages = messages.any((m) => m.role == ChatRole.user);
    final chatItems = _buildChatItems(
      messages: messages,
    ).reversed.toList(growable: false);

    return Scaffold(
      appBar: _ConciergeAppBar(
        onOpenSessions: () => _showSessionsSheet(context, state),
      ),
      body: Column(
        children: [
          const AiPrivacyNote(),
          AnimatedSize(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOutCubic,
            child: hasUserMessages
                ? const SizedBox.shrink()
                : _ConciergeLanding(
                    cartCount: cartItems.length,
                    wishlistCount: wishlistIds.length,
                    onSend: _quickSend,
                  ),
          ),
          Expanded(
            child: ListView.builder(
              reverse: true,
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
              itemCount: chatItems.length,
              itemBuilder: (context, index) {
                final item = chatItems[index];
                return switch (item) {
                  _ChatDayItem(:final date) => _DaySeparator(date: date),
                  _ChatGapItem(:final height) => SizedBox(height: height),
                  _ChatMessageItem(:final message, :final lastUserText) =>
                    KeyedSubtree(
                      key: ValueKey(message.id),
                      child: _MessageBubble(
                        message: message,
                        lastUserText: lastUserText,
                      ),
                    ),
                };
              },
            ),
          ),
          AnimatedPadding(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutCubic,
            padding: EdgeInsets.only(
              left: 16,
              right: 16,
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: SafeArea(
              top: false,
              minimum: const EdgeInsets.only(bottom: 12),
              child: _LuxuryInputBar(
                controller: _controller,
                isStreaming: state.isStreaming,
                onSend: _send,
              ),
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

  void _showSessionsSheet(BuildContext context, AiChatState state) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) => _ChatSessionsSheet(state: state),
    );
  }
}

sealed class _ChatItem {
  const _ChatItem();
}

class _ChatDayItem extends _ChatItem {
  const _ChatDayItem(this.date);
  final DateTime date;
}

class _ChatGapItem extends _ChatItem {
  const _ChatGapItem(this.height);
  final double height;
}

class _ChatMessageItem extends _ChatItem {
  const _ChatMessageItem({required this.message, required this.lastUserText});

  final ChatMessage message;
  final String? lastUserText;
}

List<_ChatItem> _buildChatItems({required List<ChatMessage> messages}) {
  final out = <_ChatItem>[];
  DateTime? lastDay;
  String? lastUserText;
  ChatRole? lastRole;

  for (final m in messages) {
    final day = DateTime(m.createdAt.year, m.createdAt.month, m.createdAt.day);
    if (lastDay == null || day.isAfter(lastDay)) {
      out.add(_ChatDayItem(day));
      lastDay = day;
    }

    if (lastRole != null) {
      final change = lastRole != m.role;
      out.add(_ChatGapItem(change ? 16 : 8));
    }

    if (m.role == ChatRole.user) {
      lastUserText = m.text;
    }

    out.add(_ChatMessageItem(message: m, lastUserText: lastUserText));
    lastRole = m.role;
  }
  return out;
}

class _ConciergeAppBar extends ConsumerWidget implements PreferredSizeWidget {
  const _ConciergeAppBar({required this.onOpenSessions});

  final VoidCallback onOpenSessions;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    return AppBar(
      centerTitle: false,
      titleSpacing: 12,
      title: Row(
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  cs.primary.withValues(alpha: 0.95),
                  cs.tertiary.withValues(alpha: 0.85),
                ],
              ),
              boxShadow: AppShadows.sm(
                color: cs.primary.withValues(alpha: 0.24),
              ),
            ),
            child: const Padding(
              padding: EdgeInsets.all(7),
              child: Icon(Icons.auto_awesome, size: 18, color: Colors.white),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Nova Concierge',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w900),
                ),
                Text(
                  'Your personal shopping assistant',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: cs.onSurface.withValues(alpha: 0.7),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          tooltip: 'Sessions',
          onPressed: onOpenSessions,
          icon: const Icon(Icons.chat_bubble_outline),
        ),
        const AiClearChatAction(),
      ],
    );
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
    final showInlineResults =
        !isUser &&
        !message.isStreaming &&
        (intent == 'recommend' || intent == 'search') &&
        _isConciergeQuerySpecificEnough(lastUserText);

    final bubbleFg = cs.onSurface;
    final bubbleRadius = BorderRadius.circular(isUser ? 26 : 22);

    final bubbleDecoration = isUser
        ? BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                cs.primary.withValues(alpha: 0.16),
                cs.tertiary.withValues(alpha: 0.10),
              ],
            ),
            borderRadius: bubbleRadius,
          )
        : BoxDecoration(
            color: cs.surface,
            borderRadius: bubbleRadius,
            boxShadow: AppShadows.md(
              color: Colors.black.withValues(alpha: 0.10),
            ),
          );

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Column(
        crossAxisAlignment: isUser
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: [
          ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.sizeOf(context).width * 0.78,
            ),
            child: DecoratedBox(
              decoration: bubbleDecoration,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (!isUser)
                      Row(
                        children: [
                          DecoratedBox(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                colors: [
                                  cs.primary.withValues(alpha: 0.95),
                                  cs.tertiary.withValues(alpha: 0.85),
                                ],
                              ),
                            ),
                            child: const Padding(
                              padding: EdgeInsets.all(5),
                              child: Icon(
                                Icons.auto_awesome,
                                size: 12,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Nova Concierge',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.labelSmall
                                  ?.copyWith(fontWeight: FontWeight.w900),
                            ),
                          ),
                          Text(
                            timeLabel,
                            style: Theme.of(context).textTheme.labelSmall
                                ?.copyWith(
                                  color: cs.onSurface.withValues(alpha: 0.55),
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                        ],
                      ),
                    if (!isUser) const SizedBox(height: 8),
                    if (message.isStreaming && message.text.isEmpty)
                      const _TypingIndicator()
                    else
                      Text(
                        message.text,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: bubbleFg,
                          height: 1.28,
                          fontWeight: isUser
                              ? FontWeight.w700
                              : FontWeight.w600,
                        ),
                      ),
                    if (message.isStreaming && message.text.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      const _TypingIndicator(),
                    ],
                    if (showActions) ...[
                      const SizedBox(height: 10),
                      _MessageActions(message: message),
                    ],
                  ],
                ),
              ),
            ),
          ),
          if (showInlineResults) ...[
            const SizedBox(height: 12),
            _InlineResultsSection(intent: intent),
          ],
          if (isUser) ...[
            const SizedBox(height: 6),
            Text(
              timeLabel,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: cs.onSurface.withValues(alpha: 0.55),
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
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
            ).textTheme.labelSmall?.copyWith(color: cs.onSurface),
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

class _ChatSessionsSheet extends ConsumerWidget {
  const _ChatSessionsSheet({required this.state});

  final AiChatState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessions = state.filteredSessions;
    final cs = Theme.of(context).colorScheme;
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
                  'Sessions',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              FilledButton.tonalIcon(
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
          DecoratedBox(
            decoration: BoxDecoration(
              color: cs.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: cs.outlineVariant.withValues(alpha: 0.55),
              ),
            ),
            child: TextField(
              onChanged: (value) => ref
                  .read(aiChatViewModelProvider.notifier)
                  .updateSearchQuery(value),
              decoration: InputDecoration(
                hintText: 'Search sessions',
                prefixIcon: Icon(Icons.search),
                border: InputBorder.none,
                hintStyle: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: cs.onSurface.withValues(alpha: 0.65),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Flexible(
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: sessions.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final session = sessions[index];
                final preview = session.messages.isEmpty
                    ? ''
                    : session.messages.last.text.trim().replaceAll('\n', ' ');
                final selected = session.id == state.activeSessionId;
                return InkWell(
                  onTap: () {
                    ref
                        .read(aiChatViewModelProvider.notifier)
                        .selectSession(session.id);
                    Navigator.of(context).pop();
                  },
                  borderRadius: BorderRadius.circular(18),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: selected
                          ? cs.primary.withValues(alpha: 0.08)
                          : cs.surface,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: cs.outlineVariant.withValues(alpha: 0.55),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  session.title,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: Theme.of(context).textTheme.titleSmall
                                      ?.copyWith(fontWeight: FontWeight.w900),
                                ),
                                if (preview.isNotEmpty) ...[
                                  const SizedBox(height: 4),
                                  Text(
                                    preview,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: Theme.of(context).textTheme.bodySmall
                                        ?.copyWith(
                                          color: cs.onSurface.withValues(
                                            alpha: 0.7,
                                          ),
                                        ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          const SizedBox(width: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                _formatDate(session.updatedAt),
                                style: Theme.of(context).textTheme.labelSmall
                                    ?.copyWith(
                                      color: cs.onSurface.withValues(
                                        alpha: 0.6,
                                      ),
                                      fontWeight: FontWeight.w700,
                                    ),
                              ),
                              const SizedBox(height: 6),
                              if (selected)
                                Icon(
                                  Icons.check_circle,
                                  color: cs.primary,
                                  size: 18,
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
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
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        OutlinedButton.icon(
          style: OutlinedButton.styleFrom(
            textStyle: Theme.of(context).textTheme.labelMedium,
          ),
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
          style: OutlinedButton.styleFrom(
            textStyle: Theme.of(context).textTheme.labelMedium,
          ),
          onPressed: () =>
              ref.read(aiChatViewModelProvider.notifier).regenerateLast(),
          icon: const Icon(Icons.refresh, size: 16),
          label: const Text('Regenerate'),
        ),
      ],
    );
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
          borderRadius: BorderRadius.circular(22),
          boxShadow: AppShadows.md(color: Colors.black.withValues(alpha: 0.10)),
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
                      Icons.shopping_bag_outlined,
                      size: 16,
                      color: cs.onSurface.withValues(alpha: 0.75),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Picked for you',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                SizedBox(
                  height: 180,
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
              height: 180,
              child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
            ),
            error: (_, __) => const SizedBox.shrink(),
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
    final buttonBg = cs.primary.withValues(alpha: 0.10);
    return SizedBox(
      width: 190,
      child: InkWell(
        onTap: () => context.push('${AppRoutes.product}?id=${product.id}'),
        borderRadius: BorderRadius.circular(18),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: cs.surface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: cs.outlineVariant.withValues(alpha: 0.55),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: AppCachedNetworkImage(
                      url: product.imageUrl,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  product.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        '${product.currency} ${product.price.toStringAsFixed(0)}',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: cs.onSurface.withValues(alpha: 0.75),
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    Consumer(
                      builder: (context, ref, _) {
                        return InkWell(
                          onTap: () {
                            final color = product.availableColors.isEmpty
                                ? 'Default'
                                : product.availableColors.first;
                            final size = product.availableSizes.isEmpty
                                ? 'Default'
                                : product.availableSizes.first;
                            ref
                                .read(cartViewModelProvider.notifier)
                                .add(
                                  product: product,
                                  selectedColor: color,
                                  selectedSize: size,
                                );
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Added to cart')),
                            );
                          },
                          borderRadius: BorderRadius.circular(999),
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              color: buttonBg,
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: const Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                              child: Text(
                                'Add',
                                style: TextStyle(fontWeight: FontWeight.w900),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
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
      height: 16,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          final t = _controller.value;
          double p1 = 0.0;
          double p2 = 0.0;
          double p3 = 0.0;
          if (t < 0.33) {
            p1 = 1;
          } else if (t < 0.66) {
            p2 = 1;
          } else {
            p3 = 1;
          }

          Widget dot(double active) {
            final base = cs.onSurface.withValues(alpha: 0.35);
            final on = cs.onSurface.withValues(alpha: 0.75);
            return AnimatedContainer(
              duration: const Duration(milliseconds: 160),
              width: 6,
              height: 6,
              margin: const EdgeInsets.only(right: 5),
              decoration: BoxDecoration(
                color: active > 0 ? on : base,
                shape: BoxShape.circle,
              ),
            );
          }

          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [dot(p1), dot(p2), dot(p3)],
          );
        },
      ),
    );
  }
}

class _ConciergeLanding extends StatelessWidget {
  const _ConciergeLanding({
    required this.cartCount,
    required this.wishlistCount,
    required this.onSend,
  });

  final int cartCount;
  final int wishlistCount;
  final ValueChanged<String> onSend;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 10),
      child: Column(
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              color: cs.surface,
              borderRadius: BorderRadius.circular(22),
              boxShadow: AppShadows.md(
                color: Colors.black.withValues(alpha: 0.10),
              ),
              border: Border.all(
                color: cs.outlineVariant.withValues(alpha: 0.55),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DecoratedBox(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [
                          cs.primary.withValues(alpha: 0.95),
                          cs.tertiary.withValues(alpha: 0.85),
                        ],
                      ),
                    ),
                    child: const Padding(
                      padding: EdgeInsets.all(10),
                      child: Icon(
                        Icons.auto_awesome,
                        size: 18,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Hi Ahmad',
                          style: Theme.of(context).textTheme.titleSmall
                              ?.copyWith(fontWeight: FontWeight.w900),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'What can I help you shop for today?',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: cs.onSurface.withValues(alpha: 0.78),
                                fontWeight: FontWeight.w600,
                                height: 1.22,
                              ),
                        ),
                        const SizedBox(height: 10),
                        _ChatContextPanel(
                          cartCount: cartCount,
                          wishlistCount: wishlistCount,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 2.4,
            children: [
              _ActionTile(
                title: 'Find deals today',
                icon: Icons.local_offer_outlined,
                onTap: () => onSend('Find me the best deals today under \$50.'),
              ),
              _ActionTile(
                title: 'Pick an outfit',
                icon: Icons.checkroom_outlined,
                onTap: () =>
                    onSend('Build me a clean minimal outfit. Budget \$150.'),
              ),
              _ActionTile(
                title: 'Gift ideas',
                icon: Icons.card_giftcard,
                onTap: () => onSend(
                  'Gift ideas under \$80. Recipient is 25, minimal style.',
                ),
              ),
              _ActionTile(
                title: 'Track my order',
                icon: Icons.local_shipping_outlined,
                onTap: () => onSend('Help me track my last order.'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.title,
    required this.icon,
    required this.onTap,
  });

  final String title;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.55)),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
          child: Row(
            children: [
              Icon(icon, size: 18, color: cs.primary.withValues(alpha: 0.9)),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
        ),
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
