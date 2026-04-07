import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../app/theme.dart';
import '../../core/l10n/app_strings.dart';
import 'history_repository.dart';
import 'models/history_entry.dart';

// ──────────────────────────────────────────────────────────────────────────────
// HistoryPage
// ──────────────────────────────────────────────────────────────────────────────

class HistoryPage extends ConsumerStatefulWidget {
  const HistoryPage({super.key});

  @override
  ConsumerState<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends ConsumerState<HistoryPage> {
  final _search = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final historyAsync = ref.watch(historyProvider);
    final s            = ref.watch(stringsProvider);

    return Scaffold(
      appBar: AppBar(
        title:   Text(s.history),
        actions: [
          TextButton.icon(
            onPressed: () async {
              final ok = await _confirmClear(context, s);
              if (ok && context.mounted) {
                await ref.read(historyRepositoryProvider).clearAll();
              }
            },
            icon:  const Icon(Icons.delete_sweep_outlined, size: 18),
            label: Text(s.clearAll),
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: Column(
        children: [
          // ── Search bar ────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
            child: TextField(
              controller: _search,
              decoration: InputDecoration(
                hintText:   s.searchHistory,
                prefixIcon: const Icon(Icons.search_rounded, size: 20),
                suffixIcon: _query.isNotEmpty
                    ? IconButton(
                        icon:      const Icon(Icons.clear_rounded, size: 18),
                        onPressed: () {
                          _search.clear();
                          setState(() => _query = '');
                        },
                      )
                    : null,
                isDense: true,
              ),
              onChanged: (v) => setState(() => _query = v),
            ),
          ),

          // ── History list ──────────────────────────────────────────────
          Expanded(
            child: historyAsync.when(
              data: (entries) {
                final q        = _query.toLowerCase();
                final filtered = _query.isEmpty
                    ? entries
                    : entries.where((e) =>
                          e.title.toLowerCase().contains(q) ||
                          (e.channelName?.toLowerCase().contains(q) ?? false),
                        ).toList();

                if (filtered.isEmpty) {
                  return _EmptyHistory(
                    isFiltered: _query.isNotEmpty,
                    s:          s,
                  );
                }

                return ListView.separated(
                  padding:           const EdgeInsets.fromLTRB(20, 0, 20, 80),
                  itemCount:         filtered.length,
                  separatorBuilder:  (_, __) => const SizedBox(height: 8),
                  itemBuilder:       (_, i) => _HistoryTile(entry: filtered[i]),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error:   (e, _) => Center(child: Text('$e')),
            ),
          ),
        ],
      ),
    );
  }

  Future<bool> _confirmClear(BuildContext context, AppStrings s) async {
    return await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title:   Text(s.clearHistoryTitle),
            content: Text(s.clearHistoryBody),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child:     Text(s.cancel),
              ),
              FilledButton(
                style:     FilledButton.styleFrom(backgroundColor: AppColors.error),
                onPressed: () => Navigator.pop(ctx, true),
                child:     Text(s.clear),
              ),
            ],
          ),
        ) ??
        false;
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// History tile — fully theme-aware, no hardcoded dark colours
// ──────────────────────────────────────────────────────────────────────────────

class _HistoryTile extends ConsumerWidget {
  const _HistoryTile({required this.entry});
  final HistoryEntry entry;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark   = Theme.of(context).brightness == Brightness.dark;
    final s        = ref.watch(stringsProvider);
    final dateStr  = DateFormat('MMM d, y · HH:mm').format(entry.downloadedAt);
    final fmtColor = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    final dateColor= isDark ? AppColors.darkTextMuted     : AppColors.lightTextMuted;

    return Container(
      decoration: BoxDecoration(
        color:        isDark ? AppColors.darkCard : AppColors.lightCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          width: 0.5,
        ),
      ),
      child: Row(
        children: [
          // ── Thumbnail ──────────────────────────────────────────────────
          if (entry.thumbnailUrl != null)
            ClipRRect(
              borderRadius: const BorderRadius.horizontal(
                left: Radius.circular(12),
              ),
              child: CachedNetworkImage(
                imageUrl:    entry.thumbnailUrl!,
                width:       84,
                height:      60,
                fit:         BoxFit.cover,
                errorWidget: (_, __, ___) => _ThumbPlaceholder(isDark: isDark),
              ),
            )
          else
            ClipRRect(
              borderRadius: const BorderRadius.horizontal(
                left: Radius.circular(12),
              ),
              child: _ThumbPlaceholder(isDark: isDark),
            ),

          // ── Info ───────────────────────────────────────────────────────
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    entry.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize:   14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        entry.isAudio
                            ? Icons.music_note_rounded
                            : Icons.movie_outlined,
                        size:  12,
                        color: AppColors.brand,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${entry.format.toUpperCase()} · ${entry.resolution}',
                        style: const TextStyle(
                          fontSize: 11,
                          color:    AppColors.brand,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Flexible(
                        child: Text(
                          dateStr,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: 11, color: dateColor),
                        ),
                      ),
                    ],
                  ),
                  if (entry.channelName != null) ...[
                    const SizedBox(height: 3),
                    Text(
                      entry.channelName!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 11, color: fmtColor),
                    ),
                  ],
                ],
              ),
            ),
          ),

          // ── Actions ────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.only(right: 4),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _ActionBtn(
                  icon:    Icons.folder_open_rounded,
                  tooltip: s.showFile,
                  onTap:   () => _revealFile(entry.outputPath),
                ),
                _ActionBtn(
                  icon:    Icons.play_circle_outline_rounded,
                  tooltip: s.play,
                  onTap:   () => _openFile(entry.outputPath),
                ),
                PopupMenuButton<String>(
                  icon: Icon(
                    Icons.more_vert_rounded,
                    size:  18,
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.lightTextSecondary,
                  ),
                  onSelected: (action) async {
                    if (action == 'open') {
                      await launchUrl(Uri.parse(entry.url),
                          mode: LaunchMode.externalApplication);
                    } else if (action == 'delete') {
                      await ref
                          .read(historyRepositoryProvider)
                          .delete(entry.jobId);
                    }
                  },
                  itemBuilder: (_) => [
                    PopupMenuItem(
                      value: 'open',
                      child: Row(children: [
                        const Icon(Icons.open_in_browser_rounded, size: 16),
                        const SizedBox(width: 8),
                        Text(s.openInBrowser),
                      ]),
                    ),
                    PopupMenuItem(
                      value: 'delete',
                      child: Row(children: [
                        const Icon(Icons.delete_outline_rounded, size: 16, color: AppColors.error),
                        const SizedBox(width: 8),
                        Text(s.remove,
                            style: const TextStyle(color: AppColors.error)),
                      ]),
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

  String? _resolve(String basePath) {
    if (File(basePath).existsSync()) return basePath;
    const exts = ['mp4','mkv','webm','mp3','m4a','opus','flac','wav','ogg','mov','avi'];
    for (final ext in exts) {
      final c = '$basePath.$ext';
      if (File(c).existsSync()) return c;
    }
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

// ──────────────────────────────────────────────────────────────────────────────
// Supporting widgets
// ──────────────────────────────────────────────────────────────────────────────

class _ThumbPlaceholder extends StatelessWidget {
  const _ThumbPlaceholder({required this.isDark});
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width:  84,
      height: 60,
      child: Container(
        color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        child: Icon(
          Icons.movie_outlined,
          size:  20,
          color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
        ),
      ),
    );
  }
}

class _ActionBtn extends StatelessWidget {
  const _ActionBtn({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });
  final IconData     icon;
  final String       tooltip;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap:        onTap,
        borderRadius: BorderRadius.circular(6),
        child: Padding(
          padding: const EdgeInsets.all(6),
          child:   Icon(icon, size: 18, color: AppColors.brand),
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// Empty state — fully theme-aware
// ──────────────────────────────────────────────────────────────────────────────

class _EmptyHistory extends StatelessWidget {
  const _EmptyHistory({required this.isFiltered, required this.s});
  final bool       isFiltered;
  final AppStrings s;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color  = isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color:        isDark ? AppColors.darkCard : AppColors.lightCard,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                  width: 0.5,
                ),
              ),
              child: Icon(
                isFiltered
                    ? Icons.search_off_rounded
                    : Icons.history_rounded,
                size:  40,
                color: color,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              isFiltered ? s.noResultsFound : s.noHistoryYet,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.lightTextSecondary,
                  ),
            ),
            if (!isFiltered) ...[
              const SizedBox(height: 6),
              Text(
                'Completed downloads will appear here',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: color,
                    ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
