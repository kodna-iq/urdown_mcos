import 'package:flutter/material.dart';

// Custom title bar is disabled — using native macOS title bar.
// window_manager is not initialized from Dart (to fix VirtualBox blank window).
// DragToMoveArea and custom window controls require an initialized
// window_manager, so they are removed for now.
//
// The native title bar shows "UrDown" and provides the standard
// macOS close/minimize/maximize controls.
class UrDownTitleBar extends StatelessWidget {
  const UrDownTitleBar({super.key});

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}
