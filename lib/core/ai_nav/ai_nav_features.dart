class AiNavFeatures {
  const AiNavFeatures({
    required this.f0,
    required this.f1,
    required this.f2,
    required this.f3,
    required this.f4,
  });

  final double f0;
  final double f1;
  final double f2;
  final double f3;
  final double f4;

  List<double> toVector() => <double>[f0, f1, f2, f3, f4];

  static double _clamp01(double v) => v.clamp(0.0, 1.0).toDouble();

  factory AiNavFeatures.fromAppSignals({
    required int currentTabIndex,
    required int tabCount,
    required int cartCount,
    required int wishlistCount,
    required bool isSignedIn,
    required int hourOfDay,
  }) {
    final tabNorm = tabCount <= 1 ? 0.0 : currentTabIndex / (tabCount - 1);
    final cartNorm = _clamp01(cartCount / 20.0);
    final wishlistNorm = _clamp01(wishlistCount / 50.0);
    final signedIn = isSignedIn ? 1.0 : 0.0;
    final hourNorm = _clamp01(hourOfDay / 23.0);

    return AiNavFeatures(
      f0: tabNorm,
      f1: cartNorm,
      f2: wishlistNorm,
      f3: signedIn,
      f4: hourNorm,
    );
  }
}
