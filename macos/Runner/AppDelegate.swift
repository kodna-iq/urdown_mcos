import Cocoa
import FlutterMacOS

@main
class AppDelegate: FlutterAppDelegate {

  override func applicationDidFinishLaunching(_ notification: Notification) {
    // Bring app to front immediately — critical on VirtualBox.
    NSApp.activate(ignoringOtherApps: true)

    // ── VirtualBox display flush ──────────────────────────────────────────
    // On VirtualBox (no Metal), CALayer backing stores are not auto-flushed.
    // We force a synchronous redraw of every window's content view at 3
    // checkpoints to guarantee the first Flutter frame is actually painted.
    for delay in [0.3, 0.8, 1.5] {
      DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
        for window in NSApp.windows {
          // Force-show any hidden window
          if !window.isVisible {
            window.makeKeyAndOrderFront(nil)
          }
          // Flush the CALayer tree synchronously
          window.contentView?.setNeedsDisplay(window.contentView?.bounds ?? .zero)
          window.contentView?.displayIfNeeded()
          window.displayIfNeeded()
        }
        NSApp.activate(ignoringOtherApps: true)
      }
    }
  }

  override func applicationShouldTerminateAfterLastWindowClosed(
    _ sender: NSApplication
  ) -> Bool {
    return true
  }

  override func applicationSupportsSecureRestorableState(
    _ app: NSApplication
  ) -> Bool {
    return true
  }
}
