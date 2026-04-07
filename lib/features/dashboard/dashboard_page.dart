import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme.dart';
import '../../core/l10n/app_strings.dart';
import '../download/providers/download_queue_provider.dart';
import '../download/widgets/download_card.dart';
import '../download/models/download_job.dart';
import '../../services/clipboard_monitor.dart';

// ──────────────────────────────────────────────────────────────────────────────
// DashboardPage
// ──────────────────────────────────────────────────────────────────────────────

class DashboardPage extends ConsumerStatefulWidget {
  const DashboardPage({super.key});

  @override
  ConsumerState<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends ConsumerState<DashboardPage> {
  String?                    _clipboardUrl;
  StreamSubscription<String>? _clipboardSub;

  @override
  void initState() {
    super.initState();
    _clipboardSub = ClipboardMonitor.instance.urlStream.listen((url) {
      if (mounted) setState(() => _clipboardUrl = url);
    });
  }

  @override
  void dispose() {
    _clipboardSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final stats         = ref.watch(downloadStatsProvider);
    final activeJobs    = ref.watch(activeJobsProvider);
    final recentDone    = ref.watch(completedJobsProvider);
    final s             = ref.watch(stringsProvider);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // ── Header area ─────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(28, 28, 28, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _PageHeader(),
                  const SizedBox(height: 20),

                  // Clipboard detection banner
                  if (_clipboardUrl != null) ...[
                    _ClipboardBanner(
                      url:        _clipboardUrl!,
                      onDownload: () {
                        final url = _clipboardUrl!;
                        setState(() => _clipboardUrl = null);
                        ClipboardMonitor.instance.reset();
                        context.pushNamed('download_new',
                            queryParameters: {'url': url});
                      },
                      onDismiss: () {
                        setState(() => _clipboardUrl = null);
                        ClipboardMonitor.instance.reset();
                      },
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Stats row
                  stats.when(
                    data:    (data) => _StatsRow(stats: data),
                    loading: () => const _StatsRowSkeleton(),
                    error:   (_, __) => const SizedBox.shrink(),
                  ),

                  const SizedBox(height: 28),
                  const _QuickAddBox(),
                  const SizedBox(height: 28),
                ],
              ),
            ),
          ),

          // ── Active downloads section ─────────────────────────────────
          SliverToBoxAdapter(
            child: activeJobs.when(
              data: (jobs) {
                if (jobs.isEmpty) return const SizedBox.shrink();
                return Padding(
                  padding: const EdgeInsets.fromLTRB(28, 0, 28, 0),
                  child: _SectionHeader(
                    title:  s.activeDownloads,
                    count:  jobs.length,
                    action: TextButton(
                      onPressed: () => context.goNamed('queue'),
                      child:     Text(s.viewAll),
                    ),
                  ),
                );
              },
              loading: () => const SizedBox.shrink(),
              error:   (_, __) => const SizedBox.shrink(),
            ),
          ),

          activeJobs.when(
            data: (jobs) {
              if (jobs.isEmpty) {
                return const SliverToBoxAdapter(child: SizedBox.shrink());
              }
              return SliverPadding(
                padding: const EdgeInsets.fromLTRB(28, 10, 28, 0),
                sliver: SliverList.separated(
                  itemCount:        jobs.take(3).length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder:      (_, i) => DownloadCard(job: jobs[i]),
                ),
              );
            },
            loading: () => const SliverToBoxAdapter(child: SizedBox.shrink()),
            error:   (_, __) => const SliverToBoxAdapter(child: SizedBox.shrink()),
          ),

          // ── Recently completed section ───────────────────────────────
          SliverToBoxAdapter(
            child: recentDone.when(
              data: (jobs) {
                if (jobs.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.fromLTRB(28, 24, 28, 0),
                    child: _EmptyState(),
                  );
                }
                return Padding(
                  padding: const EdgeInsets.fromLTRB(28, 24, 28, 0),
                  child: _SectionHeader(
                    title:  s.recentlyCompleted,
                    count:  jobs.length,
                    action: TextButton(
                      onPressed: () => context.goNamed('history'),
                      child:     Text(s.viewHistory),
                    ),
                  ),
                );
              },
              loading: () => const SizedBox.shrink(),
              error:   (_, __) => const SizedBox.shrink(),
            ),
          ),

          recentDone.when(
            data: (jobs) {
              if (jobs.isEmpty) {
                return const SliverToBoxAdapter(child: SizedBox.shrink());
              }
              return SliverPadding(
                padding: const EdgeInsets.fromLTRB(28, 10, 28, 60),
                sliver: SliverList.separated(
                  itemCount:        jobs.take(5).length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder:      (_, i) => DownloadCard(job: jobs[i]),
                ),
              );
            },
            loading: () => const SliverToBoxAdapter(child: SizedBox.shrink()),
            error:   (_, __) => const SliverToBoxAdapter(child: SizedBox.shrink()),
          ),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// Page header
// ──────────────────────────────────────────────────────────────────────────────

class _PageHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final s      = AppStrings.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(s.dashboard, style: Theme.of(context).textTheme.headlineLarge),
        const SizedBox(height: 4),
        Text(
          s.manageDownloads,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.lightTextSecondary,
              ),
        ),
      ],
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// Stats row — 4 metric cards, 2×2 on narrow viewports
// ──────────────────────────────────────────────────────────────────────────────

class _StatsRow extends StatelessWidget {
  const _StatsRow({required this.stats});
  final DownloadStats stats;

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    final cards = [
      _StatCard(label: s.total,     value: '${stats.total}',     icon: Icons.download_rounded,     color: AppColors.brand),
      _StatCard(label: s.completed, value: '${stats.completed}', icon: Icons.check_circle_rounded, color: AppColors.success),
      _StatCard(label: s.active,    value: '${stats.active}',    icon: Icons.bolt_rounded,         color: AppColors.info),
      _StatCard(label: s.failed,    value: '${stats.failed}',    icon: Icons.error_rounded,        color: AppColors.error),
    ];

    return LayoutBuilder(
      builder: (_, c) {
        if (c.maxWidth < 380) {
          return Column(children: [
            Row(children: [
              Expanded(child: cards[0]),
              const SizedBox(width: 12),
              Expanded(child: cards[1]),
            ]),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(child: cards[2]),
              const SizedBox(width: 12),
              Expanded(child: cards[3]),
            ]),
          ]);
        }
        return Row(children: [
          Expanded(child: cards[0]), const SizedBox(width: 12),
          Expanded(child: cards[1]), const SizedBox(width: 12),
          Expanded(child: cards[2]), const SizedBox(width: 12),
          Expanded(child: cards[3]),
        ]);
      },
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });
  final String  label;
  final String  value;
  final IconData icon;
  final Color   color;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color:        isDark ? AppColors.darkCard : AppColors.lightCard,
        borderRadius: BorderRadius.circular(14),
        border:       Border.all(color: color.withValues(alpha: 0.2), width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color:        color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 15, color: color),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  fontSize:   26,
                  color:      isDark ? AppColors.darkText : AppColors.lightText,
                ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.lightTextSecondary,
                ),
          ),
        ],
      ),
    );
  }
}

class _StatsRowSkeleton extends StatelessWidget {
  const _StatsRowSkeleton();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      children: List.generate(4, (i) => Expanded(
        child: Padding(
          padding: EdgeInsets.only(right: i < 3 ? 12.0 : 0),
          child: Container(
            height: 92,
            decoration: BoxDecoration(
              color:        isDark ? AppColors.darkCard : AppColors.lightCard,
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        ),
      )),
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// Quick-add URL box
// ──────────────────────────────────────────────────────────────────────────────

class _QuickAddBox extends ConsumerStatefulWidget {
  const _QuickAddBox();

  @override
  ConsumerState<_QuickAddBox> createState() => _QuickAddBoxState();
}

class _QuickAddBoxState extends ConsumerState<_QuickAddBox> {
  final _ctrl = TextEditingController();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final s      = ref.watch(stringsProvider);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color:        isDark ? AppColors.darkCard : AppColors.lightCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          width: 0.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(s.downloadAVideo, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 4),
          Text(s.pasteUrlHint,   style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _ctrl,
                  decoration: InputDecoration(
                    hintText: 'https://youtube.com/watch?v=...',
                    prefixIcon: const Icon(Icons.link_rounded, size: 18),
                    suffixIcon: _ctrl.text.isNotEmpty
                        ? IconButton(
                            icon:    const Icon(Icons.close_rounded, size: 16),
                            onPressed: () {
                              _ctrl.clear();
                              setState(() {});
                            },
                          )
                        : null,
                  ),
                  onChanged:   (_) => setState(() {}),
                  onSubmitted: _submit,
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton.icon(
                onPressed: _ctrl.text.isNotEmpty
                    ? () => _submit(_ctrl.text)
                    : null,
                icon:  const Icon(Icons.download_rounded, size: 18),
                label: Text(s.download),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _submit(String url) {
    if (url.trim().isEmpty) return;
    context.pushNamed('download_new', queryParameters: {'url': url.trim()});
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// Clipboard banner — fully theme-aware, no hardcoded dark colours
// ──────────────────────────────────────────────────────────────────────────────

class _ClipboardBanner extends StatelessWidget {
  const _ClipboardBanner({
    required this.url,
    required this.onDownload,
    required this.onDismiss,
  });
  final String       url;
  final VoidCallback onDownload;
  final VoidCallback onDismiss;

  static bool _isLive(String url) {
    final u = url.toLowerCase();
    return u.contains('/live') ||
        u.contains('twitch.tv') ||
        (u.contains('tiktok.com') && u.contains('live')) ||
        u.contains('fb.watch') ||
        (u.contains('facebook.com') && u.contains('/live'));
  }

  @override
  Widget build(BuildContext context) {
    final isDark   = Theme.of(context).brightness == Brightness.dark;
    final s        = AppStrings.of(context);
    final isLive   = _isLive(url);
    final accent   = isLive ? AppColors.error : AppColors.brand;
    final urlColor = isDark
        ? AppColors.darkTextSecondary
        : AppColors.lightTextSecondary;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color:        accent.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border:       Border.all(color: accent.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          Icon(
            isLive ? Icons.live_tv_rounded : Icons.content_paste_rounded,
            size: 18, color: accent,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isLive ? 'Live stream detected' : s.linkDetected,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize:   13,
                    color:      accent,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  url,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 11.5, color: urlColor),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          TextButton(
            onPressed: onDownload,
            style: TextButton.styleFrom(
              foregroundColor: accent,
              textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            ),
            child: Text(isLive ? 'Record' : s.download),
          ),
          IconButton(
            onPressed:   onDismiss,
            icon:        const Icon(Icons.close_rounded, size: 16),
            color:       isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
            visualDensity: VisualDensity.compact,
          ),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// Section header
// ──────────────────────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    required this.count,
    this.action,
  });
  final String  title;
  final int     count;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      children: [
        Text(title, style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color:        isDark ? AppColors.darkBorder : AppColors.lightBorder,
            borderRadius: BorderRadius.circular(99),
          ),
          child: Text(
            '$count',
            style: TextStyle(
              fontSize: 11,
              color:    isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.lightTextSecondary,
            ),
          ),
        ),
        const Spacer(),
        if (action != null) action!,
      ],
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// Empty state
// ──────────────────────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final s      = AppStrings.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 60),
      child: Center(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color:        isDark ? AppColors.darkCard : AppColors.lightCard,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                  width: 0.5,
                ),
              ),
              child: Icon(
                Icons.download_rounded,
                size:  40,
                color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              s.noDownloadsYet,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.lightTextSecondary,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              s.pasteToStart,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
