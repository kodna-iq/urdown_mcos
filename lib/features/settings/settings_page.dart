import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../app/theme.dart';
import '../../core/constants/app_constants.dart';
import '../update/update_dialog.dart';
import '../../services/update_service.dart';
import 'app_settings.dart';
import 'settings_repository.dart';
import '../../core/l10n/locale_service.dart';
import '../../core/l10n/app_strings.dart';
import '../../services/github/github_config_service.dart';
import '../../core/engine/binary_update_engine.dart';
import 'widgets/github_config_tile.dart';

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  bool _isCheckingUpdate = false;
  bool _isCheckingYtDlp  = false;

  static final _siteFiles = AppConstants.cookieSiteDisplayNames;
  final Map<String, bool> _siteHasCookies = {};

  @override
  void initState() {
    super.initState();
    _checkAllCookies();
    // الاشتراك في stream المزامنة لتحديث chips الكوكيز تلقائياً
    GithubConfigService.instance.onSync.listen((_) {
      if (mounted) _checkAllCookies();
    });
  }

  Future<void> _checkForUpdateManually() async {
    setState(() => _isCheckingUpdate = true);
    try {
      await ref.read(updateNotifierProvider.notifier).checkForUpdate(
        currentVersion: AppConstants.appVersion,
        force: true,
      );
      if (!mounted) return;

      final updateState = ref.read(updateNotifierProvider);
      if (updateState.info != null) {
        ref.read(updateNotifierProvider.notifier).undismiss();
        await showDialog<void>(
          context: context,
          barrierDismissible: false,
          builder: (_) => UpdateDialog(info: updateState.info!),
        );
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.check_circle_rounded, size: 16, color: AppColors.success),
                  const SizedBox(width: 10),
                  Text(ref.read(stringsProvider).upToDate),
                ],
              ),
              duration: const Duration(seconds: 3),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${ref.read(stringsProvider).updateCheckFailed}: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isCheckingUpdate = false);
    }
  }

  Future<void> _updateYtDlpManually() async {
    if (_isCheckingYtDlp) return;
    setState(() => _isCheckingYtDlp = true);
    try {
      await ref.read(binaryUpdateProvider.notifier).checkAndUpdate(force: true);
      if (!mounted) return;
      final s = ref.read(binaryUpdateProvider);
      final msg = switch (s.phase) {
        BinaryUpdatePhase.updated  => 'yt-dlp updated → ${s.toVersion} ✓',
        BinaryUpdatePhase.upToDate => 'yt-dlp is already up to date.',
        BinaryUpdatePhase.failed   => s.errorMessage,
        _                          => 'Done.',
      };
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg), duration: const Duration(seconds: 4)),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${ref.read(stringsProvider).updateEngineFailed}: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isCheckingYtDlp = false);
    }
  }

  Future<void> _checkAllCookies() async {
    try {
      final dir    = await getApplicationSupportDirectory();
      final result = <String, bool>{};
      for (final entry in _siteFiles.entries) {
        final file = File(p.join(dir.path, entry.value));
        result[entry.key] = file.existsSync() && file.lengthSync() > 100;
      }
      if (mounted) setState(() => _siteHasCookies.addAll(result));
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final settingsAsync = ref.watch(settingsProvider);
    final s             = ref.watch(stringsProvider);

    return Scaffold(
      appBar: AppBar(title: Text(s.settings)),
      body: settingsAsync.when(
        data:    (settings) => _buildBody(context, settings, s),
        loading: () => const Center(child: CircularProgressIndicator()),
        error:   (e, _) => Center(child: Text('${s.error}: $e')),
      ),
    );
  }

  Widget _buildBody(BuildContext context, AppSettings settings, AppStrings s) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 100),
      children: [

        // ── Downloads ──────────────────────────────────────────────────
        _SectionHeader(label: s.downloads),
        _SettingsCard(isDark: isDark, children: [
          _PathTile(
            label: s.outputDirectory,
            value: settings.outputDirectory.isEmpty
                ? s.defaultDownloads
                : settings.outputDirectory,
            onTap: Platform.isAndroid
                ? null
                : () async {
                    final dir = await FilePicker.platform.getDirectoryPath();
                    if (dir != null) {
                      _save(settings.copyWith(outputDirectory: dir));
                    }
                  },
          ),
          _Divider(),
          _SliderTile(
            label:     s.maxConcurrent,
            value:     settings.maxConcurrentDownloads.toDouble(),
            min:       1,
            max:       5,
            divisions: 4,
            display:   settings.maxConcurrentDownloads.toString(),
            onChanged: (v) =>
                _save(settings.copyWith(maxConcurrentDownloads: v.round())),
          ),
          _Divider(),
          _DropdownTile<int>(
            label: s.bandwidthLimit,
            value: settings.bandwidthLimitKBs,
            items: [
              DropdownMenuItem(value: 0,     child: Text(s.bwUnlimited)),
              DropdownMenuItem(value: 512,   child: Text(s.bw512)),
              DropdownMenuItem(value: 1024,  child: Text(s.bw1mb)),
              DropdownMenuItem(value: 2048,  child: Text(s.bw2mb)),
              DropdownMenuItem(value: 5120,  child: Text(s.bw5mb)),
              DropdownMenuItem(value: 10240, child: Text(s.bw10mb)),
            ],
            onChanged: (v) =>
                _save(settings.copyWith(bandwidthLimitKBs: v ?? 0)),
          ),
        ]),
        const SizedBox(height: 20),

        // ── Default Quality ────────────────────────────────────────────
        _SectionHeader(label: s.defaultQuality),
        _SettingsCard(isDark: isDark, children: [
          _DropdownTile<String>(
            label: s.defaultFormat,
            value: settings.defaultFormat,
            items: [...AppConstants.videoFormats, ...AppConstants.audioFormats]
                .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                .toList(),
            onChanged: (v) => _save(settings.copyWith(defaultFormat: v)),
          ),
          _Divider(),
          _DropdownTile<String>(
            label: s.defaultResolution,
            value: settings.defaultResolution,
            items: AppConstants.resolutions
                .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                .toList(),
            onChanged: (v) => _save(settings.copyWith(defaultResolution: v)),
          ),
        ]),
        const SizedBox(height: 20),

        // ── Behaviour ──────────────────────────────────────────────────
        _SectionHeader(label: s.behavior),
        _SettingsCard(isDark: isDark, children: [
          _SwitchTile(
            label:     s.embedThumbnailByDefault,
            value:     settings.embedThumbnail,
            onChanged: (v) => _save(settings.copyWith(embedThumbnail: v)),
          ),
          _Divider(),
          _SwitchTile(
            label:     s.addMetadata,
            value:     settings.addMetadata,
            onChanged: (v) => _save(settings.copyWith(addMetadata: v)),
          ),
          _Divider(),
          _SwitchTile(
            label:     s.clipboardMonitor,
            subtitle:  s.clipboardSubtitle,
            value:     settings.clipboardMonitorEnabled,
            onChanged: (v) =>
                _save(settings.copyWith(clipboardMonitorEnabled: v)),
          ),
          _Divider(),
          _SwitchTile(
            label:     s.notifications,
            value:     settings.notificationsEnabled,
            onChanged: (v) =>
                _save(settings.copyWith(notificationsEnabled: v)),
          ),
        ]),
        const SizedBox(height: 20),

        // ── Language ───────────────────────────────────────────────────
        _SectionHeader(label: s.language),
        _SettingsCard(isDark: isDark, children: [
          _DropdownTile<String>(
            label: s.appLanguage,
            value: settings.appLanguage,
            items: SupportedLocales.names.entries.map((e) {
              return DropdownMenuItem(value: e.key, child: Text(e.value));
            }).toList(),
            onChanged: (code) {
              if (code == null) return;
              _save(settings.copyWith(appLanguage: code));
              ref.read(localeProvider.notifier).setLocale(Locale(code));
            },
          ),
        ]),
        const SizedBox(height: 20),

        // ── Appearance ─────────────────────────────────────────────────
        _SectionHeader(label: s.appearance),
        _SettingsCard(isDark: isDark, children: [
          _DropdownTile<ThemeMode>(
            label: s.theme,
            value: settings.themeMode,
            items: [
              DropdownMenuItem(value: ThemeMode.dark,   child: Text(s.themeDark)),
              DropdownMenuItem(value: ThemeMode.light,  child: Text(s.themeLight)),
              DropdownMenuItem(value: ThemeMode.system, child: Text(s.themeSystem)),
            ],
            onChanged: (v) {
              if (v != null) {
                _save(settings.copyWith(themeMode: v));
                ref.read(themeModeProvider.notifier).setTheme(v);
              }
            },
          ),
        ]),
        const SizedBox(height: 20),

        // ── Accounts & Cookies ─────────────────────────────────────────
        _SectionHeader(label: s.accountsCookies),
        _SettingsCard(isDark: isDark, children: [
          // إدارة الكوكيز اليدوية (استيراد ملف .txt لكل موقع)
          ListTile(
            leading: const Icon(Icons.cookie_rounded, color: AppColors.brand, size: 22),
            title:   Text(s.manageCookies),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Wrap(
                spacing:    6,
                runSpacing: 4,
                children: _siteFiles.keys.map((site) {
                  final has = _siteHasCookies[site] ?? false;
                  return _CookieChip(site: site, has: has);
                }).toList(),
              ),
            ),
            trailing: const Icon(Icons.chevron_right_rounded, size: 20),
            onTap: () async {
              await context.pushNamed('youtube_auth');
              _checkAllCookies();
            },
            isThreeLine: true,
          ),
          _Divider(),
          // الكوكيز + السيرفرات عبر GitHub config.json
          const GithubConfigTile(),
        ]),
        const SizedBox(height: 20),

        // ── Updates & About ────────────────────────────────────────────
        _SectionHeader(label: s.about),
        _SettingsCard(isDark: isDark, children: [
          _InfoTile(label: s.appVersion, value: AppConstants.appVersion),
          _Divider(),
          _SwitchTile(
            label:     s.checkUpdatesStartup,
            value:     settings.checkUpdatesOnStartup,
            onChanged: (v) =>
                _save(settings.copyWith(checkUpdatesOnStartup: v)),
          ),
          _Divider(),
          _UpdateCheckTile(
            isChecking: _isCheckingUpdate,
            onTap:      _checkForUpdateManually,
          ),
          _Divider(),
          _YtDlpUpdateTile(
            isChecking: _isCheckingYtDlp,
            onTap:      _updateYtDlpManually,
          ),
        ]),
      ],
    );
  }

  void _save(AppSettings s) =>
      ref.read(settingsProvider.notifier).saveSettings(s);
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Shared layout primitives
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 2),
      child: Text(
        label.toUpperCase(),
        style: const TextStyle(
          fontSize:      11,
          fontWeight:    FontWeight.w700,
          color:         AppColors.brand,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  const _SettingsCard({required this.children, required this.isDark});
  final List<Widget> children;
  final bool         isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color:        isDark ? AppColors.darkCard : AppColors.lightCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          width: 0.5,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Column(children: children),
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Divider(height: 1, indent: 16, endIndent: 16);
  }
}

// ── Tiles ─────────────────────────────────────────────────────────────────────

class _SwitchTile extends StatelessWidget {
  const _SwitchTile({
    required this.label,
    this.subtitle,
    required this.value,
    required this.onChanged,
  });
  final String   label;
  final String?  subtitle;
  final bool     value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      title:    Text(label,    style: const TextStyle(fontSize: 14)),
      subtitle: subtitle != null
          ? Text(subtitle!, style: const TextStyle(fontSize: 12))
          : null,
      value:     value,
      onChanged: onChanged,
    );
  }
}

class _DropdownTile<T> extends StatelessWidget {
  const _DropdownTile({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  });
  final String                   label;
  final T                        value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?>         onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Expanded(child: Text(label, style: const TextStyle(fontSize: 14))),
          DropdownButton<T>(
            value:        value,
            items:        items,
            onChanged:    onChanged,
            underline:    const SizedBox.shrink(),
            isDense:      true,
            borderRadius: BorderRadius.circular(10),
          ),
        ],
      ),
    );
  }
}

class _SliderTile extends StatelessWidget {
  const _SliderTile({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.divisions,
    required this.display,
    required this.onChanged,
  });
  final String  label;
  final double  value;
  final double  min;
  final double  max;
  final int     divisions;
  final String  display;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: const TextStyle(fontSize: 14)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color:        AppColors.brand.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  display,
                  style: const TextStyle(
                    fontSize:   13,
                    fontWeight: FontWeight.w700,
                    color:      AppColors.brand,
                  ),
                ),
              ),
            ],
          ),
          Slider(
            value:     value,
            min:       min,
            max:       max,
            divisions: divisions,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}

class _PathTile extends StatelessWidget {
  const _PathTile({
    required this.label,
    required this.value,
    this.onTap,
  });
  final String    label;
  final String    value;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      title:    Text(label, style: const TextStyle(fontSize: 14)),
      subtitle: Text(
        value,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style:    const TextStyle(fontSize: 12),
      ),
      trailing: onTap != null
          ? const Icon(Icons.folder_open_rounded, size: 20, color: AppColors.brand)
          : const Icon(Icons.folder_off_outlined,  size: 20),
      onTap:   onTap,
      enabled: onTap != null,
    );
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 14)),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color:        AppColors.brand.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              value,
              style: const TextStyle(
                fontSize:   12,
                fontWeight: FontWeight.w600,
                color:      AppColors.brand,
                fontFamily: 'Courier',
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Update Check Tile ─────────────────────────────────────────────────────────

class _UpdateCheckTile extends ConsumerWidget {
  const _UpdateCheckTile({
    required this.isChecking,
    required this.onTap,
  });
  final bool         isChecking;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s           = ref.watch(stringsProvider);
    final updateState = ref.watch(updateNotifierProvider);
    final hasUpdate   = updateState.info != null;
    final phase       = updateState.phase;

    String subtitle;
    Color? subtitleColor;

    if (isChecking || phase == UpdatePhase.checking) {
      subtitle = s.updateChecking;
    } else if (hasUpdate) {
      subtitle = 'v${updateState.info!.version} — ${s.updateAvailable}';
      subtitleColor = AppColors.brand;
    } else {
      subtitle = '${s.currentVersion}: ${AppConstants.appVersion}';
    }

    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color:        AppColors.brand.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(Icons.system_update_rounded, color: AppColors.brand, size: 20),
      ),
      title:    Text(s.checkForUpdates, style: const TextStyle(fontSize: 14)),
      subtitle: Text(subtitle, style: TextStyle(fontSize: 12, color: subtitleColor)),
      trailing: isChecking || phase == UpdatePhase.checking
          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
          : hasUpdate
              ? Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color:        AppColors.brand.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(s.updateUpdate,
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.brand)),
                )
              : const Icon(Icons.chevron_right_rounded, size: 20),
      onTap: isChecking ? null : onTap,
    );
  }
}

// ── Cookie Chip ───────────────────────────────────────────────────────────────

class _CookieChip extends StatelessWidget {
  const _CookieChip({required this.site, required this.has});
  final String site;
  final bool   has;

  @override
  Widget build(BuildContext context) {
    final color = has ? AppColors.success : AppColors.darkTextSecondary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color:        color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
        border:       Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            has ? Icons.check_circle_rounded : Icons.cancel_outlined,
            size:  11,
            color: color,
          ),
          const SizedBox(width: 4),
          Text(
            site,
            style: TextStyle(
              fontSize:   11,
              color:      color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

// ── yt-dlp / ffmpeg Binary Update Tile ────────────────────────────────────────

class _YtDlpUpdateTile extends ConsumerWidget {
  const _YtDlpUpdateTile({
    required this.isChecking,
    required this.onTap,
  });
  final bool         isChecking;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final st    = ref.watch(binaryUpdateProvider);
    final loc   = ref.watch(stringsProvider);
    final phase = st.phase;

    String subtitle;
    Color? subtitleColor;
    final pct = st.progress > 0
        ? '${(st.progress * 100).toStringAsFixed(0)}%'
        : '';

    if (isChecking || phase == BinaryUpdatePhase.checking) {
      subtitle = loc.updateEngineChecking;
    } else if (phase == BinaryUpdatePhase.downloading) {
      subtitle = loc.updateEngineDownloading(st.currentBinary, pct);
    } else if (phase == BinaryUpdatePhase.extracting) {
      subtitle = loc.updateEngineExtracting(st.currentBinary);
    } else if (phase == BinaryUpdatePhase.updated) {
      subtitle      = loc.updateEngineUpdated(st.currentBinary, st.fromVersion, st.toVersion);
      subtitleColor = AppColors.success;
    } else if (phase == BinaryUpdatePhase.failed) {
      subtitle      = st.errorMessage.isNotEmpty ? st.errorMessage : loc.updateEngineFailed;
      subtitleColor = AppColors.error;
    } else if (phase == BinaryUpdatePhase.upToDate) {
      subtitle      = loc.updateEngineUpToDate;
      subtitleColor = AppColors.success;
    } else {
      subtitle = loc.updateEngineSubtitle;
    }

    final busy = isChecking ||
        phase == BinaryUpdatePhase.checking ||
        phase == BinaryUpdatePhase.downloading ||
        phase == BinaryUpdatePhase.extracting;

    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.brand.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(8),
        ),
        child: busy
            ? const SizedBox(
                width: 20, height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.brand,
                ),
              )
            : Icon(
                phase == BinaryUpdatePhase.updated
                    ? Icons.check_circle_rounded
                    : Icons.download_for_offline_rounded,
                color: phase == BinaryUpdatePhase.updated
                    ? AppColors.success
                    : AppColors.brand,
                size: 20,
              ),
      ),
      title: Text(loc.updateEngine, style: const TextStyle(fontSize: 14)),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(subtitle, style: TextStyle(fontSize: 11.5, color: subtitleColor)),
          if (phase == BinaryUpdatePhase.downloading && st.progress > 0) ...[
            const SizedBox(height: 5),
            ClipRRect(
              borderRadius: BorderRadius.circular(2),
              child: LinearProgressIndicator(
                value: st.progress,
                backgroundColor: AppColors.brand.withValues(alpha: 0.12),
                valueColor: const AlwaysStoppedAnimation(AppColors.brand),
                minHeight: 3,
              ),
            ),
          ],
        ],
      ),
      trailing: busy ? null : const Icon(Icons.chevron_right_rounded, size: 18),
      onTap:    busy ? null : onTap,
      isThreeLine: phase == BinaryUpdatePhase.downloading && st.progress > 0,
    );
  }
}
