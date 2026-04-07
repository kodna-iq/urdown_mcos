import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'binary_locator.dart';

class FfmpegRunner {
  FfmpegRunner._();

  // ─── High-level operations ────────────────────────────────────────────

  /// Merge separate video + audio streams into a single container.
  static Future<void> mergeStreams({
    required String videoPath,
    required String audioPath,
    required String outputPath,
  }) async {
    await _run([
      '-i', videoPath,
      '-i', audioPath,
      '-c:v', 'copy',
      '-c:a', 'aac',
      '-map', '0:v:0',
      '-map', '1:a:0',
      '-movflags', '+faststart',
      '-y',
      outputPath,
    ]);
  }

  /// Convert a file to a different container (stream copy, no re-encode).
  static Future<void> convertFormat({
    required String inputPath,
    required String outputPath,
  }) async {
    await _run(['-i', inputPath, '-c', 'copy', '-y', outputPath]);
  }

  /// Extract the audio track from a video file.
  static Future<void> extractAudio({
    required String inputPath,
    required String outputPath,
    String format = 'mp3',
    String quality = '0',
  }) async {
    await _run([
      '-i', inputPath,
      '-q:a', quality,
      '-map', 'a',
      '-vn',
      '-y',
      outputPath,
    ]);
  }

  /// Trim a file by absolute time range without re-encoding.
  static Future<void> trimVideo({
    required String inputPath,
    required String outputPath,
    required String startTime,
    required String endTime,
  }) async {
    await _run([
      '-i', inputPath,
      '-ss', startTime,
      '-to', endTime,
      '-c', 'copy',
      '-y',
      outputPath,
    ]);
  }

  /// Embed a subtitle file as a soft subtitle track.
  static Future<void> embedSubtitles({
    required String videoPath,
    required String subtitlePath,
    required String outputPath,
    String language = 'eng',
  }) async {
    await _run([
      '-i', videoPath,
      '-i', subtitlePath,
      '-c', 'copy',
      '-c:s', 'mov_text',
      '-metadata:s:s:0', 'language=$language',
      '-y',
      outputPath,
    ]);
  }

  /// Embed a thumbnail image as cover art (e.g. for MP3/M4A files).
  static Future<void> embedThumbnail({
    required String audioPath,
    required String thumbnailPath,
    required String outputPath,
  }) async {
    await _run([
      '-i', audioPath,
      '-i', thumbnailPath,
      '-map', '0:a',
      '-map', '1:v',
      '-c', 'copy',
      '-id3v2_version', '3',
      '-metadata:s:v', 'title=Album cover',
      '-metadata:s:v', 'comment=Cover (front)',
      '-y',
      outputPath,
    ]);
  }

  /// Transcode video to H.264 + AAC for maximum compatibility across
  /// Windows, macOS, Android, and iOS.
  ///
  /// - Video: libx264 (H.264), CRF 23 (good quality/size balance)
  /// - Audio: AAC 192k stereo
  /// - Container: MP4 with faststart for web/streaming
  ///
  /// If the video is already H.264, this is a no-op (returns false).
  /// Returns true if transcoding was performed, false if skipped.
  static Future<bool> transcodeToH264({
    required String inputPath,
    required String outputPath,
    void Function(double progress)? onProgress,
  }) async {
    // Check current codec via ffprobe
    final meta = await probeFile(inputPath);
    final streams = meta['streams'] as List<dynamic>? ?? [];
    final videoStream = streams.firstWhere(
      (s) => s['codec_type'] == 'video' && s['disposition']?['attached_pic'] != 1,
      orElse: () => null,
    );

    final codec = videoStream?['codec_name'] as String? ?? '';
    print('[FfmpegRunner] Input codec: $codec');

    // Skip if already H.264
    if (codec == 'h264') {
      print('[FfmpegRunner] Already H.264, skipping transcode');
      return false;
    }

    print('[FfmpegRunner] Transcoding $codec → H.264...');

    final ffmpegPath = await BinaryLocator.ffmpegPath();

    // Get duration for progress calculation
    final durationStr = meta['format']?['duration'] as String? ?? '0';
    final totalSeconds = double.tryParse(durationStr) ?? 0;

    final args = [
      '-hide_banner',
      '-loglevel', 'error',
      '-progress', 'pipe:1',  // write progress to stdout
      '-i', inputPath,
      // Video: H.264, good quality
      '-c:v', 'libx264',
      '-crf', '23',
      '-preset', 'fast',
      '-profile:v', 'high',
      '-level', '4.1',
      '-pix_fmt', 'yuv420p',
      // Audio: AAC stereo
      '-c:a', 'aac',
      '-b:a', '192k',
      '-ac', '2',
      // Remove extra streams (thumbnails etc)
      '-map', '0:v:0',
      '-map', '0:a:0?',
      // MP4 faststart for compatibility
      '-movflags', '+faststart',
      '-y',
      outputPath,
    ];

    final process = await Process.start(ffmpegPath, args, runInShell: false);

    // Parse progress from stdout
    process.stdout
        .transform(utf8.decoder)
        .transform(const LineSplitter())
        .listen((line) {
      if (onProgress != null && totalSeconds > 0 && line.startsWith('out_time_ms=')) {
        final ms = int.tryParse(line.replaceFirst('out_time_ms=', '')) ?? 0;
        final seconds = ms / 1000000.0;
        final pct = (seconds / totalSeconds * 100).clamp(0.0, 100.0);
        onProgress(pct);
      }
    });

    final errors = <String>[];
    process.stderr
        .transform(utf8.decoder)
        .transform(const LineSplitter())
        .listen((line) {
      if (line.trim().isNotEmpty) errors.add(line);
    });

    final exitCode = await process.exitCode;
    if (exitCode != 0) {
      throw Exception('FFmpeg transcode failed: ${errors.join(' ')}');
    }

    print('[FfmpegRunner] Transcode complete');
    return true;
  }

  /// Run ffprobe on a file and return parsed JSON metadata.
  static Future<Map<String, dynamic>> probeFile(String filePath) async {
    final ffprobePath = await BinaryLocator.ffprobePath();

    final result = await Process.run(
      ffprobePath,
      [
        '-v', 'quiet',
        '-print_format', 'json',
        '-show_streams',
        '-show_format',
        filePath,
      ],
      runInShell: false,
      stdoutEncoding: utf8,
      stderrEncoding: utf8,
    );

    if (result.exitCode != 0) {
      throw Exception('ffprobe failed: ${result.stderr}');
    }

    return jsonDecode(result.stdout as String) as Map<String, dynamic>;
  }

  // ─── Internal runner ──────────────────────────────────────────────────

  static Future<void> _run(List<String> args) async {
    final binaryPath = await BinaryLocator.ffmpegPath();
    final result = await Process.run(
      binaryPath,
      ['-hide_banner', '-loglevel', 'error', ...args],
      runInShell: false,
      stdoutEncoding: utf8,
      stderrEncoding: utf8,
    );

    if (result.exitCode != 0) {
      final msg = (result.stderr as String).replaceAll('\n', ' ').trim();
      throw Exception('FFmpeg error: $msg');
    }
  }
}
