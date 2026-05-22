abstract class CheckoutAddressStore {
  Future<Map<String, String>?> loadAddress();

  Future<void> saveAddress(Map<String, String> payload);
}
