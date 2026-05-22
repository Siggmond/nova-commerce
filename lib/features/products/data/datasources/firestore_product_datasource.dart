import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreProductDataSource {
  FirestoreProductDataSource(this._db);

  final FirebaseFirestore _db;

  Future<QuerySnapshot<Map<String, dynamic>>> fetchFeatured({
    int limit = 20,
    DocumentSnapshot<Map<String, dynamic>>? startAfterDoc,
    bool orderByCreatedAt = true,
  }) {
    Query<Map<String, dynamic>> q = _db
        .collection('products')
        .where('featured', isEqualTo: true);

    if (orderByCreatedAt) {
      q = q.orderBy('createdAt', descending: true);
    } else {
      q = q.orderBy(FieldPath.documentId);
    }

    q = q.limit(limit);
    if (startAfterDoc != null) {
      q = q.startAfterDocument(startAfterDoc);
    }
    return q.get();
  }

  Future<DocumentSnapshot<Map<String, dynamic>>> fetchById(String id) {
    return _db.collection('products').doc(id).get();
  }

  Future<QuerySnapshot<Map<String, dynamic>>> fetchByIds(List<String> ids) {
    return _db
        .collection('products')
        .where(FieldPath.documentId, whereIn: ids)
        .get();
  }
}
