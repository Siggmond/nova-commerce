import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';

class LocalStorageRuntime {
  LocalStorageRuntime._();

  static Future<void>? _inFlight;
  static bool _initialized = false;

  static Future<void> prime() {
    return ensureInitialized();
  }

  static Future<void> ensureInitialized() {
    if (_initialized) {
      return Future<void>.value();
    }

    final active = _inFlight;
    if (active != null) {
      return active;
    }

    final future = _initialize();
    _inFlight = future;
    return future;
  }

  static Future<void> _initialize() async {
    try {
      await Hive.initFlutter();
      _initialized = true;
    } catch (e) {
      if (!kReleaseMode) {
        debugPrint('LocalStorageRuntime init failed: $e');
      }
      rethrow;
    } finally {
      _inFlight = null;
    }
  }
}
