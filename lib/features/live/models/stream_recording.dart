import 'package:flutter/material.dart';
import '../../../core/l10n/app_strings.dart';

// ─── Recording Status ─────────────────────────────────────────────────────────

enum RecordingStatus {
  idle,
  connecting,
  recording,
  paused,
  resuming,
  stopping,
  saved,
  failed,
}

extension RecordingStatusX on RecordingStatus {
  bool get isActive =>
      this == RecordingStatus.connecting ||
      this == RecordingStatus.recording ||
      this == RecordingStatus.paused ||
      this == RecordingStatus.resuming;

  bool get canPause => this == RecordingStatus.recording;
  bool get canResume => this == RecordingStatus.paused;
  bool get canStop => isActive || this == RecordingStatus.stopping;

  String get label {
    return switch (this) {
      RecordingStatus.idle => 'Idle',
      RecordingStatus.connecting => 'Connecting',
      RecordingStatus.recording => 'Recording',
      RecordingStatus.paused => 'Paused',
      RecordingStatus.resuming => 'Resuming',
      RecordingStatus.stopping => 'Saving...',
      RecordingStatus.saved => 'Saved',
      RecordingStatus.failed => 'Failed',
    };
  }

  String localizedLabel(AppStrings s) {
    return switch (this) {
      RecordingStatus.idle => s.liveStatusIdle,
      RecordingStatus.connecting => s.liveStatusConnecting,
      RecordingStatus.recording => s.liveStatusRecording,
      RecordingStatus.paused => s.liveStatusPaused,
      RecordingStatus.resuming => s.liveStatusResuming,
      RecordingStatus.stopping => s.liveStatusStopping,
      RecordingStatus.saved => s.liveStatusSaved,
      RecordingStatus.failed => s.liveStatusFailed,
    };
  }

  Color get color {
    return switch (this) {
      RecordingStatus.idle => const Color(0xFF6B7280),
      RecordingStatus.connecting => const Color(0xFFFB923C),
      RecordingStatus.recording => const Color(0xFFEF4444),
      RecordingStatus.paused => const Color(0xFFFB923C),
      RecordingStatus.resuming => const Color(0xFFFB923C),
      RecordingStatus.stopping => const Color(0xFFFB923C),
      RecordingStatus.saved => const Color(0xFF4ADE80),
      RecordingStatus.failed => const Color(0xFFEF4444),
    };
  }
}

// ─── Platform Info ────────────────────────────────────────────────────────────

class PlatformInfo {
  const PlatformInfo({
    required this.name,
    required this.color,
    required this.icon,
  });

  final String name;
  final Color color;
  final IconData icon;

  static PlatformInfo fromUrl(String url) {
    final u = url.toLowerCase();
    if (u.contains('youtube') || u.contains('youtu.be')) {
      return const PlatformInfo(
        name: 'YouTube',
        color: Color(0xFFFF0000),
        icon: Icons.play_circle_rounded,
      );
    }
    if (u.contains('tiktok')) {
      return const PlatformInfo(
        name: 'TikTok',
        color: Color(0xFF69C9D0),
        icon: Icons.music_video_rounded,
      );
    }
    if (u.contains('facebook') || u.contains('fb.watch')) {
      return const PlatformInfo(
        name: 'Facebook',
        color: Color(0xFF1877F2),
        icon: Icons.facebook_rounded,
      );
    }
    if (u.contains('instagram')) {
      return const PlatformInfo(
        name: 'Instagram',
        color: Color(0xFFE1306C),
        icon: Icons.camera_alt_rounded,
      );
    }
    if (u.contains('twitch')) {
      return const PlatformInfo(
        name: 'Twitch',
        color: Color(0xFF9146FF),
        icon: Icons.sports_esports_rounded,
      );
    }
    if (u.contains('twitter') || u.contains('x.com')) {
      return const PlatformInfo(
        name: 'Twitter/X',
        color: Color(0xFF1DA1F2),
        icon: Icons.alternate_email_rounded,
      );
    }
    return const PlatformInfo(
      name: 'Live Stream',
      color: Color(0xFF00E5FF),
      icon: Icons.live_tv_rounded,
    );
  }
}

// ─── Stream Recording State ───────────────────────────────────────────────────

class StreamRecording {
  StreamRecording({
    required this.id,
    required this.url,
    required this.quality,
    required this.format,
    this.maxDurationSeconds,
  }) : platform = PlatformInfo.fromUrl(url),
       startedAt = DateTime.now();

  final String id;
  final String url;
  final String quality;
  final String format;
  final int? maxDurationSeconds;
  final PlatformInfo platform;
  final DateTime startedAt;

  RecordingStatus status = RecordingStatus.idle;
  Duration duration = Duration.zero;
  int sizeBytes = 0;
  String? outputPath;
  String? errorMessage;
  int cpuPercent = 0;
  int memoryMb = 0;
  bool convertingToMp4 = false; // true while ffmpeg converts FLV → MP4

  String get durationFormatted {
    final h = duration.inHours;
    final m = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return h > 0 ? '$h:$m:$s' : '$m:$s';
  }

  String get sizeFormatted {
    if (sizeBytes < 1024 * 1024) {
      return '${(sizeBytes / 1024).toStringAsFixed(1)} KB';
    }
    return '${(sizeBytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  StreamRecording copyWith({
    RecordingStatus? status,
    Duration? duration,
    int? sizeBytes,
    String? outputPath,
    String? errorMessage,
    int? cpuPercent,
    int? memoryMb,
  }) {
    final copy = StreamRecording(
      id: id,
      url: url,
      quality: quality,
      format: format,
      maxDurationSeconds: maxDurationSeconds,
    );
    copy.status = status ?? this.status;
    copy.duration = duration ?? this.duration;
    copy.sizeBytes = sizeBytes ?? this.sizeBytes;
    copy.outputPath = outputPath ?? this.outputPath;
    copy.errorMessage = errorMessage;
    copy.cpuPercent = cpuPercent ?? this.cpuPercent;
    copy.memoryMb = memoryMb ?? this.memoryMb;
    return copy;
  }
}
