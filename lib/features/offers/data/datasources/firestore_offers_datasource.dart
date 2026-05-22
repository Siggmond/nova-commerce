import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:nova_commerce/features/offers/domain/repositories/offers_repository.dart';

class FirestoreOffersDataSource {
  FirestoreOffersDataSource(this._db);

  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> get _col =>
      _db.collection('offers');

  Query<Map<String, dynamic>> _baseQuery() {
    return _col;
  }

  Query<Map<String, dynamic>> _composeOffersQuery({
    required OffersQuery query,
    required int limit,
    DocumentSnapshot<Map<String, dynamic>>? startAfterDoc,
  }) {
    Query<Map<String, dynamic>> q = _baseQuery();

    final onlyFeatured = query.onlyFeatured;
    if (onlyFeatured == true) {
      q = q.where('isFeatured', isEqualTo: true);
    }

    final channel = query.channel;
    if (channel != null) {
      q = q.where('channels', arrayContains: channel.name);
    }

    final tags = query.tags;
    if (tags != null && tags.isNotEmpty) {
      final unique = tags
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toSet();
      if (unique.isNotEmpty) {
        q = q.where('tags', arrayContainsAny: unique.take(10).toList());
      }
    }

    final text = query.searchText?.trim().toLowerCase();
    if (text != null && text.isNotEmpty) {
      final token = text.split(RegExp(r'\s+')).first;
      if (token.isNotEmpty) {
        q = q.where('searchTokens', arrayContains: token);
      }
    }

    switch (query.sort) {
      case OfferSort.recommended:
        q = q
            .orderBy('isFeatured', descending: true)
            .orderBy('startAt', descending: true);
      case OfferSort.endingSoon:
        q = q.orderBy('endAt');
      case OfferSort.highestDiscount:
        q = q.orderBy('discountValue', descending: true);
      case OfferSort.newest:
        q = q.orderBy('startAt', descending: true);
    }

    q = q.limit(limit);
    if (startAfterDoc != null) {
      q = q.startAfterDocument(startAfterDoc);
    }

    return q;
  }

  Future<QuerySnapshot<Map<String, dynamic>>> fetchOffers({
    required OffersQuery query,
    required int limit,
    DocumentSnapshot<Map<String, dynamic>>? startAfterDoc,
  }) {
    return _composeOffersQuery(
      query: query,
      limit: limit,
      startAfterDoc: startAfterDoc,
    ).get();
  }

  Future<DocumentSnapshot<Map<String, dynamic>>> fetchById(String id) {
    return _col.doc(id).get();
  }
}
