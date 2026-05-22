abstract class GoldRepository {
  Stream<int> watchGoldBalance();

  Future<int> getGoldBalance();

  Future<int> awardGoldForOrder({
    required String orderId,
    required int goldEarned,
  });
}
