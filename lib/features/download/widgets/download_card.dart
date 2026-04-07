import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart'
    hide DownloadProgress;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../app/theme.dart';
import '../../../core/l10n/app_strings.dart';
import '../models/download_job.dart';
import '../providers/download_queue_provider.dart';
import '../services/download_manager.dart';

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// DownloadCard  — rich card for a single download job
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

class DownloadCard extends ConsumerWidget {
  const DownloadCard({required this.job, super.key});
  final DownloadJob job;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progress = ref.watch(jobProgressProvider(job.jobId));
    final isDark   = Theme.of(context).brightness == Brightness.dark;
    final s        = ref.watch(stringsProvider);

    // Derive a subtle left-border accent colour based on status
    final accentColor = _statusAccent(job.status);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color:        isDark ? AppColors.darkCard : AppColors.lightCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          width: 0.5,
        ),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color:       Colors.black.withValues(alpha: 0.04),
                  blurRadius:  8,
                  offset:      const Offset(0, 2),
                ),
              ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Coloured left accent stripe
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: 3,
                color: accentColor.withValues(alpha: 0.6),
              ),

              // Card body
              Expanded(
                child: Column(
                  children: [
                    // ── Main row ──────────────────────────────────────────
                    Padding(
                      padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _Thumbnail(url: job.thumbnailUrl),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _JobInfo(
                              job:      job,
                              progress: progress,
                              isDark:   isDark,
                              s:        s,
                            ),
                          ),
                          const SizedBox(width: 6),
                          _ActionButtons(job: job),
                        ],
                      ),
                    ),

                    // ── Progress bar ──────────────────────────────────────
                    if (job.isActive || job.isQueued)
                      _ProgressSection(
                        job:      job,
                        progress: progress,
                        isDark:   isDark,
                      ),

                    // ── Error banner ──────────────────────────────────────
                    if (job.isFailed && job.errorMessage != null)
                      _ErrorBanner(message: job.errorMessage!),

                    // ── Completed actions ─────────────────────────────────
                    if (job.isCompleted)
                      _CompletedActions(job: job, s: s),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _statusAccent(DownloadStatus status) => switch (status) {
    DownloadStatus.active    => AppColors.brand,
    DownloadStatus.queued    => AppColors.info,
    DownloadStatus.paused    => AppColors.warning,
    DownloadStatus.completed => AppColors.success,
    DownloadStatus.failed    => AppColors.error,
    DownloadStatus.cancelled => AppColors.darkTextMuted,
  };
}

// ── Job Info (title, status, badges) ─────────────────────────────────────────

class _JobInfo extends StatelessWidget {
  const _JobInfo({
    required this.job,
    required this.progress,
    required this.isDark,
    required this.s,
  });
  final DownloadJob       job;
  final DownloadProgress  progress;
  final bool              isDark;
  final AppStrings        s;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title
        Text(
          job.title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
                height:     1.35,
              ),
        ),
        const SizedBox(height: 5),

        // Status chip + channel name
        Row(
          children: [
            _StatusChip(status: job.status, s: s),
            if (job.channelName != null) ...[
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  job.channelName!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.lightTextSecondary,
                      ),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 6),

        // Info badges row
        Wrap(
          spacing:    5,
          runSpacing: 4,
          children: [
            _Badge(label: job.format.toUpperCase(), isDark: isDark),
            _Badge(label: job.resolution, isDark: isDark),
            if (job.isActive && progress.speed.isNotEmpty)
              _Badge(
                label:  progress.speed,
                isDark: isDark,
                color:  AppColors.brand,
              ),
            if (job.isActive && progress.eta.isNotEmpty)
              _Badge(
                label:  'ETA ${progress.eta}',
                isDark: isDark,
              ),
          ],
        ),
      ],
    );
  }
}

// ── Progress Section ──────────────────────────────────────────────────────────

class _ProgressSection extends StatelessWidget {
  const _ProgressSection({
    required this.job,
    required this.progress,
    required this.isDark,
  });
  final DownloadJob      job;
  final DownloadProgress progress;
  final bool             isDark;

  @override
  Widget build(BuildContext context) {
    final pct = (progress.percent / 100).clamp(0.0, 1.0);

    return Padding(
      padding: const EdgeInsets.fromLTRB(15, 0, 12, 12),
      child: Column(
        children: [
          // Animated progress bar
          TweenAnimationBuilder<double>(
            duration: const Duration(milliseconds: 400),
            curve:    Curves.easeOut,
            tween:    Tween(begin: 0, end: job.isQueued ? 0.0 : pct),
            builder:  (_, v, __) => ClipRRect(
              borderRadius: BorderRadius.circular(3),
              child: LinearProgressIndicator(
                value:           job.isQueued ? null : v,
                minHeight:       5,
                backgroundColor: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                valueColor:      const AlwaysStoppedAnimation(AppColors.brand),
              ),
            ),
          ),

          // Stats row (only while actively downloading)
          if (job.isActive) ...[
            const SizedBox(height: 5),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Text(
                    '${progress.percent.toStringAsFixed(1)}%'
                    '${progress.totalSize.isNotEmpty ? "  ·  ${progress.totalSize}" : ""}',
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: isDark
                              ? AppColors.darkTextMuted
                              : AppColors.lightTextMuted,
                        ),
                  ),
                ),
                if (progress.fragment != null)
                  Text(
                    'Part ${progress.fragment}',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: isDark
                              ? AppColors.darkTextMuted
                              : AppColors.lightTextMuted,
                        ),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

// ── Error Banner ──────────────────────────────────────────────────────────────

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(15, 0, 12, 12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        decoration: BoxDecoration(
          color:        AppColors.error.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(8),
          border:       Border.all(color: AppColors.error.withValues(alpha: 0.25)),
        ),
        child: Row(
          children: [
            const Icon(Icons.error_outline_rounded, size: 14, color: AppColors.error),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 12, color: AppColors.error, height: 1.4),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Completed Actions ─────────────────────────────────────────────────────────

class _CompletedActions extends StatelessWidget {
  const _CompletedActions({required this.job, required this.s});
  final DownloadJob job;
  final AppStrings  s;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(15, 0, 12, 12),
      child: Row(
        children: [
          _CompletedBtn(
            icon:    Icons.folder_open_rounded,
            label:   s.showFile,
            onTap:   () => _revealFile(job.outputPath),
          ),
          const SizedBox(width: 8),
          _CompletedBtn(
            icon:    Icons.play_circle_outline_rounded,
            label:   s.play,
            onTap:   () => _openFile(job.outputPath),
            primary: true,
          ),
        ],
      ),
    );
  }

  String? _resolve(String basePath) {
    if (File(basePath).existsSync()) return basePath;
    const exts = ['mp4', 'mkv', 'webm', 'mp3', 'm4a', 'opus', 'flac', 'wav', 'ogg', 'mov', 'avi'];
    for (final ext in exts) {
      final c = '$basePath.$ext';
      if (File(c).existsSync()) return c;
    }
    try {
      final dir  = Directory(File(basePath).parent.path);
      final base = File(basePath).uri.pathSegments.last;
      if (dir.existsSync()) {
        final matches = dir.listSync().whereType<File>()
            .where((f) => f.path.contains(base))
            .toList();
        if (matches.isNotEmpty) return matches.first.path;
      }
    } catch (_) {}
    return null;
  }

  Future<void> _revealFile(String path) async {
    final target = (_resolve(path) ?? path).replaceAll('/', '\\');
    try {
      if (Platform.isWindows) {
        await Process.start('explorer.exe', ['/select,', target]);
      } else if (Platform.isMacOS) {
        await Process.start('open', ['-R', _resolve(path) ?? path]);
      } else {
        await Process.start('xdg-open', [File(path).parent.path]);
      }
    } catch (_) {
      await launchUrl(Uri.directory(File(path).parent.path));
    }
  }

  Future<void> _openFile(String path) async {
    final file = _resolve(path);
    if (file != null) await launchUrl(Uri.file(file));
  }
}

// ── Thumbnail ─────────────────────────────────────────────────────────────────

class _Thumbnail extends StatelessWidget {
  const _Thumbnail({this.url});
  final String? url;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: SizedBox(
        width: 76,
        height: 54,
        child: url != null
            ? CachedNetworkImage(
                imageUrl:    url!,
                fit:         BoxFit.cover,
                placeholder: (_, __) => const _ThumbnailPlaceholder(),
                errorWidget: (_, __, ___) => const _ThumbnailPlaceholder(),
              )
            : const _ThumbnailPlaceholder(),
      ),
    );
  }
}

class _ThumbnailPlaceholder extends StatelessWidget {
  const _ThumbnailPlaceholder();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
      child: Center(
        child: Icon(
          Icons.movie_outlined,
          size:  22,
          color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
        ),
      ),
    );
  }
}

// ── Status Chip ───────────────────────────────────────────────────────────────

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status, required this.s});
  final DownloadStatus status;
  final AppStrings     s;

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (status) {
      DownloadStatus.active    => (s.statusDownloading, AppColors.brand),
      DownloadStatus.queued    => (s.statusQueued,      AppColors.info),
      DownloadStatus.paused    => (s.statusPaused,      AppColors.warning),
      DownloadStatus.completed => (s.statusDone,        AppColors.success),
      DownloadStatus.failed    => (s.statusFailed,      AppColors.error),
      DownloadStatus.cancelled => (s.statusCancelled,   AppColors.darkTextMuted),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color:        color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize:   10,
          fontWeight: FontWeight.w700,
          color:      color,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}

// ── Info Badge ────────────────────────────────────────────────────────────────

class _Badge extends StatelessWidget {
  const _Badge({required this.label, required this.isDark, this.color});
  final String  label;
  final bool    isDark;
  final Color?  color;

  @override
  Widget build(BuildContext context) {
    final fg = color ??
        (isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color != null
            ? color!.withValues(alpha: 0.12)
            : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize:   10,
          color:      fg,
          fontWeight: color != null ? FontWeight.w600 : FontWeight.w400,
        ),
      ),
    );
  }
}

// ── Completed Btn ─────────────────────────────────────────────────────────────

class _CompletedBtn extends StatelessWidget {
  const _CompletedBtn({
    required this.icon,
    required this.label,
    required this.onTap,
    this.primary = false,
  });
  final IconData     icon;
  final String       label;
  final VoidCallback onTap;
  final bool         primary;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Expanded(
      child: InkWell(
        onTap:        onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 7),
          decoration: BoxDecoration(
            color: primary
                ? AppColors.brand.withValues(alpha: 0.1)
                : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
            borderRadius: BorderRadius.circular(8),
            border: primary
                ? Border.all(color: AppColors.brand.withValues(alpha: 0.3))
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 14, color: AppColors.brand),
              const SizedBox(width: 5),
              Text(
                label,
                style: const TextStyle(
                  fontSize:   12,
                  color:      AppColors.brand,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Action Buttons ────────────────────────────────────────────────────────────

class _ActionButtons extends ConsumerWidget {
  const _ActionButtons({required this.job});
  final DownloadJob job;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final manager = ref.read(downloadManagerProvider);
    final s       = ref.watch(stringsProvider);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (job.isActive)
          _IconBtn(
            icon:    Icons.pause_rounded,
            tooltip: s.pause,
            onTap:   () => manager.pause(job.jobId),
          ),
        if (job.isPaused)
          _IconBtn(
            icon:    Icons.play_arrow_rounded,
            tooltip: s.resume,
            onTap:   () => manager.resume(job.jobId),
            color:   AppColors.brand,
          ),
        if (job.isFailed)
          _IconBtn(
            icon:    Icons.refresh_rounded,
            tooltip: s.retry,
            onTap:   () => manager.retry(job.jobId),
            color:   AppColors.warning,
          ),
        if (!job.isCompleted)
          _IconBtn(
            icon:    Icons.close_rounded,
            tooltip: s.cancel,
            onTap:   () => manager.cancel(job.jobId),
          ),
        _IconBtn(
          icon:    Icons.delete_outline_rounded,
          tooltip: s.deleteTitle,
          onTap:   () => _showDeleteDialog(context, manager, s, ref),
          color:   AppColors.error.withValues(alpha: 0.7),
        ),
      ],
    );
  }

  Future<void> _showDeleteDialog(
    BuildContext context,
    DownloadManager manager,
    AppStrings s,
    WidgetRef ref,
  ) async {
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title:   Text(s.deleteTitle),
        content: Text(s.deleteQuestion),
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
      final resolved = _resolveFile(job.outputPath);
      if (resolved != null) {
        try { await File(resolved).delete(); } catch (_) {}
      }
    }
    await manager.deleteJob(job.jobId);
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

class _IconBtn extends StatelessWidget {
  const _IconBtn({
    required this.icon,
    required this.tooltip,
    required this.onTap,
    this.color,
  });
  final IconData     icon;
  final String       tooltip;
  final VoidCallback onTap;
  final Color?       color;

  @override
  Widget build(BuildContext context) {
    final isDark    = Theme.of(context).brightness == Brightness.dark;
    final iconColor = color ??
        (isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary);
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap:        onTap,
        borderRadius: BorderRadius.circular(6),
        child: Padding(
          padding: const EdgeInsets.all(5),
          child:   Icon(icon, size: 18, color: iconColor),
        ),
      ),
    );
  }
}
