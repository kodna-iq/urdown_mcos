import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme.dart';
import '../../core/l10n/app_strings.dart';
import '../../services/notification_service.dart';
import '../../services/url_sanitizer.dart';
import 'models/stream_recording.dart';
import 'providers/multi_stream_provider.dart';
import 'services/multi_stream_manager.dart';
import 'widgets/active_recordings_panel.dart';

// ─── Live Record Tab ──────────────────────────────────────────────────────────

class LiveRecordTab extends ConsumerStatefulWidget {
  const LiveRecordTab({super.key, this.initialUrl});
  final String? initialUrl;

  @override
  ConsumerState<LiveRecordTab> createState() => _LiveRecordTabState();
}

class _LiveRecordTabState extends ConsumerState<LiveRecordTab> {
  final _urlCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();
  String _quality = 'best';
  String _format = 'mp4';
  int? _maxMinutes;
  bool _isAdding = false;
  int _nextId = 1;

  StreamSubscription<List<StreamRecording>>? _notifSub;

  static const _qualities = ['best', '1080p', '720p', '480p', '360p'];
  static const _formats = ['mp4', 'mkv', 'ts'];

  @override
  void initState() {
    super.initState();
    if (widget.initialUrl != null) _urlCtrl.text = widget.initialUrl!;
    _notifSub = MultiStreamManager.instance.recordingsStream.listen((recordings) {
      for (final r in recordings) {
        if (r.status == RecordingStatus.saved) {
          NotificationService.instance.showDownloadComplete('live_${r.id}');
        }
      }
    });
  }

  @override
  void dispose() {
    _urlCtrl.dispose();
    _scrollCtrl.dispose();
    _notifSub?.cancel();
    super.dispose();
  }

  Future<void> _addStream() async {
    final url = _urlCtrl.text.trim();
    if (url.isEmpty || !UrlSanitizer.isValid(url)) {
      _showSnack(ref.read(stringsProvider).enterValidUrl);
      return;
    }

    final activeCount = ref.read(activeRecordingCountProvider);
    if (activeCount >= MultiStreamManager.maxConcurrentRecordings) {
      _showSnack(ref.read(stringsProvider).maxRecordingsMsg(MultiStreamManager.maxConcurrentRecordings));
      return;
    }

    setState(() => _isAdding = true);
    try {
      final id = 'rec_${_nextId++}';
      await MultiStreamManager.instance.startRecording(
        id: id, url: url, quality: _quality, format: _format,
        maxDurationSeconds: _maxMinutes != null ? _maxMinutes! * 60 : null,
      );
      setState(() => _urlCtrl.clear());
      await Future.delayed(const Duration(milliseconds: 200));
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(0,
            duration: const Duration(milliseconds: 400), curve: Curves.easeOut);
      }
    } catch (e) {
      _showSnack(e.toString());
    } finally {
      if (mounted) setState(() => _isAdding = false);
    }
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final s = ref.watch(stringsProvider);
    final hasRecordings = (ref.watch(recordingsProvider).valueOrNull ?? []).isNotEmpty;
    return Column(children: [
      _buildHeader(isDark, s),
      Expanded(child: hasRecordings ? _buildList(isDark) : _buildEmpty(isDark, s)),
    ]);
  }

  Widget _buildHeader(bool isDark, AppStrings s) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightBg,
        border: Border(bottom: BorderSide(color: isDark ? AppColors.darkBorder : AppColors.lightBorder)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(
            child: TextField(
              controller: _urlCtrl,
              onChanged: (_) => setState(() {}),
              onSubmitted: (_) => _addStream(),
              decoration: InputDecoration(
                hintText: s.pasteLiveUrl,
                prefixIcon: const Icon(Icons.live_tv_rounded, size: 18),
                isDense: true,
                suffixIcon: _urlCtrl.text.isNotEmpty
                    ? IconButton(icon: const Icon(Icons.clear_rounded, size: 16), onPressed: () => setState(() => _urlCtrl.clear()), visualDensity: VisualDensity.compact)
                    : null,
              ),
            ),
          ),
          const SizedBox(width: 10),
          _RecordButton(enabled: _urlCtrl.text.trim().isNotEmpty && !_isAdding, isLoading: _isAdding, onTap: _addStream, s: s),
        ]),
        const SizedBox(height: 10),
        LayoutBuilder(builder: (_, constraints) {
          final isNarrow = constraints.maxWidth < 340;
          final qualityDropdown = _MiniDropdown(label: s.quality, value: _quality, items: _qualities, onChanged: (v) => setState(() => _quality = v ?? _quality));
          final formatDropdown = _MiniDropdown(label: s.format, value: _format, items: _formats, onChanged: (v) => setState(() => _format = v ?? _format));
          final durationDropdown = _MiniDropdown(
            label: s.maxDuration,
            value: _maxMinutes == null ? s.unlimited : '$_maxMinutes min',
            items: [s.unlimited, '10 min', '30 min', '60 min', '120 min'],
            onChanged: (v) => setState(() {
              _maxMinutes = (v == null || v == s.unlimited) ? null : int.tryParse(v.split(' ').first);
            }),
          );
          if (isNarrow) {
            final half = (constraints.maxWidth - 8) / 2;
            return Wrap(spacing: 8, runSpacing: 8, children: [
              SizedBox(width: half, child: qualityDropdown),
              SizedBox(width: half, child: formatDropdown),
              SizedBox(width: constraints.maxWidth, child: durationDropdown),
            ]);
          }
          return Row(children: [
            Expanded(child: qualityDropdown),
            const SizedBox(width: 8),
            Expanded(child: formatDropdown),
            const SizedBox(width: 8),
            Expanded(child: durationDropdown),
          ]);
        }),
        const SizedBox(height: 10),
        Wrap(spacing: 6, runSpacing: 4, children: [
          ('YouTube', Icons.play_circle_rounded, const Color(0xFFFF0000)),
          ('TikTok', Icons.music_video_rounded, const Color(0xFF69C9D0)),
          ('Facebook', Icons.facebook_rounded, const Color(0xFF1877F2)),
          ('Instagram', Icons.camera_alt_rounded, const Color(0xFFE1306C)),
          ('Twitch', Icons.sports_esports_rounded, const Color(0xFF9146FF)),
          ('Twitter/X', Icons.alternate_email_rounded, const Color(0xFF1DA1F2)),
        ].map((p) => _PlatformChip(name: p.$1, icon: p.$2, color: p.$3)).toList()),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.warning.withValues(alpha: 0.07),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.warning.withValues(alpha: 0.2)),
          ),
          child: Row(children: [
            const Icon(Icons.info_outline_rounded, size: 12, color: AppColors.warning),
            const SizedBox(width: 6),
            Expanded(child: Text(s.cookieWarning, style: const TextStyle(fontSize: 10.5, color: AppColors.warning))),
          ]),
        ),
      ]),
    );
  }

  Widget _buildList(bool isDark) {
    return SingleChildScrollView(
      controller: _scrollCtrl,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 20),
      child: ActiveRecordingsPanel(isDark: isDark),
    );
  }

  Widget _buildEmpty(bool isDark, AppStrings s) {
    return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Container(
        width: 64, height: 64,
        decoration: BoxDecoration(color: AppColors.brand.withValues(alpha: 0.08), shape: BoxShape.circle),
        child: const Icon(Icons.live_tv_rounded, size: 30, color: AppColors.brand),
      ),
      const SizedBox(height: 16),
      Text(s.noActiveRecordings, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: isDark ? AppColors.darkText : AppColors.lightText)),
      const SizedBox(height: 6),
      Text(s.pasteUrlAndRecord, style: TextStyle(fontSize: 12, color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary)),
      const SizedBox(height: 4),
      Text(s.liveRecordLimit(MultiStreamManager.maxConcurrentRecordings), style: TextStyle(fontSize: 11, color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted)),
    ]));
  }
}

// ─── Record Button ────────────────────────────────────────────────────────────

class _RecordButton extends StatelessWidget {
  const _RecordButton({required this.enabled, required this.isLoading, required this.onTap, required this.s});
  final bool enabled;
  final bool isLoading;
  final VoidCallback onTap;
  final AppStrings s;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: enabled ? AppColors.error : AppColors.error.withValues(alpha: 0.4),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          if (isLoading)
            const SizedBox(width: 13, height: 13, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
          else
            const Icon(Icons.fiber_manual_record_rounded, size: 14, color: Colors.white),
          const SizedBox(width: 6),
          Text(s.record, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white)),
        ]),
      ),
    );
  }
}

// ─── Platform Chip ────────────────────────────────────────────────────────────

class _PlatformChip extends StatelessWidget {
  const _PlatformChip({required this.name, required this.icon, required this.color});
  final String name;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(99),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 11, color: color),
        const SizedBox(width: 4),
        Text(name, style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.w500)),
      ]),
    );
  }
}

// ─── Mini Dropdown ────────────────────────────────────────────────────────────

class _MiniDropdown extends StatelessWidget {
  const _MiniDropdown({required this.label, required this.value, required this.items, required this.onChanged});
  final String label;
  final String value;
  final List<String> items;
  final void Function(String?) onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 10)),
      const SizedBox(height: 2),
      DropdownButtonFormField<String>(
        value: items.contains(value) ? value : items.first,
        decoration: const InputDecoration(isDense: true, contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8)),
        items: items.map((e) => DropdownMenuItem(value: e, child: Text(e, style: const TextStyle(fontSize: 12)))).toList(),
        onChanged: onChanged,
      ),
    ]);
  }
}
