import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// All languages supported by UrDown.
class SupportedLocales {
  SupportedLocales._();

  static const en = Locale('en');
  static const ar = Locale('ar');
  static const ku = Locale('ku');
  static const zh = Locale('zh');
  static const es = Locale('es');
  static const ru = Locale('ru');

  static const all = [en, ar, zh, es, ru, ku];
  static const _supported = {'en', 'ar', 'ku', 'zh', 'es', 'ru'};

  static Locale resolve(String? languageCode) {
    if (languageCode != null && _supported.contains(languageCode)) {
      return Locale(languageCode);
    }
    return en;
  }

  static const names = {
    'en': 'English',
    'ar': 'عربي',
    'ku': 'کوردی',
    'zh': '中文',
    'es': 'Español',
    'ru': 'Русский',
  };

  static const rtl = {'ar', 'ku'};
  static bool isRtl(String languageCode) => rtl.contains(languageCode);

  /// Localization delegates — includes a fallback for Kurdish (ku)
  /// which is not supported by Flutter's built-in Material localizations.
  static const localizationsDelegates = [
    _KurdishMaterialLocalizationsDelegate(),
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ];
}

// ─── Kurdish fallback delegate ────────────────────────────────────────────
// Flutter's GlobalMaterialLocalizations does not include Kurdish (ku).
// This delegate intercepts 'ku' and returns English Material strings so
// widgets like NavigationRail/AlertDialog don't crash with
// "No MaterialLocalizations found".

class _KurdishMaterialLocalizationsDelegate
    extends LocalizationsDelegate<MaterialLocalizations> {
  const _KurdishMaterialLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => locale.languageCode == 'ku';

  @override
  Future<MaterialLocalizations> load(Locale locale) async =>
      const DefaultMaterialLocalizations();

  @override
  bool shouldReload(_KurdishMaterialLocalizationsDelegate old) => false;
}

// ─── Locale Notifier ─────────────────────────────────────────────────────

class LocaleNotifier extends Notifier<Locale> {
  static const _prefKey        = 'app_language';
  static const _firstLaunchKey = 'locale_first_launch_done';

  @override
  Locale build() {
    _initialize();
    return SupportedLocales.en;
  }

  Future<void> _initialize() async {
    final prefs = await SharedPreferences.getInstance();
    final isFirstLaunch = !(prefs.getBool(_firstLaunchKey) ?? false);

    if (isFirstLaunch) {
      final systemCode = _detectSystemLanguage();
      final detected   = SupportedLocales.resolve(systemCode);
      await prefs.setString(_prefKey, detected.languageCode);
      await prefs.setBool(_firstLaunchKey, true);
      state = detected;
      print('[Locale] First launch — system=$systemCode → app=${detected.languageCode}');
    } else {
      final saved  = prefs.getString(_prefKey);
      final locale = SupportedLocales.resolve(saved);
      state = locale;
      print('[Locale] Loaded saved locale: ${locale.languageCode}');
    }
  }

  String? _detectSystemLanguage() {
    try {
      final raw = Platform.localeName;
      if (raw.isEmpty) return null;
      return raw.split(RegExp(r'[_\-]')).first.toLowerCase();
    } catch (e) {
      print('[Locale] Could not detect system language: $e');
      return null;
    }
  }

  Future<void> setLocale(Locale locale) async {
    state = locale;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefKey, locale.languageCode);
    print('[Locale] User set locale to: ${locale.languageCode}');
  }

  String get languageCode => state.languageCode;
}

final localeProvider =
    NotifierProvider<LocaleNotifier, Locale>(LocaleNotifier.new);
