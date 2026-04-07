import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/constants/app_constants.dart';
import '../core/l10n/app_strings.dart';
import '../core/widgets/urdown_logo.dart';
import '../core/widgets/urdown_title_bar.dart';
import '../app/theme.dart';
import '../features/about/about_page.dart';
import '../features/dashboard/dashboard_page.dart';
import '../features/history/history_page.dart';
import '../features/new_download/new_download_page.dart';
import '../features/queue/queue_page.dart';
import '../features/settings/settings_page.dart';
import '../features/settings/settings_repository.dart';
import '../features/settings/youtube_auth_page.dart';
import '../features/update/update_banner.dart';
import '../features/update/binary_update_banner.dart';
import '../services/update_service.dart';
import '../core/engine/binary_update_engine.dart';

// ──────────────────────────────────────────────────────────────────────────────
// Navigation destinations
// ──────────────────────────────────────────────────────────────────────────────

List<NavigationDestination> _bottomDestinations(AppStrings s) => [
  NavigationDestination(
    icon:         const Icon(Icons.home_outlined),
    selectedIcon: const Icon(Icons.home_rounded),
    label:        s.home,
  ),
  NavigationDestination(
    icon:         const Icon(Icons.download_outlined),
    selectedIcon: const Icon(Icons.download_for_offline_rounded),
    label:        s.queue,
  ),
  NavigationDestination(
    icon:         const Icon(Icons.history_outlined),
    selectedIcon: const Icon(Icons.history_rounded),
    label:        s.history,
  ),
  NavigationDestination(
    icon:         const Icon(Icons.tune_outlined),
    selectedIcon: const Icon(Icons.tune_rounded),
    label:        s.settings,
  ),
  NavigationDestination(
    icon:         const Icon(Icons.info_outline_rounded),
    selectedIcon: const Icon(Icons.info_rounded),
    label:        s.aboutApp,
  ),
];

// ──────────────────────────────────────────────────────────────────────────────
// App Shell
// ──────────────────────────────────────────────────────────────────────────────

class _AppShell extends ConsumerStatefulWidget {
  const _AppShell({required this.navigationShell});
  final StatefulNavigationShell navigationShell;

  @override
  ConsumerState<_AppShell> createState() => _AppShellState();
}

class _AppShellState extends ConsumerState<_AppShell> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final settings = await ref.read(settingsProvider.future);
      if (!mounted) return;

      // ── App update check ────────────────────────────────────────────
      if (settings.checkUpdatesOnStartup) {
        await ref.read(updateNotifierProvider.notifier).checkForUpdate(
          currentVersion: AppConstants.appVersion,
        );
      }

      // ── Binary update check (yt-dlp & ffmpeg) — always enabled ─────
      if (mounted) {
        ref.read(binaryUpdateProvider.notifier).checkAndUpdate().ignore();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final s      = ref.watch(stringsProvider);
    final isWide = MediaQuery.sizeOf(context).width >= 720;

    if (isWide) {
      return _WideLayout(
        navigationShell:       widget.navigationShell,
        onDestinationSelected: _navigate,
        s:                     s,
      );
    }
    return _NarrowLayout(
      navigationShell:       widget.navigationShell,
      onDestinationSelected: _navigate,
      s:                     s,
    );
  }

  void _navigate(int index) {
    widget.navigationShell.goBranch(
      index,
      initialLocation: index == widget.navigationShell.currentIndex,
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// Wide layout (desktop ≥ 720 px)
//
// Visual hierarchy (top to bottom):
//   ┌─────────────────────────────────────────────┐
//   │  UrDownTitleBar  (38 px — same as sidebar)  │  ← custom chrome
//   ├─────────────────────────────────────────────┤
//   │  UpdateBanner (animated, hidden when idle)  │  ← update notice
//   ├────────┬────────────────────────────────────┤
//   │ SideNav│  Page content                      │
//   │ (68 px)│                                    │
//   └────────┴────────────────────────────────────┘
//
// The title bar, sidebar, and app background all share AppColors.darkSurface /
// AppColors.darkBg so there are no visible seams — exactly like the NVIDIA App.
// ──────────────────────────────────────────────────────────────────────────────

class _WideLayout extends StatelessWidget {
  const _WideLayout({
    required this.navigationShell,
    required this.onDestinationSelected,
    required this.s,
  });

  final StatefulNavigationShell  navigationShell;
  final void Function(int)       onDestinationSelected;
  final AppStrings               s;

  @override
  Widget build(BuildContext context) {
    final isDark  = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Column(
        children: [
          // ── 1. Custom title bar (replaces native window chrome) ────────
          const UrDownTitleBar(),

          // ── 2. Update notification strips ─────────────────────────────
          const UpdateBanner(),
          const BinaryUpdateBanner(),

          // ── 3. Main area: sidebar + page ──────────────────────────────
          Expanded(
            child: Row(
              children: [
                _SideNav(
                  selectedIndex:         navigationShell.currentIndex,
                  onDestinationSelected: onDestinationSelected,
                  s:                     s,
                ),
                VerticalDivider(
                  width:     1,
                  thickness: 0.5,
                  color:     isDark ? AppColors.darkBorder : AppColors.lightBorder,
                ),
                Expanded(child: navigationShell),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// Narrow layout (mobile / small window)
// ──────────────────────────────────────────────────────────────────────────────

class _NarrowLayout extends StatelessWidget {
  const _NarrowLayout({
    required this.navigationShell,
    required this.onDestinationSelected,
    required this.s,
  });

  final StatefulNavigationShell  navigationShell;
  final void Function(int)       onDestinationSelected;
  final AppStrings               s;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const UrDownTitleBar(),
          const UpdateBanner(),
          const BinaryUpdateBanner(),
          Expanded(child: navigationShell),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex:         navigationShell.currentIndex,
        onDestinationSelected: onDestinationSelected,
        destinations:          _bottomDestinations(s),
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// Side Navigation Rail
// ──────────────────────────────────────────────────────────────────────────────

class _SideNav extends StatelessWidget {
  const _SideNav({
    required this.selectedIndex,
    required this.onDestinationSelected,
    required this.s,
  });
  final int              selectedIndex;
  final void Function(int) onDestinationSelected;
  final AppStrings       s;

  @override
  Widget build(BuildContext context) {
    return NavigationRail(
      selectedIndex:         selectedIndex,
      onDestinationSelected: onDestinationSelected,
      extended:              false,
      minWidth:              68,
      // The small UrDown icon sits above the nav items — same column
      leading: const Padding(
        padding: EdgeInsets.only(top: 10, bottom: 6),
        child:   UrDownIcon(size: 36),
      ),
      destinations: [
        _dest(Icons.home_outlined,          Icons.home_rounded,                s.home),
        _dest(Icons.download_outlined,      Icons.download_for_offline_rounded, s.queue),
        _dest(Icons.history_outlined,       Icons.history_rounded,             s.history),
        _dest(Icons.tune_outlined,          Icons.tune_rounded,                s.settings),
        _dest(Icons.info_outline_rounded,   Icons.info_rounded,                s.aboutApp),
      ],
    );
  }

  NavigationRailDestination _dest(IconData off, IconData on, String label) =>
      NavigationRailDestination(
        icon:         Icon(off),
        selectedIcon: Icon(on),
        label:        Text(label),
      );
}

// ──────────────────────────────────────────────────────────────────────────────
// Router provider
// ──────────────────────────────────────────────────────────────────────────────

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation:     '/',
    debugLogDiagnostics: false,
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (_, __, shell) => _AppShell(navigationShell: shell),
        branches: [
          StatefulShellBranch(routes: [
            GoRoute(path: '/',         name: 'dashboard',
                builder: (_, __) => const DashboardPage()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: '/queue',    name: 'queue',
                builder: (_, __) => const QueuePage()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: '/history',  name: 'history',
                builder: (_, __) => const HistoryPage()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: '/settings', name: 'settings',
                builder: (_, __) => const SettingsPage()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: '/about',    name: 'about',
                builder: (_, __) => const AboutPage()),
          ]),
        ],
      ),
      GoRoute(
        path: '/download/new',
        name: 'download_new',
        builder: (_, state) {
          final url = state.uri.queryParameters['url'];
          return NewDownloadPage(initialUrl: url);
        },
      ),
      GoRoute(
        path:    '/youtube-auth',
        name:    'youtube_auth',
        builder: (_, __) => const YouTubeAuthPage(),
      ),
    ],
  );
});
