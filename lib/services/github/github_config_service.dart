// ═══════════════════════════════════════════════════════════════════════════════
// GITHUB CONFIG SERVICE — UrDown Desktop (Windows / macOS / Linux)
//
// منقول بالكامل من نسخة الأندرويد مع تعديلات مناسبة للـ Desktop:
//   • بدلاً من Android Keystore → SharedPreferences مشفّرة بـ XOR+base64
//     (الكمبيوتر لا يملك Keystore، flutter_secure_storage غير مضمون على كل OS)
//   • باقي المنطق مطابق 100% للأندرويد
//
// الميزات المُطبَّقة:
//   ✓ config.json موحّد (cookies + servers + api_keys)
//   ✓ كاش offline في SharedPreferences يعمل بعد إغلاق البرنامج
//   ✓ تحديث تلقائي كل 10 دقائق (Timer.periodic)
//   ✓ broadcast Stream يُشعر الـ UI بأي تغيير فوري
//   ✓ runtime token يُدخله المستخدم يدوياً (أولوية أعلى من compile-time)
//   ✓ runtime URL override قابل للتغيير من الإعدادات
//   ✓ syncOnStartup يقرأ runtime token أولاً ثم compile-time (إصلاح خلل الأندرويد)
//   ✓ initBackground() لا يعطّل البدء
//
// مخطط config.json:
// {
//   "cookies": {
//     "youtube":   "<netscape-cookies-txt>",
//     "tiktok":    "<netscape-cookies-txt>",
//     "facebook":  "<netscape-cookies-txt>",
//     "instagram": "<netscape-cookies-txt>"
//   },
//   "intelligence_server": { "url": "...", "api_key": "..." },
//   "multi_server": {
//     "primary":  { "url": "...", "api_key": "..." },
//     "backup":   { "url": "...", "api_key": "..." },
//     "fallback": { "url": "...", "api_key": "..." }
//   }
// }
//
// متغيرات البناء (--dart-define):
//   GITHUB_CONFIG_TOKEN  — GitHub PAT بصلاحية repo read
//   GITHUB_CONFIG_URL    — رابط API لـ config.json
// ═══════════════════════════════════════════════════════════════════════════════

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ── متغيرات البناء ─────────────────────────────────────────────────────────────

const String _kConfigToken = String.fromEnvironment(
  'GITHUB_CONFIG_TOKEN',
  defaultValue: '',
);

const String _kConfigUrl = String.fromEnvironment(
  'GITHUB_CONFIG_URL',
  defaultValue:
      'https://api.github.com/repos/kodna-iq/streamvault-cookies/contents/config.json',
);

// ── مفاتيح SharedPreferences ───────────────────────────────────────────────────

const _kCacheKey        = 'gh_config_cache_json';
const _kCacheTimeKey    = 'gh_config_cache_time';
const _kRuntimeToken    = 'gh_config_runtime_token_enc'; // مشفّر XOR+base64
const _kRuntimeUrl      = 'gh_config_runtime_url';

// ── فترة التحديث ───────────────────────────────────────────────────────────────

const _kRefreshInterval = Duration(minutes: 10);

// ── نماذج البيانات ─────────────────────────────────────────────────────────────

class GithubServerEntry {
  final String url;
  final String apiKey;
  const GithubServerEntry({required this.url, required this.apiKey});

  bool get isConfigured => url.isNotEmpty;

  static GithubServerEntry fromJson(dynamic raw) {
    if (raw is Map<String, dynamic>) {
      return GithubServerEntry(
        url:    raw['url']     as String? ?? '',
        apiKey: raw['api_key'] as String? ?? '',
      );
    }
    return const GithubServerEntry(url: '', apiKey: '');
  }
}

class GithubRemoteConfig {
  final Map<String, String> cookies;
  final GithubServerEntry   intelligenceServer;
  final GithubServerEntry   primaryServer;
  final GithubServerEntry   backupServer;
  final GithubServerEntry   fallbackServer;
  final DateTime            fetchedAt;

  const GithubRemoteConfig({
    required this.cookies,
    required this.intelligenceServer,
    required this.primaryServer,
    required this.backupServer,
    required this.fallbackServer,
    required this.fetchedAt,
  });

  static final empty = GithubRemoteConfig(
    cookies:            {},
    intelligenceServer: GithubServerEntry(url: '', apiKey: ''),
    primaryServer:      GithubServerEntry(url: '', apiKey: ''),
    backupServer:       GithubServerEntry(url: '', apiKey: ''),
    fallbackServer:     GithubServerEntry(url: '', apiKey: ''),
    fetchedAt:          DateTime.fromMillisecondsSinceEpoch(0),
  );

  factory GithubRemoteConfig.fromJson(Map<String, dynamic> json) {
    // ── cookies ──────────────────────────────────────────────────────────
    final rawCookies = json['cookies'] as Map<String, dynamic>? ?? {};
    final cookies = <String, String>{};
    for (final e in rawCookies.entries) {
      final val = e.value as String? ?? '';
      if (val.trim().isNotEmpty) {
        cookies[e.key] = val.replaceAll(r'\n', '\n').replaceAll(r'\t', '\t');
      }
    }

    // ── intelligence_server ───────────────────────────────────────────────
    final intSrv = GithubServerEntry.fromJson(
        json['intelligence_server'] ?? <String, dynamic>{});

    // ── multi_server ──────────────────────────────────────────────────────
    final ms       = json['multi_server'] as Map<String, dynamic>? ?? {};
    final primary  = GithubServerEntry.fromJson(ms['primary']  ?? <String, dynamic>{});
    final backup   = GithubServerEntry.fromJson(ms['backup']   ?? <String, dynamic>{});
    final fallback = GithubServerEntry.fromJson(ms['fallback'] ?? <String, dynamic>{});

    return GithubRemoteConfig(
      cookies:            cookies,
      intelligenceServer: intSrv,
      primaryServer:      primary,
      backupServer:       backup,
      fallbackServer:     fallback,
      fetchedAt:          DateTime.now(),
    );
  }

  String toJsonString() => jsonEncode({
    'cookies': cookies,
    'intelligence_server': {
      'url':     intelligenceServer.url,
      'api_key': intelligenceServer.apiKey,
    },
    'multi_server': {
      'primary':  {'url': primaryServer.url,  'api_key': primaryServer.apiKey},
      'backup':   {'url': backupServer.url,   'api_key': backupServer.apiKey},
      'fallback': {'url': fallbackServer.url, 'api_key': fallbackServer.apiKey},
    },
    '_fetched_at': fetchedAt.toIso8601String(),
  });

  static GithubRemoteConfig fromJsonString(String raw) {
    try {
      return GithubRemoteConfig.fromJson(
          jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return GithubRemoteConfig.empty;
    }
  }
}

// ── حالة المزامنة ──────────────────────────────────────────────────────────────

enum GithubConfigSyncStatus { idle, syncing, updated, failed, cached }

class GithubConfigSyncResult {
  final GithubConfigSyncStatus status;
  final String                 message;
  final GithubRemoteConfig     config;

  const GithubConfigSyncResult({
    required this.status,
    required this.message,
    required this.config,
  });
}

// ── الخدمة الرئيسية ────────────────────────────────────────────────────────────

class GithubConfigService {
  GithubConfigService._();
  static final instance = GithubConfigService._();

  // ── الحالة الداخلية ────────────────────────────────────────────────────
  GithubRemoteConfig     _config      = GithubRemoteConfig.empty;
  GithubConfigSyncStatus _status      = GithubConfigSyncStatus.idle;
  String                 _statusMsg   = 'Not yet synced.';
  DateTime?              _lastSync;
  Timer?                 _refreshTimer;
  bool                   _initialised = false;

  // ── Broadcast Stream — يُشعر الـ UI بكل تغيير ────────────────────────
  final _controller =
      StreamController<GithubConfigSyncResult>.broadcast();

  Stream<GithubConfigSyncResult> get onSync => _controller.stream;

  // ── Getters عامة ──────────────────────────────────────────────────────
  GithubRemoteConfig     get config    => _config;
  GithubConfigSyncStatus get status    => _status;
  String                 get statusMsg => _statusMsg;
  DateTime?              get lastSync  => _lastSync;

  /// true إذا كان التوكن مدمجاً في البناء (--dart-define)
  /// — في هذه الحالة لا يُعرض حقل الإدخال للمستخدم
  bool get isTokenBuiltIn => _kConfigToken.isNotEmpty;

  String get lastSyncLabel {
    if (_lastSync == null) return 'Never synced';
    final t  = _lastSync!;
    final hm = '${t.hour.toString().padLeft(2, '0')}:'
               '${t.minute.toString().padLeft(2, '0')}';
    return 'Last updated $hm';
  }

  // ── تهيئة عند البدء (تحجب البدء حتى تنتهي) ────────────────────────────
  Future<void> init() async {
    if (_initialised) return;
    _initialised = true;
    await _loadCache();
    await _fetchAndApply();
    _startTimer();
  }

  /// يُحمّل الكاش فوراً ثم يجلب من الشبكة في الخلفية — لا يعطّل البدء.
  Future<void> initBackground() async {
    if (_initialised) return;
    _initialised = true;
    await _loadCache();
    _fetchAndApply().ignore();
    _startTimer();
  }

  void _startTimer() {
    _refreshTimer?.cancel();
    _refreshTimer = Timer.periodic(_kRefreshInterval, (_) {
      _fetchAndApply().ignore();
    });
  }

  /// تحديث يدوي (مثلاً عند ضغط المستخدم زر Refresh).
  Future<GithubConfigSyncResult> refresh() => _fetchAndApply();

  void dispose() {
    _refreshTimer?.cancel();
    _refreshTimer = null;
    if (!_controller.isClosed) _controller.close();
    _initialised = false;
  }

  // ── إدارة التوكن و URL بوقت التشغيل ────────────────────────────────────
  //
  // Desktop لا يملك Android Keystore، لذا نستخدم XOR+base64 بسيط.
  // هذا ليس تشفيراً قوياً لكنه يمنع قراءة التوكن بالعين المجردة من SharedPreferences.
  // المستخدم المتقدم يمكنه دائماً استخدام --dart-define=GITHUB_CONFIG_TOKEN.

  static const _xorKey = 0x5A; // مفتاح XOR ثابت

  static String _obfuscate(String value) {
    final bytes = utf8.encode(value);
    final xored = bytes.map((b) => b ^ _xorKey).toList();
    return base64.encode(xored);
  }

  static String _deobfuscate(String encoded) {
    try {
      final bytes = base64.decode(encoded);
      final xored = bytes.map((b) => b ^ _xorKey).toList();
      return utf8.decode(xored);
    } catch (_) {
      return '';
    }
  }

  Future<void> saveRuntimeToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    if (token.trim().isEmpty) {
      await prefs.remove(_kRuntimeToken);
    } else {
      await prefs.setString(_kRuntimeToken, _obfuscate(token.trim()));
    }
  }

  Future<String> loadRuntimeToken() async {
    final prefs = await SharedPreferences.getInstance();
    final enc = prefs.getString(_kRuntimeToken) ?? '';
    return enc.isEmpty ? '' : _deobfuscate(enc);
  }

  Future<void> saveRuntimeUrl(String url) async {
    final prefs = await SharedPreferences.getInstance();
    if (url.trim().isEmpty) {
      await prefs.remove(_kRuntimeUrl);
    } else {
      await prefs.setString(_kRuntimeUrl, url.trim());
    }
  }

  Future<String> loadRuntimeUrl() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_kRuntimeUrl) ?? '';
  }

  Future<bool> hasToken() async {
    if (_kConfigToken.isNotEmpty) return true;
    return (await loadRuntimeToken()).isNotEmpty;
  }

  // ── منطق الجلب الأساسي ─────────────────────────────────────────────────

  Future<GithubConfigSyncResult> _fetchAndApply() async {
    _status    = GithubConfigSyncStatus.syncing;
    _statusMsg = 'Syncing…';
    _emit();

    // ترتيب الأولوية: runtime token أولاً ثم compile-time
    // (هذا يُصلح خلل الأندرويد الذي يقرأ compile-time فقط في syncOnStartup)
    final token  = await _effectiveToken();
    final apiUrl = await _effectiveUrl();

    if (!apiUrl.startsWith('https://')) {
      return _fail('Rejected: HTTPS URL required.');
    }
    if (token.isEmpty) {
      return _fail(
          'No GitHub token — build with --dart-define=GITHUB_CONFIG_TOKEN=xxx '
          'or set one in Settings.');
    }

    try {
      final resp = await http.get(
        Uri.parse(apiUrl),
        headers: {
          'Authorization': 'token $token',
          'Accept':        'application/vnd.github.v3.raw',
          'Cache-Control': 'no-cache',
        },
      ).timeout(const Duration(seconds: 25));

      print('[GithubConfig] HTTP ${resp.statusCode} — ${resp.body.length} chars');

      if (resp.statusCode == 404) return _fail('config.json not found (404).');
      if (resp.statusCode == 401 || resp.statusCode == 403) {
        return _fail('GitHub token rejected (${resp.statusCode}).');
      }
      if (resp.statusCode != 200) {
        return _fail('HTTP ${resp.statusCode} from GitHub.');
      }

      final Map<String, dynamic> jsonData = _decodeGithubBody(resp.body);

      if (!jsonData.containsKey('cookies') &&
          !jsonData.containsKey('intelligence_server') &&
          !jsonData.containsKey('multi_server')) {
        return _fail('config.json missing all known keys.');
      }

      final config = GithubRemoteConfig.fromJson(jsonData);

      // اكتب الكوكيز على القرص
      await _writeCookies(config.cookies);

      // احفظ الـ config كاملاً في SharedPreferences
      await _saveCache(config);

      _config    = config;
      _lastSync  = DateTime.now();
      _status    = GithubConfigSyncStatus.updated;
      _statusMsg = lastSyncLabel;

      final result = GithubConfigSyncResult(
          status: _status, message: _statusMsg, config: _config);
      _emit(result);
      print('[GithubConfig] Synced — cookies:${config.cookies.keys.join(",")} '
          'primary:${config.primaryServer.isConfigured}');
      return result;

    } on SocketException {
      return _failWithCache('No internet — using cached config.');
    } on TimeoutException {
      return _failWithCache('Connection timed out — using cached config.');
    } on FormatException catch (e) {
      return _fail('JSON parse error: $e');
    } catch (e) {
      return _failWithCache('Sync error: $e');
    }
  }

  // ── كتابة ملفات الكوكيز ────────────────────────────────────────────────

  static const _cookieFileMap = {
    'youtube':   'youtube_cookies.txt',
    'tiktok':    'tiktok_cookies.txt',
    'facebook':  'facebook_cookies.txt',
    'instagram': 'instagram_cookies.txt',
  };

  Future<void> _writeCookies(Map<String, String> cookies) async {
    try {
      final dir = await getApplicationSupportDirectory();
      for (final e in _cookieFileMap.entries) {
        final raw = cookies[e.key];
        if (raw == null || raw.trim().isEmpty) continue;
        await File(p.join(dir.path, e.value))
            .writeAsString(raw, encoding: utf8);
        print('[GithubConfig] Wrote ${e.value} (${raw.length} chars)');
      }
    } catch (e) {
      print('[GithubConfig] Cookie write error: $e');
    }
  }

  // ── الكاش (SharedPreferences) ──────────────────────────────────────────

  Future<void> _saveCache(GithubRemoteConfig cfg) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_kCacheKey, cfg.toJsonString());
      await prefs.setInt(
          _kCacheTimeKey, DateTime.now().millisecondsSinceEpoch);
    } catch (e) {
      print('[GithubConfig] Cache write failed: $e');
    }
  }

  Future<void> _loadCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_kCacheKey);
      if (raw == null || raw.isEmpty) return;
      final cfg = GithubRemoteConfig.fromJsonString(raw);
      final ts  = prefs.getInt(_kCacheTimeKey) ?? 0;
      if (ts > 0) _lastSync = DateTime.fromMillisecondsSinceEpoch(ts);
      _config    = cfg;
      _status    = GithubConfigSyncStatus.cached;
      _statusMsg = 'Cached — ${lastSyncLabel.toLowerCase()}';
      print('[GithubConfig] Loaded from cache (${raw.length} chars)');
    } catch (e) {
      print('[GithubConfig] Cache load failed: $e');
    }
  }

  // ── دوال مساعدة ────────────────────────────────────────────────────────

  GithubConfigSyncResult _fail(String msg) {
    _status    = GithubConfigSyncStatus.failed;
    _statusMsg = msg;
    print('[GithubConfig] FAIL: $msg');
    final r = GithubConfigSyncResult(
        status: _status, message: msg, config: _config);
    _emit(r);
    return r;
  }

  GithubConfigSyncResult _failWithCache(String msg) {
    _status    = _config == GithubRemoteConfig.empty
        ? GithubConfigSyncStatus.failed
        : GithubConfigSyncStatus.cached;
    _statusMsg = msg;
    print('[GithubConfig] WARN: $msg');
    final r = GithubConfigSyncResult(
        status: _status, message: msg, config: _config);
    _emit(r);
    return r;
  }

  void _emit([GithubConfigSyncResult? r]) {
    if (_controller.isClosed) return;
    _controller.add(r ??
        GithubConfigSyncResult(
            status: _status, message: _statusMsg, config: _config));
  }

  // ترتيب الأولوية: runtime (أعلى) → compile-time
  Future<String> _effectiveToken() async {
    final rt = await loadRuntimeToken();
    return rt.isNotEmpty ? rt : _kConfigToken;
  }

  Future<String> _effectiveUrl() async {
    final ru = await loadRuntimeUrl();
    return ru.isNotEmpty ? ru : _kConfigUrl;
  }

  // يفكّ ترميز body من GitHub (raw JSON أو base64 envelope)
  static Map<String, dynamic> _decodeGithubBody(String body) {
    try {
      return jsonDecode(body) as Map<String, dynamic>;
    } catch (_) {}
    try {
      final envelope = jsonDecode(body) as Map<String, dynamic>;
      final b64      = envelope['content'] as String? ?? '';
      final decoded  = utf8.decode(base64.decode(b64.replaceAll('\n', '')));
      return jsonDecode(decoded) as Map<String, dynamic>;
    } catch (_) {}
    return <String, dynamic>{};
  }
}
