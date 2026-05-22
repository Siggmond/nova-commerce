import '../entities/payment_method.dart';
import '../entities/payment_result.dart';

abstract class PaymentRepository {
  List<PaymentMethod> supportedMethods();

  Future<PaymentResult> pay({
    required PaymentMethodType method,
    required String uid,
    required String deviceId,
    required Map<String, String> shipping,
  });
}
