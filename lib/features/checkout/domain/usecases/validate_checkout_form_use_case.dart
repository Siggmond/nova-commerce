class CheckoutValidationInput {
  const CheckoutValidationInput({
    required this.fullName,
    required this.phone,
    required this.address,
    required this.city,
    required this.country,
  });

  final String fullName;
  final String phone;
  final String address;
  final String city;
  final String country;
}

class CheckoutValidationResult {
  const CheckoutValidationResult({
    required this.fullNameMissing,
    required this.phoneMissing,
    required this.addressMissing,
    required this.cityMissing,
    required this.countryMissing,
  });

  final bool fullNameMissing;
  final bool phoneMissing;
  final bool addressMissing;
  final bool cityMissing;
  final bool countryMissing;

  bool get hasErrors =>
      fullNameMissing ||
      phoneMissing ||
      addressMissing ||
      cityMissing ||
      countryMissing;
}

class ValidateCheckoutFormUseCase {
  const ValidateCheckoutFormUseCase();

  CheckoutValidationResult call(CheckoutValidationInput input) {
    return CheckoutValidationResult(
      fullNameMissing: input.fullName.trim().isEmpty,
      phoneMissing: input.phone.trim().isEmpty,
      addressMissing: input.address.trim().isEmpty,
      cityMissing: input.city.trim().isEmpty,
      countryMissing: input.country.trim().isEmpty,
    );
  }
}
