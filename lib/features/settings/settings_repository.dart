import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app_settings.dart';

// ─── Settings Notifier ────────────────────────────────────────────────────

/// Async notifier that loads [AppSettings] from SharedPreferences on first
/// access and exposes [saveSettings] so any widget can persist changes.
class SettingsNotifier extends AsyncNotifier<AppSettings> {
  @override
  Future<AppSettings> build() => AppSettings.load();

  /// Persist [settings] and update the in-memory state.
  Future<void> saveSettings(AppSettings settings) async {
    await settings.save();
    state = AsyncData(settings);
  }
}

/// Riverpod provider — watch this anywhere you need the current settings.
/// Usage:
///   final settingsAsync = ref.watch(settingsProvider);
///   ref.read(settingsProvider.notifier).saveSettings(updated);
final settingsProvider =
    AsyncNotifierProvider<SettingsNotifier, AppSettings>(SettingsNotifier.new);
