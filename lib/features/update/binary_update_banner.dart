import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme.dart';
import '../../core/engine/binary_update_engine.dart';

// ═══════════════════════════════════════════════════════════════════════════════
// BinaryUpdateBanner
//
// Non-intrusive slim banner (similar to UpdateBanner for the app itself).
// Shows only during download / extract / after update — hides otherwise.
// Place this BELOW the app UpdateBanner in the shell scaffold.
// ═══════════════════════════════════════════════════════════════════════════════

class BinaryUpdateBanner extends ConsumerWidget {
  const BinaryUpdateBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s        = ref.watch(binaryUpdateProvider);
    final notifier = ref.read(binaryUpdateProvider.notifier);

    return AnimatedSize(
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeInOut,
      child: s.isVisible
          ? _BannerBody(state: s, notifier: notifier)
          : const SizedBox.shrink(),
    );
  }
}

class _BannerBody extends StatelessWidget {
  const _BannerBody({required this.state, required this.notifier});
  final BinaryUpdateState    state;
  final BinaryUpdateNotifier notifier;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final phase  = state.phase;

    final Color accent = switch (phase) {
      BinaryUpdatePhase.updated    => AppColors.success,
      BinaryUpdatePhase.failed     => AppColors.error,
      BinaryUpdatePhase.extracting => AppColors.warning,
      _                            => AppColors.brand,
    };

    return Material(
      color: accent.withValues(alpha: isDark ? 0.09 : 0.07),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Main row ──────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
            child: Row(
              children: [
                // Icon / spinner
                _PhaseIcon(phase: phase, color: accent),
                const SizedBox(width: 10),

                // Label
                Expanded(
                  child: _Label(state: state, color: accent),
                ),

                // Dismiss ×
                Tooltip(
                  message: 'Dismiss',
                  child: InkWell(
                    onTap: notifier.dismiss,
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.all(4),
                      child: Icon(
                        Icons.close_rounded,
                        size: 13,
                        color: accent.withValues(alpha: 0.65),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── Progress bar ───────────────────────────────────────────────
          if (phase == BinaryUpdatePhase.downloading ||
              phase == BinaryUpdatePhase.extracting)
            LinearProgressIndicator(
              value: phase == BinaryUpdatePhase.extracting
                  ? null                                       // indeterminate
                  : (state.progress > 0 ? state.progress : null),
              backgroundColor: accent.withValues(alpha: 0.12),
              valueColor: AlwaysStoppedAnimation(accent),
              minHeight: 2,
            ),
        ],
      ),
    );
  }
}

// ── Sub-widgets ──────────────────────────────────────────────────────────────

class _PhaseIcon extends StatelessWidget {
  const _PhaseIcon({required this.phase, required this.color});
  final BinaryUpdatePhase phase;
  final Color             color;

  @override
  Widget build(BuildContext context) {
    return switch (phase) {
      BinaryUpdatePhase.updated  => Icon(Icons.check_circle_rounded, size: 15, color: color),
      BinaryUpdatePhase.failed   => Icon(Icons.error_outline_rounded, size: 15, color: color),
      _ => SizedBox(
          width: 15, height: 15,
          child: CircularProgressIndicator(strokeWidth: 2, color: color),
        ),
    };
  }
}

class _Label extends StatelessWidget {
  const _Label({required this.state, required this.color});
  final BinaryUpdateState state;
  final Color             color;

  @override
  Widget build(BuildContext context) {
    final binary = state.currentBinary.isEmpty ? 'yt-dlp' : state.currentBinary;
    final pct    = '${(state.progress * 100).toStringAsFixed(0)}%';

    final text = switch (state.phase) {
      BinaryUpdatePhase.checking    => 'Checking $binary updates…',
      BinaryUpdatePhase.downloading =>
          state.progress > 0
              ? 'Updating $binary  $pct  (${state.fromVersion} → ${state.toVersion})'
              : 'Downloading $binary ${state.toVersion}…',
      BinaryUpdatePhase.extracting  => 'Installing $binary ${state.toVersion}…',
      BinaryUpdatePhase.updated     =>
          '$binary updated  ${state.fromVersion} → ${state.toVersion} ✓',
      BinaryUpdatePhase.failed      =>
          state.errorMessage.isNotEmpty ? state.errorMessage : '$binary update failed',
      _                             => '',
    };

    return Text(
      text,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        fontSize: 11.5,
        fontWeight: FontWeight.w600,
        color: color,
        height: 1.3,
      ),
    );
  }
}
