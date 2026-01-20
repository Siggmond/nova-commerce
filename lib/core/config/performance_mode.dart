import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final performanceModeProvider =
    StateNotifierProvider<PerformanceModeController, bool>((ref) {
      return PerformanceModeController();
    });

class PerformanceModeController extends StateNotifier<bool> {
  PerformanceModeController() : super(false);

  static const _key = 'performance_mode_enabled';

  SharedPreferences? _prefs;

  Future<void> setEnabled(bool enabled) async {
    if (!kDebugMode) return;
    state = enabled;
    try {
      final prefs = _prefs ?? await SharedPreferences.getInstance();
      _prefs = prefs;
      await prefs.setBool(_key, enabled);
    } catch (_) {}
  }
}
