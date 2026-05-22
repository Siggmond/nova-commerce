import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/services/platform_app_locale.dart';

/// Supported app languages. `system` means follow device locale.
enum AppLanguage { system, en, ar, fr, es }

class AppLocaleController extends StateNotifier<Locale?> {
  AppLocaleController() : super(null) {
    _load();
  }

  static const _prefsKey = 'app_locale_code';

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString(_prefsKey);
    state = _localeFromCode(code);
    await PlatformAppLocale.setLocale(state);
  }

  Locale? _localeFromCode(String? code) {
    if (code == null || code.isEmpty || code == 'system') {
      return null;
    }
    return Locale(code);
  }

  Future<void> setLanguage(AppLanguage language) async {
    final prefs = await SharedPreferences.getInstance();

    Locale? next;

    switch (language) {
      case AppLanguage.system:
        await prefs.remove(_prefsKey);
        next = null;
        state = next;
        await PlatformAppLocale.setLocale(next);
        return;
      case AppLanguage.en:
        await prefs.setString(_prefsKey, 'en');
        next = const Locale('en');
        state = next;
        await PlatformAppLocale.setLocale(next);
        return;
      case AppLanguage.ar:
        await prefs.setString(_prefsKey, 'ar');
        next = const Locale('ar');
        state = next;
        await PlatformAppLocale.setLocale(next);
        return;
      case AppLanguage.fr:
        await prefs.setString(_prefsKey, 'fr');
        next = const Locale('fr');
        state = next;
        await PlatformAppLocale.setLocale(next);
        return;
      case AppLanguage.es:
        await prefs.setString(_prefsKey, 'es');
        next = const Locale('es');
        state = next;
        await PlatformAppLocale.setLocale(next);
        return;
    }
  }
}

/// App-level locale provider. `null` means follow system.
final appLocaleProvider = StateNotifierProvider<AppLocaleController, Locale?>((
  ref,
) {
  return AppLocaleController();
});
