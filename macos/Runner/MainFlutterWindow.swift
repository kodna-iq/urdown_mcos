import Cocoa
import FlutterMacOS

class MainFlutterWindow: NSWindow {
  override func awakeFromNib() {
    let flutterViewController = FlutterViewController()
    let windowFrame = self.frame
    self.contentViewController = flutterViewController
    self.setFrame(windowFrame, display: true)

    // ── VirtualBox / SoftwareGL hardening ────────────────────────────────
    // 1. Force the window to be fully opaque so the OS uses the software
    //    renderer path (no Metal layer compositing needed).
    self.isOpaque = true
    self.backgroundColor = NSColor(
      red: 7.0/255, green: 9.0/255, blue: 13.0/255, alpha: 1.0
    ) // #07090D — matches Flutter darkBg

    // 2. Disable state restoration so no phantom window appears on boot.
    self.isRestorable = false

    // 3. Show immediately BEFORE window_manager can call orderOut:.
    //    window_manager.ensureInitialized() will hide it again, but our
    //    Dart side calls show()+focus() right after ensureInitialized()
    //    so it comes back immediately.
    self.makeKeyAndOrderFront(nil)
    NSApp.activate(ignoringOtherApps: true)

    RegisterGeneratedPlugins(registry: flutterViewController)

    super.awakeFromNib()
  }
}
