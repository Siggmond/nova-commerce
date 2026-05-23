import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AppSpace {
  static double get xxs => 4.r;
  static double get xs => 5.r;
  static double get sm => 8.r;
  static double get md => 12.r;
  static double get lg => 14.r;
  static double get xl => 16.r;
  static double get xxl => 20.r;
  static double get section => 24.r;
}

class AppInsets {
  static EdgeInsets get screen => EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 16.h);

  static EdgeInsets get screenTight =>
      EdgeInsets.fromLTRB(12.w, 10.h, 12.w, 10.h);

  static EdgeInsets get card => EdgeInsets.all(16.r);

  static EdgeInsets get cardTight => EdgeInsets.all(12.r);

  static EdgeInsets get button =>
      EdgeInsets.symmetric(horizontal: 16.w, vertical: 11.h);

  static EdgeInsets get state => EdgeInsets.all(24.r);

  static EdgeInsets h(double v) => EdgeInsets.symmetric(horizontal: v.w);

  static EdgeInsets v(double v) => EdgeInsets.symmetric(vertical: v.h);
}

class AppRadii {
  static double get sm => 10.r;
  static double get md => 12.r;
  static double get lg => 16.r;
  static double get xl => 20.r;
  static double get pill => 999.r;
}

class AppElevation {
  static const double low = 0.5;
  static const double card = 1;
  static const double floating = 2;
}

class AppHitTargets {
  static double get min => 44.r;
  static double get comfortable => 48.r;
}
