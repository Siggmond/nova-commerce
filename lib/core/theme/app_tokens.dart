import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AppSpace {
  static double get xxs => 4.r;
  static double get xs => 5.r;
  static double get sm => 8.r;
  static double get md => 12.r;
  static double get lg => 14.r;
  static double get xl => 16.r;
}

class AppInsets {
  static EdgeInsets get screen => EdgeInsets.fromLTRB(12.w, 8.h, 12.w, 14.h);

  static EdgeInsets get screenTight =>
      EdgeInsets.fromLTRB(12.w, 8.h, 12.w, 8.h);

  static EdgeInsets get card => EdgeInsets.all(10.r);

  static EdgeInsets get cardTight => EdgeInsets.all(8.r);

  static EdgeInsets get button =>
      EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h);

  static EdgeInsets get state => EdgeInsets.all(14.r);

  static EdgeInsets h(double v) => EdgeInsets.symmetric(horizontal: v.w);

  static EdgeInsets v(double v) => EdgeInsets.symmetric(vertical: v.h);
}

class AppRadii {
  static double get sm => 9.r;
  static double get md => 12.r;
  static double get lg => 16.r;
  static double get xl => 18.r;
  static double get pill => 999.r;
}

class AppElevation {
  static const double low = 1;
  static const double card = 2;
  static const double floating = 3;
}

class AppHitTargets {
  static const double min = 40;
}
