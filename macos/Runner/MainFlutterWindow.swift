import Cocoa
import FlutterMacOS

class MainFlutterWindow: NSWindow {
  override func awakeFromNib() {
    let flutterViewController = FlutterViewController()
    self.contentViewController = flutterViewController

    // ── Window setup (pure Swift — no window_manager interference) ────────

    // 1. Size and center on the actual screen (not storyboard's 2560-wide screen)
    let screenSize = NSScreen.main?.visibleFrame ?? NSRect(x: 0, y: 0, width: 1280, height: 800)
    let winW: CGFloat = min(1280, screenSize.width  - 40)
    let winH: CGFloat = min(800,  screenSize.height - 40)
    let winX = screenSize.minX + (screenSize.width  - winW) / 2
    let winY = screenSize.minY + (screenSize.height - winH) / 2
    self.setFrame(NSRect(x: winX, y: winY, width: winW, height: winH), display: true)

    // 2. Enforce minimum size
    self.minSize = NSSize(width: 760, height: 520)

    // 3. Opaque window — critical for VirtualBox SoftwareGL.
    //    Non-opaque windows use Metal compositing which is absent on VirtualBox.
    self.isOpaque = true
    self.backgroundColor = NSColor(
      calibratedRed: 7.0/255, green: 9.0/255, blue: 13.0/255, alpha: 1.0
    )

    // 4. Disable state restoration (avoids phantom windows on VirtualBox boot)
    self.isRestorable = false

    // 5. Show the window NOW — before anything else can hide it.
    self.makeKeyAndOrderFront(nil)
    NSApp.activate(ignoringOtherApps: true)

    RegisterGeneratedPlugins(registry: flutterViewController)

    super.awakeFromNib()
  }
}
