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
  // PROBLEM: ensureInitialized() hides the window via orderOut(nil).
  // waitUntilReadyToShow() waits for Flutter "AppLifecycleState.resumed"
  // to show it again. On VirtualBox this event NEVER fires → window stays
  // hidden forever.
  //
  // FIX: Fire-and-forget the callback (it works on real Mac),
  // then after runApp() add a 300ms fallback that shows the window
  // if the callback hasn't fired yet.
  if (Platform.isMacOS || Platform.isWindows || Platform.isLinux) {
    await windowManager.ensureInitialized();

    const WindowOptions options = WindowOptions(
      size:            Size(1280, 800),
      minimumSize:     Size(760, 520),
      center:          true,
      backgroundColor: Color(0xFF07090D),
      skipTaskbar:     false,
      titleBarStyle:   TitleBarStyle.hidden,
      title:           'UrDown',
    );

    // Primary path: works on real Mac
    windowManager.waitUntilReadyToShow(options, () async {
      await windowManager.show();
      await windowManager.focus();
    });
  }

  // ── 2. Init ────────────────────────────────────────────────────────────
  final dir = await getApplicationSupportDirectory();
  _isar = await Isar.open(
    [DownloadJobSchema, HistoryEntrySchema],
    directory: dir.path,
    inspector: false,
  );

  final settings = await AppSettings.load();
  if (settings.clipboardMonitorEnabled) {
    ClipboardMonitor.instance.start();
  }

  // Non-blocking — must NOT delay runApp()
  GithubConfigService.instance.initBackground().ignore();

  // ── 3. Launch ──────────────────────────────────────────────────────────
  runApp(const ProviderScope(child: UrDownApp()));

  // ── 4. Fallback window show (fixes VirtualBox + any env where
  //       lifecycle events are unreliable) ────────────────────────────────
  // runApp() returns immediately after scheduling widget build.
  // We wait 300 ms for the first frame, then force-show if still hidden.
  if (Platform.isMacOS || Platform.isWindows || Platform.isLinux) {
    await Future.delayed(const Duration(milliseconds: 300));
    final visible = await windowManager.isVisible();
    if (!visible) {
      await windowManager.show();
      await windowManager.focus();
    }
  }
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
