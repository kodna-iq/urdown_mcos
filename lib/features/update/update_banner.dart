import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../app/theme.dart';
import '../../core/l10n/app_strings.dart';
import '../../services/update_service.dart';

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// UpdateBanner  — non-intrusive top bar, Chrome / VS Code style
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

/// Drop this widget at the very top of the app shell, above all page content.
/// It renders nothing when there is no pending update.
class UpdateBanner extends ConsumerWidget {
  const UpdateBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s        = ref.watch(updateNotifierProvider);
    final notifier = ref.read(updateNotifierProvider.notifier);
    final strings  = ref.watch(stringsProvider);

    return AnimatedSize(
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeInOut,
      child: s.isVisible
          ? _BannerContent(state: s, notifier: notifier, strings: strings)
          : const SizedBox.shrink(),
    );
  }
}

// ── Banner body ─────────────────────────────────────────────────────────────

class _BannerContent extends StatelessWidget {
  const _BannerContent({required this.state, required this.notifier, required this.strings});
  final UpdateState     state;
  final UpdateNotifier  notifier;
  final AppStrings      strings;

  @override
  Widget build(BuildContext context) {
    final isDark  = Theme.of(context).brightness == Brightness.dark;
    final phase   = state.phase;
    final info    = state.info!;
    final progress = state.progress;

    final Color accent = switch (phase) {
      UpdatePhase.ready      => AppColors.success,
      UpdatePhase.failed     => AppColors.error,
      UpdatePhase.verifying  => AppColors.warning,
      _                      => AppColors.brand,
    };

    return Material(
      color: accent.withValues(alpha: isDark ? 0.09 : 0.07),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Main row ───────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                // Animated icon / spinner
                _PhaseIcon(phase: phase, color: accent),
                const SizedBox(width: 10),

                // Message
                Expanded(
                  child: _BannerLabel(
                    phase:        phase,
                    info:         info,
                    progress:     progress,
                    color:        accent,
                    errorMessage: state.errorMessage,
                  ),
                ),

                // Action button
                if (phase == UpdatePhase.ready)
                  _ActionButton(
                    label: strings.restartAndInstall,
                    color: accent,
                    onTap: notifier.installAndRestart,
                  )
                else if (phase == UpdatePhase.failed)
                  _ActionButton(
                    label: state.canRetry ? strings.retryUpdate : strings.openDownloadPage,
                    color: accent,
                    onTap: state.canRetry
                        ? notifier.retry
                        : () => launchUrl(
                              Uri.parse(info.releasePageUrl),
                              mode: LaunchMode.externalApplication,
                            ),
                  ),

                // Dismiss ×
                const SizedBox(width: 6),
                Tooltip(
                  message: 'Dismiss',
                  child: InkWell(
                    onTap: notifier.dismiss,
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.all(4),
                      child: Icon(
                        Icons.close_rounded,
                        size: 14,
                        color: accent.withValues(alpha: 0.7),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── Progress track (thin, 2 px) ────────────────────────────────
          if (phase == UpdatePhase.downloading || phase == UpdatePhase.verifying)
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: LinearProgressIndicator(
                key: ValueKey(phase),
                value: phase == UpdatePhase.verifying
                    ? null          // indeterminate while verifying
                    : (progress > 0 ? progress : null),
                backgroundColor: accent.withValues(alpha: 0.12),
                valueColor: AlwaysStoppedAnimation(accent),
                minHeight: 2,
              ),
            ),
        ],
      ),
    );
  }
}

// ── Sub-widgets ──────────────────────────────────────────────────────────────

class _PhaseIcon extends StatelessWidget {
  const _PhaseIcon({required this.phase, required this.color});
  final UpdatePhase phase;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return switch (phase) {
      UpdatePhase.ready      => Icon(Icons.check_circle_rounded, size: 16, color: color),
      UpdatePhase.failed     => Icon(Icons.error_outline_rounded, size: 16, color: color),
      UpdatePhase.installing => SizedBox(
          width: 16,
          height: 16,
          child: CircularProgressIndicator(strokeWidth: 2, color: color),
        ),
      UpdatePhase.verifying  => SizedBox(
          width: 16,
          height: 16,
          child: CircularProgressIndicator(strokeWidth: 2, color: color),
        ),
      _                      => Icon(Icons.system_update_alt_rounded, size: 16, color: color),
    };
  }
}

class _BannerLabel extends ConsumerWidget {
  const _BannerLabel({
    required this.phase,
    required this.info,
    required this.progress,
    required this.color,
    this.errorMessage,
  });
  final UpdatePhase phase;
  final UpdateInfo  info;
  final double      progress;
  final Color       color;
  final String?     errorMessage;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s   = ref.watch(stringsProvider);
    final pct = '${(progress * 100).toStringAsFixed(0)}%';

    final text = switch (phase) {
      UpdatePhase.ready      => '${s.updateReady}  (v${info.version})',
      UpdatePhase.failed     => errorMessage ?? s.updateFailed,
      UpdatePhase.installing => '${s.updateInstalling} v${info.version}…',
      UpdatePhase.verifying  => '${s.updateVerifying} v${info.version}…',
      UpdatePhase.downloading when progress > 0
                             => '${s.updateDownloading} v${info.version}  ·  $pct',
      UpdatePhase.downloading => '${s.updateDownloading} v${info.version}…',
      _                      => '${s.updateAvailable}: v${info.version}',
    };

    return Text(
      text,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: color,
        height: 1.3,
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.label,
    required this.color,
    required this.onTap,
  });
  final String       label;
  final Color        color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onTap,
      style: TextButton.styleFrom(
        foregroundColor: color,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        textStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
      child: Text(label),
    );
  }
}
