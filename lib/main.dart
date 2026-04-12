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

  if (Platform.isMacOS || Platform.isWindows || Platform.isLinux) {
    await windowManager.ensureInitialized();

    // TitleBarStyle.normal is used intentionally.
    //
    // TitleBarStyle.hidden requires Metal GPU compositing to show content.
    // On VirtualBox (SoftwareGL / no Metal) the window renders blank forever.
    // Using the native title bar bypasses Metal layer compositing entirely,
    // so the window always shows regardless of GPU capabilities.
    //
    // The custom UrDownTitleBar widget is hidden automatically (see
    // urdown_title_bar.dart) when the native title bar is active.
    const WindowOptions options = WindowOptions(
      size:         Size(1280, 800),
      minimumSize:  Size(760, 520),
      center:       true,
      skipTaskbar:  false,
      titleBarStyle: TitleBarStyle.normal,
      title:        'UrDown',
    );

    // waitUntilReadyToShow relies on AppLifecycleState.resumed which never
    // fires on VirtualBox. We apply options then show immediately instead.
    windowManager.waitUntilReadyToShow(options, () async {
      await windowManager.show();
      await windowManager.focus();
    });

    // Immediate fallback — shows the window without waiting for lifecycle.
    await windowManager.show();
    await windowManager.focus();
  }

  // ── Init ───────────────────────────────────────────────────────────────
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

  GithubConfigService.instance.initBackground().ignore();

  // ── Launch ─────────────────────────────────────────────────────────────
  runApp(const ProviderScope(child: UrDownApp()));

  // ── Safety net ─────────────────────────────────────────────────────────
  if (Platform.isMacOS || Platform.isWindows || Platform.isLinux) {
    for (final ms in [300, 800, 1500]) {
      await Future.delayed(Duration(milliseconds: ms));
      if (!await windowManager.isVisible()) {
        await windowManager.show();
        await windowManager.focus();
      }
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
