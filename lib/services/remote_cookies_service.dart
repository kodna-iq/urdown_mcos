import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/constants/app_constants.dart';

// ──────────────────────────────────────────────────────────────────────────────
// SECURITY NOTE:
// الـ token لا يُخزَّن في الكود مباشرة في الإنتاج.
// يجب تمريره عبر:
//   - environment variable عند البناء:  --dart-define=COOKIES_TOKEN=xxx
//   - أو إدخاله من المستخدم في الواجهة (يُحفظ في SharedPreferences)
// ──────────────────────────────────────────────────────────────────────────────

const String _kCookiesToken = String.fromEnvironment(
  'COOKIES_TOKEN',
  defaultValue: '', // فارغ = لا مزامنة في debug بدون token
);

const String _kCookiesApiUrl = String.fromEnvironment(
  'COOKIES_API_URL',
  defaultValue: 'https://api.github.com/repos/kodna-iq/streamvault-cookies/contents/cookies.json',
);

// SharedPreferences key for runtime token (Windows alternative to Android Keystore)
const _kRuntimeTokenPref = 'cookies_runtime_token';

enum CookieSyncStatus { idle, syncing, updated, failed }

class RemoteCookiesService {
  RemoteCookiesService._();

  static CookieSyncStatus lastStatus = CookieSyncStatus.idle;
  static String _syncInfo = 'لم تتم المزامنة بعد.';
  static DateTime? _lastSyncTime;

  static Future<String> getSyncInfo() async => _syncInfo;

  static Future<void> syncOnStartup({String? serverUrl}) async {
    // تحقق من HTTPS — لا مزامنة على HTTP
    final apiUrl = serverUrl ?? _kCookiesApiUrl;
    if (!apiUrl.startsWith('https://')) {
      print('[CookieSync] Rejected non-HTTPS cookies URL: $apiUrl');
      lastStatus = CookieSyncStatus.failed;
      _syncInfo = 'Rejected: HTTPS required.';
      return;
    }

    // Token: compile-time --dart-define أولاً، ثم runtime من SharedPreferences
    String effectiveToken = _kCookiesToken;
    if (effectiveToken.isEmpty) {
      effectiveToken = await loadServerToken();
    }

    if (effectiveToken.isEmpty) {
      print('[CookieSync] No COOKIES_TOKEN set — skipping sync');
      lastStatus = CookieSyncStatus.idle;
      _syncInfo = 'Token not configured — build with --dart-define=COOKIES_TOKEN=xxx';
      return;
    }

    lastStatus = CookieSyncStatus.syncing;
    _syncInfo = 'جاري المزامنة…';

    try {
      // Use GitHub API with token — supports private repos
      // Accept: application/vnd.github.v3.raw → returns file content directly
      final resp = await http.get(
        Uri.parse(apiUrl),
        headers: {
          'Authorization': 'token $effectiveToken',
          'Accept': 'application/vnd.github.v3.raw',
          'Cache-Control': 'no-cache',
        },
      ).timeout(const Duration(seconds: 25));

      print('[CookieSync] HTTP ${resp.statusCode} — body length: ${resp.body.length}');

      if (resp.statusCode == 404) {
        lastStatus = CookieSyncStatus.failed;
        _syncInfo = 'لم يتم رفع الكوكيز — شغّل encrypt_and_upload.py أولاً.';
        return;
      }
      if (resp.statusCode == 401 || resp.statusCode == 403) {
        lastStatus = CookieSyncStatus.failed;
        _syncInfo = 'انتهت صلاحية التوكن (${resp.statusCode}).';
        return;
      }
      if (resp.statusCode != 200) {
        lastStatus = CookieSyncStatus.failed;
        _syncInfo = 'خطأ HTTP ${resp.statusCode}.';
        return;
      }

      // The raw content IS the cookies.json we uploaded
      Map<String, dynamic> jsonData;
      try {
        jsonData = jsonDecode(resp.body) as Map<String, dynamic>;
      } catch (_) {
        // If Accept header was ignored, GitHub returns a JSON envelope with base64 content
        final envelope = jsonDecode(resp.body) as Map<String, dynamic>;
        final b64 = envelope['content'] as String? ?? '';
        final decoded = utf8.decode(base64.decode(b64.replaceAll('\n', '')));
        jsonData = jsonDecode(decoded) as Map<String, dynamic>;
      }

      final cookies = jsonData['cookies'] as Map<String, dynamic>?;
      if (cookies == null || cookies.isEmpty) {
        lastStatus = CookieSyncStatus.failed;
        _syncInfo = 'cookies.json فارغ.';
        return;
      }

      final dir = await getApplicationSupportDirectory();
      final siteMap = {
        // NOTE: These keys match the JSON response field names from the
        // cookies API endpoint, NOT domain names. AppConstants.cookieSiteFiles
        // handles domain→file mapping for URL-based lookups.
        'youtube':   'youtube_cookies.txt',
        'facebook':  'facebook_cookies.txt',
        'tiktok':    'tiktok_cookies.txt',
        'instagram': 'instagram_cookies.txt',
      };

      final saved = <String>[];
      for (final e in siteMap.entries) {
        final raw = cookies[e.key] as String?;
        if (raw == null || raw.trim().isEmpty) continue;
        // cookies stored as \n-escaped strings — convert to real newlines
        final content = raw.replaceAll(r'\n', '\n').replaceAll(r'\t', '\t');
        await File(p.join(dir.path, e.value)).writeAsString(content, encoding: utf8);
        saved.add(_label(e.key));
        print('[CookieSync] Saved ${e.value} (${content.length} chars)');
      }

      _lastSyncTime = DateTime.now();
      lastStatus = CookieSyncStatus.updated;
      final t = _lastSyncTime!;
      final hm = '${t.hour.toString().padLeft(2,'0')}:${t.minute.toString().padLeft(2,'0')}';
      _syncInfo = saved.isEmpty
          ? 'متصل — لا توجد كوكيز.'
          : 'آخر تحديث $hm — ${saved.join(' · ')}';

    } on SocketException {
      lastStatus = CookieSyncStatus.failed;
      _syncInfo = 'لا يوجد اتصال بالإنترنت.';
    } on TimeoutException {
      lastStatus = CookieSyncStatus.failed;
      _syncInfo = 'انتهت مهلة الاتصال.';
    } on FormatException catch (e) {
      lastStatus = CookieSyncStatus.failed;
      _syncInfo = 'خطأ في قراءة JSON: $e';
    } catch (e) {
      lastStatus = CookieSyncStatus.failed;
      _syncInfo = 'فشل: $e';
      print('[CookieSync] ERROR: $e');
    }
  }

  static Future<Map<String, bool>> checkLocalCookies() async {
    final dir = await getApplicationSupportDirectory();
    final m = AppConstants.cookieSiteDisplayNames;
    return { for (final e in m.entries)
      e.key: File(p.join(dir.path, e.value)).let((f) => f.existsSync() && f.lengthSync() > 100)
    };
  }

  static Future<void> saveCookiesForSite(String filename, String content) async {
    final dir = await getApplicationSupportDirectory();
    await File(p.join(dir.path, filename)).writeAsString(content);
  }

  static Future<void> deleteCookiesForSite(String filename) async {
    final f = File(p.join((await getApplicationSupportDirectory()).path, filename));
    if (f.existsSync()) await f.delete();
  }

  static Future<String> cookieFilePath(String filename) async =>
      p.join((await getApplicationSupportDirectory()).path, filename);

  /// Save a GitHub PAT entered by the user at runtime.
  /// Stored in SharedPreferences on Windows (no Android Keystore available).
  static Future<void> saveServerToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    if (token.trim().isEmpty) {
      await prefs.remove(_kRuntimeTokenPref);
    } else {
      await prefs.setString(_kRuntimeTokenPref, token.trim());
    }
  }

  /// Returns the runtime token saved by the user, or empty string if none.
  static Future<String> loadServerToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_kRuntimeTokenPref) ?? '';
  }

  /// True if either a compile-time or runtime token is available.
  static Future<bool> hasToken() async {
    if (_kCookiesToken.isNotEmpty) return true;
    return (await loadServerToken()).isNotEmpty;
  }

  static String _label(String s) =>
      const {'youtube':'YouTube','facebook':'Facebook','tiktok':'TikTok','instagram':'Instagram'}[s] ?? s;
}

extension _Let<T> on T {
  R let<R>(R Function(T) f) => f(this);
}
