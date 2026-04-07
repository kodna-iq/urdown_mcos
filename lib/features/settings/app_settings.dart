import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppSettings {
  final String outputDirectory;
  final int maxConcurrentDownloads;
  final int bandwidthLimitKBs;
  final bool embedThumbnail;
  final bool addMetadata;
  final bool downloadSubtitlesByDefault;
  final String defaultSubtitleLanguages;
  final String defaultFormat;
  final String defaultResolution;
  final bool clipboardMonitorEnabled;
  final bool notificationsEnabled;
  final bool checkUpdatesOnStartup;
  final ThemeMode themeMode;
  final String appLanguage;

  const AppSettings({
    this.outputDirectory = '',
    this.maxConcurrentDownloads = 3,
    this.bandwidthLimitKBs = 0,
    this.embedThumbnail = true,
    this.addMetadata = true,
    this.downloadSubtitlesByDefault = false,
    this.defaultSubtitleLanguages = 'en',
    this.defaultFormat = 'mp4',
    this.defaultResolution = '1080p',
    this.clipboardMonitorEnabled = true,
    this.notificationsEnabled = true,
    this.checkUpdatesOnStartup = true,
    this.themeMode = ThemeMode.dark,
    this.appLanguage = 'en',
  });

  AppSettings copyWith({
    String? outputDirectory,
    int? maxConcurrentDownloads,
    int? bandwidthLimitKBs,
    bool? embedThumbnail,
    bool? addMetadata,
    bool? downloadSubtitlesByDefault,
    String? defaultSubtitleLanguages,
    String? defaultFormat,
    String? defaultResolution,
    bool? clipboardMonitorEnabled,
    bool? notificationsEnabled,
    bool? checkUpdatesOnStartup,
    ThemeMode? themeMode,
    String? appLanguage,
  }) {
    return AppSettings(
      outputDirectory: outputDirectory ?? this.outputDirectory,
      maxConcurrentDownloads:
          maxConcurrentDownloads ?? this.maxConcurrentDownloads,
      bandwidthLimitKBs: bandwidthLimitKBs ?? this.bandwidthLimitKBs,
      embedThumbnail: embedThumbnail ?? this.embedThumbnail,
      addMetadata: addMetadata ?? this.addMetadata,
      downloadSubtitlesByDefault:
          downloadSubtitlesByDefault ?? this.downloadSubtitlesByDefault,
      defaultSubtitleLanguages:
          defaultSubtitleLanguages ?? this.defaultSubtitleLanguages,
      defaultFormat: defaultFormat ?? this.defaultFormat,
      defaultResolution: defaultResolution ?? this.defaultResolution,
      clipboardMonitorEnabled:
          clipboardMonitorEnabled ?? this.clipboardMonitorEnabled,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      checkUpdatesOnStartup:
          checkUpdatesOnStartup ?? this.checkUpdatesOnStartup,
      themeMode: themeMode ?? this.themeMode,
      appLanguage: appLanguage ?? this.appLanguage,
    );
  }

  static const _keyOutputDir = 'output_dir';
  static const _keyMaxConcurrent = 'max_concurrent';
  static const _keyBandwidth = 'bandwidth_kbs';
  static const _keyEmbedThumb = 'embed_thumbnail';
  static const _keyAddMeta = 'add_metadata';
  static const _keySubsByDefault = 'subs_default';
  static const _keySubLangs = 'sub_languages';
  static const _keyFormat = 'default_format';
  static const _keyResolution = 'default_resolution';
  static const _keyClipboard = 'clipboard_monitor';
  static const _keyNotifs = 'notifications';
  static const _keyUpdates = 'check_updates';
  static const _keyTheme    = 'theme_mode';
  static const _keyLanguage = 'app_language';

  Future<void> save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyOutputDir, outputDirectory);
    await prefs.setInt(_keyMaxConcurrent, maxConcurrentDownloads);
    await prefs.setInt(_keyBandwidth, bandwidthLimitKBs);
    await prefs.setBool(_keyEmbedThumb, embedThumbnail);
    await prefs.setBool(_keyAddMeta, addMetadata);
    await prefs.setBool(_keySubsByDefault, downloadSubtitlesByDefault);
    await prefs.setString(_keySubLangs, defaultSubtitleLanguages);
    await prefs.setString(_keyFormat, defaultFormat);
    await prefs.setString(_keyResolution, defaultResolution);
    await prefs.setBool(_keyClipboard, clipboardMonitorEnabled);
    await prefs.setBool(_keyNotifs, notificationsEnabled);
    await prefs.setBool(_keyUpdates, checkUpdatesOnStartup);
    await prefs.setString(_keyTheme, themeMode.name);
    await prefs.setString(_keyLanguage, appLanguage);
  }

  static Future<AppSettings> load() async {
    final prefs = await SharedPreferences.getInstance();
    final themeName = prefs.getString(_keyTheme) ?? 'dark';
    final theme = ThemeMode.values.firstWhere(
      (t) => t.name == themeName,
      orElse: () => ThemeMode.dark,
    );
    return AppSettings(
      appLanguage: prefs.getString(_keyLanguage) ?? 'en',
      outputDirectory: prefs.getString(_keyOutputDir) ?? '',
      maxConcurrentDownloads: prefs.getInt(_keyMaxConcurrent) ?? 3,
      bandwidthLimitKBs: prefs.getInt(_keyBandwidth) ?? 0,
      embedThumbnail: prefs.getBool(_keyEmbedThumb) ?? true,
      addMetadata: prefs.getBool(_keyAddMeta) ?? true,
      downloadSubtitlesByDefault: prefs.getBool(_keySubsByDefault) ?? false,
      defaultSubtitleLanguages: prefs.getString(_keySubLangs) ?? 'en',
      defaultFormat: prefs.getString(_keyFormat) ?? 'mp4',
      defaultResolution: prefs.getString(_keyResolution) ?? '1080p',
      clipboardMonitorEnabled: prefs.getBool(_keyClipboard) ?? true,
      notificationsEnabled: prefs.getBool(_keyNotifs) ?? true,
      checkUpdatesOnStartup: prefs.getBool(_keyUpdates) ?? true,
      themeMode: theme,
      // NOTE: appLanguage is loaded above and passed correctly.
      // The locale is also persisted separately by LocaleNotifier ('app_locale').
      // Both must stay in sync — see locale_service.dart setLocale().
    );
  }
}
