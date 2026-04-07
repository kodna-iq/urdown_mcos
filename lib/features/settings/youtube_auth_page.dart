import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../app/theme.dart';
import '../../core/constants/app_constants.dart';
import '../../core/l10n/app_strings.dart';
import '../../services/remote_cookies_service.dart';

/// Page for managing per-site authentication cookies.
/// Users can import a Netscape-format cookies.txt file for each supported site,
/// which yt-dlp will use for authenticated downloads.
class YouTubeAuthPage extends StatefulWidget {
  const YouTubeAuthPage({super.key});

  @override
  State<YouTubeAuthPage> createState() => _YouTubeAuthPageState();
}

class _YouTubeAuthPageState extends State<YouTubeAuthPage> {
  static final _sites = AppConstants.cookieSiteDisplayNames;

  final Map<String, bool> _hasCookies = {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _checkAll();
  }

  Future<void> _checkAll() async {
    setState(() => _loading = true);
    try {
      final dir = await getApplicationSupportDirectory();
      final result = <String, bool>{};
      for (final entry in _sites.entries) {
        final file = File(p.join(dir.path, entry.value));
        result[entry.key] = file.existsSync() && file.lengthSync() > 100;
      }
      if (mounted) setState(() => _hasCookies.addAll(result));
    } catch (_) {}
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _importCookies(String site, String filename) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['txt'],
        dialogTitle: 'Import $site cookies.txt',
      );
      if (result == null || result.files.single.path == null) return;
      final content = await File(result.files.single.path!).readAsString();
      await RemoteCookiesService.saveCookiesForSite(filename, content);
      await _checkAll();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$site cookies imported successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to import: $e')),
        );
      }
    }
  }

  Future<void> _deleteCookies(String site, String filename) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Cookies'),
        content: Text('Remove saved cookies for $site?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await RemoteCookiesService.deleteCookiesForSite(filename);
    await _checkAll();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final s = AppStrings.of(context);

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBg : AppColors.lightBg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(s.manageCookies),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(20),
              children: [
                // Info card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.brand.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.brand.withValues(alpha: 0.2)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.info_outline_rounded,
                          color: AppColors.brand, size: 18),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Import a Netscape-format cookies.txt file for each site '
                          'to enable downloading members-only or age-restricted content.',
                          style: TextStyle(
                            fontSize: 12.5,
                            color: isDark
                                ? AppColors.darkTextSecondary
                                : AppColors.lightTextSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Per-site cookie cards
                ..._sites.entries.map((entry) {
                  final site     = entry.key;
                  final filename = entry.value;
                  final hasCookies = _hasCookies[site] ?? false;

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Container(
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.darkCard : AppColors.lightCard,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isDark
                              ? AppColors.darkBorder
                              : AppColors.lightBorder,
                        ),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        leading: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: hasCookies
                                ? Colors.green.withValues(alpha: 0.1)
                                : (isDark
                                    ? AppColors.darkBorder
                                    : AppColors.lightBorder),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            hasCookies
                                ? Icons.check_circle_rounded
                                : Icons.cookie_outlined,
                            color: hasCookies ? Colors.green : AppColors.brand,
                            size: 20,
                          ),
                        ),
                        title: Text(site,
                            style: const TextStyle(fontWeight: FontWeight.w600)),
                        subtitle: Text(
                          hasCookies ? 'Cookies stored' : 'No cookies',
                          style: TextStyle(
                            fontSize: 12,
                            color: hasCookies ? Colors.green : null,
                          ),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(
                                  Icons.upload_file_rounded,
                                  size: 20),
                              tooltip: 'Import cookies.txt',
                              onPressed: () =>
                                  _importCookies(site, filename),
                            ),
                            if (hasCookies)
                              IconButton(
                                icon: const Icon(Icons.delete_outline_rounded,
                                    size: 20, color: AppColors.error),
                                tooltip: 'Delete cookies',
                                onPressed: () =>
                                    _deleteCookies(site, filename),
                              ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),

                const SizedBox(height: 80),
              ],
            ),
    );
  }
}
