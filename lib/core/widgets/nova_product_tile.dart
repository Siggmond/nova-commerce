import 'package:flutter/material.dart';

import '../../domain/entities/product.dart';
import 'product_tile_compact.dart';

class NovaProductTile extends StatelessWidget {
  const NovaProductTile({
    super.key,
    required this.product,
    required this.onTap,
    this.isSaved,
    this.onToggleSaved,
  });

  final Product product;
  final VoidCallback onTap;
  final bool? isSaved;
  final VoidCallback? onToggleSaved;

  @override
  Widget build(BuildContext context) {
    return ProductTileCompact(
      product: product,
      onTap: onTap,
      isSaved: isSaved,
      onToggleSaved: onToggleSaved,
    );
  }
}
