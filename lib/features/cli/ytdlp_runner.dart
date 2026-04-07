import 'dart:async';
import 'dart:typed_data';
import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../core/constants/app_constants.dart';
import '../download/models/download_job.dart';
import '../download/models/media_info.dart';
import '../settings/app_settings.dart';
import 'binary_locator.dart';
import 'progress_parser.dart';

class YtDlpRunner {
  Process? _process;
  bool _cancelled = false;

  // ─── Error classification (مطابق لـ MainActivity.kt في الأندرويد) ────

  /// يُصنّف رسالة الخطأ الخام إلى رمز خطأ آلي.
  /// مطابق لـ classifyErrorCode في MainActivity.kt
  static String classifyErrorCode(String error) {
    final e = error.toLowerCase();
    if (e.contains('status code 0')) return 'geo_block';
    if (e.contains('403') || e.contains('forbidden') || e.contains('sabr') ||
        e.contains('access denied')) return 'forbidden403';
    if (e.contains('timed out') || e.contains('timeout')) return 'timeout';
    if (e.contains('no video formats') || e.contains('requested format') ||
        e.contains('missing a url')) return 'no_formats';
    if (e.contains('sign in') || e.contains('login required') ||
        e.contains('members only') || e.contains('checkpoint')) {
      return 'auth_required';
    }
    if (e.contains('errno 7') || e.contains('gaierror') ||
        e.contains('no address associated with hostname')) return 'dns_error';
    if (e.contains('network') || e.contains('socket') ||
        e.contains('connection')) return 'network_error';
    if (e.contains('unsupported url') || e.contains('unable to extract')) {
      return 'extractor_error';
    }
    if (e.contains('private')) return 'private_content';
    if (e.contains('cancelled')) return 'cancelled';
    return 'unknown';
  }

  /// يحوّل رمز الخطأ إلى رسالة عرض للمستخدم.
  /// مطابق لـ toDisplayMessage في MainActivity.kt مع إضافات خاصة بالكوكيز.
  static String toDisplayMessage(String error) {
    final e = error.toLowerCase();
    if (e.contains('status code 0')) {
      return 'محتوى محجوب في منطقتك — جرّب استخدام VPN';
    }
    if (e.contains('403') || e.contains('forbidden') || e.contains('sabr')) {
      return 'تم رفض الوصول (403) — جرّب استيراد الكوكيز من الإعدادات';
    }
    if (e.contains('timed out') || e.contains('timeout')) {
      return 'انتهت مهلة الاتصال — يُرجى المحاولة مجدداً';
    }
    if (e.contains('no video formats') || e.contains('requested format')) {
      return 'لا توجد صيغ متاحة';
    }
    // ── رسائل خاصة بالكوكيز والتسجيل (مُستوحاة من الأندرويد) ──────────
    if (e.contains('checkpoint')) {
      return 'فيسبوك يتطلب تسجيل الدخول — استورد الكوكيز من الإعدادات';
    }
    if (e.contains('sign in') || e.contains('login required')) {
      return 'يتطلب تسجيل دخول — استورد الكوكيز من الإعدادات';
    }
    if (e.contains('members only')) {
      return 'محتوى حصري للمشتركين — استورد الكوكيز من الإعدادات';
    }
    if (e.contains('private')) return 'هذا الفيديو خاص';
    if (e.contains('errno 7') || e.contains('gaierror') ||
        e.contains('no address associated')) {
      return 'لا يوجد اتصال بالإنترنت — تحقق من الشبكة';
    }
    if (e.contains('network') || e.contains('connection') ||
        e.contains('socket')) {
      return 'خطأ في الشبكة — تحقق من الاتصال';
    }
    if (e.isEmpty) return 'خطأ غير معروف — حاول مرة أخرى';
    return error;
  }

  // ─── Static: cookie helpers ───────────────────────────────────────────

  /// يعيد args الكوكيز بناءً على النطاق.
  /// يستخدم AppConstants.cookieSiteFiles كمصدر حقيقة وحيد.
  static Future<List<String>> _cookiesArgs(String url) async {
    final siteFiles = AppConstants.cookieSiteFiles;

    String? fileName;
    for (final entry in siteFiles.entries) {
      if (url.contains(entry.key)) {
        fileName = entry.value;
        break;
      }
    }

    if (fileName == null) return [];

    try {
      final dir = await getApplicationSupportDirectory();
      final cookiesFile = File(p.join(dir.path, fileName));
      if (cookiesFile.existsSync() && cookiesFile.lengthSync() > 100) {
        print('[YtDlpRunner] Using saved cookies: $fileName');
        return ['--cookies', cookiesFile.path];
      }
    } catch (_) {}

    print('[YtDlpRunner] No saved cookies for $url');
    return [];
  }

  // ─── Static: fetch metadata ───────────────────────────────────────────

  /// يجلب معلومات الوسائط بدون تحميل (--dump-json).
  static Future<MediaInfo> fetchInfo(String url) async {
    final binaryPath = await BinaryLocator.ytDlpPath();

    final process = await Process.start(
      binaryPath,
      [
        '--dump-json',
        '--no-download',
        '--no-playlist',
        '--no-warnings',
        '--no-progress',
        ...await _cookiesArgs(url),
        url,
      ],
      runInShell: false,
    );

    final stdoutBytes = BytesBuilder();
    final stderrLines = <String>[];

    await Future.wait([
      process.stdout.forEach((chunk) => stdoutBytes.add(chunk)),
      process.stderr
          .transform(utf8.decoder)
          .transform(const LineSplitter())
          .forEach((line) => stderrLines.add(line)),
    ]);

    final exitCode = await process.exitCode;

    if (exitCode != 0) {
      // ── استخدام classifyErrorCode + toDisplayMessage مثل الأندرويد ──
      final rawError = stderrLines
          .where((l) => l.startsWith('ERROR:'))
          .map((l) => l.replaceFirst('ERROR:', '').trim())
          .join(' ');
      final fallback = stderrLines.isNotEmpty ? stderrLines.last : '';
      final errorText = rawError.isNotEmpty
          ? rawError
          : fallback.isNotEmpty
              ? fallback
              : 'yt-dlp exited with code $exitCode';

      final displayMsg = toDisplayMessage(errorText);
      throw Exception(displayMsg);
    }

    final raw = utf8.decode(stdoutBytes.toBytes(), allowMalformed: true).trim();

    if (raw.isEmpty) {
      throw Exception('yt-dlp returned empty output for URL: $url');
    }

    // البحث عن آخر سطر JSON صالح
    String? jsonLine;
    final lines = raw.split('\n');
    for (int i = lines.length - 1; i >= 0; i--) {
      final clean = lines[i].trim().replaceFirst('\uFEFF', '');
      if (clean.startsWith('{') && clean.endsWith('}')) {
        jsonLine = clean;
        break;
      }
    }
    // fallback: أطول سطر يبدأ بـ {
    if (jsonLine == null) {
      for (final line in lines) {
        final clean = line.trim().replaceFirst('\uFEFF', '');
        if (clean.startsWith('{')) {
          if (jsonLine == null || clean.length > jsonLine.length) jsonLine = clean;
        }
      }
    }

    if (jsonLine == null || jsonLine.isEmpty) {
      throw Exception('yt-dlp returned no JSON for URL: $url');
    }

    try {
      final json = jsonDecode(jsonLine) as Map<String, dynamic>;
      return MediaInfo.fromJson(json);
    } catch (e) {
      print('[YtDlpRunner] JSON parse error: $e');
      print('[YtDlpRunner] Raw start: ${jsonLine.substring(0, jsonLine.length.clamp(0, 300))}');
      try {
        final lastBrace = jsonLine.lastIndexOf('}');
        if (lastBrace > 0 && lastBrace < jsonLine.length - 1) {
          final trimmed = jsonLine.substring(0, lastBrace + 1);
          return MediaInfo.fromJson(jsonDecode(trimmed) as Map<String, dynamic>);
        }
      } catch (_) {}
      throw Exception('Failed to parse video info: $e');
    }
  }

  // ─── Instance: stream download events ────────────────────────────────

  Stream<DownloadEvent> download(DownloadJob job) async* {
    _cancelled = false;

    final binaryPath = await BinaryLocator.ytDlpPath();
    final settings = await AppSettings.load();
    final args = await _buildArgs(job, settings);

    print('[YtDlpRunner] Starting: $binaryPath');
    print('[YtDlpRunner] Args: ${args.join(' ')}');

    _process = await Process.start(
      binaryPath,
      args,
      runInShell: false,
    );

    final stderrLines = <String>[];

    final outputController = StreamController<String>();
    var stdoutDone = false;
    var stderrDone = false;

    void maybeClose() {
      if (stdoutDone && stderrDone) {
        if (!outputController.isClosed) outputController.close();
      }
    }

    _process!.stdout
        .transform(utf8.decoder)
        .transform(const LineSplitter())
        .listen(
          (line) {
            print('[yt-dlp stdout] $line');
            if (!outputController.isClosed) outputController.add(line);
          },
          onError: (Object e) {
            if (!outputController.isClosed) outputController.addError(e);
          },
          onDone: () {
            stdoutDone = true;
            maybeClose();
          },
          cancelOnError: false,
        );

    _process!.stderr
        .transform(utf8.decoder)
        .transform(const LineSplitter())
        .listen(
          (line) {
            print('[yt-dlp stderr] $line');
            stderrLines.add(line);
            if (!outputController.isClosed) outputController.add(line);
          },
          onError: (Object e) {
            if (!outputController.isClosed) outputController.addError(e);
          },
          onDone: () {
            stderrDone = true;
            maybeClose();
          },
          cancelOnError: false,
        );

    _process!.exitCode.then((_) {
      if (!outputController.isClosed) outputController.close();
    });

    await for (final line in outputController.stream) {
      if (_cancelled) break;
      final event = ProgressParser.parse(line);
      if (event != null) yield event;
    }

    if (_cancelled) return;

    final exitCode = await _process!.exitCode;
    print('[YtDlpRunner] Exit code: $exitCode');

    if (exitCode == 0) {
      yield const DownloadEventCompleted();
    } else {
      // ── تطبيق منطق الأندرويد: classifyErrorCode + toDisplayMessage ──────
      final rawError = stderrLines
          .where((l) => l.startsWith('ERROR:'))
          .map((l) => l.replaceFirst('ERROR:', '').trim())
          .join(' ');
      final fallback = stderrLines.isNotEmpty ? stderrLines.last : '';
      final errorText = rawError.isNotEmpty
          ? rawError
          : fallback.isNotEmpty
              ? fallback
              : 'yt-dlp exited with code $exitCode';

      // ── فحص رسائل الكوكيز من stderr (مثل أندرويد يفحص callback lines) ──
      final cookieHint = _extractCookieHint(stderrLines);

      final displayMsg = cookieHint ?? toDisplayMessage(errorText);
      yield DownloadEventFailed(displayMsg);
    }
  }

  /// يبحث في سطور stderr عن أي إشارة لمشاكل الكوكيز أو المصادقة.
  /// مستوحى من منطق الأندرويد الذي يفحص كل سطر في الـ callback.
  static String? _extractCookieHint(List<String> lines) {
    for (final line in lines.reversed) {
      final l = line.toLowerCase();
      if (l.contains('checkpoint')) {
        return 'فيسبوك يتطلب تسجيل الدخول — استورد الكوكيز من الإعدادات';
      }
      if (l.contains('sign in') || l.contains('login required')) {
        return 'يتطلب تسجيل دخول — استورد الكوكيز من الإعدادات';
      }
      if (l.contains('members only')) {
        return 'محتوى حصري للمشتركين — استورد الكوكيز من الإعدادات';
      }
      if (l.contains('403') || l.contains('forbidden')) {
        return 'تم رفض الوصول (403) — جرّب استيراد الكوكيز من الإعدادات';
      }
    }
    return null;
  }

  void cancel() {
    _cancelled = true;
    if (_process != null) {
      _process!.kill();
      _process = null;
    }
  }

  // ─── Argument builder ─────────────────────────────────────────────────

  Future<List<String>> _buildArgs(DownloadJob job, AppSettings settings) async {
    final args = <String>[];

    if (job.type != DownloadType.playlist) {
      args.add('--no-playlist');
    }

    final outputArg = '${job.outputPath}.%(ext)s';
    args.addAll(['--output', outputArg]);

    const audioFmts = ['mp3', 'aac', 'flac', 'wav', 'm4a', 'opus'];
    final isAudio = job.extractAudio || audioFmts.contains(job.format.toLowerCase());

    if (isAudio) {
      args.addAll(['--format', 'bestaudio/best']);
      args.addAll([
        '--extract-audio',
        '--audio-format', job.format,
        '--audio-quality', '0',
      ]);

      const thumbSupportedAudio = ['m4a', 'aac', 'opus', 'flac'];
      if (job.embedThumbnail && thumbSupportedAudio.contains(job.format.toLowerCase())) {
        args.add('--embed-thumbnail');
      }

      args.add('--add-metadata');
      args.add('--no-mtime');
    } else {
      final formatStr = _buildFormatString(job.resolution, job.format);
      args.addAll(['--format', formatStr]);
      const mergeFmts = ['mp4', 'mkv', 'webm', 'avi', 'mov'];
      if (mergeFmts.contains(job.format.toLowerCase())) {
        args.addAll(['--merge-output-format', job.format]);
      }

      if (job.embedThumbnail) {
        args.add('--embed-thumbnail');
      }
      args.add('--add-metadata');
      args.add('--no-mtime');

      if (job.downloadSubtitles) {
        args.addAll([
          '--write-subs',
          '--write-auto-subs',
          '--sub-lang', job.subtitleLanguages ?? 'en',
          '--sub-format', 'srt/vtt/best',
          '--embed-subs',
        ]);
      }
    }

    args.add('--continue');
    args.addAll(['--retries', '3']);
    args.addAll(['--fragment-retries', '3']);
    if (!isAudio) {
      args.addAll(['--concurrent-fragments', '4']);
    }

    if (settings.bandwidthLimitKBs > 0) {
      args.addAll(['--limit-rate', '${settings.bandwidthLimitKBs}K']);
    }

    // إضافة الكوكيز لتجاوز bot-detection والمحتوى المقيّد
    args.addAll(await YtDlpRunner._cookiesArgs(job.url));

    args.add('--newline');
    args.add(job.url);

    return args;
  }

  String _buildFormatString(String resolution, String format) {
    final ext = format.toLowerCase();
    final height = _resolutionToHeight(resolution);

    if (height == null) {
      return 'bestvideo[ext=$ext]+bestaudio[ext=m4a]'
          '/bestvideo+bestaudio'
          '/best';
    }

    return 'bestvideo[height<=$height][ext=$ext]+bestaudio[ext=m4a]'
        '/bestvideo[height<=$height]+bestaudio'
        '/best[height<=$height]'
        '/best';
  }

  int? _resolutionToHeight(String resolution) {
    return switch (resolution) {
      '360p'  => 360,
      '480p'  => 480,
      '720p'  => 720,
      '1080p' => 1080,
      '1440p' => 1440,
      '2160p' => 2160,
      '4K'    => 2160,
      '8K'    => 4320,
      _       => null,
    };
  }
}
