import Cocoa
import FlutterMacOS

@main
class AppDelegate: FlutterAppDelegate {

  override func applicationDidFinishLaunching(_ notification: Notification) {
    // Activate the app so it gets focus — required on VirtualBox
    NSApp.activate(ignoringOtherApps: true)

    // Fallback: if window_manager doesn't show the window within 1.5 s
    // (e.g. on VirtualBox where lifecycle events are unreliable),
    // forcefully order all windows to front.
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
