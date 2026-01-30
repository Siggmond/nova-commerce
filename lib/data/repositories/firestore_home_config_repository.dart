import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/repositories/home_config_repository.dart';
import '../datasources/firestore_home_config_datasource.dart';

class FirestoreHomeConfigRepository implements HomeConfigRepository {
  FirestoreHomeConfigRepository(this._dataSource);

  final FirestoreHomeConfigDataSource _dataSource;

  factory FirestoreHomeConfigRepository.fromFirestore(FirebaseFirestore firestore) {
    return FirestoreHomeConfigRepository(FirestoreHomeConfigDataSource(firestore));
  }

  @override
  Stream<Map<String, dynamic>> watchHomeConfig() {
    return _dataSource.watchConfig();
  }
}
