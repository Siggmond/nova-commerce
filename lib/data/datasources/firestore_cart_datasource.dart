import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreCartDataSource {
  FirestoreCartDataSource(this._db);

  final FirebaseFirestore _db;

  DocumentReference<Map<String, dynamic>> cartDoc(String cartId) {
    return _db.collection('carts').doc(cartId);
  }

  Future<DocumentSnapshot<Map<String, dynamic>>> loadCart(String cartId) {
    return cartDoc(cartId).get();
  }

  Future<void> saveCart(String cartId, Map<String, dynamic> payload) {
    return cartDoc(cartId).set(payload, SetOptions(merge: true));
  }
}
