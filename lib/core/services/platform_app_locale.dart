import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PlatformAppLocale {
  static const MethodChannel _channel = MethodChannel(
    'com.novacommerce.nova_commerce/platform_app_locale',
  );

  static Future<void> setLocale(Locale? locale) async {
    if (kIsWeb) return;

    try {
      final languageTag = locale?.toLanguageTag() ?? '';
      await _channel.invokeMethod<void>('setLocale', <String, Object?>{
        'languageTag': languageTag,
      });
    } catch (_) {
      // Best-effort only.
    }
  }
}
