import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../app/theme.dart';
import '../../core/constants/app_constants.dart';
import '../../core/l10n/app_strings.dart';
import '../../core/widgets/urdown_logo.dart';
import '../../services/update_service.dart';

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// UpdateDialog  — detailed update sheet (shown from Settings or banner tap)
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

class UpdateDialog extends ConsumerStatefulWidget {
  const UpdateDialog({required this.info, super.key});
  final UpdateInfo info;

  @override
  ConsumerState<UpdateDialog> createState() => _UpdateDialogState();
}

class _UpdateDialogState extends ConsumerState<UpdateDialog> {
  bool _notesExpanded = false;

  @override
  Widget build(BuildContext context) {
    final s        = ref.watch(updateNotifierProvider);
    final notifier = ref.read(updateNotifierProvider.notifier);
    final isDark   = Theme.of(context).brightness == Brightness.dark;

    final phase      = s.phase;
    final progress   = s.progress;
    final isReady    = phase == UpdatePhase.ready;
    final isDownloading = phase == UpdatePhase.downloading;
    final isVerifying   = phase == UpdatePhase.verifying;
    final isFailed   = phase == UpdatePhase.failed;
    final isInstalling = phase == UpdatePhase.installing;

    return Dialog(
      backgroundColor: isDark ? AppColors.darkCard : AppColors.lightCard,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 440),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Header ───────────────────────────────────────────────────
            _DialogHeader(
              info: widget.info,
              isDark: isDark,
              currentVersion: AppConstants.appVersion,
            ),

            // ── Body ─────────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  // Status card
                  _StatusCard(
                    phase: phase,
                    progress: progress,
                    errorMessage: s.errorMessage,
                    isDark: isDark,
                  ),
                  const SizedBox(height: 16),

                  // Release notes (collapsible)
                  if (widget.info.releaseNotes.isNotEmpty) ...[
                    _NotesToggle(
                      version: widget.info.version,
                      expanded: _notesExpanded,
                      onToggle: () =>
                          setState(() => _notesExpanded = !_notesExpanded),
                    ),
                    if (_notesExpanded) ...[
                      const SizedBox(height: 8),
                      _NotesBody(
                        text: widget.info.releaseNotes,
                        isDark: isDark,
                      ),
                    ],
                    const SizedBox(height: 16),
                  ],

                  // Action buttons
                  _DialogActions(
                    phase:     phase,
                    info:      widget.info,
                    canRetry:  s.canRetry,
                    onDismiss: () => Navigator.of(context).pop(),
                    onPrimary: () => _onPrimary(context, notifier, phase),
                  ),

                  // Extra hint when installing
                  if (isInstalling)
                    const Padding(
                      padding: EdgeInsets.only(top: 10),
                      child: Center(
                        child: Text(
                          'The app will close and restart automatically…',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 11, color: AppColors.darkTextSecondary),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _onPrimary(
    BuildContext context,
    UpdateNotifier notifier,
    UpdatePhase phase,
  ) async {
    switch (phase) {
      case UpdatePhase.ready:
        Navigator.of(context).pop();
        await notifier.installAndRestart();

      case UpdatePhase.failed:
        if (ref.read(updateNotifierProvider).canRetry) {
          await notifier.retry();
        } else {
          final url = Uri.tryParse(widget.info.releasePageUrl);
          if (url != null) {
            await launchUrl(url, mode: LaunchMode.externalApplication);
          }
          if (context.mounted) Navigator.of(context).pop();
        }

      case UpdatePhase.downloading:
      case UpdatePhase.verifying:
      case UpdatePhase.checking:
      case UpdatePhase.installing:
        // No action needed — show is already in progress
        break;

      case UpdatePhase.idle:
        Navigator.of(context).pop();
    }
  }
}

// ── Supporting widgets ───────────────────────────────────────────────────────

class _DialogHeader extends StatelessWidget {
  const _DialogHeader({
    required this.info,
    required this.isDark,
    required this.currentVersion,
  });
  final UpdateInfo info;
  final bool isDark;
  final String currentVersion;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.brand.withValues(alpha: isDark ? 0.08 : 0.06),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        border: Border(
          bottom: BorderSide(
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          ),
        ),
      ),
      child: Row(
        children: [
          const VidoxIcon(size: 44),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Update Available',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      'v$currentVersion',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.lightTextSecondary,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      child: Icon(
                        Icons.arrow_forward_rounded,
                        size: 12,
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.lightTextSecondary,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.brand.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'v${info.version}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.brand,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusCard extends ConsumerWidget {
  const _StatusCard({
    required this.phase,
    required this.progress,
    required this.isDark,
    this.errorMessage,
  });
  final UpdatePhase phase;
  final double progress;
  final bool isDark;
  final String? errorMessage;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(stringsProvider);
    final Color color;
    final IconData icon;
    final String label;

    switch (phase) {
      case UpdatePhase.ready:
        color = AppColors.success;
        icon  = Icons.check_circle_rounded;
        label = s.updateReady;
      case UpdatePhase.failed:
        color = AppColors.error;
        icon  = Icons.error_outline_rounded;
        label = errorMessage ?? s.updateFailed;
      case UpdatePhase.verifying:
        color = AppColors.warning;
        icon  = Icons.verified_rounded;
        label = s.updateVerifying;
      case UpdatePhase.installing:
        color = AppColors.brand;
        icon  = Icons.install_mobile_rounded;
        label = s.updateInstalling;
      default:
        color = AppColors.brand;
        icon  = Icons.downloading_rounded;
        label = progress > 0
            ? '${s.updateDownloading} ${(progress * 100).toStringAsFixed(0)}%'
            : '${s.updateDownloading}…';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: color.withValues(alpha: 0.25)),
          ),
          child: Row(
            children: [
              // Icon or spinner
              if (phase == UpdatePhase.downloading ||
                  phase == UpdatePhase.verifying ||
                  phase == UpdatePhase.installing)
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: color,
                    value: phase == UpdatePhase.downloading && progress > 0
                        ? null
                        : null,
                  ),
                )
              else
                Icon(icon, size: 16, color: color),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
              ),
              if (phase == UpdatePhase.downloading && progress > 0)
                Text(
                  '${(progress * 100).toStringAsFixed(0)}%',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: color,
                  ),
                ),
            ],
          ),
        ),

        // Progress bar
        if (phase == UpdatePhase.downloading || phase == UpdatePhase.verifying)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: phase == UpdatePhase.verifying
                    ? null
                    : (progress > 0 ? progress : null),
                minHeight: 5,
                backgroundColor: color.withValues(alpha: 0.12),
                valueColor: AlwaysStoppedAnimation(color),
              ),
            ),
          ),
      ],
    );
  }
}

class _NotesToggle extends ConsumerWidget {
  const _NotesToggle({
    required this.version,
    required this.expanded,
    required this.onToggle,
  });
  final String version;
  final bool expanded;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(stringsProvider);
    // "What's new in vX.Y.Z" — translated per locale
    final label = _whatsNew(s.languageCode, version);

    return InkWell(
      onTap: onToggle,
      borderRadius: BorderRadius.circular(6),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Row(
          children: [
            Icon(
              expanded
                  ? Icons.keyboard_arrow_up_rounded
                  : Icons.keyboard_arrow_down_rounded,
              size: 18,
              color: AppColors.brand,
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.brand,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  static String _whatsNew(String code, String version) {
    const map = <String, String>{
      'en': "What's new in v",
      'ar': 'الجديد في الإصدار v',
      'zh': 'v 版本新内容',
      'es': 'Novedades en v',
      'ru': 'Что нового в v',
      'ku': 'چی نوێیە لە وەشانی v',
    };
    final prefix = map[code] ?? map['en']!;
    return '$prefix$version';
  }
}

class _NotesBody extends StatelessWidget {
  const _NotesBody({required this.text, required this.isDark});
  final String text;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      constraints: const BoxConstraints(maxHeight: 160),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkBg : AppColors.lightBg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
      ),
      child: SingleChildScrollView(
        child: Text(
          text,
          style: TextStyle(
            fontSize: 12.5,
            height: 1.5,
            color: isDark
                ? AppColors.darkTextSecondary
                : AppColors.lightTextSecondary,
          ),
        ),
      ),
    );
  }
}

class _DialogActions extends ConsumerWidget {
  const _DialogActions({
    required this.phase,
    required this.info,
    required this.canRetry,
    required this.onDismiss,
    required this.onPrimary,
  });
  final UpdatePhase  phase;
  final UpdateInfo   info;
  final bool         canRetry;
  final VoidCallback onDismiss;
  final VoidCallback onPrimary;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(stringsProvider);

    final isDownloading = phase == UpdatePhase.downloading ||
        phase == UpdatePhase.verifying ||
        phase == UpdatePhase.installing;

    final String primaryLabel = switch (phase) {
      UpdatePhase.ready  => s.restartAndInstall,
      UpdatePhase.failed => canRetry ? s.retryUpdate : s.openDownloadPage,
      _                  => '${s.updateDownloading}…',
    };

    final IconData primaryIcon = switch (phase) {
      UpdatePhase.ready  => Icons.restart_alt_rounded,
      UpdatePhase.failed => canRetry ? Icons.refresh_rounded : Icons.open_in_browser_rounded,
      _                  => Icons.hourglass_empty_rounded,
    };

    return Row(
      children: [
        // Later / dismiss
        Expanded(
          child: OutlinedButton(
            onPressed: onDismiss,
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 13),
            ),
            child: Text(s.laterBtn),
          ),
        ),
        const SizedBox(width: 10),

        // Primary action
        Expanded(
          flex: 2,
          child: FilledButton.icon(
            onPressed: isDownloading ? null : onPrimary,
            icon: isDownloading
                ? const SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : Icon(primaryIcon, size: 16),
            label: Text(primaryLabel),
            style: FilledButton.styleFrom(
              backgroundColor: phase == UpdatePhase.failed
                  ? AppColors.error
                  : AppColors.brand,
              foregroundColor: phase == UpdatePhase.failed
                  ? Colors.white
                  : AppColors.darkBg,
              padding: const EdgeInsets.symmetric(vertical: 13),
            ),
          ),
        ),
      ],
    );
  }
}
