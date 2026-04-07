import 'dart:io';

/// Shows OS-level notifications for download events.
/// On platforms without a notification plugin available (desktop),
/// this gracefully no-ops. Wire in flutter_local_notifications or
/// local_notifier if you want real desktop toasts.
class NotificationService {
  NotificationService._();
  static final instance = NotificationService._();

  bool _initialized = false;

  /// Call once from main() after WidgetsFlutterBinding.ensureInitialized().
  Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;
    // Placeholder: attach a real notification plugin here when needed.
    // e.g. flutter_local_notifications initialisation.
  }

  /// Show a "Download complete" notification.
  Future<void> showDownloadComplete(String jobId) async {
    if (!_shouldNotify()) return;
    _log('Download complete: $jobId');
    // TODO: replace with real notification when plugin is integrated.
  }

  /// Show a "Download failed" notification.
  Future<void> showDownloadFailed(String title, String reason) async {
    if (!_shouldNotify()) return;
    _log('Download failed: $title — $reason');
    // TODO: replace with real notification when plugin is integrated.
  }

  bool _shouldNotify() {
    // Desktop platforms need a separate plugin (local_notifier / flutter_local_notifications).
    // Mobile platforms can use flutter_local_notifications directly.
    return Platform.isAndroid || Platform.isIOS || Platform.isMacOS;
  }

  void _log(String msg) {
    // ignore: avoid_print
    print('[NotificationService] $msg');
  }
}
