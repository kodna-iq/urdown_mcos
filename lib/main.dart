import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:window_manager/window_manager.dart';

import 'app/router.dart';
import 'app/theme.dart';
import 'core/l10n/locale_service.dart';
import 'features/download/models/download_job.dart';
import 'features/history/models/history_entry.dart';
import 'services/clipboard_monitor.dart';
import 'services/github/github_config_service.dart';
import 'features/settings/app_settings.dart';

late final Isar _isar;
final isarProvider = Provider<Isar>((ref) => _isar);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ── 1. Window Manager ─────────────────────────────────────────────────
  // CRITICAL: ensureInitialized() must be called first.
  // waitUntilReadyToShow must NOT be awaited — doing so creates a deadlock:
  //   - waitUntilReadyToShow waits for Flutter engine "ready" signal
  //   - "ready" signal fires only after runApp() attaches the widget tree
  //   - but runApp() is blocked by the await → deadlock → blank window
  // Solution: fire-and-forget, let callback run after runApp().
  if (Platform.isMacOS || Platform.isWindows || Platform.isLinux) {
    await windowManager.ensureInitialized();

    const options = WindowOptions(
      size:            Size(1280, 800),
      minimumSize:     Size(760, 520),
      center:          true,
      backgroundColor: Color(0xFF07090D),
      skipTaskbar:     false,
      titleBarStyle:   TitleBarStyle.hidden,
      title:           'UrDown',
    );

    // Fire-and-forget — NEVER await this before runApp()
    windowManager.waitUntilReadyToShow(options, () async {
      await windowManager.show();
      await windowManager.focus();
    });
  }

  // ── 2. Start runApp immediately — background tasks come AFTER ──────────
  // On macOS the window only appears after runApp() signals engine-ready.
  // Move all heavy init to background AFTER runApp(), or do it quickly here.

  // Database — fast, keep here
  final dir = await getApplicationSupportDirectory();
  _isar = await Isar.open(
    [DownloadJobSchema, HistoryEntrySchema],
    directory: dir.path,
    inspector: false,
  );

  // Settings — fast, keep here
  final settings = await AppSettings.load();

  // Clipboard monitor — synchronous start
  if (settings.clipboardMonitorEnabled) {
    ClipboardMonitor.instance.start();
  }

  // GitHub config — non-blocking, must NOT block runApp
  GithubConfigService.instance.initBackground().ignore();

  // ── 3. Launch ──────────────────────────────────────────────────────────
  runApp(const ProviderScope(child: UrDownApp()));
}

class UrDownApp extends ConsumerWidget {
  const UrDownApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router    = ref.watch(appRouterProvider);
    final themeMode = ref.watch(themeModeProvider);
    final locale    = ref.watch(localeProvider);

    return MaterialApp.router(
      title:                     'UrDown',
      debugShowCheckedModeBanner: false,
      theme:                     AppTheme.light,
      darkTheme:                 AppTheme.dark,
      themeMode:                 themeMode,
      locale:                    locale,
      supportedLocales:          SupportedLocales.all,
      localizationsDelegates:    SupportedLocales.localizationsDelegates,
      routerConfig:              router,
    );
  }
}
