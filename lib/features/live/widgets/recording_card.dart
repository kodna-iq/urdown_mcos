import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/l10n/app_strings.dart';
import '../../../core/l10n/locale_service.dart';

import '../../../app/theme.dart';
import '../models/stream_recording.dart';
import '../services/multi_stream_manager.dart';

class RecordingCard extends ConsumerStatefulWidget {
  const RecordingCard({
    super.key,
    required this.recording,
    required this.isDark,
    required this.onRemove,
  });

  final StreamRecording recording;
  final bool isDark;
  final VoidCallback onRemove;

  @override
  ConsumerState<RecordingCard> createState() => _RecordingCardState();
}

class _RecordingCardState extends ConsumerState<RecordingCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseCtrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..repeat(reverse: true);

  late final Animation<double> _pulse =
      Tween(begin: 0.35, end: 1.0).animate(_pulseCtrl);

  @override
  void dispose() {
    _pulseCtrl.dispose();
    super.dispose();
  }

  AppStrings get _s => ref.read(stringsProvider);
  MultiStreamManager get _mgr => MultiStreamManager.instance;
  StreamRecording get r => widget.recording;

  @override
  Widget build(BuildContext context) {
    final status = r.status;
    final isActive = status.isActive;
    final borderColor = status == RecordingStatus.failed
        ? AppColors.error
        : status == RecordingStatus.saved
            ? AppColors.success
            : isActive
                ? r.platform.color
                : (widget.isDark ? AppColors.darkBorder : AppColors.lightBorder);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: widget.isDark ? AppColors.darkCard : AppColors.lightCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: borderColor.withValues(alpha: isActive ? 0.65 : 0.4),
          width: isActive ? 1.5 : 1,
        ),
        boxShadow: isActive
            ? [
                BoxShadow(
                  color: r.platform.color.withValues(alpha: 0.07),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                )
              ]
            : null,
      ),
      child: Column(
        children: [
          _buildHeader(),
          if (status == RecordingStatus.recording ||
              status == RecordingStatus.paused)
            _buildProgressRow(),
          if (status == RecordingStatus.saved) _buildSavedRow(),
          if (status == RecordingStatus.failed) _buildErrorRow(),
          if (isActive) _buildResourceBar(),
        ],
      ),
    );
  }

  // ── Header ────────────────────────────────────────────────────────────

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 12, 10, 10),
      child: Row(
        children: [
          // Platform icon
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: r.platform.color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(r.platform.icon, size: 17, color: r.platform.color),
          ),
          const SizedBox(width: 10),

          // Title + URL
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  r.platform.name,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: r.platform.color,
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  r.url,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 10,
                    color: widget.isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.lightTextSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),

          // Status badge
          _buildStatusBadge(),
          const SizedBox(width: 6),

          // Action buttons
          _buildActions(),
        ],
      ),
    );
  }

  // ── Status badge ──────────────────────────────────────────────────────

  Widget _buildStatusBadge() {
    final status = r.status;
    final color = status.color;
    final shouldPulse = status == RecordingStatus.connecting ||
        status == RecordingStatus.recording;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(99),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (shouldPulse) ...[
            AnimatedBuilder(
              animation: _pulse,
              builder: (_, __) => Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: color.withValues(alpha: _pulse.value),
                ),
              ),
            ),
            const SizedBox(width: 4),
          ],
          if (status == RecordingStatus.paused) ...[
            Icon(Icons.pause_rounded, size: 10, color: color),
            const SizedBox(width: 3),
          ],
          Text(
            status == RecordingStatus.recording
                ? r.durationFormatted
                : status.localizedLabel(_s),
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: color,
              fontFamily: status == RecordingStatus.recording
                  ? 'monospace'
                  : null,
            ),
          ),
        ],
      ),
    );
  }

  // ── Action buttons ────────────────────────────────────────────────────

  Widget _buildActions() {
    final status = r.status;

    if (status == RecordingStatus.stopping) {
      final label = r.convertingToMp4 ? _s.convertingToMp4 : _s.saving;
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
        decoration: BoxDecoration(
          color: AppColors.warning.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(
              width: 10,
              height: 10,
              child: CircularProgressIndicator(
                strokeWidth: 1.8,
                color: AppColors.warning,
              ),
            ),
            const SizedBox(width: 5),
            Text(
              label,
              style: const TextStyle(fontSize: 10, color: AppColors.warning),
            ),
          ],
        ),
      );
    }

    if (status == RecordingStatus.saved || status == RecordingStatus.failed) {
      return IconButton(
        icon: const Icon(Icons.close_rounded, size: 16),
        onPressed: widget.onRemove,
        visualDensity: VisualDensity.compact,
        tooltip: _s.removeRecording,
        color: widget.isDark
            ? AppColors.darkTextSecondary
            : AppColors.lightTextSecondary,
      );
    }

    if (status.isActive) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Pause / Resume
          if (status.canPause)
            _ActionBtn(
              icon: Icons.pause_rounded,
              color: AppColors.warning,
              tooltip: _s.pause,
              onTap: () => _mgr.pauseRecording(r.id),
            )
          else if (status.canResume)
            _ActionBtn(
              icon: Icons.play_arrow_rounded,
              color: AppColors.success,
              tooltip: _s.resume,
              onTap: () => _mgr.resumeRecording(r.id),
            ),
          const SizedBox(width: 5),
          // Stop
          _ActionBtn(
            icon: Icons.stop_rounded,
            color: AppColors.error,
            tooltip: _s.stopRecording,
            onTap: () => _mgr.stopRecording(r.id),
          ),
        ],
      );
    }

    return const SizedBox.shrink();
  }

  // ── Progress row ──────────────────────────────────────────────────────

  Widget _buildProgressRow() {
    final isPaused = r.status == RecordingStatus.paused;
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
      child: Row(
        children: [
          // Live indicator / paused indicator
          if (!isPaused)
            AnimatedBuilder(
              animation: _pulse,
              builder: (_, __) => Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.error.withValues(alpha: _pulse.value),
                ),
              ),
            )
          else
            const Icon(Icons.pause_circle_filled_rounded,
                size: 8, color: AppColors.warning),
          const SizedBox(width: 8),

          // Duration
          Text(
            r.durationFormatted,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w900,
              fontFamily: 'monospace',
              color: isPaused ? AppColors.warning : AppColors.error,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(width: 14),

          // File size
          if (r.sizeBytes > 0) ...[
            const SizedBox(width: 4),
            Icon(
              Icons.storage_rounded,
              size: 11,
              color: widget.isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.lightTextSecondary,
            ),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                r.sizeFormatted,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 11,
                  color: widget.isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.lightTextSecondary,
                ),
              ),
            ),
          ],

          const Spacer(),

          if (isPaused) ...[
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.warning.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                    color: AppColors.warning.withValues(alpha: 0.3)),
              ),
              child: Text(
                _s.pausedLabel,
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w800,
                  color: AppColors.warning,
                  letterSpacing: 1,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ── Resource bar ──────────────────────────────────────────────────────

  Widget _buildResourceBar() {
    if (r.cpuPercent == 0 && r.memoryMb == 0) return const SizedBox.shrink();
    return Container(
      margin: const EdgeInsets.fromLTRB(14, 0, 14, 10),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: (widget.isDark ? AppColors.darkBorder : AppColors.lightBorder)
            .withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            Icons.memory_rounded,
            size: 11,
            color: widget.isDark
                ? AppColors.darkTextSecondary
                : AppColors.lightTextSecondary,
          ),
          const SizedBox(width: 5),
          Text(
            'CPU ${r.cpuPercent}%',
            style: TextStyle(
              fontSize: 10,
              color: _cpuColor(r.cpuPercent),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 12),
          Icon(
            Icons.storage_rounded,
            size: 11,
            color: widget.isDark
                ? AppColors.darkTextSecondary
                : AppColors.lightTextSecondary,
          ),
          const SizedBox(width: 5),
          Text(
            'RAM ${r.memoryMb} MB',
            style: TextStyle(
              fontSize: 10,
              color: _memColor(r.memoryMb),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Color _cpuColor(int cpu) {
    if (cpu > 80) return AppColors.error;
    if (cpu > 50) return AppColors.warning;
    return AppColors.success;
  }

  Color _memColor(int mb) {
    if (mb > 400) return AppColors.error;
    if (mb > 200) return AppColors.warning;
    return AppColors.success;
  }

  // ── Saved row ─────────────────────────────────────────────────────────

  Widget _buildSavedRow() {
    final path = r.outputPath;
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: AppColors.success.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(10),
        border:
            Border.all(color: AppColors.success.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.check_circle_rounded,
                  size: 13, color: AppColors.success),
              const SizedBox(width: 6),
              Text(
                _s.recordingSaved,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.success,
                ),
              ),
              const Spacer(),
              if (r.duration > Duration.zero) ...[
                const Icon(Icons.timer_outlined,
                    size: 11, color: AppColors.success),
                const SizedBox(width: 3),
                Text(
                  r.durationFormatted,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.success,
                    fontFamily: 'monospace',
                  ),
                ),
              ],
            ],
          ),
          if (path != null) ...[
            const SizedBox(height: 6),
            Row(
              children: [
                Expanded(
                  child: Text(
                    path,
                    style: TextStyle(
                      fontSize: 10,
                      color: AppColors.success.withValues(alpha: 0.8),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                _OpenFolderBtn(path: path),
              ],
            ),
          ] else ...[
            const SizedBox(height: 4),
            Text(
              _s.savedToOutput,
              style: TextStyle(
                fontSize: 10,
                color: AppColors.success.withValues(alpha: 0.75),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ── Error row ─────────────────────────────────────────────────────────

  Widget _buildErrorRow() {
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.error.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.error_outline_rounded,
                  size: 13, color: AppColors.error),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  r.errorMessage ?? _s.unknownError,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.error,
                    height: 1.4,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _ActionChip(
                icon: Icons.refresh_rounded,
                label: _s.retry,
                color: AppColors.brand,
                onTap: () => _mgr.retryRecording(r.id),
              ),
              const SizedBox(width: 8),
              _ActionChip(
                icon: Icons.close_rounded,
                label: _s.removeRecording,
                color: AppColors.darkTextSecondary,
                onTap: widget.onRemove,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Action button ────────────────────────────────────────────────────────────

class _ActionBtn extends StatelessWidget {
  const _ActionBtn({
    required this.icon,
    required this.color,
    required this.tooltip,
    required this.onTap,
  });

  final IconData icon;
  final Color color;
  final String tooltip;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: color.withValues(alpha: 0.35)),
          ),
          child: Icon(icon, size: 15, color: color),
        ),
      ),
    );
  }
}

// ─── Action chip ──────────────────────────────────────────────────────────────

class _ActionChip extends StatelessWidget {
  const _ActionChip({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(7),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 12, color: color),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Open folder button ───────────────────────────────────────────────────────

class _OpenFolderBtn extends ConsumerWidget {
  const _OpenFolderBtn({required this.path});
  final String path;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final _s = ref.watch(stringsProvider);
    return Tooltip(
      message: _s.openOutputFolder,
      child: GestureDetector(
        onTap: () {
          if (Platform.isWindows) {
            Process.run(
              'explorer',
              ['/select,', path.replaceAll('/', '\\')],
              runInShell: false,
            );
          } else if (Platform.isMacOS) {
            Process.run('open', ['-R', path], runInShell: false);
          } else {
            // Linux: open containing directory
            final dir = path.contains('/')
                ? path.substring(0, path.lastIndexOf('/'))
                : path;
            Process.run('xdg-open', [dir], runInShell: false);
          }
        },
        child: Container(
          padding: const EdgeInsets.all(5),
          decoration: BoxDecoration(
            color: AppColors.success.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(6),
          ),
          child: const Icon(
            Icons.folder_open_rounded,
            size: 13,
            color: AppColors.success,
          ),
        ),
      ),
    );
  }
}
