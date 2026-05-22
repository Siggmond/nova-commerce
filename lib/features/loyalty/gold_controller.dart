import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:nova_commerce/app/config/app_env.dart';
import 'package:nova_commerce/app/di/app_providers.dart';
import 'package:nova_commerce/features/auth/auth.dart';
import 'package:nova_commerce/features/loyalty/data/datasources/shared_prefs_gold_datasource.dart';
import 'package:nova_commerce/features/loyalty/data/repositories/firestore_gold_repository.dart';
import 'package:nova_commerce/features/loyalty/data/repositories/shared_prefs_gold_repository.dart';
import 'package:nova_commerce/features/loyalty/domain/repositories/gold_repository.dart';

int goldEarnedFromOrderTotal(double orderTotal) {
  if (orderTotal <= 0) return 0;
  final earned = (orderTotal / 10).floor();
  return earned <= 0 ? 1 : earned;
}

final goldRepositoryProvider = Provider<GoldRepository>((ref) {
  final local = SharedPrefsGoldRepository(SharedPrefsGoldDataSource());
  if (AppEnv.useFakeRepos) return local;

  final user = ref.watch(authUserProvider).valueOrNull;
  final uid = user?.uid;
  if (uid == null || uid.trim().isEmpty) {
    debugPrint('GoldRepository: Local (no uid)');
    return local;
  }
  if (user is AuthUser && user.isAnonymous) {
    debugPrint('GoldRepository: Local (anonymous)');
    return local;
  }

  debugPrint('GoldRepository: Firestore (uid=${uid.trim()})');
  return FirestoreGoldRepository(FirebaseFirestore.instance, uid.trim());
});

final goldSourceLabelProvider = Provider<String>((ref) {
  if (AppEnv.useFakeRepos) return 'Local';

  final user = ref.watch(authUserProvider).valueOrNull;
  final uid = user?.uid;
  if (uid == null || uid.trim().isEmpty) return 'Local';
  if (user is AuthUser && user.isAnonymous) return 'Local';
  return 'Firestore';
});

final goldControllerProvider =
    StateNotifierProvider<GoldController, AsyncValue<int>>((ref) {
      final repo = ref.watch(goldRepositoryProvider);
      return GoldController(repo);
    });

final goldBalanceProvider = Provider<AsyncValue<int>>((ref) {
  return ref.watch(goldControllerProvider);
});

class GoldController extends StateNotifier<AsyncValue<int>> {
  GoldController(this._repo) : super(const AsyncValue<int>.loading()) {
    _load();
  }

  final GoldRepository _repo;

  Future<void> _load() async {
    try {
      final balance = await _repo.getGoldBalance();
      state = AsyncValue<int>.data(balance);
    } catch (e, st) {
      state = AsyncValue<int>.error(e, st);
    }
  }

  Future<int> awardForOrder({
    required String orderId,
    required double orderTotal,
  }) async {
    final earned = goldEarnedFromOrderTotal(orderTotal);
    if (earned <= 0) {
      final balance = await _repo.getGoldBalance();
      state = AsyncValue<int>.data(balance);
      return 0;
    }

    final balance = await _repo.awardGoldForOrder(
      orderId: orderId,
      goldEarned: earned,
    );
    state = AsyncValue<int>.data(balance);
    return earned;
  }
}
