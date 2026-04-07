import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';

import '../../../main.dart';
import '../models/download_job.dart';
import '../services/download_manager.dart';

// ---------------------------------------------------------------------------
// Polling-based providers.
// Isar 3: findAll() is only on QQueryOperations. To reach it from QWhere we
// must pass through a sortBy/thenBy or property() step. Simplest fix: use
// collection.getAll() with all IDs, or use the where() → dummy sortBy path.
// We use isar.downloadJobs.filter()...build() via the property extension.
// ---------------------------------------------------------------------------

Stream<List<DownloadJob>> _pollJobs(
  Future<List<DownloadJob>> Function() query,
) async* {
  while (true) {
    try {
      yield await query();
    } catch (_) {
      yield [];
    }
    await Future.delayed(const Duration(milliseconds: 500));
  }
}

/// Fetch all DownloadJobs from the collection
Future<List<DownloadJob>> _allJobs(Isar isar) =>
    isar.downloadJobs.where().idProperty().findAll().then(
          (ids) => isar.downloadJobs.getAll(ids).then(
                (jobs) => jobs.whereType<DownloadJob>().toList(),
              ),
        );

/// All jobs ordered by creation date desc
final allJobsProvider = StreamProvider<List<DownloadJob>>((ref) {
  final isar = ref.watch(isarProvider);
  return _pollJobs(() async {
    final jobs = await _allJobs(isar);
    jobs.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return jobs;
  });
});

/// Currently active (downloading) jobs
final activeJobsProvider = StreamProvider<List<DownloadJob>>((ref) {
  final isar = ref.watch(isarProvider);
  return _pollJobs(() async {
    final jobs = await _allJobs(isar);
    final filtered = jobs.where((j) => j.status == DownloadStatus.active).toList();
    filtered.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    return filtered;
  });
});

/// Queued jobs waiting to start
final queuedJobsProvider = StreamProvider<List<DownloadJob>>((ref) {
  final isar = ref.watch(isarProvider);
  return _pollJobs(() async {
    final jobs = await _allJobs(isar);
    final filtered = jobs.where((j) => j.status == DownloadStatus.queued).toList();
    filtered.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    return filtered;
  });
});

/// Paused jobs
final pausedJobsProvider = StreamProvider<List<DownloadJob>>((ref) {
  final isar = ref.watch(isarProvider);
  return _pollJobs(() async {
    final jobs = await _allJobs(isar);
    final filtered = jobs.where((j) => j.status == DownloadStatus.paused).toList();
    filtered.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return filtered;
  });
});

/// Completed jobs (latest 20 only)
final completedJobsProvider = StreamProvider<List<DownloadJob>>((ref) {
  final isar = ref.watch(isarProvider);
  return _pollJobs(() async {
    final jobs = await _allJobs(isar);
    final filtered = jobs.where((j) => j.status == DownloadStatus.completed).toList();
    filtered.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return filtered.take(20).toList();
  });
});

/// Failed jobs
final failedJobsProvider = StreamProvider<List<DownloadJob>>((ref) {
  final isar = ref.watch(isarProvider);
  return _pollJobs(() async {
    final jobs = await _allJobs(isar);
    final filtered = jobs.where((j) => j.status == DownloadStatus.failed).toList();
    filtered.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return filtered;
  });
});

/// Download statistics
final downloadStatsProvider = StreamProvider<DownloadStats>((ref) {
  final isar = ref.watch(isarProvider);
  return _pollJobs(() => _allJobs(isar)).map(
    (jobs) => DownloadStats(
      total: jobs.length,
      active: jobs.where((j) => j.status == DownloadStatus.active).length,
      completed: jobs.where((j) => j.status == DownloadStatus.completed).length,
      failed: jobs.where((j) => j.status == DownloadStatus.failed).length,
      queued: jobs.where((j) => j.status == DownloadStatus.queued).length,
    ),
  );
});

/// Live progress for all active downloads
final progressStreamProvider =
    StreamProvider<Map<String, DownloadProgress>>((ref) {
  final manager = ref.watch(downloadManagerProvider);
  return manager.progressStream;
});

/// Progress for a specific job
final jobProgressProvider =
    Provider.family<DownloadProgress, String>((ref, jobId) {
  final progressMap = ref.watch(progressStreamProvider).valueOrNull ?? {};
  return progressMap[jobId] ?? DownloadProgress.empty;
});
