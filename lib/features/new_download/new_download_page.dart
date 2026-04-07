import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme.dart';
import '../../core/constants/app_constants.dart';
import '../../core/l10n/app_strings.dart';
import '../../services/url_sanitizer.dart';
import '../download/models/media_info.dart';
import '../download/services/download_manager.dart';
import '../live/live_record_tab.dart';
import '../media/media_info_fetcher.dart';

// ──────────────────────────────────────────────────────────────────────────────
// NewDownloadPage
// ──────────────────────────────────────────────────────────────────────────────

class NewDownloadPage extends ConsumerStatefulWidget {
  const NewDownloadPage({super.key, this.initialUrl});
  final String? initialUrl;

  @override
  ConsumerState<NewDownloadPage> createState() => _NewDownloadPageState();
}

class _NewDownloadPageState extends ConsumerState<NewDownloadPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tab;

  // Single download
  final _urlCtrl  = TextEditingController();
  final _formKey  = GlobalKey<FormState>();
  bool       _isFetching  = false;
  MediaInfo? _mediaInfo;
  String?    _fetchError;
  bool       _isDownloading = false;

  // Bulk download
  final _bulkCtrl = TextEditingController();
  bool   _isBulkDownloading = false;
  String _bulkStatus = '';

  // Shared options
  String _format     = AppConstants.defaultFormat;
  String _resolution = AppConstants.defaultResolution;
  bool   _subtitles  = false;
  bool   _thumbnail  = true;
  bool   _audioOnly  = false;
  final _subtitleLangCtrl = TextEditingController(text: 'en');

  static bool _isLiveUrl(String url) {
    final u = url.toLowerCase();
    return u.contains('/live') ||
        u.contains('twitch.tv') ||
        (u.contains('tiktok.com') && u.contains('live')) ||
        u.contains('fb.watch') ||
        (u.contains('facebook.com') && (u.contains('/live') || u.contains('/videos')));
  }

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 3, vsync: this);
    if (widget.initialUrl != null) {
      final url  = widget.initialUrl!;
      final urls = _parseUrls(url);
      if (urls.length > 1) {
        _bulkCtrl.text = urls.join('\n');
        _tab.animateTo(1);
      } else if (_isLiveUrl(url)) {
        _tab.animateTo(2);
      } else {
        _urlCtrl.text = url;
        WidgetsBinding.instance.addPostFrameCallback((_) => _fetchInfo());
      }
    }
  }

  @override
  void dispose() {
    _tab.dispose();
    _urlCtrl.dispose();
    _bulkCtrl.dispose();
    _subtitleLangCtrl.dispose();
    super.dispose();
  }

  List<String> _parseUrls(String text) => text
      .split(RegExp(r'[\n\r\s]+'))
      .map((u) => u.trim())
      .where((u) => u.startsWith('http'))
      .toList();

  Future<void> _fetchInfo() async {
    final url = _urlCtrl.text.trim();
    if (url.isEmpty) return;
    if (!UrlSanitizer.isValid(url)) {
      setState(() => _fetchError = 'Invalid URL. Only http/https is supported.');
      return;
    }
    setState(() {
      _isFetching = true;
      _fetchError = null;
      _mediaInfo  = null;
    });
    try {
      final fetcher = ref.read(mediaInfoFetcherProvider);
      final info    = await fetcher.fetch(url);
      if (mounted) setState(() => _mediaInfo = info);
    } catch (e) {
      if (mounted) {
        setState(() =>
            _fetchError = e.toString().replaceAll('Exception: ', ''));
      }
    } finally {
      if (mounted) setState(() => _isFetching = false);
    }
  }

  Future<void> _startDownload() async {
    if (_mediaInfo == null) return;
    setState(() => _isDownloading = true);
    try {
      final manager = ref.read(downloadManagerProvider);
      await manager.enqueue(
        url:               _urlCtrl.text.trim(),
        info:              _mediaInfo!,
        format:            _format,
        resolution:        _resolution,
        downloadSubtitles: _subtitles,
        embedThumbnail:    _thumbnail,
        extractAudio:      _audioOnly,
        subtitleLanguages: _subtitles ? _subtitleLangCtrl.text.trim() : null,
      );
      if (mounted) context.goNamed('queue');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isDownloading = false);
    }
  }

  Future<void> _importTxt() async {
    final r = await FilePicker.platform
        .pickFiles(type: FileType.custom, allowedExtensions: ['txt']);
    if (r?.files.single.path != null) {
      final text = await File(r!.files.single.path!).readAsString();
      final urls = _parseUrls(text);
      setState(() {
        _bulkCtrl.text = urls.join('\n');
        _bulkStatus    = '${urls.length} URLs imported';
      });
    }
  }

  Future<void> _startBulk() async {
    final urls = _parseUrls(_bulkCtrl.text);
    if (urls.isEmpty) return;
    setState(() {
      _isBulkDownloading = true;
      _bulkStatus        = 'Starting…';
    });
    try {
      final manager = ref.read(downloadManagerProvider);
      final fetcher = ref.read(mediaInfoFetcherProvider);
      var success   = 0;

      for (var i = 0; i < urls.length; i++) {
        setState(() => _bulkStatus = 'Fetching ${i + 1}/${urls.length}…');
        try {
          final info = await fetcher.fetch(urls[i]);
          await manager.enqueue(
            url:               urls[i],
            info:              info,
            format:            _format,
            resolution:        _resolution,
            downloadSubtitles: _subtitles,
            embedThumbnail:    _thumbnail,
            extractAudio:      _audioOnly,
            subtitleLanguages: _subtitles ? _subtitleLangCtrl.text.trim() : null,
          );
          success++;
        } catch (_) {}
      }

      setState(() => _bulkStatus = 'Done — $success/${urls.length} added');
      if (mounted) context.goNamed('queue');
    } finally {
      if (mounted) setState(() => _isBulkDownloading = false);
    }
  }

  // ── Shared options panel ───────────────────────────────────────────────────

  Widget _sharedOptions(AppStrings s) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Label(s.outputOptions),
        const SizedBox(height: 12),
        Row(children: [
          Expanded(
            child: _Dropdown(
              label:     s.format,
              value:     _format,
              items:     [...AppConstants.videoFormats, ...AppConstants.audioFormats],
              onChanged: (v) => setState(() => _format = v ?? _format),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _Dropdown(
              label:     s.resolution,
              value:     _resolution,
              items:     AppConstants.resolutions,
              onChanged: (v) => setState(() => _resolution = v ?? _resolution),
            ),
          ),
        ]),
        const SizedBox(height: 16),
        _Label(s.options),
        const SizedBox(height: 8),
        _Toggle(
          icon:      Icons.image_outlined,
          label:     s.embedThumbnail,
          subtitle:  s.addCoverArt,
          value:     _thumbnail,
          onChanged: (v) => setState(() => _thumbnail = v),
        ),
        _Toggle(
          icon:      Icons.music_note_outlined,
          label:     s.extractAudio,
          subtitle:  s.saveAsAudio,
          value:     _audioOnly,
          onChanged: (v) {
            setState(() {
              _audioOnly = v;
              if (v && const ['mp4','mkv','webm','avi','mov']
                  .contains(_format.toLowerCase())) {
                _format = 'mp3';
              }
            });
          },
        ),
        _Toggle(
          icon:      Icons.subtitles_outlined,
          label:     s.downloadSubtitles,
          subtitle:  s.downloadSubtitleTracks,
          value:     _subtitles,
          onChanged: (v) => setState(() => _subtitles = v),
        ),
        if (_subtitles && !_audioOnly) ...[
          const SizedBox(height: 4),
          _Label(s.subtitleLanguage),
          const SizedBox(height: 6),
          TextField(
            controller: _subtitleLangCtrl,
            decoration: InputDecoration(
              hintText:   s.subtitleLangHint,
              prefixIcon: const Icon(Icons.language_rounded, size: 18),
              isDense:    true,
            ),
          ),
        ],
      ],
    );
  }

  // ── Single URL tab ─────────────────────────────────────────────────────────

  Widget _singleTab(AppStrings s) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _Label(s.videoURL),
            const SizedBox(height: 8),

            // URL row
            Row(children: [
              Expanded(
                child: TextFormField(
                  controller: _urlCtrl,
                  decoration: InputDecoration(
                    hintText:   'https://youtube.com/watch?v=…',
                    prefixIcon: const Icon(Icons.link_rounded),
                    suffixIcon: _urlCtrl.text.isNotEmpty
                        ? IconButton(
                            icon:      const Icon(Icons.clear_rounded),
                            onPressed: () {
                              _urlCtrl.clear();
                              setState(() {
                                _mediaInfo  = null;
                                _fetchError = null;
                              });
                            },
                          )
                        : null,
                  ),
                  onChanged:      (_) => setState(() {}),
                  onFieldSubmitted: (_) => _fetchInfo(),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Enter a URL';
                    if (!UrlSanitizer.isValid(v)) return 'Invalid URL';
                    return null;
                  },
                ),
              ),
              const SizedBox(width: 12),
              FilledButton.icon(
                onPressed: _isFetching ? null : _fetchInfo,
                icon: _isFetching
                    ? const _Spinner()
                    : const Icon(Icons.search_rounded),
                label: Text(s.fetch),
              ),
            ]),

            // Fetch error
            if (_fetchError != null) ...[
              const SizedBox(height: 12),
              _ErrorBox(message: _fetchError!),
            ],

            // Media preview + options
            if (_mediaInfo != null) ...[
              const SizedBox(height: 24),
              _MediaPreview(info: _mediaInfo!),
              const SizedBox(height: 24),
              _sharedOptions(s),
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: (_isDownloading || _mediaInfo == null)
                      ? null
                      : _startDownload,
                  icon:  _isDownloading
                      ? const _Spinner()
                      : const Icon(Icons.download_rounded),
                  label: Text(_isDownloading ? s.adding : s.startDownload),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 15),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ── Bulk URL tab ───────────────────────────────────────────────────────────

  Widget _bulkTab(AppStrings s) {
    final urls = _parseUrls(_bulkCtrl.text);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Expanded(child: _Label(s.bulkUrls)),
            OutlinedButton.icon(
              onPressed: _importTxt,
              icon:      const Icon(Icons.upload_file_rounded, size: 16),
              label:     Text(s.importTxt),
            ),
          ]),
          const SizedBox(height: 8),

          // Multiline text field
          TextField(
            controller: _bulkCtrl,
            maxLines:   10,
            onChanged:  (_) => setState(() {}),
            decoration: const InputDecoration(
              hintText:        'https://youtube.com/watch?v=…\nhttps://…',
              contentPadding:  EdgeInsets.all(14),
            ),
          ),
          const SizedBox(height: 8),

          if (urls.isNotEmpty)
            _CountBadge(count: urls.length),
          if (_bulkStatus.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              _bulkStatus,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],

          const SizedBox(height: 24),
          _sharedOptions(s),
          const SizedBox(height: 28),

          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: (urls.isEmpty || _isBulkDownloading)
                  ? null
                  : _startBulk,
              icon:  _isBulkDownloading
                  ? const _Spinner()
                  : const Icon(Icons.download_rounded),
              label: Text(
                _isBulkDownloading ? _bulkStatus : s.download,
              ),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 15),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = ref.watch(stringsProvider);

    return Scaffold(
      appBar: AppBar(
        title:   Text(s.newDownload),
        leading: IconButton(
          icon:      const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
        bottom: TabBar(
          controller: _tab,
          tabs: [
            Tab(icon: const Icon(Icons.link_rounded),                  text: s.singleURL),
            Tab(icon: const Icon(Icons.list_rounded),                  text: s.bulk),
            Tab(icon: const Icon(Icons.fiber_manual_record_rounded),   text: 'Live'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tab,
        children: [
          _singleTab(s),
          _bulkTab(s),
          LiveRecordTab(initialUrl: widget.initialUrl),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// Media preview card — theme-aware
// ──────────────────────────────────────────────────────────────────────────────

class _MediaPreview extends StatelessWidget {
  const _MediaPreview({required this.info});
  final MediaInfo info;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        color:        isDark ? AppColors.darkCard : AppColors.lightCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          width: 0.5,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Thumbnail
          if (info.thumbnailUrl != null)
            ClipRRect(
              borderRadius: const BorderRadius.horizontal(
                left: Radius.circular(14),
              ),
              child: CachedNetworkImage(
                imageUrl:    info.thumbnailUrl!,
                width:       120,
                height:      82,
                fit:         BoxFit.cover,
                errorWidget: (_, __, ___) => const SizedBox.shrink(),
              ),
            ),

          // Info
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    info.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 10,
                    children: [
                      if (info.uploader != null)
                        _MetaChip(
                          label: info.uploader!,
                          icon:  Icons.person_outline_rounded,
                        ),
                      _MetaChip(
                        label: info.durationFormatted,
                        icon:  Icons.schedule_rounded,
                      ),
                      if (info.subtitles.isNotEmpty)
                        _MetaChip(
                          label: '${info.subtitles.length} subs',
                          icon:  Icons.subtitles_outlined,
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// Small supporting widgets
// ──────────────────────────────────────────────────────────────────────────────

class _Label extends StatelessWidget {
  const _Label(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(context).textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  const _MetaChip({required this.label, required this.icon});
  final String   label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color  = isDark
        ? AppColors.darkTextSecondary
        : AppColors.lightTextSecondary;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: color),
        const SizedBox(width: 4),
        Text(label,
            style: TextStyle(fontSize: 12, color: color)),
      ],
    );
  }
}

class _ErrorBox extends StatelessWidget {
  const _ErrorBox({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color:        AppColors.error.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline_rounded,
              color: AppColors.error, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(message,
                style: const TextStyle(color: AppColors.error, fontSize: 13)),
          ),
        ],
      ),
    );
  }
}

class _CountBadge extends StatelessWidget {
  const _CountBadge({required this.count});
  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color:        AppColors.brand.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.brand.withValues(alpha: 0.2)),
      ),
      child: Text(
        '$count valid URL${count == 1 ? '' : 's'} detected',
        style: const TextStyle(
          color:      AppColors.brand,
          fontSize:   13,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _Toggle extends StatelessWidget {
  const _Toggle({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });
  final IconData          icon;
  final String            label;
  final String            subtitle;
  final bool              value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color:        isDark ? AppColors.darkCard : AppColors.lightCard,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          width: 0.5,
        ),
      ),
      child: SwitchListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
        secondary: Icon(icon, size: 20, color: AppColors.brand),
        title:    Text(label,    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
        value:     value,
        onChanged: onChanged,
      ),
    );
  }
}

class _Dropdown extends StatelessWidget {
  const _Dropdown({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  });
  final String             label;
  final String             value;
  final List<String>       items;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(height: 4),
        DropdownButtonFormField<String>(
          value: value,
          decoration: const InputDecoration(isDense: true),
          items: items
              .map((e) => DropdownMenuItem(value: e, child: Text(e)))
              .toList(),
          onChanged: onChanged,
        ),
      ],
    );
  }
}

/// 14×14 spinner for button loading states
class _Spinner extends StatelessWidget {
  const _Spinner();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width:  14,
      height: 14,
      child:  CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
    );
  }
}
