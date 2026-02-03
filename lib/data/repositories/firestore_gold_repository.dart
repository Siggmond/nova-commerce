import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/repositories/gold_repository.dart';

class FirestoreGoldRepository implements GoldRepository {
  FirestoreGoldRepository(this._db, this._uid);

  final FirebaseFirestore _db;
  final String _uid;

  DocumentReference<Map<String, dynamic>> get _userRef {
    return _db.collection('users').doc(_uid);
  }

  DocumentReference<Map<String, dynamic>> _ledgerRef(String orderId) {
    return _userRef.collection('goldLedger').doc(orderId);
  }

  @override
  Stream<int> watchGoldBalance() {
    return _userRef.snapshots().map((snap) {
      final data = snap.data();
      final raw = data == null ? null : data['goldBalance'];
      return (raw is num) ? raw.toInt() : 0;
    });
  }

  @override
  Future<int> getGoldBalance() async {
    final snap = await _userRef.get();
    final data = snap.data();
    final raw = data == null ? null : data['goldBalance'];
    return (raw is num) ? raw.toInt() : 0;
  }

  @override
  Future<int> awardGoldForOrder({
    required String orderId,
    required int goldEarned,
  }) async {
    final oid = orderId.trim();
    if (oid.isEmpty) return getGoldBalance();
    if (goldEarned <= 0) return getGoldBalance();

    return _db.runTransaction<int>((tx) async {
      final ledger = _ledgerRef(oid);
      final ledgerSnap = await tx.get(ledger);

      final userSnap = await tx.get(_userRef);
      final userData = userSnap.data();
      final currentRaw = userData == null ? null : userData['goldBalance'];
      final current = (currentRaw is num) ? currentRaw.toInt() : 0;

      if (ledgerSnap.exists) {
        return current;
      }

      final next = current + goldEarned;

      tx.set(ledger, {
        'orderId': oid,
        'goldEarned': goldEarned,
        'createdAt': FieldValue.serverTimestamp(),
      });

      tx.set(_userRef, {
        'goldBalance': FieldValue.increment(goldEarned),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      return next;
    });
  }
}
