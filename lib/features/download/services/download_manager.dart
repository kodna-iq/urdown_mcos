import 'dart:async';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

import '../../../main.dart';
import '../../../core/constants/app_constants.dart';
import '../../../services/notification_service.dart';
import '../../cli/ffmpeg_runner.dart';
import '../../cli/ytdlp_runner.dart';
import '../../history/history_repository.dart';
import '../../history/models/history_entry.dart';
import '../../settings/app_settings.dart';
import '../models/download_job.dart';
import '../models/media_info.dart';

// ─── Provider ─────────────────────────────────────────────────────────────

final downloadManagerProvider = Provider<DownloadManager>((ref) {
  final isar = ref.watch(isarProvider);
  final manager = DownloadManager(isar, ref);
  ref.onDispose(manager.dispose);
  return manager;
});

// ─── Download Manager ─────────────────────────────────────────────────────

class DownloadManager {
  DownloadManager(this._isar, this._ref) {
    _init().catchError((Object e, StackTrace st) {
      print('[DownloadManager] init error: $e\n$st');
    });
  }

  final Isar _isar;
  final Ref _ref;

  final Map<String, YtDlpRunner> _runners = {};

  bool _scheduling = false;
  bool _initialized = false; // FIX: don't schedule before _init() completes

  final _progressController =
      StreamController<Map<String, DownloadProgress>>.broadcast();
  final Map<String, DownloadProgress> _progressMap = {};

  Stream<Map<String, DownloadProgress>> get progressStream =>
      _progressController.stream;

  static const _uuid = Uuid();

  // ─── Lifecycle ───────────────────────────────────────────────────────

  Future<void> _init() async {
    print('[DownloadManager] _init() started');
    // FIX: use anyId() instead of idProperty() chaining
    final allJobs = await _isar.downloadJobs.where().anyId().findAll();
    final stalledJobs = allJobs.where((j) => j.status == DownloadStatus.active).toList();
    print('[DownloadManager] Found ${stalledJobs.length} stalled jobs');

    for (final job in stalledJobs) {
      await _updateJob(job.copyWith(status: DownloadStatus.queued));
    }

    _initialized = true;
    print('[DownloadManager] _init() complete, calling _scheduleNext');
    _scheduleNext();
  }

  void dispose() {
    for (final runner in _runners.values) {
      runner.cancel();
    }
    _progressController.close();
  }

  // ─── Public API ──────────────────────────────────────────────────────

  Future<void> enqueue({
    required String url,
    required MediaInfo info,
    required String format,
    required String resolution,
    bool downloadSubtitles = false,
    bool embedThumbnail = true,
    bool extractAudio = false,
    String? subtitleLanguages,
  }) async {
    final settings = await AppSettings.load();
    final outputDir = await _resolveOutputDir(settings);

    final safeTitle = _sanitizeFilename(info.title);
    final outputPath = p.join(outputDir, safeTitle);

    final type = info.isPlaylist
        ? DownloadType.playlist
        : extractAudio
            ? DownloadType.audio
            : DownloadType.video;

    final job = DownloadJob(
      jobId: _uuid.v4(),
      url: url,
      title: info.title,
      thumbnailUrl: info.thumbnailUrl,
      outputPath: outputPath,
      format: format,
      resolution: resolution,
      channelName: info.uploader,
      duration: info.durationFormatted,
      status: DownloadStatus.queued,
      type: type,
      downloadSubtitles: downloadSubtitles,
      embedThumbnail: embedThumbnail,
      extractAudio: extractAudio,
      subtitleLanguages: subtitleLanguages,
    );

    await _isar.writeTxn(() async {
      await _isar.downloadJobs.put(job);
    });

    print('[DownloadManager] Job enqueued: ${job.jobId}');
    _scheduleNext();
  }

  Future<void> pause(String jobId) async {
    final job = await _getJob(jobId);
    if (job == null || !job.isActive) return;
    _runners[jobId]?.cancel();
    _runners.remove(jobId);
    await _updateJob(job.copyWith(status: DownloadStatus.paused));
    _scheduleNext();
  }

  Future<void> resume(String jobId) async {
    final job = await _getJob(jobId);
    if (job == null || !job.isPaused) return;
    await _updateJob(job.copyWith(status: DownloadStatus.queued));
    _scheduleNext();
  }

  Future<void> cancel(String jobId) async {
    _runners[jobId]?.cancel();
    _runners.remove(jobId);
    final job = await _getJob(jobId);
    if (job != null) {
      await _updateJob(job.copyWith(status: DownloadStatus.cancelled));
    }
    _scheduleNext();
  }

  Future<void> retry(String jobId) async {
    final job = await _getJob(jobId);
    if (job == null) return;
    await _updateJob(job.copyWith(
      status: DownloadStatus.queued,
      retryCount: 0,
      errorMessage: null,
      progress: 0,
    ));
    _scheduleNext();
  }

  Future<void> deleteJob(String jobId) async {
    _runners[jobId]?.cancel();
    _runners.remove(jobId);
    await _isar.writeTxn(() async {
      await _isar.downloadJobs.deleteByJobId(jobId);
    });
    _progressMap.remove(jobId);
    _emitProgress();
    _scheduleNext();
  }

  Future<void> deleteAllJobs() async {
    // إلغاء كل التنزيلات النشطة
    for (final runner in _runners.values) {
      runner.cancel();
    }
    _runners.clear();
    _progressMap.clear();

    // حذف كل السجلات من قاعدة البيانات
    await _isar.writeTxn(() async {
      final all = await _isar.downloadJobs.where().anyId().findAll();
      final ids = all.map((j) => j.id).toList();
      await _isar.downloadJobs.deleteAll(ids);
    });

    _emitProgress();
  }

  Future<void> clearCompleted() async {
    await _isar.writeTxn(() async {
      final allJobs = await _isar.downloadJobs.where().anyId().findAll();
      final toDelete = allJobs
          .where((j) => j.status == DownloadStatus.completed || j.status == DownloadStatus.cancelled)
          .map((j) => j.id)
          .toList();
      await _isar.downloadJobs.deleteAll(toDelete);
    });
  }

  // ─── Scheduler ───────────────────────────────────────────────────────

  Future<void> _scheduleNext() async {
    if (!_initialized) {
      print('[DownloadManager] _scheduleNext skipped: not initialized yet');
      return;
    }
    if (_scheduling) return;
    _scheduling = true;
    try {
      await _scheduleNextInternal();
    } catch (e, st) {
      print('[DownloadManager] scheduler error: $e\n$st');
    } finally {
      _scheduling = false;
    }
  }

  Future<void> _scheduleNextInternal() async {
    final settings = await AppSettings.load();
    final maxConcurrent = settings.maxConcurrentDownloads;

    // FIX: single db read using anyId()
    final allJobs = await _isar.downloadJobs.where().anyId().findAll();
    final active = allJobs.where((j) => j.status == DownloadStatus.active).length;

    print('[DownloadManager] active=$active maxConcurrent=$maxConcurrent');

    if (active >= maxConcurrent) return;

    final slots = maxConcurrent - active;
    final queued = allJobs.where((j) => j.status == DownloadStatus.queued).toList();
    queued.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    final queuedSlice = queued.take(slots).toList();

    print('[DownloadManager] queued=${queued.length} slots=$slots starting=${queuedSlice.length}');

    for (final job in queuedSlice) {
      final activeJob = job.copyWith(
        status: DownloadStatus.active,
        startedAt: DateTime.now(),
      );
      await _updateJob(activeJob);
      print('[DownloadManager] Starting download: ${job.jobId}');
      _startDownload(activeJob);
    }
  }

  void _startDownload(DownloadJob job) {
    final runner = YtDlpRunner();
    _runners[job.jobId] = runner;

    runner.download(job).listen(
      (event) => _handleEvent(job.jobId, event),
      onError: (Object e) => _handleError(job.jobId, e.toString()),
      onDone: () => _runners.remove(job.jobId),
    );
  }

  Future<void> _handleEvent(String jobId, DownloadEvent event) async {
    final job = await _getJob(jobId);
    if (job == null) return;

    switch (event) {
      case DownloadEventProgress(:final progress):
        final previousPercent = _progressMap[jobId]?.percent ?? job.progress;
        _progressMap[jobId] = progress;
        _emitProgress();
        if ((progress.percent - previousPercent).abs() >= 1.0) {
          await _updateJob(job.copyWith(
            progress: progress.percent,
            speed: progress.speed,
            eta: progress.eta,
          ));
        }

      case DownloadEventCompleted():
        // ── Post-processing: transcode to H.264 for universal compatibility ──
        await _transcodeIfNeeded(job);

        _progressMap.remove(jobId);
        _emitProgress();
        final completedJob = job.copyWith(
          status: DownloadStatus.completed,
          progress: 100,
          completedAt: DateTime.now(),
        );
        await _updateJob(completedJob);
        await _addToHistory(completedJob);
        await NotificationService.instance.showDownloadComplete(jobId);
        // Play completion sound using macOS native afplay (no external pod needed)
        try {
          if (Platform.isMacOS) {
            final execPath = Platform.resolvedExecutable;
            final appDir = p.dirname(p.dirname(execPath));
            final soundPath = p.join(appDir, 'Frameworks', 'App.framework',
                'Resources', 'flutter_assets', 'assets', 'sounds', 'DHD.mp3');
            Process.run('afplay', [soundPath]);
          }
        } catch (_) {}
        _scheduleNext();

      case DownloadEventFailed(:final reason):
        print('[DownloadManager] Download failed: $reason');
        _progressMap.remove(jobId);
        _emitProgress();
        if (job.retryCount < AppConstants.maxRetries) {
          await Future.delayed(
            Duration(seconds: (job.retryCount + 1) * AppConstants.retryBaseDelaySeconds),
          );
          await _updateJob(job.copyWith(
            status: DownloadStatus.queued,
            retryCount: job.retryCount + 1,
            errorMessage: reason,
          ));
          _scheduleNext();
        } else {
          await _updateJob(job.copyWith(
            status: DownloadStatus.failed,
            errorMessage: reason,
          ));
          await NotificationService.instance.showDownloadFailed(job.title, reason);
          _scheduleNext();
        }

      case DownloadEventLog():
        break;
    }
  }

  Future<void> _handleError(String jobId, String message) async {
    print('[DownloadManager] Error for $jobId: $message');
    final job = await _getJob(jobId);
    if (job == null) return;
    await _updateJob(job.copyWith(
      status: DownloadStatus.failed,
      errorMessage: message,
    ));
    _scheduleNext();
  }

  // ─── Transcode ───────────────────────────────────────────────────────

  /// After download, find the actual file yt-dlp created and transcode
  /// it to H.264+AAC if it's not already in that format.
  Future<void> _transcodeIfNeeded(DownloadJob job) async {
    if (job.extractAudio) return; // audio-only jobs don't need video transcode

    try {
      // yt-dlp appends the extension, so find the actual file
      final dir = Directory(p.dirname(job.outputPath));
      final base = p.basenameWithoutExtension(job.outputPath);
      if (!dir.existsSync()) return;

      final files = dir
          .listSync()
          .whereType<File>()
          .where((f) =>
              p.basenameWithoutExtension(f.path) == base &&
              _isVideoFile(f.path))
          .toList();

      if (files.isEmpty) {
        print('[Transcode] No video file found for base: $base');
        return;
      }

      final inputFile = files.first;
      final inputPath = inputFile.path;
      final ext = p.extension(inputPath); // e.g. ".mp4"
      final tempPath = '${inputPath}_h264$ext';

      print('[Transcode] Starting: $inputPath');

      final transcoded = await FfmpegRunner.transcodeToH264(
        inputPath: inputPath,
        outputPath: tempPath,
        onProgress: (pct) {
          // Update progress map with transcode progress (shown as 100-based offset)
          _progressMap[job.jobId] = DownloadProgress(
            percent: pct,
            totalSize: 'Converting...',
            speed: '',
            eta: '',
          );
          _emitProgress();
        },
      );

      if (transcoded) {
        // Replace original with transcoded version
        await inputFile.delete();
        await File(tempPath).rename(inputPath);
        print('[Transcode] Done: replaced $inputPath');
      } else {
        // Already H.264 - delete temp if created
        final temp = File(tempPath);
        if (temp.existsSync()) await temp.delete();
      }
    } catch (e, st) {
      // Transcode failure must NOT fail the download - file is still usable
      print('[Transcode] Warning: $e\n$st');
    }
  }

  bool _isVideoFile(String path) {
    final ext = p.extension(path).toLowerCase();
    return ['.mp4', '.mkv', '.webm', '.avi', '.mov', '.m4v'].contains(ext);
  }

  // ─── History ─────────────────────────────────────────────────────────

  Future<void> _addToHistory(DownloadJob job) async {
    final repo = _ref.read(historyRepositoryProvider);
    int fileSize = 0;
    try {
      final dir = Directory(p.dirname(job.outputPath));
      final base = p.basenameWithoutExtension(job.outputPath);
      if (dir.existsSync()) {
        final files = dir
            .listSync()
            .whereType<File>()
            .where((f) => p.basenameWithoutExtension(f.path) == base)
            .toList();
        if (files.isNotEmpty) {
          fileSize = await files.first.length();
        }
      }
    } catch (_) {}

    final entry = HistoryEntry(
      jobId:        job.jobId,
      url:          job.url,
      title:        job.title,
      thumbnailUrl: job.thumbnailUrl,
      outputPath:   job.outputPath,
      format:       job.format,
      resolution:   job.resolution,
      channelName:  job.channelName,
      duration:     job.duration,
      downloadedAt: job.completedAt ?? DateTime.now(),
      fileSizeBytes: fileSize,
      isAudio:      job.extractAudio || job.type == DownloadType.audio,
    );

    try {
      await repo.add(entry);
    } catch (_) {}
  }

  // ─── Helpers ─────────────────────────────────────────────────────────

  Future<DownloadJob?> _getJob(String jobId) async {
    return _isar.downloadJobs.getByJobId(jobId);
  }

  Future<void> _updateJob(DownloadJob job) async {
    await _isar.writeTxn(() async {
      await _isar.downloadJobs.put(job);
    });
  }

  void _emitProgress() {
    if (!_progressController.isClosed) {
      _progressController.add(Map.unmodifiable(_progressMap));
    }
  }

  Future<String> _resolveOutputDir(AppSettings settings) async {
    if (settings.outputDirectory.isNotEmpty) {
      try {
        final dir = Directory(settings.outputDirectory);
        if (!dir.existsSync()) await dir.create(recursive: true);
        return settings.outputDirectory;
      } catch (_) {}
    }

    try {
      if (Platform.isAndroid) {
        final dir = await getExternalStorageDirectory();
        if (dir != null) {
          final downloads = Directory(p.join(dir.path, 'UrDown'));
          if (!downloads.existsSync()) await downloads.create(recursive: true);
          return downloads.path;
        }
      } else if (Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
        final home = Platform.environment['HOME'] ??
            Platform.environment['USERPROFILE'] ??
            (await getApplicationDocumentsDirectory()).path;
        final downloads = Directory(p.join(home, 'Downloads', 'UrDown'));
        if (!downloads.existsSync()) await downloads.create(recursive: true);
        return downloads.path;
      }
    } catch (_) {}

    final docDir = await getApplicationDocumentsDirectory();
    return docDir.path;
  }

  static String _sanitizeFilename(String name) {
    var sanitized = name
        .replaceAll(RegExp(r'[<>:"/\\|?*\x00-\x1F]'), '_')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
    if (sanitized.length > 200) sanitized = sanitized.substring(0, 200);
    if (sanitized.isEmpty) sanitized = 'download';
    return sanitized;
  }
}
