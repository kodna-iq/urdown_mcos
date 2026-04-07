// ═══════════════════════════════════════════════════════════════════════════════
// BINARY UPDATE ENGINE — Windows
//
// Automatically updates yt-dlp.exe and ffmpeg/ffprobe on startup.
// Strategy:
//   1. yt-dlp: tries built-in self-updater (yt-dlp -U), then falls back to
//              direct GitHub API download (yt-dlp/yt-dlp releases)
//   2. ffmpeg:  checks installed version vs BtbN GitHub release,
//              downloads ffmpeg-master-latest-win64-gpl.zip and extracts EXEs
//
// Cooldown: 12 hours between background checks (SharedPreferences).
// Progress: Riverpod StateNotifier — BinaryUpdateNotifier.
// Atomic replace on Windows: download to .tmp → copy → delete .tmp
// ═══════════════════════════════════════════════════════════════════════════════

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../features/cli/binary_locator.dart';

// ── Prefs keys ────────────────────────────────────────────────────────────────
const _kLastCheckMs  = 'bin_update_last_check_ms';
const _kYtDlpVersion = 'bin_ytdlp_version';
const _cooldownHours = 12;

// ── GitHub API endpoints ──────────────────────────────────────────────────────
const _ytdlpStableApi  = 'https://api.github.com/repos/yt-dlp/yt-dlp/releases/latest';
const _ytdlpNightlyApi = 'https://api.github.com/repos/yt-dlp/yt-dlp-nightly-builds/releases/latest';
const _ffmpegApi       = 'https://api.github.com/repos/BtbN/FFmpeg-Builds/releases/latest';

// ══════════════════════════════════════════════════════════════════════════════
// BinaryUpdateState — immutable snapshot
// ══════════════════════════════════════════════════════════════════════════════

enum BinaryUpdatePhase {
  idle,        // nothing happening
  checking,    // querying GitHub
  downloading, // downloading binary
  extracting,  // unzipping (ffmpeg)
  upToDate,    // already on latest
  updated,     // just updated — show success
  failed,      // error
}

class BinaryUpdateState {
  const BinaryUpdateState({
    this.phase            = BinaryUpdatePhase.idle,
    this.currentBinary    = '',
    this.fromVersion      = '',
    this.toVersion        = '',
    this.progress         = 0.0,
    this.errorMessage     = '',
    this.dismissed        = false,
  });

  final BinaryUpdatePhase phase;
  final String            currentBinary;   // 'yt-dlp' or 'ffmpeg'
  final String            fromVersion;
  final String            toVersion;
  final double            progress;        // 0.0 → 1.0
  final String            errorMessage;
  final bool              dismissed;

  bool get isVisible =>
      !dismissed &&
      (phase == BinaryUpdatePhase.downloading ||
       phase == BinaryUpdatePhase.extracting  ||
       phase == BinaryUpdatePhase.updated     ||
       phase == BinaryUpdatePhase.failed);

  BinaryUpdateState copyWith({
    BinaryUpdatePhase? phase,
    String? currentBinary,
    String? fromVersion,
    String? toVersion,
    double? progress,
    String? errorMessage,
    bool?   dismissed,
  }) => BinaryUpdateState(
    phase:         phase         ?? this.phase,
    currentBinary: currentBinary ?? this.currentBinary,
    fromVersion:   fromVersion   ?? this.fromVersion,
    toVersion:     toVersion     ?? this.toVersion,
    progress:      progress      ?? this.progress,
    errorMessage:  errorMessage  ?? this.errorMessage,
    dismissed:     dismissed     ?? this.dismissed,
  );
}

// ══════════════════════════════════════════════════════════════════════════════
// BinaryUpdateNotifier — Riverpod StateNotifier
// ══════════════════════════════════════════════════════════════════════════════

class BinaryUpdateNotifier extends StateNotifier<BinaryUpdateState> {
  BinaryUpdateNotifier() : super(const BinaryUpdateState());

  bool _inProgress = false;

  // ── Public ─────────────────────────────────────────────────────────────────

  /// Call on app startup. Respects cooldown unless [force] = true.
  Future<void> checkAndUpdate({bool force = false}) async {
    if (_inProgress) return;
    if (!force && !await _shouldCheck()) return;

    _inProgress = true;
    try {
      await _updateYtDlp();
      await _updateFfmpeg();
      await _recordCheck();
    } finally {
      _inProgress = false;
      // If still in checking/idle after all updates, set upToDate
      if (state.phase == BinaryUpdatePhase.checking ||
          state.phase == BinaryUpdatePhase.idle) {
        state = state.copyWith(phase: BinaryUpdatePhase.upToDate);
      }
    }
  }

  void dismiss() => state = state.copyWith(dismissed: true);

  // ── yt-dlp update ──────────────────────────────────────────────────────────

  Future<void> _updateYtDlp() async {
    if (!mounted) return;
    state = state.copyWith(
      phase: BinaryUpdatePhase.checking,
      currentBinary: 'yt-dlp',
      dismissed: false,
    );

    try {
      final ytDlpPath = await BinaryLocator.ytDlpPath();

      // Step 1: Try built-in self-updater (yt-dlp -U) — fastest path
      final selfUpdateOk = await _selfUpdate(ytDlpPath);
      if (selfUpdateOk) return;

      // Step 2: Fallback — download directly from GitHub releases
      await _ytdlpGithubUpdate(ytDlpPath);

    } catch (e) {
      print('[BinaryUpdate] yt-dlp update error: $e');
      if (mounted) {
        state = state.copyWith(
          phase: BinaryUpdatePhase.failed,
          errorMessage: 'yt-dlp update failed: $e',
        );
      }
    }
  }

  /// Uses yt-dlp's own self-update mechanism.
  /// Returns true if it handled the update (success or already up to date).
  Future<bool> _selfUpdate(String binaryPath) async {
    try {
      final installed = await _ytdlpInstalledVersion(binaryPath);
      final latest    = await _fetchLatestTag(_ytdlpStableApi);

      if (!_isNewer(latest, installed)) {
        print('[BinaryUpdate] yt-dlp up to date: $installed');
        if (mounted) state = state.copyWith(phase: BinaryUpdatePhase.upToDate);
        return true;
      }

      print('[BinaryUpdate] yt-dlp update available: $installed → $latest');
      if (mounted) {
        state = state.copyWith(
          phase:       BinaryUpdatePhase.downloading,
          fromVersion: installed,
          toVersion:   latest,
          progress:    0.0,
        );
      }

      // yt-dlp -U handles download+replace internally
      final result = await Process.run(binaryPath, ['-U'], runInShell: false)
          .timeout(const Duration(minutes: 5));
      final output = '${result.stdout}${result.stderr}'.toLowerCase();

      if (result.exitCode == 0 ||
          output.contains('updated') ||
          output.contains('up to date')) {
        final newVersion = await _ytdlpInstalledVersion(binaryPath);
        await _persistYtDlpVersion(newVersion);
        if (mounted) {
          state = state.copyWith(
            phase:     BinaryUpdatePhase.updated,
            toVersion: newVersion,
            progress:  1.0,
          );
        }
        print('[BinaryUpdate] yt-dlp self-update OK: $installed → $newVersion');
        return true;
      }

      print('[BinaryUpdate] yt-dlp -U returned ${result.exitCode}, falling back to GitHub');
      return false;

    } catch (e) {
      print('[BinaryUpdate] yt-dlp self-update error: $e — falling back');
      return false;
    }
  }

  /// Direct download from GitHub releases API (fallback).
  Future<void> _ytdlpGithubUpdate(String binaryPath) async {
    for (final apiUrl in [_ytdlpStableApi, _ytdlpNightlyApi]) {
      try {
        final tag       = await _fetchLatestTag(apiUrl);
        final installed = await _ytdlpInstalledVersion(binaryPath);

        if (!_isNewer(tag, installed)) {
          if (mounted) state = state.copyWith(phase: BinaryUpdatePhase.upToDate);
          return;
        }

        if (mounted) {
          state = state.copyWith(
            phase:       BinaryUpdatePhase.downloading,
            fromVersion: installed,
            toVersion:   tag,
            progress:    0.0,
          );
        }

        final isNightly = apiUrl.contains('nightly');
        final repo      = isNightly ? 'yt-dlp/yt-dlp-nightly-builds' : 'yt-dlp/yt-dlp';
        final binName   = Platform.isWindows ? 'yt-dlp.exe' : 'yt-dlp_macos';
        final url       = 'https://github.com/$repo/releases/download/$tag/$binName';

        final ok = await _downloadBinary(binaryPath, url);
        if (ok) {
          await _persistYtDlpVersion(tag);
          if (mounted) {
            state = state.copyWith(
              phase:    BinaryUpdatePhase.updated,
              toVersion: tag,
              progress: 1.0,
            );
          }
          print('[BinaryUpdate] yt-dlp GitHub update OK: $installed → $tag');
          return;
        }
      } catch (e) {
        print('[BinaryUpdate] GitHub channel $apiUrl failed: $e');
      }
    }
    if (mounted) {
      state = state.copyWith(
        phase:        BinaryUpdatePhase.failed,
        errorMessage: 'All yt-dlp update channels failed.',
      );
    }
  }

  // ── ffmpeg update ──────────────────────────────────────────────────────────

  Future<void> _updateFfmpeg() async {
    if (!mounted) return;
    try {
      final ffmpegPath  = await BinaryLocator.ffmpegPath();
      final ffprobePath = await BinaryLocator.ffprobePath();

      // Check installed version
      final installed = await BinaryLocator.ffmpegVersion() ?? 'unknown';

      // Get latest BtbN tag
      final r = await http.get(
        Uri.parse(_ffmpegApi),
        headers: {'Accept': 'application/vnd.github.v3+json', 'User-Agent': 'UrDown/1.0'},
      ).timeout(const Duration(seconds: 15));

      if (r.statusCode != 200) {
        print('[BinaryUpdate] ffmpeg API HTTP ${r.statusCode}');
        return;
      }

      final json   = jsonDecode(r.body) as Map<String, dynamic>;
      final assets = (json['assets'] as List? ?? []);

      // Find the essentials-only build (smaller than full GPL)
      // Prefer: ffmpeg-master-latest-win64-gpl-shared.zip  → too large
      // Use:    ffmpeg-master-latest-win64-lgpl.zip         → ~30 MB
      // Best for our use case (no GPL linking issues):
      //         ffmpeg-master-latest-win64-gpl.zip           → ~130 MB
      // We'll pick the smallest zip that includes ffmpeg.exe + ffprobe.exe
      String? zipUrl;
      for (final asset in assets) {
        final name = ((asset as Map)['name'] as String? ?? '').toLowerCase();
        if (Platform.isWindows) {
          if (name.contains('win64') && name.endsWith('.zip') &&
              name.contains('gpl') && !name.contains('shared') &&
              !name.contains('lgpl')) {
            zipUrl = asset['browser_download_url'] as String?;
            break;
          }
        } else if (Platform.isMacOS) {
          if (name.contains('macos') && name.endsWith('.zip')) {
            zipUrl = asset['browser_download_url'] as String?;
            break;
          }
        }
      }

      if (zipUrl == null) {
        print('[BinaryUpdate] No suitable ffmpeg asset found');
        return;
      }

      final tag = (json['tag_name'] as String? ?? '').replaceAll('-', '.');
      if (!_isNewer(tag, installed)) {
        print('[BinaryUpdate] ffmpeg up to date: $installed');
        return;
      }

      print('[BinaryUpdate] ffmpeg update: $installed → $tag');
      if (mounted) {
        state = state.copyWith(
          phase:         BinaryUpdatePhase.downloading,
          currentBinary: 'ffmpeg',
          fromVersion:   installed,
          toVersion:     tag,
          progress:      0.0,
          dismissed:     false,
        );
      }

      // Download zip
      final tmpDir  = await getTemporaryDirectory();
      final zipFile = File(p.join(tmpDir.path, 'ffmpeg_update.zip'));
      final ok = await _downloadWithProgress(zipUrl, zipFile);
      if (!ok) {
        print('[BinaryUpdate] ffmpeg download failed');
        return;
      }

      // Extract ffmpeg.exe and ffprobe.exe from the zip
      if (mounted) {
        state = state.copyWith(phase: BinaryUpdatePhase.extracting, progress: 0.9);
      }

      await _extractFfmpegFromZip(zipFile, ffmpegPath, ffprobePath);
      try { await zipFile.delete(); } catch (_) {}

      if (mounted) {
        state = state.copyWith(
          phase:    BinaryUpdatePhase.updated,
          toVersion: tag,
          progress: 1.0,
        );
      }
      print('[BinaryUpdate] ffmpeg updated: $installed → $tag');

    } catch (e) {
      // ffmpeg update is optional — log but don't surface error
      print('[BinaryUpdate] ffmpeg update skipped: $e');
    }
  }

  /// Extract ffmpeg.exe and ffprobe.exe from the BtbN zip using Dart's `Archive`.
  /// BtbN zip structure: ffmpeg-xxx/bin/ffmpeg.exe, ffmpeg-xxx/bin/ffprobe.exe
  Future<void> _extractFfmpegFromZip(
      File zipFile, String ffmpegDest, String ffprobeDest) async {
    // Use PowerShell Expand-Archive on Windows — no external library needed.
    final tmpDir    = await getTemporaryDirectory();
    final extractTo = p.join(tmpDir.path, 'ffmpeg_extracted');
    await Directory(extractTo).create(recursive: true);

    // PowerShell is available on all Windows 10+ machines
    final result = await Process.run('powershell', [
      '-NoProfile', '-Command',
      'Expand-Archive -Path "${zipFile.path}" -DestinationPath "$extractTo" -Force',
    ]).timeout(const Duration(minutes: 5));

    if (result.exitCode != 0) {
      throw Exception('PowerShell extract failed: ${result.stderr}');
    }

    // Find ffmpeg.exe and ffprobe.exe inside extracted folder
    final extracted = Directory(extractTo);
    await for (final entity in extracted.list(recursive: true)) {
      if (entity is File) {
        final name = p.basename(entity.path).toLowerCase();
        if (name == 'ffmpeg.exe' || name == 'ffmpeg') {
          await _atomicReplace(entity.path, ffmpegDest);
          if (!Platform.isWindows) {
            await Process.run('chmod', ['+x', ffmpegDest]);
          }
        } else if (name == 'ffprobe.exe' || name == 'ffprobe') {
          await _atomicReplace(entity.path, ffprobeDest);
          if (!Platform.isWindows) {
            await Process.run('chmod', ['+x', ffprobeDest]);
          }
        }
      }
    }

    // Cleanup
    try { await extracted.delete(recursive: true); } catch (_) {}
  }

  // ── Download helpers ───────────────────────────────────────────────────────

  /// Download a binary file with progress reporting.
  Future<bool> _downloadBinary(String destPath, String url) async {
    final tmpPath = '$destPath.tmp';
    try {
      final req   = http.Request('GET', Uri.parse(url));
      final sresp = await req.send().timeout(const Duration(minutes: 10));
      if (sresp.statusCode != 200) return false;

      final total    = sresp.contentLength ?? 0;
      var   received = 0;
      final sink     = File(tmpPath).openWrite();

      await for (final chunk in sresp.stream) {
        if (!mounted) { await sink.close(); return false; }
        sink.add(chunk);
        received += chunk.length;
        if (total > 0 && mounted) {
          state = state.copyWith(
            progress: (received / total).clamp(0.0, 0.95),
          );
        }
      }
      await sink.flush();
      await sink.close();

      if (File(tmpPath).lengthSync() < 1024 * 100) {
        throw Exception('Downloaded file too small');
      }

      await _atomicReplace(tmpPath, destPath);
      return true;
    } catch (e) {
      try { File(tmpPath).deleteSync(); } catch (_) {}
      print('[BinaryUpdate] _downloadBinary error: $e');
      return false;
    }
  }

  /// Download with progress (returns File on success).
  Future<bool> _downloadWithProgress(String url, File dest) async {
    final tmp = File('${dest.path}.part');
    try {
      final req   = http.Request('GET', Uri.parse(url));
      final sresp = await req.send().timeout(const Duration(minutes: 10));
      if (sresp.statusCode != 200) return false;

      final total    = sresp.contentLength ?? 0;
      var   received = 0;
      final sink     = tmp.openWrite();

      await for (final chunk in sresp.stream) {
        if (!mounted) { await sink.close(); return false; }
        sink.add(chunk);
        received += chunk.length;
        if (total > 0 && mounted) {
          state = state.copyWith(
            progress: (received / total * 0.85).clamp(0.0, 0.85),
          );
        }
      }
      await sink.flush();
      await sink.close();

      if (dest.existsSync()) await dest.delete();
      await tmp.rename(dest.path);
      return true;
    } catch (e) {
      try { if (tmp.existsSync()) await tmp.delete(); } catch (_) {}
      return false;
    }
  }

  /// Windows atomic replace: copy new → dest, delete new.
  Future<void> _atomicReplace(String srcPath, String destPath) async {
    await Directory(p.dirname(destPath)).create(recursive: true);
    await File(srcPath).copy(destPath);
    try { await File(srcPath).delete(); } catch (_) {}
  }

  // ── Version helpers ────────────────────────────────────────────────────────

  Future<String> _fetchLatestTag(String apiUrl) async {
    final r = await http.get(Uri.parse(apiUrl), headers: {
      'Accept':     'application/vnd.github.v3+json',
      'User-Agent': 'UrDown/1.0',
    }).timeout(const Duration(seconds: 15));
    if (r.statusCode != 200) throw Exception('GitHub HTTP ${r.statusCode}');
    final tag = (jsonDecode(r.body) as Map)['tag_name'] as String?;
    if (tag == null || tag.isEmpty) throw Exception('No tag_name');
    return tag;
  }

  Future<String> _ytdlpInstalledVersion(String binaryPath) async {
    // Try SharedPreferences first (faster)
    try {
      final prefs = await SharedPreferences.getInstance();
      final v = prefs.getString(_kYtDlpVersion);
      if (v != null && v.isNotEmpty) return v;
    } catch (_) {}
    // Fall back to running the binary
    try {
      final r = await Process.run(binaryPath, ['--version'], runInShell: false)
          .timeout(const Duration(seconds: 5));
      final v = (r.stdout as String).trim();
      if (v.isNotEmpty) { await _persistYtDlpVersion(v); return v; }
    } catch (_) {}
    return 'unknown';
  }

  Future<void> _persistYtDlpVersion(String v) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_kYtDlpVersion, v);
    } catch (_) {}
  }

  /// Returns true if [latest] is newer than [installed].
  bool _isNewer(String latest, String installed) {
    if (installed == 'unknown') return true;
    final parse = (String s) => s
        .replaceAll(RegExp(r'[^0-9.]'), '.')
        .split('.')
        .where((x) => x.isNotEmpty)
        .map((x) => int.tryParse(x) ?? 0)
        .toList();
    final l = parse(latest);
    final i = parse(installed);
    for (int j = 0; j < 4 && j < l.length && j < i.length; j++) {
      if (l[j] > i[j]) return true;
      if (l[j] < i[j]) return false;
    }
    return l.length > i.length;
  }

  // ── Cooldown ───────────────────────────────────────────────────────────────

  Future<bool> _shouldCheck() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final last  = prefs.getInt(_kLastCheckMs) ?? 0;
      final diff  = DateTime.now().millisecondsSinceEpoch - last;
      return diff > _cooldownHours * 3600 * 1000;
    } catch (_) { return true; }
  }

  Future<void> _recordCheck() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_kLastCheckMs, DateTime.now().millisecondsSinceEpoch);
    } catch (_) {}
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// Riverpod provider
// ══════════════════════════════════════════════════════════════════════════════

final binaryUpdateProvider =
    StateNotifierProvider<BinaryUpdateNotifier, BinaryUpdateState>(
  (_) => BinaryUpdateNotifier(),
);
