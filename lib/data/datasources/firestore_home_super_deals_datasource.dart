import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreHomeSuperDealsDataSource {
  FirestoreHomeSuperDealsDataSource(this._firestore);

  final FirebaseFirestore _firestore;

  Future<List<String>> fetchSuperDealsProductIds({int limit = 12}) async {
    final primary = await _firestore.doc('home_config/superDeals').get();
    final primaryData = primary.data();

    final doc = (primaryData != null && primaryData.isNotEmpty)
        ? primary
        : await _firestore.doc('home/superDeals').get();
    final data = doc.data();
    final raw = data == null ? null : data['productIds'];
    if (raw is! List) return <String>[];
    final ids = raw
        .whereType<String>()
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
    if (ids.length <= limit) return ids;
    return ids.take(limit).toList(growable: false);
  }
}
