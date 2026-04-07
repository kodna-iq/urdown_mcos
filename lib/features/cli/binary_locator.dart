import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// Locates yt-dlp, ffmpeg, and ffprobe binaries.
/// This build targets macOS only.
class BinaryLocator {
  BinaryLocator._();

  static Future<String> ytDlpPath() async => _bundledMacOSPath('yt-dlp');
  static Future<String> ffmpegPath() async => _bundledMacOSPath('ffmpeg');
  static Future<String> ffprobePath() async => _bundledMacOSPath('ffprobe');

  static Future<bool> isYtDlpAvailable() async {
    try {
      final path = await ytDlpPath();
      final result = await Process.run(path, ['--version'], runInShell: false);
      return result.exitCode == 0;
    } catch (_) {
      return false;
    }
  }

  static Future<bool> updateYtDlp() async {
    try {
      final path = await ytDlpPath();
      print('[BinaryLocator] Updating yt-dlp at: $path');
      final result = await Process.run(path, ['-U'], runInShell: false);
      final out = '${result.stdout}${result.stderr}'.toLowerCase();
      return result.exitCode == 0 || out.contains('up to date') || out.contains('updated');
    } catch (e) {
      print('[BinaryLocator] yt-dlp update failed: $e');
      return false;
    }
  }

  static Future<bool> isFfmpegAvailable() async {
    try {
      final path = await ffmpegPath();
      final result = await Process.run(path, ['-version'], runInShell: false);
      return result.exitCode == 0;
    } catch (_) {
      return false;
    }
  }

  static Future<String?> ytDlpVersion() async {
    try {
      final path = await ytDlpPath();
      final result = await Process.run(path, ['--version'], runInShell: false);
      if (result.exitCode == 0) return (result.stdout as String).trim();
    } catch (_) {}
    return null;
  }

  static Future<String?> ffmpegVersion() async {
    try {
      final path = await ffmpegPath();
      final result = await Process.run(path, ['-version'], runInShell: false);
      if (result.exitCode == 0) {
        final out = result.stdout as String;
        final match = RegExp(r'ffmpeg version (\S+)').firstMatch(out);
        return match?.group(1);
      }
    } catch (_) {}
    return null;
  }

  // ─── macOS bundled path ───────────────────────────────────────────────────
  //
  // Release .app layout:
  //   UrDown.app/
  //     Contents/
  //       MacOS/          ← Platform.resolvedExecutable
  //       Frameworks/
  //         App.framework/
  //           Resources/
  //             flutter_assets/
  //               assets/binaries/macos/<name>
  //
  static String _bundledMacOSPath(String name) {
    final exeDir      = p.dirname(Platform.resolvedExecutable);
    final contentsDir = p.dirname(exeDir);
    return p.join(
      contentsDir,
      'Frameworks',
      'App.framework',
      'Resources',
      'flutter_assets',
      'assets',
      'binaries',
      'macos',
      name,
    );
  }
}
