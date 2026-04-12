import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

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

  // ── Window Management ──────────────────────────────────────────────────
  // window_manager.ensureInitialized() calls [NSWindow orderOut:] which hides
  // the window, then waits for AppLifecycleState.resumed before showing it.
  // On VirtualBox this lifecycle event NEVER fires → window stays hidden.
  //
  // Fix: Skip ALL window_manager Dart calls entirely.
  // The native Swift side (MainFlutterWindow.swift + AppDelegate.swift)
  // handles window sizing, positioning, and showing directly via NSWindow APIs.
  // This bypasses the entire broken lifecycle dance.

  // ── Database ───────────────────────────────────────────────────────────
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
