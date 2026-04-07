import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme.dart';
import '../../../core/l10n/app_strings.dart';
import '../models/stream_recording.dart';
import '../providers/multi_stream_provider.dart';
import '../services/multi_stream_manager.dart';
import 'recording_card.dart';

class ActiveRecordingsPanel extends ConsumerWidget {
  const ActiveRecordingsPanel({super.key, required this.isDark});
  final bool isDark;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recordingsAsync = ref.watch(recordingsProvider);

    return recordingsAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
      data: (recordings) {
        if (recordings.isEmpty) return _buildEmptyState(isDark);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader(context, ref, recordings, isDark),
            const SizedBox(height: 10),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: recordings.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (_, i) {
                final rec = recordings[i];
                return RecordingCard(
                  recording: rec,
                  isDark: isDark,
                  onRemove: () =>
                      MultiStreamManager.instance.removeRecording(rec.id),
                );
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildSectionHeader(
    BuildContext context,
    WidgetRef ref,
    List<StreamRecording> recordings,
    bool isDark,
  ) {
    final activeCount =
        recordings.where((r) => r.status.isActive).length;
    final totalSize =
        recordings.fold(0, (sum, r) => sum + r.sizeBytes);

    return Row(
      children: [
        // Title
        Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: activeCount > 0 ? AppColors.error : AppColors.success,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              ref.watch(stringsProvider).activeRecordings,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: isDark ? AppColors.darkText : AppColors.lightText,
                letterSpacing: -0.3,
              ),
            ),
          ],
        ),

        const SizedBox(width: 10),

        // Active count badge
        if (activeCount > 0)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
            decoration: BoxDecoration(
              color: AppColors.error.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(99),
              border:
                  Border.all(color: AppColors.error.withValues(alpha: 0.3)),
            ),
            child: Text(
              ref.watch(stringsProvider).liveRecordingCount(activeCount),
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: AppColors.error,
              ),
            ),
          ),

        const Spacer(),

        // Total disk usage
        if (totalSize > 0) ...[
          Icon(
            Icons.storage_rounded,
            size: 11,
            color: isDark
                ? AppColors.darkTextSecondary
                : AppColors.lightTextSecondary,
          ),
          const SizedBox(width: 4),
          Text(
            _formatSize(totalSize),
            style: TextStyle(
              fontSize: 11,
              color: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.lightTextSecondary,
            ),
          ),
          const SizedBox(width: 12),
        ],

        // Stop all button
        if (activeCount > 0)
          _StopAllBtn(
            onTap: () => _stopAll(recordings),
            isDark: isDark,
            stopAllLabel: ref.watch(stringsProvider).stopAll,
          ),
      ],
    );
  }

  void _stopAll(List<StreamRecording> recordings) {
    for (final r in recordings) {
      if (r.status.isActive) {
        MultiStreamManager.instance.stopRecording(r.id);
      }
    }
  }

  Widget _buildEmptyState(bool isDark) => const SizedBox.shrink();

  String _formatSize(int bytes) {
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
  }
}

// ─── Stop All Button ──────────────────────────────────────────────────────────

class _StopAllBtn extends StatelessWidget {
  const _StopAllBtn({required this.onTap, required this.isDark, required this.stopAllLabel});
  final VoidCallback onTap;
  final bool isDark;
  final String stopAllLabel;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
        decoration: BoxDecoration(
          color: AppColors.error.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(8),
          border:
              Border.all(color: AppColors.error.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.stop_circle_rounded,
                size: 12, color: AppColors.error),
            const SizedBox(width: 4),
            Text(
              stopAllLabel,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: AppColors.error,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
