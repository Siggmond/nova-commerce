import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/repositories/home_super_deals_repository.dart';
import '../datasources/firestore_home_super_deals_datasource.dart';

class FirestoreHomeSuperDealsRepository implements HomeSuperDealsRepository {
  FirestoreHomeSuperDealsRepository(this._dataSource);

  final FirestoreHomeSuperDealsDataSource _dataSource;

  factory FirestoreHomeSuperDealsRepository.fromFirestore(
    FirebaseFirestore firestore,
  ) {
    return FirestoreHomeSuperDealsRepository(
      FirestoreHomeSuperDealsDataSource(firestore),
    );
  }

  @override
  Future<List<String>> fetchSuperDealsProductIds() {
    return _dataSource.fetchSuperDealsProductIds();
  }
}
