import Cocoa
import FlutterMacOS

@main
class AppDelegate: FlutterAppDelegate {

  override func applicationDidFinishLaunching(_ notification: Notification) {
    NSApp.activate(ignoringOtherApps: true)

    // Force-flush the window content at multiple points.
    // On VirtualBox the display server may not repaint automatically.
    for delay in [0.1, 0.3, 0.6, 1.0, 2.0] {
      DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
        for window in NSApp.windows {
          if !window.isVisible {
            window.makeKeyAndOrderFront(nil)
          }
          window.contentView?.needsDisplay = true
          window.contentView?.displayIfNeeded()
          window.displayIfNeeded()
        }
        NSApp.activate(ignoringOtherApps: true)
      }
    }
  }

  override func applicationShouldTerminateAfterLastWindowClosed(
    _ sender: NSApplication
  ) -> Bool { return true }

  override func applicationSupportsSecureRestorableState(
    _ app: NSApplication
  ) -> Bool { return true }
}
