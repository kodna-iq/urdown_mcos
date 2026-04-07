class MediaInfo {
  final String id;
  final String title;
  final String? uploader;
  final String? uploaderUrl;
  final String? description;
  final String? thumbnailUrl;
  final int? durationSeconds;
  final String? uploadDate;
  final int? viewCount;
  final String? webpage;
  final List<FormatOption> formats;
  final List<SubtitleInfo> subtitles;
  final bool isPlaylist;
  final int? playlistCount;

  const MediaInfo({
    required this.id,
    required this.title,
    this.uploader,
    this.uploaderUrl,
    this.description,
    this.thumbnailUrl,
    this.durationSeconds,
    this.uploadDate,
    this.viewCount,
    this.webpage,
    this.formats = const [],
    this.subtitles = const [],
    this.isPlaylist = false,
    this.playlistCount,
  });

  String get durationFormatted {
    if (durationSeconds == null) return '--:--';
    final d = durationSeconds!;
    final h = d ~/ 3600;
    final m = (d % 3600) ~/ 60;
    final s = d % 60;
    if (h > 0) {
      return '${h.toString().padLeft(2, '0')}:'
             '${m.toString().padLeft(2, '0')}:'
             '${s.toString().padLeft(2, '0')}';
    }
    return '${m.toString().padLeft(2, '0')}:'
           '${s.toString().padLeft(2, '0')}';
  }

  factory MediaInfo.fromJson(Map<String, dynamic> json) {
    final formats = <FormatOption>[];
    if (json['formats'] != null) {
      for (final f in json['formats'] as List) {
        formats.add(FormatOption.fromJson(f as Map<String, dynamic>));
      }
    }

    final subtitles = <SubtitleInfo>[];
    final subs = json['subtitles'] as Map<String, dynamic>?;
    if (subs != null) {
      for (final entry in subs.entries) {
        subtitles.add(SubtitleInfo(
          language: entry.key,
          formats: (entry.value as List)
              .map((s) => (s as Map)['ext'] as String? ?? 'vtt')
              .toList(),
        ));
      }
    }

    final thumbnail = json['thumbnail'] as String? ??
        (json['thumbnails'] != null
            ? ((json['thumbnails'] as List).isNotEmpty
                ? ((json['thumbnails'] as List).last)['url'] as String?
                : null)
            : null);

    // FIX BUG-08: yt-dlp returns 'duration' as a JSON number that can be
    // either int or double (e.g. YouTube sends floats like 243.0).
    // Casting directly to int? with 'as int?' throws a TypeError for doubles.
    // Fix: read as num? and convert with toInt().
    final durationRaw = json['duration'];
    final durationSeconds = durationRaw != null
        ? (durationRaw as num).toInt()
        : null;

    return MediaInfo(
      id:              json['id']          as String? ?? '',
      title:           json['title']       as String? ?? 'Unknown Title',
      uploader:        json['uploader']    as String?,
      uploaderUrl:     json['uploader_url'] as String?,
      description:     json['description'] as String?,
      thumbnailUrl:    thumbnail,
      durationSeconds: durationSeconds,
      uploadDate:      json['upload_date'] as String?,
      viewCount:       json['view_count']  as int?,
      webpage:         json['webpage_url'] as String?,
      formats:         formats,
      subtitles:       subtitles,
      isPlaylist:      json['_type'] == 'playlist',
      playlistCount:   json['playlist_count'] as int?,
    );
  }
}

class FormatOption {
  final String formatId;
  final String? ext;
  final int? height;
  final int? width;
  final double? fps;
  final int? tbr;
  final String? vcodec;
  final String? acodec;
  final String? formatNote;
  final int? filesize;

  const FormatOption({
    required this.formatId,
    this.ext,
    this.height,
    this.width,
    this.fps,
    this.tbr,
    this.vcodec,
    this.acodec,
    this.formatNote,
    this.filesize,
  });

  bool get hasVideo => vcodec != null && vcodec != 'none';
  bool get hasAudio => acodec != null && acodec != 'none';

  String get label {
    if (height != null) return '${height}p';
    if (formatNote != null) return formatNote!;
    return formatId;
  }

  factory FormatOption.fromJson(Map<String, dynamic> json) {
    return FormatOption(
      formatId:   json['format_id']   as String? ?? '',
      ext:        json['ext']         as String?,
      height:     json['height']      as int?,
      width:      json['width']       as int?,
      fps:        (json['fps']        as num?)?.toDouble(),
      tbr:        (json['tbr']        as num?)?.toInt(),
      vcodec:     json['vcodec']      as String?,
      acodec:     json['acodec']      as String?,
      formatNote: json['format_note'] as String?,
      filesize:   json['filesize']    as int?,
    );
  }
}

class SubtitleInfo {
  final String language;
  final List<String> formats;

  const SubtitleInfo({required this.language, required this.formats});
}
