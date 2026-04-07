// ─────────────────────────────────────────────────────────────────────────────
// GITHUB CONFIG TILE — Desktop
//
// منقول من نسخة الأندرويد مع تعديلات Desktop:
//   • يُظهر حالة كل سيرفر (نقطة خضراء/حمراء)
//   • زر Refresh يدوي
//   • حقل إدخال للـ Token يُحفظ في SharedPreferences (مشفّر XOR)
//   • حقل اختياري لتغيير URL المصدر
//
// يُضاف في settings_page.dart ضمن قسم "Accounts & Cookies":
//   GithubConfigTile()
// ─────────────────────────────────────────────────────────────────────────────

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../../app/theme.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/l10n/app_strings.dart';
import '../../../services/github/github_config_service.dart';

class GithubConfigTile extends ConsumerStatefulWidget {
  const GithubConfigTile({super.key});

  @override
  ConsumerState<GithubConfigTile> createState() => _GithubConfigTileState();
}

class _GithubConfigTileState extends ConsumerState<GithubConfigTile> {
  GithubConfigSyncStatus _syncStatus = GithubConfigSyncStatus.idle;
  bool _refreshing = false;
  bool _hasToken   = false;

  String _primaryUrl  = '';  String _primaryKey  = '';
  String _backupUrl   = '';  String _backupKey   = '';
  String _fallbackUrl = '';  String _fallbackKey = '';
  String _intelUrl    = '';  String _intelKey    = '';

  final Map<String, bool?> _connected = {
    'intel': null, 'primary': null, 'backup': null, 'fallback': null,
  };
  final Map<String, bool> _pinging = {};

  StreamSubscription<GithubConfigSyncResult>? _sub;

  @override
  void initState() {
    super.initState();
    _loadFromConfig();
    _loadTokenStatus();
    _autoPing();
    // الاشتراك في Stream — يُحدّث الـ UI تلقائياً كلما تمت مزامنة جديدة
    _sub = GithubConfigService.instance.onSync.listen((result) {
      if (!mounted) return;
      setState(() {
        _syncStatus = result.status;
        _loadFromConfig();
      });
      _autoPing();
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  void _loadFromConfig() {
    final cfg = GithubConfigService.instance.config;
    _intelUrl    = cfg.intelligenceServer.url;
    _intelKey    = cfg.intelligenceServer.apiKey;
    _primaryUrl  = cfg.primaryServer.url;
    _primaryKey  = cfg.primaryServer.apiKey;
    _backupUrl   = cfg.backupServer.url;
    _backupKey   = cfg.backupServer.apiKey;
    _fallbackUrl = cfg.fallbackServer.url;
    _fallbackKey = cfg.fallbackServer.apiKey;
    _syncStatus  = GithubConfigService.instance.status;
  }

  Future<void> _loadTokenStatus() async {
    final has = await GithubConfigService.instance.hasToken();
    if (mounted) setState(() => _hasToken = has);
  }

  Future<void> _refresh() async {
    if (_refreshing) return;
    setState(() { _refreshing = true; });
    try {
      final result = await GithubConfigService.instance.refresh();
      if (!mounted) return;
      setState(() {
        _syncStatus = result.status;
        _loadFromConfig();
      });
      await _autoPing();
    } finally {
      if (mounted) setState(() { _refreshing = false; });
    }
  }

  Future<void> _autoPing() async {
    final servers = {
      'intel':    (_intelUrl,    _intelKey),
      'primary':  (_primaryUrl,  _primaryKey),
      'backup':   (_backupUrl,   _backupKey),
      'fallback': (_fallbackUrl, _fallbackKey),
    };
    for (final e in servers.entries) {
      if (e.value.$1.isEmpty) {
        if (mounted) setState(() => _connected[e.key] = null);
        continue;
      }
      _pingServer(e.key, e.value.$1, e.value.$2);
    }
  }

  Future<void> _pingServer(String key, String url, String apiKey) async {
    if (_pinging[key] == true) return;
    if (mounted) setState(() => _pinging[key] = true);
    try {
      final resp = await http.get(
        Uri.parse('$url/health'),
        headers: {'X-API-Key': apiKey},
      ).timeout(const Duration(seconds: 8));
      if (mounted) setState(() => _connected[key] = resp.statusCode == 200);
    } catch (_) {
      if (mounted) setState(() => _connected[key] = false);
    } finally {
      if (mounted) setState(() => _pinging[key] = false);
    }
  }

  Future<void> _showTokenDialog() async {
    final loc          = ref.read(stringsProvider);
    final currentToken = await GithubConfigService.instance.loadRuntimeToken();
    final currentUrl   = await GithubConfigService.instance.loadRuntimeUrl();
    if (!mounted) return;

    final tokenCtrl = TextEditingController(text: currentToken);
    final urlCtrl   = TextEditingController(text: currentUrl);

    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(loc.remoteConfigDialog),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(loc.remoteConfigToken, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            TextField(
              controller: tokenCtrl,
              obscureText: true,
              decoration: const InputDecoration(
                hintText: 'ghp_xxxxxxxxxxxxxxxxxxxx',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.key_rounded),
                isDense: true,
              ),
            ),
            const SizedBox(height: 14),
            Text(loc.remoteConfigUrl, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            TextField(
              controller: urlCtrl,
              decoration: const InputDecoration(
                hintText: 'https://api.github.com/repos/.../config.json',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.link_rounded),
                isDense: true,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              loc.remoteConfigUrlHint,
              style: TextStyle(fontSize: 11, color: Colors.grey[500]),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, null),
            child: Text(loc.remoteConfigCancel),
          ),
          if (currentToken.isNotEmpty)
            TextButton(
              onPressed: () async {
                await GithubConfigService.instance.saveRuntimeToken('');
                await GithubConfigService.instance.saveRuntimeUrl('');
                if (ctx.mounted) Navigator.pop(ctx, false);
              },
              child: Text(loc.remoteConfigClear, style: const TextStyle(color: AppColors.error)),
            ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(loc.remoteConfigSave),
          ),
        ],
      ),
    );

    if (result == null) return;

    await GithubConfigService.instance.saveRuntimeToken(tokenCtrl.text.trim());
    await GithubConfigService.instance.saveRuntimeUrl(urlCtrl.text.trim());
    await _loadTokenStatus();

    if (result == true && mounted) {
      setState(() => _refreshing = true);
      await GithubConfigService.instance.refresh();
      if (mounted) {
        setState(() {
          _refreshing = false;
          _loadFromConfig();
        });
        await _autoPing();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc    = ref.watch(stringsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final anyOk        = _connected['primary'] == true || _connected['intel'] == true;
    final overallColor = anyOk ? AppColors.success : AppColors.error;
    final statusMsg    = GithubConfigService.instance.statusMsg;

    return Card(
      margin:    const EdgeInsets.symmetric(vertical: 6),
      elevation: 0,
      color:     isDark ? AppColors.darkCard : AppColors.lightCard,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          width: 0.5,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 12, 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // ── Header ─────────────────────────────────────────────────
            Row(children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: AppColors.brand.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.cloud_sync_rounded,
                    color: AppColors.brand, size: 17),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(loc.remoteConfigTitle,
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                    if (statusMsg.isNotEmpty)
                      Text(
                        statusMsg,
                        style: TextStyle(
                          fontSize: 11,
                          color: _statusColor,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),
              // نقطة الحالة الإجمالية
              Container(
                width: 10, height: 10,
                margin: const EdgeInsets.only(right: 4),
                decoration: BoxDecoration(
                  color: _hasToken ? overallColor : Colors.grey,
                  shape: BoxShape.circle,
                ),
              ),
              // زر إعداد التوكن — مخفي إذا كان مدمجاً في البناء
              if (!GithubConfigService.instance.isTokenBuiltIn)
                IconButton(
                  icon: Icon(
                    Icons.key_rounded,
                    size: 18,
                    color: _hasToken ? AppColors.brand : AppColors.warning,
                  ),
                  tooltip: loc.remoteConfigSetup,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 34, minHeight: 34),
                  onPressed: _showTokenDialog,
                ),
              // زر Refresh
              SizedBox(
                width: 34, height: 34,
                child: _refreshing
                    ? const Padding(
                        padding: EdgeInsets.all(7),
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: AppColors.brand))
                    : IconButton(
                        icon: const Icon(Icons.refresh_rounded, size: 18),
                        color: AppColors.brand,
                        tooltip: loc.remoteConfigRefresh,
                        padding: EdgeInsets.zero,
                        onPressed: _hasToken ? _refresh : null,
                      ),
              ),
            ]),

            const SizedBox(height: 12),

            // ── سيرفرات + حالتها ──────────────────────────────────────
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _buildServerChips(isDark),
            ),

            // ── حالة المزامنة ─────────────────────────────────────────
            if (_syncStatus != GithubConfigSyncStatus.idle) ...[
              const SizedBox(height: 10),
              _SyncChip(status: _syncStatus),
            ],
          ],
        ),
      ),
    );
  }

  Color get _statusColor => switch (_syncStatus) {
    GithubConfigSyncStatus.updated => AppColors.success,
    GithubConfigSyncStatus.failed  => AppColors.error,
    GithubConfigSyncStatus.syncing => AppColors.warning,
    GithubConfigSyncStatus.cached  => AppColors.warning,
    GithubConfigSyncStatus.idle    => AppColors.darkTextSecondary,
  };

  List<Widget> _buildServerChips(bool isDark) {
    final cs = Theme.of(context).colorScheme;
    final servers = [
      (key: 'intel',    label: 'Intelligence', url: _intelUrl,    icon: Icons.psychology_rounded),
      (key: 'primary',  label: 'Primary',      url: _primaryUrl,  icon: Icons.dns_rounded),
      (key: 'backup',   label: 'Backup',        url: _backupUrl,   icon: Icons.backup_rounded),
      (key: 'fallback', label: 'Fallback',      url: _fallbackUrl, icon: Icons.device_hub_rounded),
    ];

    return servers.map((srv) {
      final hasUrl  = srv.url.isNotEmpty;
      final ok      = _connected[srv.key];
      final pinging = _pinging[srv.key] == true;

      final dotColor = !hasUrl
          ? (isDark ? Colors.white24 : Colors.black26)
          : pinging
              ? AppColors.brand
              : ok == true
                  ? AppColors.success
                  : ok == false
                      ? AppColors.error
                      : Colors.grey;

      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isDark
              ? Colors.white.withValues(alpha: 0.05)
              : Colors.black.withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: dotColor.withValues(alpha: 0.25), width: 0.8),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(srv.icon, size: 12,
              color: cs.onSurface.withValues(alpha: hasUrl ? 0.6 : 0.3)),
          const SizedBox(width: 6),
          Text(srv.label,
              style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: hasUrl
                      ? cs.onSurface
                      : cs.onSurface.withValues(alpha: 0.35))),
          const SizedBox(width: 8),
          pinging
              ? SizedBox(
                  width: 7, height: 7,
                  child: CircularProgressIndicator(
                      strokeWidth: 1.5, color: AppColors.brand))
              : Container(
                  width: 7, height: 7,
                  decoration: BoxDecoration(
                      color: dotColor, shape: BoxShape.circle),
                ),
        ]),
      );
    }).toList();
  }
}

// ── Sync Status Chip ──────────────────────────────────────────────────────────

class _SyncChip extends ConsumerWidget {
  final GithubConfigSyncStatus status;
  const _SyncChip({required this.status});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loc = ref.watch(stringsProvider);
    final (color, icon, label) = switch (status) {
      GithubConfigSyncStatus.syncing =>
        (AppColors.brand,   Icons.sync_rounded,                 loc.remoteConfigSyncing),
      GithubConfigSyncStatus.updated =>
        (AppColors.success, Icons.check_circle_outline_rounded, loc.remoteConfigSynced),
      GithubConfigSyncStatus.cached  =>
        (AppColors.warning, Icons.cached_rounded,               loc.remoteConfigCached),
      GithubConfigSyncStatus.failed  =>
        (AppColors.error,   Icons.error_outline_rounded,        loc.remoteConfigSyncFailed),
      _                              =>
        (AppColors.darkTextSecondary, Icons.circle_outlined,   ''),
    };

    if (label.isEmpty) return const SizedBox.shrink();

    return Row(mainAxisSize: MainAxisSize.min, children: [
      Icon(icon, size: 11, color: color),
      const SizedBox(width: 4),
      Text(label, style: TextStyle(fontSize: 10, color: color)),
    ]);
  }
}
