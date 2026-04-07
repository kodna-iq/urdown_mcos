import '../download/models/download_job.dart';

class ProgressParser {
  ProgressParser._();

  // [download]   45.3% of 234.56MiB at 3.21MiB/s ETA 00:43
  // [download]   45.3% of ~234.56MiB at 3.21MiB/s ETA 00:43  (estimated size)
  // Fixed: handle '~ 58.59MiB' (space after ~) and double spaces after 'at'
  static final _downloadRegex = RegExp(
    r'\[download\]\s+(\d+\.?\d*)%\s+of\s+~?\s*([\d.]+\s*\w+iB)(?:\s+at\s+([\d.]+\s*\w+iB/s))?(?:\s+ETA\s+([\w:]+))?',
  );


  // [download] 100% of 234.56MiB in 00:32 at 7.3MiB/s
  static final _completeRegex = RegExp(
    r'\[download\] 100% of ~?([\d.]+\s*\w+iB)',
  );

  // [Merger] Merging formats into "output.mp4"
  static final _mergerRegex = RegExp(r'\[Merger\]');

  // [ExtractAudio] ...
  static final _extractRegex = RegExp(r'\[ExtractAudio\]');

  // ERROR: ...
  static final _errorRegex = RegExp(r'^ERROR:\s*(.+)');

  // Fragment N/M
  static final _fragmentRegex = RegExp(r'\(frag (\d+)/(\d+)\)');

  static DownloadEvent? parse(String line) {
    // Check for error
    final errorMatch = _errorRegex.firstMatch(line);
    if (errorMatch != null) {
      return DownloadEventFailed(errorMatch.group(1) ?? 'Unknown error');
    }

    // Check for completion
    if (_completeRegex.hasMatch(line)) {
      return DownloadEventProgress(
        DownloadProgress(
          percent: 100,
          totalSize: _completeRegex.firstMatch(line)?.group(1) ?? '--',
          speed: '--',
          eta: '00:00',
        ),
      );
    }

    // Check for merger (post-processing)
    if (_mergerRegex.hasMatch(line) || _extractRegex.hasMatch(line)) {
      return DownloadEventLog(line.trim());
    }

    // Check for progress
    final match = _downloadRegex.firstMatch(line);
    if (match != null) {
      final fragMatch = _fragmentRegex.firstMatch(line);
      return DownloadEventProgress(
        DownloadProgress(
          percent: double.tryParse(match.group(1) ?? '0') ?? 0,
          totalSize: match.group(2) ?? '--',
          speed: match.group(3) ?? '--',
          eta: match.group(4) ?? '--',
          fragment: fragMatch != null
              ? '${fragMatch.group(1)}/${fragMatch.group(2)}'
              : null,
        ),
      );
    }

    // Log line
    if (line.trim().isNotEmpty) {
      return DownloadEventLog(line.trim());
    }

    return null;
  }
}
