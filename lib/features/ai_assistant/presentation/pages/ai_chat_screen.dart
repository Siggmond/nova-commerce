import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import 'package:nova_commerce/app/di/app_providers.dart';
import 'package:nova_commerce/app/router/app_routes.dart';
import 'package:nova_commerce/app/theme/app_shadows.dart';
import 'package:nova_commerce/core/widgets/app_cached_network_image.dart';
import 'package:nova_commerce/gen_l10n/app_localizations.dart';
import 'package:nova_commerce/features/ai_assistant/domain/entities/chat_message.dart';
import 'package:nova_commerce/core/domain/entities/product.dart';
import 'package:nova_commerce/features/cart/cart.dart';
import 'package:nova_commerce/features/wishlist/wishlist.dart';
import 'package:nova_commerce/features/ai_assistant/presentation/state/ai_chat_viewmodel.dart';
import 'package:nova_commerce/features/ai_assistant/presentation/widgets/ai_clear_chat_action.dart';
import 'package:nova_commerce/features/ai_assistant/presentation/widgets/ai_privacy_note.dart';

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
    final t = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;
    final canSend = !isStreaming;
    final inputSurface = cs.surfaceContainerLow.withValues(alpha: 0.60);
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [cs.surface, inputSurface],
        ),
        borderRadius: BorderRadius.circular(28.r),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.55)),
        boxShadow: AppShadows.md(color: Colors.black.withValues(alpha: 0.12)),
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(10.w, 8.h, 8.w, 8.h),
        child: Row(
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                color: cs.surfaceContainerHigh.withValues(alpha: 0.92),
                borderRadius: BorderRadius.circular(14.r),
                border: Border.all(
                  color: cs.outlineVariant.withValues(alpha: 0.45),
                ),
              ),
              child: Padding(
                padding: EdgeInsets.all(8.r),
                child: Icon(
                  Icons.shopping_bag_outlined,
                  size: 18,
                  color: cs.onSurface.withValues(alpha: 0.72),
                ),
              ),
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: TextField(
                controller: controller,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) {
                  if (!canSend) return;
                  onSend();
                },
                decoration: InputDecoration(
                  hintText: t.aiChatHint,
                  border: InputBorder.none,
                  isDense: true,
                  hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: cs.onSurface.withValues(alpha: 0.65),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            SizedBox(width: 8.w),
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
                tooltip: t.aiChatTooltipSend,
                onPressed: canSend ? onSend : null,
                icon: Icon(Icons.arrow_upward_rounded, size: 18.r),
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AiChatScreenState extends ConsumerState<AiChatScreen>
    with TickerProviderStateMixin {
  final _controller = TextEditingController();

  OverlayEntry? _privacyOverlay;

  @override
  void dispose() {
    _privacyOverlay?.remove();
    _privacyOverlay = null;
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final state = ref.watch(aiChatViewModelProvider);
    final messages = state.activeSession.messages;
    final hasUserMessages = messages.any((m) => m.role == ChatRole.user);
    final chatItems = _buildChatItems(
      messages: messages,
    ).reversed.toList(growable: false);

    return Scaffold(
      appBar: _ConciergeAppBar(
        onOpenSessions: () => _showSessionsSheet(context, state),
        onShowInfo: () => _showPrivacyInfo(context, t),
      ),
      body: Stack(
        children: [
          const Positioned.fill(
            child: IgnorePointer(child: _ConciergeBackdrop()),
          ),
          Column(
            children: [
              AnimatedSize(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeOutCubic,
                child: hasUserMessages
                    ? const SizedBox.shrink()
                    : _LandingDataBridge(onSend: _quickSend),
              ),
              Expanded(
                child: ListView.builder(
                  reverse: true,
                  padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 16.h),
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
                  minimum: EdgeInsets.only(bottom: 12.h),
                  child: _LuxuryInputBar(
                    controller: _controller,
                    isStreaming: state.isStreaming,
                    onSend: _send,
                  ),
                ),
              ),
            ],
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

  void _showPrivacyInfo(BuildContext context, AppLocalizations t) {
    _privacyOverlay?.remove();
    _privacyOverlay = null;

    final overlay = Overlay.of(context);

    late final AnimationController controller;
    controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 240),
    );

    final fade = CurvedAnimation(
      parent: controller,
      curve: Curves.easeOutCubic,
    );

    final entry = OverlayEntry(
      builder: (context) {
        return Positioned(
          top: MediaQuery.of(context).padding.top + kToolbarHeight + 8,
          left: 16,
          right: 16,
          child: FadeTransition(
            opacity: fade,
            child: const Material(
              color: Colors.transparent,
              child: AiPrivacyNote(),
            ),
          ),
        );
      },
    );

    overlay.insert(entry);
    _privacyOverlay = entry;

    controller.forward();
    Future<void>.delayed(const Duration(seconds: 3)).then((_) async {
      if (!mounted) return;
      await controller.reverse();
      entry.remove();
      if (_privacyOverlay == entry) {
        _privacyOverlay = null;
      }
      controller.dispose();
    });
  }
}

class _ConciergeBackdrop extends StatelessWidget {
  const _ConciergeBackdrop();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            cs.primary.withValues(alpha: 0.08),
            Colors.transparent,
            cs.tertiary.withValues(alpha: 0.05),
          ],
          stops: const [0.0, 0.36, 1.0],
        ),
      ),
      child: Stack(
        children: [
          Align(
            alignment: const Alignment(-1.0, -0.86),
            child: DecoratedBox(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: cs.primary.withValues(alpha: 0.10),
              ),
              child: SizedBox(width: 180.w, height: 180.h),
            ),
          ),
          Align(
            alignment: const Alignment(1.0, -0.70),
            child: DecoratedBox(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: cs.secondary.withValues(alpha: 0.08),
              ),
              child: SizedBox(width: 140.w, height: 140.h),
            ),
          ),
        ],
      ),
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
  const _ConciergeAppBar({
    required this.onOpenSessions,
    required this.onShowInfo,
  });

  final VoidCallback onOpenSessions;
  final VoidCallback onShowInfo;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context)!;
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
            child: Padding(
              padding: EdgeInsets.all(7.r),
              child: Icon(Icons.auto_awesome, size: 18.r, color: Colors.white),
            ),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  t.aiChatTitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w900),
                ),
                Text(
                  t.aiChatSubtitle,
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
          tooltip: t.aiChatTooltipSessions,
          onPressed: onOpenSessions,
          icon: const Icon(Icons.history_rounded),
        ),
        IconButton(
          tooltip: t.aiChatTooltipInfo,
          onPressed: onShowInfo,
          icon: const Icon(Icons.info_outline),
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
    final t = AppLocalizations.of(context)!;
    final isUser = message.role == ChatRole.user;
    final cs = Theme.of(context).colorScheme;
    final intent = message.intent;
    final showActions = !isUser;
    final timeLabel = _formatTime(context, message.createdAt);
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
                padding: EdgeInsets.fromLTRB(12.w, 10.h, 12.w, 10.h),
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
                            child: Padding(
                              padding: EdgeInsets.all(5.r),
                              child: Icon(
                                Icons.auto_awesome,
                                size: 12,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          SizedBox(width: 8.w),
                          Expanded(
                            child: Text(
                              t.aiChatTitle,
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
                    if (!isUser) SizedBox(height: 8.h),
                    if (message.isStreaming && message.text.isEmpty)
                      const _TypingIndicator()
                    else
                      Text(
                        _localizedAssistantSeedMessage(t, message.text),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: bubbleFg,
                          height: 1.28,
                          fontWeight: isUser
                              ? FontWeight.w700
                              : FontWeight.w600,
                        ),
                      ),
                    if (message.isStreaming && message.text.isNotEmpty) ...[
                      SizedBox(height: 8.h),
                      const _TypingIndicator(),
                    ],
                    if (showActions) ...[
                      SizedBox(height: 10.h),
                      _MessageActions(message: message),
                    ],
                  ],
                ),
              ),
            ),
          ),
          if (showInlineResults) ...[
            SizedBox(height: 12.h),
            _InlineResultsSection(intent: intent),
          ],
          if (isUser) ...[
            SizedBox(height: 6.h),
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
    final t = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(12.w, 10.h, 12.w, 10.h),
        child: Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _ContextChip(
              label: t.navCart,
              value: t.aiChatCartItemsCount(cartCount),
            ),
            _ContextChip(
              label: t.wishlistTitle,
              value: t.aiChatWishlistSavedCount(wishlistCount),
            ),
          ],
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
        borderRadius: BorderRadius.circular(999.r),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
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
    final t = AppLocalizations.of(context)!;
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
                  t.aiChatSessionsTitle,
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
                label: Text(t.aiChatNewSessionCta),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          DecoratedBox(
            decoration: BoxDecoration(
              color: cs.surface,
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(
                color: cs.outlineVariant.withValues(alpha: 0.55),
              ),
            ),
            child: TextField(
              onChanged: (value) => ref
                  .read(aiChatViewModelProvider.notifier)
                  .updateSearchQuery(value),
              decoration: InputDecoration(
                hintText: t.aiChatSearchSessionsHint,
                prefixIcon: const Icon(Icons.search),
                border: InputBorder.none,
                hintStyle: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: cs.onSurface.withValues(alpha: 0.65),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          SizedBox(height: 12.h),
          Flexible(
            child: ListView.separated(
              itemCount: sessions.length,
              separatorBuilder: (_, __) => SizedBox(height: 10.h),
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
                  borderRadius: BorderRadius.circular(18.r),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: selected
                          ? cs.primary.withValues(alpha: 0.08)
                          : cs.surface,
                      borderRadius: BorderRadius.circular(18.r),
                      border: Border.all(
                        color: cs.outlineVariant.withValues(alpha: 0.55),
                      ),
                    ),
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(14.w, 12.h, 14.w, 12.h),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  session.title == _seedNewChatTitle
                                      ? t.aiChatNewChatTitle
                                      : session.title,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: Theme.of(context).textTheme.titleSmall
                                      ?.copyWith(fontWeight: FontWeight.w900),
                                ),
                                if (preview.isNotEmpty) ...[
                                  SizedBox(height: 4.h),
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
                          SizedBox(width: 10.w),
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
                              SizedBox(height: 6.h),
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
    final t = AppLocalizations.of(context)!;
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
            ).showSnackBar(SnackBar(content: Text(t.aiChatSnackbarCopied)));
          },
          icon: Icon(Icons.copy, size: 16.r),
          label: Text(t.aiChatCopyCta),
        ),
        OutlinedButton.icon(
          style: OutlinedButton.styleFrom(
            textStyle: Theme.of(context).textTheme.labelMedium,
          ),
          onPressed: () =>
              ref.read(aiChatViewModelProvider.notifier).regenerateLast(),
          icon: Icon(Icons.refresh, size: 16.r),
          label: Text(t.aiChatRegenerateCta),
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
    final t = AppLocalizations.of(context)!;
    final products = ref.watch(aiSuggestedProductsProvider);
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: EdgeInsets.zero,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: BorderRadius.circular(22.r),
          boxShadow: AppShadows.md(color: Colors.black.withValues(alpha: 0.10)),
        ),
        child: Padding(
          padding: EdgeInsets.fromLTRB(12.w, 12.h, 12.w, 12.h),
          child: products.when(
            data: (items) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.shopping_bag_outlined,
                      size: 16.r,
                      color: cs.onSurface.withValues(alpha: 0.75),
                    ),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Text(
                        t.aiChatPickedForYouTitle,
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10.h),
                SizedBox(
                  height: 180.h,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: items.length,
                    separatorBuilder: (_, __) => SizedBox(width: 10.w),
                    itemBuilder: (context, index) {
                      final p = items[index];
                      return _InlineProductCard(product: p);
                    },
                  ),
                ),
              ],
            ),
            loading: () => SizedBox(
              height: 180.h,
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
    final t = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;
    final buttonBg = cs.primary.withValues(alpha: 0.10);
    return SizedBox(
      width: 190.w,
      child: InkWell(
        onTap: () => context.push('${AppRoutes.product}?id=${product.id}'),
        borderRadius: BorderRadius.circular(18.r),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: cs.surface,
            borderRadius: BorderRadius.circular(18.r),
            border: Border.all(
              color: cs.outlineVariant.withValues(alpha: 0.55),
            ),
          ),
          child: Padding(
            padding: EdgeInsets.all(10.r),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(14.r),
                    child: AppCachedNetworkImage(
                      url: product.imageUrl,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  product.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: 4.h),
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
                                ? t.aiChatDefaultOption
                                : product.availableColors.first;
                            final size = product.availableSizes.isEmpty
                                ? t.aiChatDefaultOption
                                : product.availableSizes.first;
                            ref
                                .read(cartViewModelProvider.notifier)
                                .add(
                                  product: product,
                                  selectedColor: color,
                                  selectedSize: size,
                                );
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(t.aiChatSnackbarAddedToCart),
                              ),
                            );
                          },
                          borderRadius: BorderRadius.circular(999.r),
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              color: buttonBg,
                              borderRadius: BorderRadius.circular(999.r),
                            ),
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: 10.w,
                                vertical: 6.h,
                              ),
                              child: Text(
                                t.aiChatInlineAddCta,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w900,
                                ),
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
      height: 16.h,
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
              width: 6.r,
              height: 6.r,
              margin: EdgeInsets.only(right: 5.w),
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

class _LandingDataBridge extends ConsumerWidget {
  const _LandingDataBridge({required this.onSend});

  final ValueChanged<String> onSend;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartCount = ref.watch(
      cartItemsProvider.select((items) => items.length),
    );
    final wishlistCount = ref.watch(
      wishlistIdsProvider.select((ids) => ids.length),
    );
    return _ConciergeLanding(
      cartCount: cartCount,
      wishlistCount: wishlistCount,
      onSend: onSend,
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
    final t = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;
    final actions = [
      (
        title: t.aiChatQuickActionFindDealsTitle,
        icon: Icons.local_offer_outlined,
        tint: cs.primary,
        prompt: 'Find me the best deals today under \$50.',
      ),
      (
        title: t.aiChatQuickActionPickOutfitTitle,
        icon: Icons.checkroom_outlined,
        tint: cs.tertiary,
        prompt: 'Build me a clean minimal outfit. Budget \$150.',
      ),
      (
        title: t.aiChatQuickActionGiftIdeasTitle,
        icon: Icons.card_giftcard,
        tint: cs.secondary,
        prompt: 'Gift ideas under \$80. Recipient is 25, minimal style.',
      ),
      (
        title: t.aiChatQuickActionTrackOrderTitle,
        icon: Icons.local_shipping_outlined,
        tint: cs.primary,
        prompt: 'Help me track my last order.',
      ),
    ];

    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 10.h),
      child: Column(
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  cs.primary.withValues(alpha: 0.10),
                  cs.surface,
                  cs.tertiary.withValues(alpha: 0.10),
                ],
              ),
              borderRadius: BorderRadius.circular(24.r),
              boxShadow: AppShadows.md(
                color: Colors.black.withValues(alpha: 0.10),
              ),
              border: Border.all(
                color: cs.outlineVariant.withValues(alpha: 0.55),
              ),
            ),
            child: Padding(
              padding: EdgeInsets.fromLTRB(14.w, 14.h, 14.w, 12.h),
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
                    child: Padding(
                      padding: EdgeInsets.all(10.r),
                      child: Icon(
                        Icons.auto_awesome,
                        size: 18,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          t.aiChatTitle,
                          style: Theme.of(context).textTheme.titleSmall
                              ?.copyWith(fontWeight: FontWeight.w900),
                        ),
                        SizedBox(height: 3.h),
                        Text(
                          t.aiChatSubtitle,
                          style: Theme.of(context).textTheme.labelSmall
                              ?.copyWith(
                                color: cs.onSurface.withValues(alpha: 0.74),
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          t.aiChatLandingPrompt,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: cs.onSurface.withValues(alpha: 0.78),
                                fontWeight: FontWeight.w600,
                                height: 1.22,
                              ),
                        ),
                        SizedBox(height: 10.h),
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
          SizedBox(height: 12.h),
          SizedBox(
            height: 116.h,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: actions.length,
              separatorBuilder: (_, __) => SizedBox(width: 10.w),
              itemBuilder: (context, index) {
                final action = actions[index];
                return _ActionTile(
                  title: action.title,
                  icon: action.icon,
                  tint: action.tint,
                  onTap: () => onSend(action.prompt),
                );
              },
            ),
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
    required this.tint,
    required this.onTap,
  });

  final String title;
  final IconData icon;
  final Color tint;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return SizedBox(
      width: 180.w,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20.r),
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                tint.withValues(alpha: 0.18),
                tint.withValues(alpha: 0.06),
                cs.surface,
              ],
            ),
            borderRadius: BorderRadius.circular(20.r),
            border: Border.all(color: tint.withValues(alpha: 0.30)),
            boxShadow: AppShadows.sm(color: tint.withValues(alpha: 0.22)),
          ),
          child: Padding(
            padding: EdgeInsets.fromLTRB(12.w, 10.h, 12.w, 10.h),
            child: Row(
              children: [
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: cs.surface.withValues(alpha: 0.90),
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(
                      color: cs.outlineVariant.withValues(alpha: 0.42),
                    ),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(7.r),
                    child: Icon(
                      icon,
                      size: 18,
                      color: tint.withValues(alpha: 0.95),
                    ),
                  ),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: Text(
                    title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                      height: 1.1,
                    ),
                  ),
                ),
                SizedBox(width: 4.w),
                Icon(
                  Icons.north_east_rounded,
                  size: 18,
                  color: cs.onSurface.withValues(alpha: 0.68),
                ),
              ],
            ),
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
      padding: EdgeInsets.symmetric(vertical: 10.h),
      child: Center(
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: cs.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(999.r),
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
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

String _formatTime(BuildContext context, DateTime dt) {
  final localizations = MaterialLocalizations.of(context);
  return localizations.formatTimeOfDay(
    TimeOfDay.fromDateTime(dt),
    alwaysUse24HourFormat: MediaQuery.of(context).alwaysUse24HourFormat,
  );
}

const _seedNewChatTitle = 'New chat';

const _seedAssistantMessage =
    'I can help you narrow down fast. Tell me your budget + style + use-case, and I’ll suggest a short set of options.\n\nExample: “black hoodie under \$50, oversized”.';

String _localizedAssistantSeedMessage(AppLocalizations t, String text) {
  if (text == _seedAssistantMessage) return t.aiChatSeedAssistantMessage;
  return text;
}

String _formatDate(DateTime dt) {
  return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
}
