import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../cli/binary_locator.dart';
import '../settings/app_settings.dart';

// ─── State ────────────────────────────────────────────────────────────────────

enum LiveRecordStatus {
  idle,
  connecting,
  recording,
  stopping,
  saved,
  failed,
}

class LiveRecordState {
  const LiveRecordState({
    this.status = LiveRecordStatus.idle,
    this.duration = Duration.zero,
    this.outputPath,
    this.errorMessage,
    this.sizeBytes = 0,
  });

  final LiveRecordStatus status;
  final Duration duration;
  final String? outputPath;
  final String? errorMessage;
  final int sizeBytes;

  bool get isActive =>
      status == LiveRecordStatus.connecting ||
      status == LiveRecordStatus.recording;

  String get sizeFormatted {
    if (sizeBytes < 1024 * 1024) {
      return '${(sizeBytes / 1024).toStringAsFixed(1)} KB';
    }
    return '${(sizeBytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  String get durationFormatted {
    final h = duration.inHours;
    final m = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return h > 0 ? '$h:$m:$s' : '$m:$s';
  }

  LiveRecordState copyWith({
    LiveRecordStatus? status,
    Duration? duration,
    String? outputPath,
    String? errorMessage,
    int? sizeBytes,
  }) =>
      LiveRecordState(
        status: status ?? this.status,
        duration: duration ?? this.duration,
        outputPath: outputPath ?? this.outputPath,
        errorMessage: errorMessage,
        sizeBytes: sizeBytes ?? this.sizeBytes,
      );
}

// ─── Recorder ─────────────────────────────────────────────────────────────────

class LiveRecorder {
  Process? _process;
  Timer? _durationTimer;
  Timer? _sizeTimer;
  bool _stopped = false;
  String? _outputFilePath;

  final _stateController = StreamController<LiveRecordState>.broadcast();
  Stream<LiveRecordState> get stateStream => _stateController.stream;

  LiveRecordState _state = const LiveRecordState();
  LiveRecordState get currentState => _state;

  void _emit(LiveRecordState s) {
    _state = s;
    if (!_stateController.isClosed) _stateController.add(s);
  }

  // ── Supported platforms ──────────────────────────────────────────────
  static const supportedPlatforms = [
    'YouTube',
    'TikTok',
    'Facebook',
    'Instagram',
    'Twitch',
    'Twitter / X',
    'Other',
  ];

  static bool isLiveUrl(String url) {
    final u = url.toLowerCase();
    // YouTube live
    if (u.contains('youtube.com/live') ||
        u.contains('youtu.be') ||
        u.contains('youtube.com/watch')) return true;
    // TikTok live
    if (u.contains('tiktok.com') && u.contains('live')) return true;
    // Facebook live
    if (u.contains('facebook.com') || u.contains('fb.watch')) return true;
    // Instagram live
    if (u.contains('instagram.com')) return true;
    // Twitch
    if (u.contains('twitch.tv')) return true;
    // Twitter/X
    if (u.contains('twitter.com') || u.contains('x.com')) return true;
    return false;
  }

  // ── Start recording ──────────────────────────────────────────────────
  Future<void> start({
    required String url,
    required String quality,        // 'best', '1080p', '720p', '480p', '360p'
    required String outputFormat,   // 'mp4', 'mkv', 'ts'
    int? maxDurationSeconds,        // null = unlimited
  }) async {
    if (_state.isActive) return;
    _stopped = false;

    _emit(_state.copyWith(
      status: LiveRecordStatus.connecting,
      duration: Duration.zero,
      sizeBytes: 0,
      errorMessage: null,
    ));

    try {
      final binaryPath = await BinaryLocator.ytDlpPath();
      final settings = await AppSettings.load();
      final outputPath = await _buildOutputPath(url, outputFormat);
      _outputFilePath = outputPath;

      final args = await _buildArgs(
        url: url,
        quality: quality,
        outputFormat: outputFormat,
        outputPath: outputPath,
        maxDurationSeconds: maxDurationSeconds,
        settings: settings,
      );

      print('[LiveRecorder] Starting: $binaryPath');
      print('[LiveRecorder] Args: ${args.join(' ')}');

      _process = await Process.start(binaryPath, args, runInShell: false);

      // Detect recording start — broad pattern for all platforms:
      // YouTube:[download] fragment N/N  TikTok/FB/Twitch:[SiteName]...
      // Any % sign, ETA, frag keyword, or [bracket] means data is flowing
      void onLine(String line) {
        print('[LiveRecorder] $line');
        if (_state.status == LiveRecordStatus.connecting) {
          final isData = line.contains('[download]') ||
              line.contains('fragment') ||
              line.contains('Downloading') ||
              line.contains('Writing') ||
              line.contains('ETA') ||
              line.contains('frag ') ||
              line.contains('%') ||
              RegExp(r'^\[\w').hasMatch(line);
          if (isData) {
            _emit(_state.copyWith(status: LiveRecordStatus.recording));
            _startTimers(outputPath);
          }
        }
        if (line.startsWith('ERROR:') && !_stopped) {
          final raw = line.replaceFirst('ERROR:', '').trim();
          _emit(_state.copyWith(
            status: LiveRecordStatus.failed,
            errorMessage: _friendlyError(raw),
          ));
        }
      }

      _process!.stderr
          .transform(utf8.decoder)
          .transform(const LineSplitter())
          .listen(onLine);

      _process!.stdout
          .transform(utf8.decoder)
          .transform(const LineSplitter())
          .listen(onLine);

      // Fallback: if still connecting after 8s, assume recording started
      Future.delayed(const Duration(seconds: 8), () {
        if (_state.status == LiveRecordStatus.connecting && !_stopped) {
          _emit(_state.copyWith(status: LiveRecordStatus.recording));
          _startTimers(outputPath);
        }
      });

      // Wait for process with a 10s timeout after stop() was called
      int exitCode;
      try {
        exitCode = await _process!.exitCode
            .timeout(const Duration(seconds: 10), onTimeout: () => -1);
      } catch (_) {
        exitCode = -1;
      }
      _stopTimers();

      if (_stopped) {
        // Wait for ffmpeg to finish muxing — it needs time after yt-dlp is killed
        await Future.delayed(const Duration(seconds: 4));
        final savedPath = _findAndFixPartFile(outputPath, outputFormat);
        _emit(_state.copyWith(
          status: LiveRecordStatus.saved,
          outputPath: savedPath,
        ));
      } else if (exitCode == 0 || exitCode == -1) {
        // Stream ended naturally
        await Future.delayed(const Duration(seconds: 2));
        final savedPath = _findAndFixPartFile(outputPath, outputFormat);
        _emit(_state.copyWith(
          status: LiveRecordStatus.saved,
          outputPath: savedPath,
        ));
      } else {
        if (_state.status != LiveRecordStatus.failed) {
          // Check if file was partially recorded despite error
          final partialPath = _findSavedFile(outputPath, outputFormat);
          final hasFile = partialPath != null &&
              File(partialPath).existsSync() &&
              File(partialPath).lengthSync() > 1024;
          if (hasFile) {
            _emit(_state.copyWith(
              status: LiveRecordStatus.saved,
              outputPath: partialPath,
            ));
          } else {
            _emit(_state.copyWith(
              status: LiveRecordStatus.failed,
              errorMessage: 'فشل التسجيل (كود $exitCode). '
                  'تأكد من صحة الرابط وأن البث لا يزال نشطاً.',
            ));
          }
        }
      }
    } catch (e) {
      _stopTimers();
      _emit(_state.copyWith(
        status: LiveRecordStatus.failed,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      ));
    }
  }

  // ── Stop ─────────────────────────────────────────────────────────────
  void stop() {
    if (!_state.isActive) return;
    _stopped = true;
    _stopTimers();
    _emit(_state.copyWith(status: LiveRecordStatus.stopping));

    final proc = _process;
    if (proc == null) {
      // No process — just mark saved immediately
      final savedPath = _findSavedFile(_outputFilePath ?? '', 'mp4');
      _emit(_state.copyWith(status: LiveRecordStatus.saved, outputPath: savedPath));
      return;
    }

    // Windows: SIGINT not supported — send Ctrl+C via taskkill, then force kill
    if (Platform.isWindows) {
      // Kill yt-dlp process tree — ffmpeg subprocess will then finish muxing
      Process.run('taskkill', ['/PID', '${proc.pid}', '/T', '/F'],
          runInShell: false);
    } else {
      proc.kill(ProcessSignal.sigterm);
    }

    // Do NOT force kill immediately — let ffmpeg finish muxing the .part file
    // Force kill only after 15s if process is still hanging
    Future.delayed(const Duration(seconds: 15), () {
      try { proc.kill(); } catch (_) {}
    });
  }

  void dispose() {
    stop();
    _durationTimer?.cancel();
    _sizeTimer?.cancel();
    _stateController.close();
  }

  // ── Timers ───────────────────────────────────────────────────────────
  void _startTimers(String outputPath) {
    _durationTimer ??= Timer.periodic(const Duration(seconds: 1), (_) {
      _emit(_state.copyWith(
        duration: _state.duration + const Duration(seconds: 1),
      ));
    });
    _sizeTimer ??= Timer.periodic(const Duration(seconds: 2), (_) {
      _updateSize(outputPath);
    });
  }

  void _stopTimers() {
    _durationTimer?.cancel();
    _sizeTimer?.cancel();
    _durationTimer = null;
    _sizeTimer = null;
  }

  void _updateSize(String basePath) {
    try {
      for (final ext in ['mp4', 'mkv', 'ts', 'part', 'temp']) {
        final f = File('$basePath.$ext');
        if (f.existsSync()) {
          final sz = f.lengthSync();
          if (sz > 0) {
            _emit(_state.copyWith(sizeBytes: sz));
            return;
          }
        }
      }
    } catch (_) {}
  }

  String? _findSavedFile(String basePath, String format) {
    if (basePath.isEmpty) return null;
    // Check exact extensions first
    for (final ext in [format, 'mp4', 'mkv', 'ts', 'webm', 'part']) {
      final f = File('$basePath.$ext');
      if (f.existsSync() && f.lengthSync() > 1024) return f.path;
    }
    // Search the directory for any file starting with the base name
    try {
      final dir = Directory(p.dirname(basePath));
      final baseName = p.basename(basePath);
      if (dir.existsSync()) {
        final matches = dir
            .listSync()
            .whereType<File>()
            .where((f) => p.basename(f.path).startsWith(baseName))
            .toList()
          ..sort((a, b) => b.lengthSync().compareTo(a.lengthSync()));
        if (matches.isNotEmpty) return matches.first.path;
      }
    } catch (_) {}
    return null;
  }

  // ── Args builder ─────────────────────────────────────────────────────
  Future<List<String>> _buildArgs({
    required String url,
    required String quality,
    required String outputFormat,
    required String outputPath,
    int? maxDurationSeconds,
    required AppSettings settings,
  }) async {
    final args = <String>[
      '--no-playlist',
      '--output', '$outputPath.%(ext)s',
      '--no-warnings',
      '--newline',
      '--retries', '10',
      '--fragment-retries', '10',
      '--skip-unavailable-fragments',
    ];

    // --live-from-start only works on YouTube — skip for other platforms
    // to avoid yt-dlp rejecting the flag silently
    final isYoutube = url.contains('youtube') || url.contains('youtu.be');
    if (isYoutube) {
      args.add('--live-from-start');
    }

    // Output format — ts is most reliable for live, mp4/mkv for others
    if (['mp4', 'mkv', 'ts'].contains(outputFormat)) {
      args.addAll(['--merge-output-format', outputFormat]);
    }

    // Quality / format selection
    if (quality == 'best') {
      args.addAll(['--format', 'bestvideo+bestaudio/best']);
    } else {
      final h = _qualityToHeight(quality);
      if (h != null) {
        args.addAll([
          '--format',
          'bestvideo[height<=$h]+bestaudio/best[height<=$h]/best',
        ]);
      } else {
        args.addAll(['--format', 'bestvideo+bestaudio/best']);
      }
    }

    // Max duration using ffmpeg section time
    if (maxDurationSeconds != null && maxDurationSeconds > 0) {
      args.addAll([
        '--postprocessor-args',
        'ffmpeg:-t $maxDurationSeconds',
      ]);
    }

    // Rate limit
    if (settings.bandwidthLimitKBs > 0) {
      args.addAll(['--limit-rate', '${settings.bandwidthLimitKBs}K']);
    }

    // Cookies: first try saved cookies file, then fallback to browser extraction
    final cookies = await _cookiesArgs(url);
    if (cookies.isNotEmpty) {
      args.addAll(cookies);
    } else {
      // All platforms benefit from browser cookies — especially YouTube (anti-bot)
      // and TikTok/Facebook/Instagram (login-required)
      // Try Chrome first, then Edge (common on Windows)
      final u = url.toLowerCase();
      final needsBrowser = u.contains('youtube') ||
          u.contains('youtu.be') ||
          u.contains('tiktok.com') ||
          u.contains('instagram.com') ||
          u.contains('facebook.com') ||
          u.contains('fb.watch');
      if (needsBrowser) {
        if (Platform.isWindows) {
          // Try Edge first (default on Windows), then Chrome
          args.addAll(['--cookies-from-browser', 'edge']);
        } else {
          args.addAll(['--cookies-from-browser', 'chrome']);
        }
      }
    }

    args.add(url);
    return args;
  }

  // ── Cookies helper (mirrors YtDlpRunner._cookiesArgs) ─────────────────
  static Future<List<String>> _cookiesArgs(String url) async {
    const siteFiles = {
      'youtube.com':   'youtube_cookies.txt',
      'youtu.be':      'youtube_cookies.txt',
      'facebook.com':  'facebook_cookies.txt',
      'fb.watch':      'facebook_cookies.txt',
      'tiktok.com':    'tiktok_cookies.txt',
      'instagram.com': 'instagram_cookies.txt',
    };
    String? fileName;
    for (final entry in siteFiles.entries) {
      if (url.contains(entry.key)) { fileName = entry.value; break; }
    }
    if (fileName == null) return [];
    try {
      final dir = await getApplicationSupportDirectory();
      final f = File(p.join(dir.path, fileName));
      if (f.existsSync() && f.lengthSync() > 100) {
        return ['--cookies', f.path];
      }
    } catch (_) {}
    return [];
  }

    /// Finds saved file and renames .part → proper extension if needed.
  String? _findAndFixPartFile(String basePath, String format) {
    if (basePath.isEmpty) return null;

    // Check complete files first
    for (final ext in [format, 'mp4', 'mkv', 'ts', 'webm']) {
      final f = File('$basePath.$ext');
      if (f.existsSync() && f.lengthSync() > 1024) return f.path;
    }

    // Check .part files — rename them to proper extension
    for (final ext in ['mp4.part', 'mkv.part', 'ts.part', 'part']) {
      final f = File('$basePath.$ext');
      if (f.existsSync() && f.lengthSync() > 1024) {
        // Rename .part → .mp4 (or original format)
        final targetExt = ext.contains('.') ? ext.split('.').first : format;
        final newPath = '$basePath.$targetExt';
        try {
          f.renameSync(newPath);
          print('[LiveRecorder] Renamed $ext → $targetExt');
          return newPath;
        } catch (_) {
          return f.path; // return .part path if rename fails
        }
      }
    }

    // Search directory for any file with our base name
    try {
      final dir = Directory(p.dirname(basePath));
      final baseName = p.basename(basePath);
      if (dir.existsSync()) {
        final matches = dir
            .listSync()
            .whereType<File>()
            .where((f) => p.basename(f.path).startsWith(baseName) && f.lengthSync() > 1024)
            .toList()
          ..sort((a, b) => b.lengthSync().compareTo(a.lengthSync()));
        if (matches.isNotEmpty) return matches.first.path;
      }
    } catch (_) {}

    return null;
  }

    /// Translates yt-dlp error messages to Arabic user-friendly text.
  static String _friendlyError(String raw) {
    final r = raw.toLowerCase();
    if (r.contains('not currently live') || r.contains('is not live')) {
      return 'البث غير نشط حالياً — تأكد أن الشخص يبث الآن';
    }
    if (r.contains('private') || r.contains('login') || r.contains('sign in')) {
      return 'البث خاص أو يتطلب تسجيل دخول — أضف الكوكيز من الإعدادات';
    }
    if (r.contains('not found') || r.contains('does not exist') || r.contains('no such')) {
      return 'الحساب أو الرابط غير موجود — تحقق من الرابط';
    }
    if (r.contains('geo') || r.contains('country') || r.contains('not available in your')) {
      return 'البث محظور في منطقتك — جرّب VPN';
    }
    if (r.contains('rate') || r.contains('too many requests')) {
      return 'طلبات كثيرة — انتظر دقيقة وحاول مجدداً';
    }
    if (r.contains('cookies') || r.contains('authentication')) {
      return 'خطأ في الكوكيز — تأكد من تسجيل الدخول في Edge أو Chrome';
    }
    if (r.contains('network') || r.contains('connect') || r.contains('timeout')) {
      return 'خطأ في الاتصال بالإنترنت — تحقق من اتصالك';
    }
    if (r.contains('unsupported url') || r.contains('ie:generic')) {
      return 'الرابط غير مدعوم — تأكد أنه رابط بث مباشر صحيح';
    }
    // Return original if no match
    return raw;
  }

    int? _qualityToHeight(String q) => switch (q) {
        '360p' => 360,
        '480p' => 480,
        '720p' => 720,
        '1080p' => 1080,
        '1440p' => 1440,
        '2160p' => 2160,
        _ => null,
      };

  Future<String> _buildOutputPath(String url, String format) async {
    final settings = await AppSettings.load();
    String outDir = settings.outputDirectory;
    if (outDir.isEmpty) {
      final dir = await getDownloadsDirectory() ??
          await getApplicationDocumentsDirectory();
      outDir = dir.path;
    }

    // Build a safe filename from URL + timestamp
    final ts = DateTime.now();
    final stamp =
        '${ts.year}${ts.month.toString().padLeft(2,'0')}${ts.day.toString().padLeft(2,'0')}'
        '_${ts.hour.toString().padLeft(2,'0')}${ts.minute.toString().padLeft(2,'0')}';

    String site = 'live';
    if (url.contains('youtube')) site = 'youtube';
    else if (url.contains('tiktok')) site = 'tiktok';
    else if (url.contains('facebook') || url.contains('fb.watch')) site = 'facebook';
    else if (url.contains('instagram')) site = 'instagram';
    else if (url.contains('twitch')) site = 'twitch';
    else if (url.contains('twitter') || url.contains('x.com')) site = 'twitter';

    return p.join(outDir, '${site}_live_$stamp');
  }
}
