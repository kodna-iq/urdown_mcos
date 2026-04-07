import 'package:isar/isar.dart';

part 'history_entry.g.dart';

@collection
class HistoryEntry {
  Id id = Isar.autoIncrement;

  @Index(unique: true)
  late String jobId;

  late String url;
  late String title;
  String? thumbnailUrl;
  late String outputPath;
  late String format;
  late String resolution;
  @Index()
  String? channelName;
  String? duration;
  late DateTime downloadedAt;
  late int fileSizeBytes;
  late bool isAudio;

  HistoryEntry({
    required this.jobId,
    required this.url,
    required this.title,
    this.thumbnailUrl,
    required this.outputPath,
    required this.format,
    required this.resolution,
    this.channelName,
    this.duration,
    required this.downloadedAt,
    this.fileSizeBytes = 0,
    this.isAudio = false,
  });

  String get fileSizeFormatted {
    if (fileSizeBytes <= 0) return '--';
    if (fileSizeBytes < 1024 * 1024) {
      return '${(fileSizeBytes / 1024).toStringAsFixed(1)} KB';
    }
    if (fileSizeBytes < 1024 * 1024 * 1024) {
      return '${(fileSizeBytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(fileSizeBytes / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
  }
}
