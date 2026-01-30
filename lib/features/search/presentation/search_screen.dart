import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../core/config/app_routes.dart';
import '../../../core/widgets/product_card.dart';
import '../../../domain/entities/product.dart';
import '../../home/presentation/home_filters.dart';
import '../../wishlist/presentation/wishlist_viewmodel.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key, this.initialQuery = ''});

  final String initialQuery;

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  late final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller.text = widget.initialQuery;
    if (widget.initialQuery.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref
            .read(homeBrowseFiltersProvider.notifier)
            .setQueryImmediate(widget.initialQuery);
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filters = ref.watch(homeBrowseFiltersProvider);
    final query = filters.query;
    final results = ref.watch(homeFilteredProductsProvider);
    final ids = ref.watch(wishlistIdsProvider);

    if (_controller.text != query) {
      _controller
        ..text = query
        ..selection = TextSelection.collapsed(offset: query.length);
    }

    Widget buildResults() {
      if (query.trim().isEmpty) {
        return _EmptyState(
          title: 'Try searching for…',
          subtitle: 'Brands, styles, or product names.',
        );
      }
      if (results.isEmpty) {
        return const _EmptyState(
          title: 'No results',
          subtitle: 'Try a different keyword.',
        );
      }

      return ListView.separated(
        padding: EdgeInsets.fromLTRB(12.w, 6.h, 12.w, 12.h),
        itemCount: results.length,
        separatorBuilder: (_, __) => SizedBox(height: 6.h),
        itemBuilder: (context, index) {
          final product = results[index];
          return _SearchResultCard(
            product: product,
            isSaved: ids.contains(product.id),
            onToggleSaved: () =>
                ref.read(wishlistViewModelProvider.notifier).toggle(product.id),
          );
        },
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Search'),
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(12.w, 6.h, 12.w, 4.h),
            child: TextField(
              controller: _controller,
              autofocus: true,
              onChanged: (value) => ref
                  .read(homeBrowseFiltersProvider.notifier)
                  .setQueryDebounced(value),
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                hintText: 'Search for products',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: query.trim().isEmpty
                    ? null
                    : IconButton(
                        onPressed: () {
                          _controller.clear();
                          ref
                              .read(homeBrowseFiltersProvider.notifier)
                              .setQueryImmediate('');
                        },
                        icon: const Icon(Icons.close),
                      ),
              ),
            ),
          ),
          Expanded(child: buildResults()),
        ],
      ),
    );
  }
}

class _SearchResultCard extends ConsumerWidget {
  const _SearchResultCard({
    required this.product,
    required this.isSaved,
    required this.onToggleSaved,
  });

  final Product product;
  final bool isSaved;
  final VoidCallback onToggleSaved;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SizedBox(
      height: 124.h,
      child: ProductCard(
        product: product,
        onTap: () => context.push('${AppRoutes.product}?id=${product.id}'),
        isSaved: isSaved,
        onToggleSaved: onToggleSaved,
        fillHeight: true,
        forceShowTitle: true,
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.search, size: 44.r, color: cs.outline),
            SizedBox(height: 10.h),
            Text(
              title,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
            ),
            SizedBox(height: 4.h),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: cs.onSurface.withValues(alpha: 0.6),
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
