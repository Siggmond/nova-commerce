import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ResponsiveTextScale {
  static const double _tinyPhoneMax = 320;
  static const double _smallPhoneMax = 360;
  static const double _compactPhoneMax = 390;

  static double smallPhoneFactorFromShortestSide(double shortestSide) {
    if (shortestSide <= _tinyPhoneMax) return 0.84;
    if (shortestSide <= _smallPhoneMax) return 0.90;
    if (shortestSide <= _compactPhoneMax) return 0.95;
    return 1.0;
  }

  static double screenUtilFactor(ScreenUtil instance) {
    final shortestSide = math.min(instance.screenWidth, instance.screenHeight);
    return smallPhoneFactorFromShortestSide(shortestSide);
  }

  static double resolveSp(num fontSize, ScreenUtil instance) {
    final base = instance.setWidth(fontSize);
    return base * screenUtilFactor(instance);
  }

  static TextScaler clampForMediaQuery(MediaQueryData mq) {
    final shortestSide = math.min(mq.size.width, mq.size.height);
    if (shortestSide <= _compactPhoneMax) {
      return mq.textScaler.clamp(minScaleFactor: 0.82, maxScaleFactor: 0.96);
    }
    return mq.textScaler.clamp(minScaleFactor: 0.90, maxScaleFactor: 1.04);
  }
}
