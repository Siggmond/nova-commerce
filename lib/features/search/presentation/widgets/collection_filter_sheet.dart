import 'package:flutter/material.dart';

import 'premium_filter_sheet.dart';

class CollectionFilterSheet extends StatelessWidget {
  const CollectionFilterSheet({super.key, required this.collectionId});

  final String collectionId;

  @override
  Widget build(BuildContext context) {
    return PremiumFilterSheet.collection(collectionId: collectionId);
  }
}
