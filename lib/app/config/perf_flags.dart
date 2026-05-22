import 'package:flutter/foundation.dart';

class PerfFlags {
  static const bool enabled = bool.fromEnvironment('PERF', defaultValue: false);

  static bool get isActive => enabled && !kReleaseMode;
}
