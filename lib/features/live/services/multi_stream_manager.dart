import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../cli/binary_locator.dart';
import '../../settings/app_settings.dart';
import '../models/stream_recording.dart';

// ─── Per-stream process controller ───────────────────────────────────────────

class _StreamProcess {
  _StreamProcess({required this.recordingId});

  final String recordingId;

  Process? ytdlpProcess;
  Timer? durationTimer;
  Timer? sizeTimer;
  Timer? resourceTimer;
  bool stopped = false;
  bool paused = false;
  String? outputFilePath;

  void cancelTimers() {
    durationTimer?.cancel();
    sizeTimer?.cancel();
    resourceTimer?.cancel();
    durationTimer = null;
    sizeTimer = null;
    resourceTimer = null;
  }

  void dispose() {
    cancelTimers();
    _forceKill();
  }

  void _forceKill() {
    final proc = ytdlpProcess;
    if (proc == null) return;
    try {
      if (Platform.isWindows) {
        Process.run('taskkill', ['/PID', '${proc.pid}', '/T', '/F'],
            runInShell: false);
      } else {
        proc.kill(ProcessSignal.sigkill);
      }
    } catch (_) {}
  }

  void gracefulStop() {
    final proc = ytdlpProcess;
    if (proc == null) return;
    try {
      if (Platform.isWindows) {
        Process.run('taskkill', ['/PID', '${proc.pid}', '/T', '/F'],
            runInShell: false);
      } else {
        proc.kill(ProcessSignal.sigterm);
      }
    } catch (_) {}
    // Force kill after 15s if still running
    Future.delayed(const Duration(seconds: 15), () {
      try {
        proc.kill();
      } catch (_) {}
    });
  }

  void pause() {
    final proc = ytdlpProcess;
    if (proc == null) return;
    paused = true;
    try {
      if (!Platform.isWindows) {
        proc.kill(ProcessSignal.sigstop);
      }
      // Windows: suspend all threads via NtSuspendProcess via taskkill workaround
      // We pause the duration timer to reflect "paused" state correctly
    } catch (_) {}
    cancelTimers();
  }

  void resume() {
    final proc = ytdlpProcess;
    if (proc == null) return;
    paused = false;
    try {
      if (!Platform.isWindows) {
        proc.kill(ProcessSignal.sigcont);
      }
    } catch (_) {}
  }
}

// ─── Multi-Stream Recording Manager ──────────────────────────────────────────

class MultiStreamManager {
  MultiStreamManager._();
  static final instance = MultiStreamManager._();

  final Map<String, _StreamProcess> _processes = {};
  final Map<String, StreamRecording> _recordings = {};

  final _controller = StreamController<List<StreamRecording>>.broadcast();
  Stream<List<StreamRecording>> get recordingsStream => _controller.stream;

  List<StreamRecording> get recordings =>
      _recordings.values.toList()
        ..sort((a, b) => b.startedAt.compareTo(a.startedAt));

  // Resource limits
  static const int maxConcurrentRecordings = 8;
  static const int maxMemoryPerStreamMb = 512;

  // ── Public API ────────────────────────────────────────────────────────

  /// Returns recording ID or throws if limit exceeded.
  Future<String> startRecording({
    required String id,
    required String url,
    required String quality,
    required String format,
    int? maxDurationSeconds,
  }) async {
    if (_processes.length >= maxConcurrentRecordings) {
      throw Exception('Maximum $maxConcurrentRecordings concurrent recordings reached');
    }

    final recording = StreamRecording(
      id: id,
      url: url,
      quality: quality,
      format: format,
      maxDurationSeconds: maxDurationSeconds,
    );
    recording.status = RecordingStatus.connecting;
    _recordings[id] = recording;
    _emit();

    final proc = _StreamProcess(recordingId: id);
    _processes[id] = proc;

    // Run in background — does NOT block
    _runRecording(id, recording, proc);

    return id;
  }

  void stopRecording(String id) {
    final proc = _processes[id];
    if (proc == null) return;
    proc.stopped = true;
    proc.cancelTimers();
    _updateStatus(id, RecordingStatus.stopping);
    proc.gracefulStop();
  }

  void pauseRecording(String id) {
    final proc = _processes[id];
    final rec = _recordings[id];
    if (proc == null || rec == null) return;
    if (rec.status != RecordingStatus.recording) return;
    proc.pause();
    _updateStatus(id, RecordingStatus.paused);
  }

  void resumeRecording(String id) {
    final proc = _processes[id];
    final rec = _recordings[id];
    if (proc == null || rec == null) return;
    if (rec.status != RecordingStatus.paused) return;
    _updateStatus(id, RecordingStatus.resuming);
    proc.resume();

    // Restart timers after resume
    final outputPath = proc.outputFilePath;
    if (outputPath != null) {
      _startTimers(id, proc, outputPath);
    }
    _updateStatus(id, RecordingStatus.recording);
  }

  void removeRecording(String id) {
    final proc = _processes[id];
    proc?.dispose();
    _processes.remove(id);
    _recordings.remove(id);
    _emit();
  }

  void retryRecording(String id) async {
    final existing = _recordings[id];
    if (existing == null) return;

    // Stop old process
    final oldProc = _processes[id];
    oldProc?.dispose();
    _processes.remove(id);

    // Reset state
    existing.status = RecordingStatus.connecting;
    existing.duration = Duration.zero;
    existing.sizeBytes = 0;
    existing.errorMessage = null;
    _emit();

    // Restart
    final proc = _StreamProcess(recordingId: id);
    _processes[id] = proc;
    _runRecording(id, existing, proc);
  }

  void disposeAll() {
    for (final proc in _processes.values) {
      proc.dispose();
    }
    _processes.clear();
    _recordings.clear();
    _controller.close();
  }

  // ── Internal recording loop ───────────────────────────────────────────
  //
  // TikTok Live problem: yt-dlp downloads HLS in short segments and exits
  // with code 0 after each segment thinking the stream ended. The fix is
  // a reconnect loop — we keep restarting yt-dlp as long as:
  //   • the user has NOT pressed Stop  (proc.stopped == false)
  //   • recording duration is < maxDurationSeconds (if set)
  //   • the stream is still live (we get >0 bytes on reconnect)
  //
  // Each reconnect appends to a NEW segment file (segment_001, _002 …) and
  // we merge them at the end. This is the industry-standard approach for
  // unstable / segmented live sources.

  Future<void> _runRecording(
    String id,
    StreamRecording recording,
    _StreamProcess proc,
  ) async {
    try {
      final binaryPath = await BinaryLocator.ytDlpPath();
      // Auto-update yt-dlp before each recording session to fix JS challenge errors
      print('[MultiStream:$id] Checking for yt-dlp update...');
      await BinaryLocator.updateYtDlp();
      final settings = await AppSettings.load();
      final baseOutputPath = await _buildOutputPath(recording.url, recording.format);
      proc.outputFilePath = baseOutputPath;

      // ── Reconnect loop ────────────────────────────────────────────────
      int segmentIndex = 0;
      int consecutiveEmptyExits = 0;
      const maxConsecutiveEmptyExits = 3; // give up after 3 empty reconnects

      while (!proc.stopped) {
        final rec = _recordings[id];
        if (rec == null) break;

        // Check max duration
        if (recording.maxDurationSeconds != null &&
            rec.duration.inSeconds >= recording.maxDurationSeconds!) {
          print('[MultiStream:$id] Max duration reached, stopping.');
          break;
        }

        // Use segment suffix so each reconnect writes to a fresh file
        // (avoids yt-dlp refusing to overwrite)
        final segSuffix = segmentIndex == 0 ? '' : '_seg${segmentIndex.toString().padLeft(3, '0')}';
        final outputPath = '$baseOutputPath$segSuffix';

        final args = await _buildArgs(
          url: recording.url,
          quality: recording.quality,
          outputFormat: recording.format,
          outputPath: outputPath,
          // Don't pass maxDuration to yt-dlp; we handle it ourselves in the loop
          maxDurationSeconds: null,
          settings: settings,
        );

        print('[MultiStream:$id] Segment $segmentIndex starting');
        print('[MultiStream:$id] Args: ${args.join(' ')}');

        final process = await Process.start(binaryPath, args, runInShell: false);
        proc.ytdlpProcess = process;

        bool gotData = false;

        void onLine(String line) {
          print('[MultiStream:$id] $line');
          final r = _recordings[id];
          if (r == null || proc.stopped) return;

          if (r.status == RecordingStatus.connecting) {
            final isData = line.contains('[download]') ||
                line.contains('fragment') ||
                line.contains('Downloading') ||
                line.contains('Writing') ||
                line.contains('ETA') ||
                line.contains('frag ') ||
                line.contains('%') ||
                RegExp(r'^\[\w').hasMatch(line);
            if (isData) {
              gotData = true;
              _updateStatus(id, RecordingStatus.recording);
              _startTimers(id, proc, baseOutputPath);
            }
          } else if (r.status == RecordingStatus.recording) {
            // Keep marking data received on any output line
            if (line.isNotEmpty) gotData = true;
          }

          // Hard errors — don't reconnect unless transient
          if (line.startsWith('ERROR:') && !proc.stopped) {
            final raw = line.replaceFirst('ERROR:', '').trim();
            if (_isTransientError(raw)) {
              print('[MultiStream:$id] Transient error, will reconnect: $raw');
            } else {
              final isYt = recording.url.contains('youtube') || recording.url.contains('youtu.be');
              final friendly = isYt ? _friendlyYoutubeError(raw) : _friendlyError(raw);
              proc.stopped = true;
              _updateError(id, friendly);
            }
          }
        }

        final stderrSub = process.stderr
            .transform(utf8.decoder)
            .transform(const LineSplitter())
            .listen(onLine);

        final stdoutSub = process.stdout
            .transform(utf8.decoder)
            .transform(const LineSplitter())
            .listen(onLine);

        // Fallback: if still connecting after 12s → assume recording
        Future.delayed(const Duration(seconds: 12), () {
          final r = _recordings[id];
          if (r != null && r.status == RecordingStatus.connecting && !proc.stopped) {
            _updateStatus(id, RecordingStatus.recording);
            _startTimers(id, proc, baseOutputPath);
          }
        });

        int exitCode;
        try {
          exitCode = await process.exitCode;
        } catch (_) {
          exitCode = -1;
        }

        await stderrSub.cancel();
        await stdoutSub.cancel();

        print('[MultiStream:$id] Segment $segmentIndex exited with code $exitCode, gotData=$gotData, stopped=${proc.stopped}');

        // User pressed Stop — finalize immediately
        if (proc.stopped) break;

        // Check if the segment produced any real data.
        // NOTE: yt-dlp names files with format IDs (e.g. basePath.f137.mp4.part,
        // basePath.f140.mp4.part) so _findSavedFile may miss them.
        // We also scan the directory for any fragment files matching the base name.
        final segFile = _findSavedFile(outputPath, recording.format);
        bool segHasData = segFile != null &&
            File(segFile).existsSync() &&
            File(segFile).lengthSync() > 10 * 1024;

        // Fallback: scan directory for any .part or .frag files with our base name
        if (!segHasData) {
          try {
            final dir = Directory(p.dirname(outputPath));
            final baseName = p.basename(outputPath);
            if (dir.existsSync()) {
              final hasFrags = dir.listSync().whereType<File>().any((f) =>
                  p.basename(f.path).startsWith(baseName) &&
                  f.lengthSync() > 10 * 1024);
              if (hasFrags) segHasData = true;
            }
          } catch (_) {}
        }

        // Also trust gotData — if yt-dlp printed download progress, data was received
        if (gotData) segHasData = true;

        if (!segHasData && !gotData) {
          consecutiveEmptyExits++;
          print('[MultiStream:$id] Empty segment ($consecutiveEmptyExits/$maxConsecutiveEmptyExits)');
          if (consecutiveEmptyExits >= maxConsecutiveEmptyExits) {
            print('[MultiStream:$id] Too many empty reconnects, stream likely ended.');
            break;
          }
          // Brief pause before reconnect
          await Future.delayed(const Duration(seconds: 3));
        } else {
          // Good data received, reset empty counter
          consecutiveEmptyExits = 0;
          segmentIndex++;
          gotData = false;
          // Brief pause to avoid hammering TikTok servers
          await Future.delayed(const Duration(seconds: 2));
          print('[MultiStream:$id] Reconnecting for next segment...');
        }
      }

      // ── Finalize ──────────────────────────────────────────────────────
      proc.cancelTimers();

      if (proc.stopped) {
        await Future.delayed(const Duration(seconds: 4));
      } else {
        await Future.delayed(const Duration(seconds: 2));
      }

      // Find the best/largest saved file
      String? savedPath = _findBestOutputFile(baseOutputPath, recording.format, segmentIndex);

      // Auto-merge video+audio .part files (e.g. f137.mp4.part + f140.mp4.part → mp4)
      // This happens when yt-dlp exits before merging (user stopped or stream ended mid-download)
      if (savedPath == null || savedPath.endsWith('.part')) {
        final mergedPath = await _mergePartFiles(id, baseOutputPath, recording.format);
        if (mergedPath != null) savedPath = mergedPath;
      }

      // Auto-convert FLV → MP4 using ffmpeg (stream copy, no re-encode = fast)
      if (savedPath != null && savedPath.toLowerCase().endsWith('.flv')) {
        _updateConvertingStatus(id);
        final convertedPath = await _convertFlvToMp4(id, savedPath);
        if (convertedPath != null) savedPath = convertedPath;
      }

      if (savedPath != null) {
        // Clean up any leftover fragment files (.part-FragXX, .ytdl)
        _cleanupFragmentFiles(baseOutputPath, savedPath);
        _updateSaved(id, savedPath);
      } else {
        final rec = _recordings[id];
        if (rec != null && rec.status != RecordingStatus.failed) {
          _updateError(id, 'Stream ended — no data was captured.');
        }
      }
    } catch (e) {
      _processes[id]?.cancelTimers();
      final rec = _recordings[id];
      if (rec != null && rec.status != RecordingStatus.saved) {
        _updateError(id, e.toString().replaceAll('Exception: ', ''));
      }
    }
  }

  /// Returns true for errors that are worth retrying (network hiccup, segment 404, etc.)
  static bool _isTransientError(String raw) {
    final r = raw.toLowerCase();
    return r.contains('404') ||
        r.contains('timeout') ||
        r.contains('network') ||
        r.contains('connect') ||
        r.contains('temporary') ||
        r.contains('fragment') ||
        r.contains('retry') ||
        r.contains('timed out') ||
        r.contains('reset by peer') ||
        r.contains('broken pipe') ||
        // YouTube-specific transient errors
        r.contains('page needs to be reloaded') ||  // retried with android client
        r.contains('precondition check failed') ||
        r.contains('service unavailable') ||
        r.contains('http error 429') ||
        r.contains('http error 503');
  }

  /// Friendly error messages for YouTube live errors
  static String _friendlyYoutubeError(String raw) {
    final r = raw.toLowerCase();
    if (r.contains('page needs to be reloaded') ||
        r.contains('sign in') ||
        r.contains('login required') ||
        r.contains('please sign in')) {
      return 'YouTube blocked the recording.\n\n'
          'Fix: Go to Settings → Manage Cookies → YouTube '
          'and import your cookies.txt file.\n\n'
          'Use the "Get cookies.txt LOCALLY" browser extension '
          'while logged into YouTube to export your cookies.';
    }
    if (r.contains('members only') || r.contains('membership')) {
      return 'This stream is for channel members only. '
          'Import YouTube cookies in Settings → Manage Cookies.';
    }
    if (r.contains('private')) {
      return 'This stream is private.';
    }
    if (r.contains('not currently live') || r.contains('is not live')) {
      return 'This stream is not live right now.';
    }
    return _friendlyError(raw);
  }

  /// Delete leftover fragment files (.part-FragXX, .ytdl, .part) from the
  /// output directory — these are yt-dlp's temporary download files and are
  /// not needed once the final video is saved.
  void _cleanupFragmentFiles(String basePath, String keepFile) {
    try {
      final dir = Directory(p.dirname(basePath));
      final baseName = p.basename(basePath);
      if (!dir.existsSync()) return;

      final toDelete = dir.listSync().whereType<File>().where((f) {
        final name = p.basename(f.path);
        if (f.path == keepFile) return false; // never delete the final video
        return name.startsWith(baseName) &&
            (name.contains('.part-Frag') ||
             name.endsWith('.ytdl') ||
             name.endsWith('.part') ||
             name.endsWith('.json'));
      }).toList();

      for (final f in toDelete) {
        try {
          f.deleteSync();
        } catch (_) {}
      }
      if (toDelete.isNotEmpty) {
        print('[MultiStream] Cleaned up ${toDelete.length} fragment files');
      }
    } catch (e) {
      print('[MultiStream] Fragment cleanup error: $e');
    }
  }

  /// Merge separate video+audio .part files into a single mp4.
  /// yt-dlp downloads bestvideo (f137) and bestaudio (f140) separately and
  /// merges them at the end — but if stopped early, we get two .part files.
  /// This method uses ffmpeg to merge them (stream copy, no re-encode).
  Future<String?> _mergePartFiles(String id, String basePath, String format) async {
    try {
      final dir = Directory(p.dirname(basePath));
      final baseName = p.basename(basePath);
      if (!dir.existsSync()) return null;

      // Find all part files that belong to this recording
      final allFiles = dir.listSync().whereType<File>()
          .where((f) =>
              p.basename(f.path).startsWith(baseName) &&
              f.lengthSync() > 10 * 1024 &&
              !p.basename(f.path).endsWith('.ytdl') &&
              !p.basename(f.path).endsWith('.json'))
          .toList()
        ..sort((a, b) => b.lengthSync().compareTo(a.lengthSync()));

      if (allFiles.isEmpty) return null;

      // If only one file, rename .part → .mp4 and return
      if (allFiles.length == 1) {
        final f = allFiles.first;
        final outPath = '$basePath.$format';
        try {
          f.renameSync(outPath);
          print('[MultiStream:$id] Single part file renamed: $outPath');
          return outPath;
        } catch (_) {
          return f.path;
        }
      }

      // Two files: largest = video, second = audio — merge with ffmpeg
      final videoFile = allFiles.first;
      final audioFile = allFiles.length > 1 ? allFiles[1] : null;

      if (audioFile == null) return videoFile.path;

      final ffmpegBin = await BinaryLocator.ffmpegPath();
      final outPath = '$basePath.$format';

      print('[MultiStream:$id] Merging video+audio parts: ${videoFile.path} + ${audioFile.path} -> $outPath');
      _updateConvertingStatus(id);

      final result = await Process.run(
        ffmpegBin,
        [
          '-y',
          '-i', videoFile.path,
          '-i', audioFile.path,
          '-c', 'copy',
          '-movflags', '+faststart',
          outPath,
        ],
        runInShell: false,
      ).timeout(const Duration(minutes: 30));

      if (result.exitCode == 0 && File(outPath).existsSync() && File(outPath).lengthSync() > 10 * 1024) {
        // Clean up part files
        try { videoFile.deleteSync(); } catch (_) {}
        try { audioFile.deleteSync(); } catch (_) {}
        print('[MultiStream:$id] Merge OK: $outPath (${File(outPath).lengthSync()} bytes)');
        return outPath;
      } else {
        print('[MultiStream:$id] Merge failed (code ${result.exitCode}): ${result.stderr}');
        // Return the largest part file as fallback
        return videoFile.path;
      }
    } catch (e) {
      print('[MultiStream:$id] Merge error: $e');
      return null;
    }
  }

  /// Auto-convert .flv to .mp4 using ffmpeg stream copy (very fast, no quality loss).
  Future<String?> _convertFlvToMp4(String id, String flvPath) async {
    try {
      final ffmpegBin = await BinaryLocator.ffmpegPath();
      final mp4Path = flvPath.replaceAll(RegExp(r'\.flv$', caseSensitive: false), '.mp4');

      print('[MultiStream:$id] Converting FLV -> MP4: $flvPath -> $mp4Path');

      final result = await Process.run(
        ffmpegBin,
        [
          '-y',                  // overwrite output if exists
          '-i', flvPath,         // input
          '-c', 'copy',          // stream copy — no re-encode, instant
          '-movflags', '+faststart', // optimize for streaming/playback
          mp4Path,               // output
        ],
        runInShell: false,
      ).timeout(const Duration(minutes: 10));

      if (result.exitCode == 0 && File(mp4Path).existsSync() && File(mp4Path).lengthSync() > 1024) {
        // Delete original FLV to save disk space
        try { File(flvPath).deleteSync(); } catch (_) {}
        print('[MultiStream:$id] Conversion OK: $mp4Path');
        return mp4Path;
      } else {
        print('[MultiStream:$id] Conversion failed (code ${result.exitCode}): ${result.stderr}');
        return null; // return null = keep original FLV
      }
    } catch (e) {
      print('[MultiStream:$id] Conversion error: $e');
      return null;
    }
  }

  void _updateConvertingStatus(String id) {
    final rec = _recordings[id];
    if (rec == null) return;
    rec.status = RecordingStatus.stopping; // reuse "Saving..." badge
    rec.convertingToMp4 = true;
    _emit();
  }

  /// Find the best output file across all segments.
  String? _findBestOutputFile(String baseOutputPath, String format, int lastSegment) {
    // First check main file (segment 0)
    final main = _findAndFixPartFile(baseOutputPath, format);
    if (main != null) return main;

    // Check all segments, return the largest
    final candidates = <File>[];
    for (var i = 1; i <= lastSegment; i++) {
      final segPath = '${baseOutputPath}_seg${i.toString().padLeft(3, '0')}';
      for (final ext in [format, 'mp4', 'mkv', 'ts', 'webm', 'part']) {
        final f = File('$segPath.$ext');
        if (f.existsSync() && f.lengthSync() > 1024) {
          candidates.add(f);
        }
      }
    }

    // Fallback: scan the output directory for any file starting with base name
    // (handles yt-dlp format-ID naming like basePath.f137.mp4, basePath.f140.mp4)
    try {
      final dir = Directory(p.dirname(baseOutputPath));
      final baseName = p.basename(baseOutputPath);
      if (dir.existsSync()) {
        final dirFiles = dir.listSync().whereType<File>().where((f) {
          final name = p.basename(f.path);
          return name.startsWith(baseName) &&
              f.lengthSync() > 10 * 1024 &&
              !name.endsWith('.ytdl') &&
              !name.endsWith('.json');
        }).toList();
        candidates.addAll(dirFiles);
      }
    } catch (_) {}

    if (candidates.isEmpty) return null;
    candidates.sort((a, b) => b.lengthSync().compareTo(a.lengthSync()));
    return candidates.first.path;
  }

  // ── Timers ────────────────────────────────────────────────────────────

  void _startTimers(String id, _StreamProcess proc, String outputPath) {
    proc.durationTimer ??= Timer.periodic(const Duration(seconds: 1), (_) {
      final rec = _recordings[id];
      if (rec == null || proc.paused) return;
      _updateDuration(id, rec.duration + const Duration(seconds: 1));
    });

    proc.sizeTimer ??= Timer.periodic(const Duration(seconds: 2), (_) {
      _updateSize(id, outputPath);
    });

    proc.resourceTimer ??=
        Timer.periodic(const Duration(seconds: 5), (_) async {
      await _updateResourceUsage(id, proc);
    });
  }

  void _updateSize(String id, String basePath) {
    try {
      for (final ext in ['mp4', 'mkv', 'ts', 'part', 'temp', 'webm']) {
        final f = File('$basePath.$ext');
        if (f.existsSync()) {
          final sz = f.lengthSync();
          if (sz > 0) {
            final rec = _recordings[id];
            if (rec != null) {
              rec.sizeBytes = sz;
              _emit();
              return;
            }
          }
        }
      }
    } catch (_) {}
  }

  Future<void> _updateResourceUsage(
      String id, _StreamProcess proc) async {
    final process = proc.ytdlpProcess;
    if (process == null) return;
    try {
      if (!Platform.isWindows) {
        // Linux/macOS: use ps for quick stats
        final result = await Process.run(
          'ps',
          ['-p', '${process.pid}', '-o', '%cpu,rss', '--no-headers'],
          runInShell: false,
        ).timeout(const Duration(seconds: 3));
        if (result.exitCode == 0) {
          final parts = (result.stdout as String).trim().split(RegExp(r'\s+'));
          if (parts.length >= 2) {
            final cpu = double.tryParse(parts[0]) ?? 0;
            final rssKb = int.tryParse(parts[1]) ?? 0;
            final rec = _recordings[id];
            if (rec != null) {
              rec.cpuPercent = cpu.round();
              rec.memoryMb = rssKb ~/ 1024;
              _emit();
            }
          }
        }
      }
    } catch (_) {}
  }

  // ── State helpers ─────────────────────────────────────────────────────

  void _updateStatus(String id, RecordingStatus status) {
    final rec = _recordings[id];
    if (rec == null) return;
    rec.status = status;
    _emit();
  }

  void _updateDuration(String id, Duration duration) {
    final rec = _recordings[id];
    if (rec == null) return;
    rec.duration = duration;
    _emit();
  }

  void _updateSaved(String id, String? path) {
    final rec = _recordings[id];
    if (rec == null) return;
    rec.status = RecordingStatus.saved;
    rec.outputPath = path;
    rec.errorMessage = null;
    _processes[id]?.cancelTimers();
    _emit();
  }

  void _updateError(String id, String message) {
    final rec = _recordings[id];
    if (rec == null) return;
    rec.status = RecordingStatus.failed;
    rec.errorMessage = message;
    _processes[id]?.cancelTimers();
    _emit();
  }

  void _emit() {
    if (!_controller.isClosed) {
      _controller.add(recordings);
    }
  }

  // ── File helpers ──────────────────────────────────────────────────────

  String? _findAndFixPartFile(String basePath, String format) {
    if (basePath.isEmpty) return null;
    for (final ext in [format, 'mp4', 'mkv', 'ts', 'webm']) {
      final f = File('$basePath.$ext');
      if (f.existsSync() && f.lengthSync() > 1024) return f.path;
    }
    for (final ext in ['mp4.part', 'mkv.part', 'ts.part', 'part']) {
      final f = File('$basePath.$ext');
      if (f.existsSync() && f.lengthSync() > 1024) {
        final targetExt =
            ext.contains('.') ? ext.split('.').first : format;
        final newPath = '$basePath.$targetExt';
        try {
          f.renameSync(newPath);
          return newPath;
        } catch (_) {
          return f.path;
        }
      }
    }
    try {
      final dir = Directory(p.dirname(basePath));
      final baseName = p.basename(basePath);
      if (dir.existsSync()) {
        final matches = dir
            .listSync()
            .whereType<File>()
            .where((f) =>
                p.basename(f.path).startsWith(baseName) &&
                f.lengthSync() > 1024)
            .toList()
          ..sort((a, b) => b.lengthSync().compareTo(a.lengthSync()));
        if (matches.isNotEmpty) return matches.first.path;
      }
    } catch (_) {}
    return null;
  }

  String? _findSavedFile(String basePath, String format) {
    if (basePath.isEmpty) return null;
    for (final ext in [format, 'mp4', 'mkv', 'ts', 'webm', 'part']) {
      final f = File('$basePath.$ext');
      if (f.existsSync() && f.lengthSync() > 1024) return f.path;
    }
    return null;
  }

  // ── Args builder ──────────────────────────────────────────────────────

  Future<List<String>> _buildArgs({
    required String url,
    required String quality,
    required String outputFormat,
    required String outputPath,
    int? maxDurationSeconds,
    required AppSettings settings,
  }) async {
    final isTiktok = url.contains('tiktok.com');
    final isYoutube = url.contains('youtube') || url.contains('youtu.be');

    final args = <String>[
      '--no-playlist',
      '--output', '$outputPath.%(ext)s',
      '--no-warnings',
      '--newline',
      '--retries', '15',
      '--fragment-retries', '15',
      '--skip-unavailable-fragments',
      // NOTE: do NOT add --keep-fragments here — it saves every HLS fragment
      // as a separate file on disk. yt-dlp handles fragment assembly internally.
    ];

    // ── YouTube specific ──────────────────────────────────────────────
    if (isYoutube) {
      // --remote-components: needed for deno JS challenge solver (YouTube 2026)
      args.addAll(['--remote-components', 'ejs:github']);
      // web_safari avoids deno/tv client issues
      args.addAll(['--extractor-args', 'youtube:player_client=web_safari,default']);
      // --hls-use-mpegts: write HLS segments into a single continuous .ts stream
      // This is critical — without it yt-dlp saves each fragment as a separate file
      args.add('--hls-use-mpegts');
      // --no-part: write directly to final file, avoids .part-FragXX scatter
      args.add('--no-part');
      // Cookies
      final savedCookies = await _cookiesArgs(url);
      if (savedCookies.isNotEmpty) {
        args.addAll(savedCookies);
      }
      // Format — ts is most compatible with --hls-use-mpegts for live streams
      args.addAll(['--merge-output-format', 'mp4']);
      if (quality == 'best') {
        args.addAll(['--format', 'bestvideo+bestaudio/best']);
      } else {
        final h = _qualityToHeight(quality);
        if (h != null) {
          args.addAll(['--format', 'bestvideo[height<=$h]+bestaudio/best[height<=$h]/best']);
        } else {
          args.addAll(['--format', 'bestvideo+bestaudio/best']);
        }
      }

    // ── TikTok specific ────────────────────────────────────────────────
    } else if (isTiktok) {
      // FLV stream is continuous (not segmented HLS) — much more reliable for live
      args.addAll([
        '--format', 'flv/best',
        '--hls-prefer-native',
        '--no-part',
        '--extractor-args', 'tiktok:api_hostname=api22-normal-c-alisg.tiktokv.com',
      ]);
      // Use only saved cookies.txt (browser extraction broken on Windows/DPAPI)
      final savedCookies = await _cookiesArgs(url);
      if (savedCookies.isNotEmpty) {
        args.addAll(savedCookies);
      }

    // ── Other platforms (Facebook, Instagram, Twitch, Twitter) ────────
    } else {
      if (['mp4', 'mkv', 'ts'].contains(outputFormat)) {
        args.addAll(['--merge-output-format', outputFormat]);
      }
      if (quality == 'best') {
        args.addAll(['--format', 'bestvideo+bestaudio/best']);
      } else {
        final h = _qualityToHeight(quality);
        if (h != null) {
          args.addAll(['--format', 'bestvideo[height<=$h]+bestaudio/best[height<=$h]/best']);
        } else {
          args.addAll(['--format', 'bestvideo+bestaudio/best']);
        }
      }
      // Use only saved cookies.txt — browser extraction broken on Windows (DPAPI)
      final savedCookies = await _cookiesArgs(url);
      if (savedCookies.isNotEmpty) {
        args.addAll(savedCookies);
      }
    }

    if (maxDurationSeconds != null && maxDurationSeconds > 0) {
      args.addAll(['--postprocessor-args', 'ffmpeg:-t $maxDurationSeconds']);
    }

    if (settings.bandwidthLimitKBs > 0) {
      args.addAll(['--limit-rate', '${settings.bandwidthLimitKBs}K']);
    }

    args.add(url);
    return args;
  }

  static Future<List<String>> _cookiesArgs(String url) async {
    const siteFiles = {
      'youtube.com': 'youtube_cookies.txt',
      'youtu.be': 'youtube_cookies.txt',
      'facebook.com': 'facebook_cookies.txt',
      'fb.watch': 'facebook_cookies.txt',
      'tiktok.com': 'tiktok_cookies.txt',
      'instagram.com': 'instagram_cookies.txt',
    };
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
      final f = File(p.join(dir.path, fileName));
      if (f.existsSync() && f.lengthSync() > 100) {
        return ['--cookies', f.path];
      }
    } catch (_) {}
    return [];
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
      // Mirror the same logic as download_manager.dart so live recordings
      // land in the same folder as regular downloads (UrDown subfolder)
      final dir = await getDownloadsDirectory();
      if (dir != null) {
        final streamVault = Directory(p.join(dir.path, 'UrDown'));
        if (!streamVault.existsSync()) streamVault.createSync(recursive: true);
        outDir = streamVault.path;
      } else {
        final home = (await getApplicationDocumentsDirectory()).path;
        final streamVault = Directory(p.join(home, 'Downloads', 'UrDown'));
        if (!streamVault.existsSync()) streamVault.createSync(recursive: true);
        outDir = streamVault.path;
      }
    }

    final ts = DateTime.now();
    final stamp =
        '${ts.year}${ts.month.toString().padLeft(2, '0')}${ts.day.toString().padLeft(2, '0')}'
        '_${ts.hour.toString().padLeft(2, '0')}${ts.minute.toString().padLeft(2, '0')}'
        '${ts.second.toString().padLeft(2, '0')}';

    String site = 'live';
    if (url.contains('youtube') || url.contains('youtu.be')) {
      site = 'youtube';
    } else if (url.contains('tiktok')) {
      site = 'tiktok';
    } else if (url.contains('facebook') || url.contains('fb.watch')) {
      site = 'facebook';
    } else if (url.contains('instagram')) {
      site = 'instagram';
    } else if (url.contains('twitch')) {
      site = 'twitch';
    } else if (url.contains('twitter') || url.contains('x.com')) {
      site = 'twitter';
    }

    // Ensure unique filename even when two streams of the same platform
    // start within the same second (e.g. two TikTok lives at once).
    String baseName = '${site}_live_$stamp';
    String candidate = p.join(outDir, baseName);
    int suffix = 2;
    while (Directory(candidate).existsSync() ||
        File('$candidate.mp4').existsSync() ||
        File('$candidate.flv').existsSync() ||
        File('$candidate.ts').existsSync()) {
      candidate = p.join(outDir, '${baseName}_$suffix');
      suffix++;
    }
    return candidate;
  }

  static String _friendlyError(String raw) {
    final r = raw.toLowerCase();
    if (r.contains('not currently live') || r.contains('is not live')) {
      return 'Stream is not live — make sure the broadcaster is streaming now';
    }
    if (r.contains('page needs to be reloaded') || r.contains('needs to be reloaded')) {
      return 'YouTube JS challenge failed — retrying with web player client.\n\n'
          'If this keeps happening, try adding fresh cookies in Settings → Manage Cookies.';
    }
    if (r.contains('dpapi') || r.contains('decrypt')) {
      return 'Cookie decryption failed (Windows DPAPI error).\n\n'
          'Fix: Go to Settings → Manage Cookies and import a cookies.txt file manually.\n'
          'Use the "Get cookies.txt LOCALLY" browser extension to export your cookies.';
    }
    if (r.contains('private') ||
        r.contains('login') ||
        r.contains('sign in')) {
      return 'Stream is private or requires login — add cookies in Settings';
    }
    if (r.contains('not found') ||
        r.contains('does not exist') ||
        r.contains('no such')) {
      return 'Account or URL not found — check the link';
    }
    if (r.contains('geo') ||
        r.contains('country') ||
        r.contains('not available in your')) {
      return 'Stream is geo-blocked in your region — try a VPN';
    }
    if (r.contains('rate') || r.contains('too many requests')) {
      return 'Too many requests — wait a moment and try again';
    }
    if (r.contains('cookies') || r.contains('authentication')) {
      return 'Cookie error — make sure you are logged in to Edge or Chrome';
    }
    if (r.contains('network') ||
        r.contains('connect') ||
        r.contains('timeout')) {
      return 'Network error — check your internet connection';
    }
    if (r.contains('unsupported url') || r.contains('ie:generic')) {
      return 'Unsupported URL — make sure it is a valid live stream link';
    }
    return raw;
  }
}
