import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme.dart';
import '../../core/l10n/app_strings.dart';
import '../download/models/download_job.dart';
import '../download/providers/download_queue_provider.dart';
import '../download/services/download_manager.dart';
import '../download/widgets/download_card.dart';

class QueuePage extends ConsumerWidget {
  const QueuePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark   = Theme.of(context).brightness == Brightness.dark;
    final active   = ref.watch(activeJobsProvider);
    final queued   = ref.watch(queuedJobsProvider);
    final paused   = ref.watch(pausedJobsProvider);
    final failed   = ref.watch(failedJobsProvider);
    final manager  = ref.read(downloadManagerProvider);
    final s        = ref.watch(stringsProvider);

    return Scaffold(
      appBar: AppBar(
        title:   Text(s.queue),
        actions: [
          IconButton(
            icon:    const Icon(Icons.clear_all_rounded, size: 20),
            tooltip: s.clearCompleted,
            onPressed: () => manager.clearCompleted(),
          ),
          IconButton(
            icon:  const Icon(Icons.delete_sweep_rounded, size: 20),
            tooltip: s.deleteAll,
            style: IconButton.styleFrom(foregroundColor: AppColors.error),
            onPressed: () => _showDeleteAllDialog(context, ref, manager, s),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 12, left: 4),
            child: FilledButton.icon(
              onPressed: () => context.goNamed('download_new'),
              icon:      const Icon(Icons.add_rounded, size: 16),
              label:     Text(s.add),
              style: FilledButton.styleFrom(
                padding:     const EdgeInsets.symmetric(horizontal: 14),
                minimumSize: const Size(0, 36),
              ),
            ),
          ),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          const SliverToBoxAdapter(child: SizedBox(height: 4)),

          _Section(
            title:        s.downloading,
            jobsAsync:    active,
            isDark:       isDark,
            icon:         Icons.bolt_rounded,
            iconColor:    AppColors.brand,
            emptyMessage: s.noActiveDownloads,
          ),
          _Section(
            title:        s.queued,
            jobsAsync:    queued,
            isDark:       isDark,
            icon:         Icons.queue_rounded,
            iconColor:    AppColors.info,
            emptyMessage: s.queueIsEmpty,
          ),
          _Section(
            title:     s.paused,
            jobsAsync: paused,
            isDark:    isDark,
            icon:      Icons.pause_circle_outline_rounded,
            iconColor: AppColors.warning,
            showIfEmpty: false,
          ),
          _Section(
            title:     s.failed,
            jobsAsync: failed,
            isDark:    isDark,
            icon:      Icons.error_outline_rounded,
            iconColor: AppColors.error,
            showIfEmpty: false,
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 80)),
        ],
      ),
    );
  }

  Future<void> _showDeleteAllDialog(
    BuildContext context,
    WidgetRef ref,
    DownloadManager manager,
    AppStrings s,
  ) async {
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title:   Text(s.deleteAll),
        content: Text(s.deleteAllQuestion),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, 'cancel'),
            child:     Text(s.cancel),
          ),
          OutlinedButton(
            onPressed: () => Navigator.pop(ctx, 'record'),
            child:     Text(s.removeFromList),
          ),
          FilledButton(
            style:     FilledButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () => Navigator.pop(ctx, 'file'),
            child:     Text(s.deleteFilesToo),
          ),
        ],
      ),
    );

    if (result == null || result == 'cancel') return;

    if (result == 'file') {
      final allJobs = [
        ...?ref.read(activeJobsProvider).value,
        ...?ref.read(queuedJobsProvider).value,
        ...?ref.read(pausedJobsProvider).value,
        ...?ref.read(failedJobsProvider).value,
      ];
      for (final job in allJobs) {
        final resolved = _resolveFile(job.outputPath);
        if (resolved != null) {
          try { await File(resolved).delete(); } catch (_) {}
        }
      }
    }
    await manager.deleteAllJobs();
  }

  String? _resolveFile(String basePath) {
    if (File(basePath).existsSync()) return basePath;
    const exts = ['mp4','mkv','webm','mp3','m4a','opus','flac','wav','ogg','mov','avi'];
    for (final ext in exts) {
      final c = '$basePath.$ext';
      if (File(c).existsSync()) return c;
    }
    return null;
  }
}

// ── Section widget ────────────────────────────────────────────────────────────

class _Section extends StatelessWidget {
  const _Section({
    required this.title,
    required this.jobsAsync,
    required this.isDark,
    required this.icon,
    required this.iconColor,
    this.emptyMessage,
    this.showIfEmpty = true,
  });

  final String                     title;
  final AsyncValue<List<DownloadJob>> jobsAsync;
  final bool                       isDark;
  final IconData                   icon;
  final Color                      iconColor;
  final String?                    emptyMessage;
  final bool                       showIfEmpty;

  @override
  Widget build(BuildContext context) {
    return jobsAsync.when(
      data: (jobs) {
        if (jobs.isEmpty && !showIfEmpty) {
          return const SliverToBoxAdapter(child: SizedBox.shrink());
        }
        return SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Section header row
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color:        iconColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Icon(icon, size: 14, color: iconColor),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    const SizedBox(width: 8),
                    // Count badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(
                        color:        iconColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${jobs.length}',
                        style: TextStyle(
                          fontSize:   11,
                          fontWeight: FontWeight.w700,
                          color:      iconColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Empty state or job list
                if (jobs.isEmpty && emptyMessage != null)
                  _EmptyCard(message: emptyMessage!, isDark: isDark)
                else
                  ...jobs.map((job) => DownloadCard(job: job)),

                const SizedBox(height: 8),
              ],
            ),
          ),
        );
      },
      loading: () => const SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.all(20),
          child:   Center(child: CircularProgressIndicator()),
        ),
      ),
      error: (e, _) => SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child:   Text('$e'),
        ),
      ),
    );
  }
}

// ── Empty Card ────────────────────────────────────────────────────────────────

class _EmptyCard extends StatelessWidget {
  const _EmptyCard({required this.message, required this.isDark});
  final String message;
  final bool   isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      decoration: BoxDecoration(
        color:        isDark ? AppColors.darkCard : AppColors.lightCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          width: 0.5,
        ),
      ),
      child: Center(
        child: Text(
          message,
          style: TextStyle(
            fontSize: 13,
            color:    isDark
                ? AppColors.darkTextSecondary
                : AppColors.lightTextSecondary,
          ),
        ),
      ),
    );
  }
}
