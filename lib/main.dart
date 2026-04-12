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
  // Root cause on VirtualBox:
  //   windowManager.ensureInitialized() calls [NSWindow orderOut:] which
  //   HIDES the window. It then waits for AppLifecycleState.resumed before
  //   showing it again. On VirtualBox this lifecycle event NEVER fires
  //   because the Metal GPU compositor is absent, so the window stays
  //   hidden forever.
  //
  // Fix:
  //   - Skip waitUntilReadyToShow() entirely.
  //   - Configure the window options manually via setSize / setAlignment.
  //   - Call show() + focus() immediately after ensureInitialized().
  //   - The Swift side (MainFlutterWindow) also calls makeKeyAndOrderFront
  //     early so the window is never in a hidden state.
  if (Platform.isMacOS || Platform.isWindows || Platform.isLinux) {
    await windowManager.ensureInitialized();

    // Apply window options without going through waitUntilReadyToShow.
    await windowManager.setSize(const Size(1280, 800));
    await windowManager.setMinimumSize(const Size(760, 520));
    await windowManager.setAlignment(Alignment.center);
    await windowManager.setSkipTaskbar(false);
    await windowManager.setTitleBarStyle(TitleBarStyle.hidden);
    await windowManager.setTitle('UrDown');
    await windowManager.setBackgroundColor(const Color(0xFF07090D));

    // Show immediately — do NOT wait for lifecycle events.
    await windowManager.show();
    await windowManager.focus();
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

  // ── 4. Safety net — re-show after first frame in case anything hid it ─
  if (Platform.isMacOS || Platform.isWindows || Platform.isLinux) {
    await Future.delayed(const Duration(milliseconds: 500));
    if (!await windowManager.isVisible()) {
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
