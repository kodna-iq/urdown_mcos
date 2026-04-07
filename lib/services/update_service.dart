// ignore_for_file: avoid_catches_without_on_clauses

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// UpdateInfo  — immutable release metadata
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

class UpdateInfo {
  const UpdateInfo({
    required this.version,
    required this.releaseNotes,
    required this.downloadUrl,
    required this.checksumUrl,
    required this.releasePageUrl,
    required this.publishedAt,
  });

  final String version;
  final String releaseNotes;
  final String downloadUrl;
  final String checksumUrl;    // URL to .sha256 asset — empty if not in release
  final String releasePageUrl;
  final String publishedAt;
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// UpdatePhase  — state-machine phases (Chrome / VS Code style)
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

/// Idle → Checking → Downloading → Verifying → Ready → Installing → [exit]
///                                               ↕              ↕
///                                            Failed ←──────────┘
///                                               ↓ (retry)
///                                          Downloading
enum UpdatePhase {
  idle,         // No update activity
  checking,     // Querying GitHub releases API
  downloading,  // Background file download with progress
  verifying,    // SHA-256 integrity check
  ready,        // Installer on disk, waiting for user to restart
  installing,   // Launching installer & closing app
  failed,       // Error occurred — retryable or open browser
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// UpdateState  — immutable snapshot broadcast to UI
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

class UpdateState {
  const UpdateState({
    this.phase = UpdatePhase.idle,
    this.info,
    this.progress = 0.0,
    this.errorMessage,
    this.retryCount = 0,
    this.dismissed = false,
  });

  final UpdatePhase phase;
  final UpdateInfo? info;
  final double progress;        // 0.0 → 1.0 during download
  final String? errorMessage;
  final int retryCount;
  final bool dismissed;         // user closed the banner

  /// Whether the update banner should be shown.
  bool get isVisible =>
      info != null &&
      !dismissed &&
      phase != UpdatePhase.idle &&
      phase != UpdatePhase.checking;

  bool get canRetry => retryCount < UpdateNotifier.maxRetries;

  UpdateState copyWith({
    UpdatePhase? phase,
    UpdateInfo? info,
    double? progress,
    String? errorMessage,
    int? retryCount,
    bool? dismissed,
  }) {
    return UpdateState(
      phase:        phase        ?? this.phase,
      info:         info         ?? this.info,
      progress:     progress     ?? this.progress,
      errorMessage: errorMessage,  // explicitly allow null to clear error
      retryCount:   retryCount   ?? this.retryCount,
      dismissed:    dismissed    ?? this.dismissed,
    );
  }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// UpdateNotifier  — Riverpod StateNotifier (single source of truth)
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

class UpdateNotifier extends StateNotifier<UpdateState> {
  UpdateNotifier() : super(const UpdateState());

  // ── Configuration ──────────────────────────────────────────────────────
  static const _githubOwner         = 'kodna-iq';
  static const _githubRepo          = 'urdown';
  static const _apiUrl              =
      'https://api.github.com/repos/$_githubOwner/$_githubRepo/releases/latest';
  static const _prefLastCheck       = 'update_last_check_v3';
  static const _checkIntervalHours  = 24;
  static const maxRetries           = 3;

  String? _installerPath;

  // ────────────────────────────────────────────────────────────────────────
  // Public API
  // ────────────────────────────────────────────────────────────────────────

  /// Check GitHub releases for a newer version.
  /// - Respects [_checkIntervalHours] cache unless [force] is true.
  /// - On finding a newer version, automatically starts background download.
  Future<void> checkForUpdate({
    required String currentVersion,
    bool force = false,
  }) async {
    if (state.phase != UpdatePhase.idle && !force) return;

    // Honour check-interval (skip if checked recently)
    if (!force) {
      final prefs = await SharedPreferences.getInstance();
      final lastMs = prefs.getInt(_prefLastCheck) ?? 0;
      final elapsed = DateTime.now().millisecondsSinceEpoch - lastMs;
      if (elapsed < _checkIntervalHours * 3600 * 1000) return;
    }

    state = state.copyWith(phase: UpdatePhase.checking, dismissed: false);

    try {
      final resp = await http.get(
        Uri.parse(_apiUrl),
        headers: {'Accept': 'application/vnd.github+json'},
      ).timeout(const Duration(seconds: 15));

      if (resp.statusCode != 200) {
        state = state.copyWith(phase: UpdatePhase.idle);
        return;
      }

      // Stamp successful check time
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_prefLastCheck, DateTime.now().millisecondsSinceEpoch);

      final json = jsonDecode(resp.body) as Map<String, dynamic>;
      final tag  = ((json['tag_name'] as String?) ?? '').replaceFirst('v', '');
      if (tag.isEmpty || !_isNewer(tag, currentVersion)) {
        state = state.copyWith(phase: UpdatePhase.idle);
        return;
      }

      final assets = (json['assets'] as List<dynamic>?) ?? [];
      final keyword    = _platformKeyword();
      final assetUrl   = _findAssetUrl(assets, keyword) ?? '';
      final sha256Url  =
          _findAssetUrl(assets, '$keyword.sha256') ??
          _findAssetUrl(assets, '.sha256') ?? '';

      if (assetUrl.isEmpty) {
        state = state.copyWith(phase: UpdatePhase.idle);
        return;
      }

      final info = UpdateInfo(
        version:        tag,
        releaseNotes:   (json['body'] as String?) ?? '',
        downloadUrl:    assetUrl,
        checksumUrl:    sha256Url,
        releasePageUrl: (json['html_url'] as String?) ?? '',
        publishedAt:    (json['published_at'] as String?) ?? '',
      );

      state = state.copyWith(
        phase:      UpdatePhase.downloading,
        info:       info,
        progress:   0.0,
        retryCount: 0,
        errorMessage: null,
      );

      // Kick off background download — do NOT await
      unawaited(_downloadInBackground(info));
    } catch (_) {
      state = state.copyWith(phase: UpdatePhase.idle);
    }
  }

  /// User dismissed the update banner — hides it without cancelling download.
  void dismiss() {
    state = state.copyWith(dismissed: true);
  }

  /// Re-show a previously dismissed update (e.g. from Settings page).
  void undismiss() {
    state = state.copyWith(dismissed: false);
  }

  /// Retry a failed download with exponential back-off.
  Future<void> retry() async {
    final info = state.info;
    if (info == null) return;
    if (!state.canRetry) {
      state = state.copyWith(
        phase: UpdatePhase.failed,
        errorMessage: 'Max retries reached. Open the download page to update manually.',
      );
      return;
    }

    final newRetry = state.retryCount + 1;
    state = state.copyWith(
      phase:        UpdatePhase.downloading,
      progress:     0.0,
      errorMessage: null,
      retryCount:   newRetry,
      dismissed:    false,
    );

    // Exponential back-off: 2 s, 4 s, 8 s
    final delay = Duration(seconds: 1 << newRetry);
    await Future.delayed(delay);
    if (!mounted) return;
    unawaited(_downloadInBackground(info));
  }

  /// Launch the installer and exit the app.
  Future<void> installAndRestart() async {
    final path = _installerPath;
    if (path == null || !File(path).existsSync()) {
      state = state.copyWith(
        phase: UpdatePhase.failed,
        errorMessage: 'Installer not found. Please retry.',
      );
      return;
    }

    state = state.copyWith(phase: UpdatePhase.installing);

    try {
      if (Platform.isWindows) {
        // VERYSILENT:          no UI
        // CLOSEAPPLICATIONS:   closes open copies of the app
        // RESTARTAPPLICATIONS: reopens the app after install
        await Process.start(
          path,
          ['/VERYSILENT', '/CLOSEAPPLICATIONS', '/RESTARTAPPLICATIONS'],
          runInShell: false,
          mode: ProcessStartMode.detached,
        );
        exit(0);
      } else if (Platform.isMacOS) {
        // Opens the DMG in Finder so user can drag-install
        await Process.start('open', [path], runInShell: false);
        exit(0);
      } else if (Platform.isAndroid) {
        _launchAndroidApk(path);
      }
    } catch (e) {
      if (mounted) {
        state = state.copyWith(
          phase: UpdatePhase.failed,
          errorMessage: 'Failed to launch installer: $e',
        );
      }
    }
  }

  // ────────────────────────────────────────────────────────────────────────
  // Private — Download pipeline
  // ────────────────────────────────────────────────────────────────────────

  Future<void> _downloadInBackground(UpdateInfo info) async {
    if (!mounted) return;

    try {
      final tmpDir  = await getTemporaryDirectory();
      final ext     = _installerExt();
      final dest    = File(p.join(tmpDir.path, 'urdown_update_${info.version}$ext'));
      final partial = File('${dest.path}.part');

      // Already fully downloaded → skip to verification
      if (dest.existsSync() && dest.lengthSync() > 1024) {
        _installerPath = dest.path;
        await _verifyAndFinalize(dest, info);
        return;
      }

      // ── Resume support ─────────────────────────────────────────────────
      int startByte = 0;
      if (partial.existsSync()) {
        startByte = partial.lengthSync();
      }

      final req = http.Request('GET', Uri.parse(info.downloadUrl));
      if (startByte > 0) {
        req.headers['Range'] = 'bytes=$startByte-';
      }

      final sresp = await req.send().timeout(const Duration(minutes: 30));
      if (sresp.statusCode != 200 && sresp.statusCode != 206) {
        throw Exception('HTTP ${sresp.statusCode}');
      }

      final contentLength = sresp.contentLength ?? 0;
      final total         = startByte + contentLength;
      int received        = startByte;

      final sink = partial.openWrite(
        mode: startByte > 0 ? FileMode.append : FileMode.write,
      );

      // Stream-download with progress updates
      await for (final chunk in sresp.stream) {
        if (!mounted) {
          await sink.close();
          return;
        }
        sink.add(chunk);
        received += chunk.length;
        if (total > 0) {
          state = state.copyWith(
            phase:    UpdatePhase.downloading,
            progress: (received / total).clamp(0.0, 1.0),
          );
        }
      }
      await sink.flush();
      await sink.close();

      // Promote partial → final
      if (dest.existsSync()) await dest.delete();
      await partial.rename(dest.path);
      _installerPath = dest.path;

      await _verifyAndFinalize(dest, info);
    } catch (e) {
      if (!mounted) return;
      if (state.canRetry) {
        await retry();
      } else {
        state = state.copyWith(
          phase:        UpdatePhase.failed,
          errorMessage: 'Download failed: $e',
        );
      }
    }
  }

  Future<void> _verifyAndFinalize(File installer, UpdateInfo info) async {
    if (!mounted) return;
    state = state.copyWith(phase: UpdatePhase.verifying, progress: 1.0);

    try {
      if (info.checksumUrl.isNotEmpty) {
        final resp = await http
            .get(Uri.parse(info.checksumUrl))
            .timeout(const Duration(seconds: 15));

        if (resp.statusCode == 200) {
          // File may be "<hash>  <filename>" or just "<hash>"
          final expected =
              resp.body.trim().split(RegExp(r'\s+')).first.toLowerCase();

          if (expected.isNotEmpty) {
            final actual = await _sha256OfFile(installer);
            if (actual != expected) {
              // Corrupt file — delete it
              try { await installer.delete(); } catch (_) {}
              _installerPath = null;
              if (mounted) {
                state = state.copyWith(
                  phase:        UpdatePhase.failed,
                  errorMessage: 'Integrity check failed — file may be corrupt. Retrying…',
                );
                await retry(); // auto-retry after checksum failure
              }
              return;
            }
          }
        }
      }
      // ✓ Verified (or no checksum to compare) — ready to install
      if (mounted) {
        state = state.copyWith(phase: UpdatePhase.ready, progress: 1.0);
      }
    } catch (_) {
      // Verification request failed — proceed anyway (network may be spotty)
      if (mounted) {
        state = state.copyWith(phase: UpdatePhase.ready, progress: 1.0);
      }
    }
  }

  // ────────────────────────────────────────────────────────────────────────
  // Private — helpers
  // ────────────────────────────────────────────────────────────────────────

  Future<String> _sha256OfFile(File file) async {
    final bytes = await file.readAsBytes();
    return sha256.convert(bytes).toString();
  }

  void _launchAndroidApk(String path) {
    // Android install intent — requires REQUEST_INSTALL_PACKAGES permission
    // declared in AndroidManifest.xml.
    try {
      Process.run('am', [
        'start',
        '-a', 'android.intent.action.VIEW',
        '-d', 'file://$path',
        '-t', 'application/vnd.android.package-archive',
        '--flags', '0x10000001',
      ]);
    } catch (_) {}
  }

  // ── Version comparison ─────────────────────────────────────────────────

  bool _isNewer(String remote, String current) {
    final r = _semver(remote);
    final c = _semver(current);
    for (var i = 0; i < 3; i++) {
      if (r[i] > c[i]) return true;
      if (r[i] < c[i]) return false;
    }
    return false;
  }

  List<int> _semver(String v) {
    final parts = v.split('.').take(3).toList();
    while (parts.length < 3) parts.add('0');
    return parts.map((s) => int.tryParse(s) ?? 0).toList();
  }

  // ── Platform helpers ───────────────────────────────────────────────────

  String _installerExt() {
    if (Platform.isWindows) return '.exe';
    if (Platform.isMacOS)   return '.dmg';
    if (Platform.isAndroid) return '.apk';
    return '.bin';
  }

  String _platformKeyword() {
    if (Platform.isWindows) return 'windows';
    if (Platform.isMacOS)   return 'macos';
    if (Platform.isAndroid) return 'android';
    return '';
  }

  String? _findAssetUrl(List<dynamic> assets, String keyword) {
    if (keyword.isEmpty) return null;
    for (final a in assets) {
      final name = ((a as Map)['name'] as String? ?? '').toLowerCase();
      if (name.contains(keyword.toLowerCase())) {
        return a['browser_download_url'] as String?;
      }
    }
    return null;
  }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Riverpod provider  — single global instance, accessible from any widget
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

/// Watch this to rebuild whenever the update state changes.
final updateNotifierProvider =
    StateNotifierProvider<UpdateNotifier, UpdateState>(
  (_) => UpdateNotifier(),
);
