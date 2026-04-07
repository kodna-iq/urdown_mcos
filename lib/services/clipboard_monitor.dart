import 'dart:async';

import 'package:flutter/services.dart';

/// Monitors the system clipboard for URLs and exposes them via [urlStream].
/// Uses a periodic poll because Flutter has no push-based clipboard event API.
class ClipboardMonitor {
  ClipboardMonitor._();
  static final instance = ClipboardMonitor._();

  final _controller = StreamController<String>.broadcast();
  Timer? _timer;
  String? _lastSeen;

  /// Stream of newly detected URLs (each emitted only once per unique URL).
  Stream<String> get urlStream => _controller.stream;

  /// Begin polling the clipboard every 1.5 seconds.
  void start() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(milliseconds: 1500), (_) => _poll());
  }

  /// Stop polling.
  void stop() {
    _timer?.cancel();
    _timer = null;
  }

  /// Clear the last-seen URL so the same link can be re-detected after dismiss.
  void reset() {
    _lastSeen = null;
  }

  Future<void> _poll() async {
    try {
      final data = await Clipboard.getData(Clipboard.kTextPlain);
      final text = data?.text?.trim() ?? '';
      if (text.isEmpty) return;
      if (text == _lastSeen) return;
      if (!_isUrl(text)) return;
      _lastSeen = text;
      if (!_controller.isClosed) {
        _controller.add(text);
      }
    } catch (_) {}
  }

  static bool _isUrl(String text) {
    return text.startsWith('http://') || text.startsWith('https://');
  }

  void dispose() {
    stop();
    _controller.close();
  }
}
