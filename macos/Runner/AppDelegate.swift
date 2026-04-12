import Cocoa
import FlutterMacOS

@main
class AppDelegate: FlutterAppDelegate {

  override func applicationDidFinishLaunching(_ notification: Notification) {
    // Activate the app so it gets focus — required on VirtualBox.
    NSApp.activate(ignoringOtherApps: true)

    // ── VirtualBox rendering fix ──────────────────────────────────────────
    // On VirtualBox the Metal compositor is absent; CALayer backing stores
    // are never flushed to the screen automatically.  Calling
    // setNeedsDisplay + display on every window's contentView after a short
    // delay forces a synchronous software-render pass that makes Flutter's
    // first frame actually appear.
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
      for window in NSApp.windows {
        window.contentView?.setNeedsDisplay(window.contentView?.bounds ?? .zero)
        window.contentView?.display()
        if !window.isVisible {
          window.makeKeyAndOrderFront(nil)
        }
      }
      NSApp.activate(ignoringOtherApps: true)
    }

    // Second-chance fallback at 1.5 s — catches slow boot / cold-start.
    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
      for window in NSApp.windows where !window.isVisible {
        window.makeKeyAndOrderFront(nil)
      }
      NSApp.activate(ignoringOtherApps: true)
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
