import 'package:isar/isar.dart';

part 'download_job.g.dart';

enum DownloadStatus { queued, active, paused, completed, failed, cancelled }

enum DownloadType { video, audio, playlist }

@collection
class DownloadJob {
  Id id = Isar.autoIncrement;

  @Index(unique: true)
  late String jobId;

  late String url;
  late String title;
  String? thumbnailUrl;
  late String outputPath;
  late String format;
  late String resolution;
  String? channelName;
  String? duration;

  @enumerated
  late DownloadStatus status;

  @enumerated
  late DownloadType type;

  late double progress;
  String? speed;
  String? eta;

  // Non-nullable with field-level default. Isar requires the constructor param
  // type to exactly match the property type — so we exclude createdAt from the
  // constructor entirely and let the field default handle it.
  // copyWith sets it explicitly when needed.
  DateTime createdAt = DateTime.now();
  DateTime? startedAt;
  DateTime? completedAt;
  late int retryCount;
  String? errorMessage;
  late bool downloadSubtitles;
  String? subtitleLanguages;
  late bool embedThumbnail;
  late bool extractAudio;

  DownloadJob({
    required this.jobId,
    required this.url,
    required this.title,
    this.thumbnailUrl,
    required this.outputPath,
    required this.format,
    required this.resolution,
    this.channelName,
    this.duration,
    required this.status,
    required this.type,
    this.progress = 0.0,
    this.speed,
    this.eta,
    this.startedAt,
    this.completedAt,
    this.retryCount = 0,
    this.errorMessage,
    this.downloadSubtitles = false,
    this.subtitleLanguages,
    this.embedThumbnail = true,
    this.extractAudio = false,
  });

  /// Creates a copy with overridden fields.
  /// createdAt is handled separately because it is not in the constructor.
  DownloadJob copyWith({
    String? jobId,
    String? url,
    String? title,
    String? thumbnailUrl,
    String? outputPath,
    String? format,
    String? resolution,
    String? channelName,
    String? duration,
    DownloadStatus? status,
    DownloadType? type,
    double? progress,
    String? speed,
    String? eta,
    DateTime? createdAt,
    DateTime? startedAt,
    DateTime? completedAt,
    int? retryCount,
    String? errorMessage,
    bool? downloadSubtitles,
    String? subtitleLanguages,
    bool? embedThumbnail,
    bool? extractAudio,
  }) {
    final copy = DownloadJob(
      jobId: jobId ?? this.jobId,
      url: url ?? this.url,
      title: title ?? this.title,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      outputPath: outputPath ?? this.outputPath,
      format: format ?? this.format,
      resolution: resolution ?? this.resolution,
      channelName: channelName ?? this.channelName,
      duration: duration ?? this.duration,
      status: status ?? this.status,
      type: type ?? this.type,
      progress: progress ?? this.progress,
      speed: speed ?? this.speed,
      eta: eta ?? this.eta,
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
      retryCount: retryCount ?? this.retryCount,
      errorMessage: errorMessage ?? this.errorMessage,
      downloadSubtitles: downloadSubtitles ?? this.downloadSubtitles,
      subtitleLanguages: subtitleLanguages ?? this.subtitleLanguages,
      embedThumbnail: embedThumbnail ?? this.embedThumbnail,
      extractAudio: extractAudio ?? this.extractAudio,
    );
    // FIX: preserve the Isar auto-increment id so put() updates the existing
    // record instead of inserting a new one (which causes Unique index violation).
    copy.id = this.id;
    copy.createdAt = createdAt ?? this.createdAt;
    return copy;
  }

  bool get isActive    => status == DownloadStatus.active;
  bool get isCompleted => status == DownloadStatus.completed;
  bool get isFailed    => status == DownloadStatus.failed;
  bool get isPaused    => status == DownloadStatus.paused;
  bool get isQueued    => status == DownloadStatus.queued;
}


class DownloadProgress {
  final double percent;
  final String totalSize;
  final String speed;
  final String eta;
  final String? fragment;

  const DownloadProgress({
    required this.percent,
    required this.totalSize,
    required this.speed,
    required this.eta,
    this.fragment,
  });

  static const empty = DownloadProgress(
    percent: 0,
    totalSize: '--',
    speed: '--',
    eta: '--',
  );
}

sealed class DownloadEvent {
  const DownloadEvent();
}

class DownloadEventProgress extends DownloadEvent {
  final DownloadProgress progress;
  const DownloadEventProgress(this.progress);
}

class DownloadEventCompleted extends DownloadEvent {
  const DownloadEventCompleted();
}

class DownloadEventFailed extends DownloadEvent {
  final String reason;
  const DownloadEventFailed(this.reason);
}

class DownloadEventLog extends DownloadEvent {
  final String message;
  const DownloadEventLog(this.message);
}

class DownloadStats {
  final int total;
  final int active;
  final int completed;
  final int failed;
  final int queued;

  const DownloadStats({
    this.total = 0,
    this.active = 0,
    this.completed = 0,
    this.failed = 0,
    this.queued = 0,
  });
}
