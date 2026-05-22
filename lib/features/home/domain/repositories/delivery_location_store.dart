abstract class DeliveryLocationStore {
  Future<String?> loadCity();

  Future<void> saveCity(String city);
}
