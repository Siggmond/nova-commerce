enum PaymentMethodType { stripe, paypal }

class PaymentMethod {
  const PaymentMethod({
    required this.type,
    required this.title,
    required this.subtitle,
  });

  final PaymentMethodType type;
  final String title;
  final String subtitle;
}
