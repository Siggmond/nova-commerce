import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreHomeConfigDataSource {
  FirestoreHomeConfigDataSource(this._firestore);

  final FirebaseFirestore _firestore;

  Stream<Map<String, dynamic>> watchConfig() {
    final primary = _firestore.doc('home_config/config').snapshots().map(
          (doc) => (doc.data() ?? <String, dynamic>{}),
        );

    return primary.asyncMap((data) async {
      if (data.isNotEmpty) return data;

      final legacy = await _firestore.doc('home/config').get();
      return legacy.data() ?? <String, dynamic>{};
    });
  }
}
