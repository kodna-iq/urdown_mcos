import Cocoa
import FlutterMacOS

class MainFlutterWindow: NSWindow {
  override func awakeFromNib() {
    let flutterViewController = FlutterViewController()
    let windowFrame = self.frame
    self.contentViewController = flutterViewController
    self.setFrame(windowFrame, display: true)

    // ── VirtualBox / SoftwareGL fix ───────────────────────────────────────
    // When window_manager sets TitleBarStyle.hidden the NSWindow becomes
    // non-opaque and Flutter renders into a layer-backed view.  On VirtualBox
    // (SoftwareGL, no Metal) the compositor never presents those layers, so
    // the window appears completely blank / black.
    //
    // Forcing the window to be opaque here makes the OS treat it as a solid
    // surface; Flutter's scaffold background then paints the dark colour on
    // the first frame, which works correctly even without Metal.
    self.isOpaque = true
    self.backgroundColor = NSColor.black   // matches Flutter's darkBg #07090D

    // Disable automatic restoration — avoids a secondary "phantom" window
    // appearing on VirtualBox on cold start.
    self.isRestorable = false

    // Show the window immediately from the native side.
    // window_manager.ensureInitialized() will hide it afterwards,
    // and either the lifecycle callback or the AppDelegate timer will
    // show it again.
    self.makeKeyAndOrderFront(nil)

    RegisterGeneratedPlugins(registry: flutterViewController)

    super.awakeFromNib()
  }
}
