import Cocoa
import FlutterMacOS

class MainFlutterWindow: NSWindow {
  override func awakeFromNib() {
    let flutterViewController = FlutterViewController()
    let windowFrame = self.frame
    self.contentViewController = flutterViewController
    self.setFrame(windowFrame, display: true)

    // Keep the window fully opaque — required for SoftwareGL / VirtualBox.
    // Non-opaque windows need Metal compositing to show content; opaque
    // windows use a simple blit that works even without a GPU.
    self.isOpaque = true
    self.backgroundColor = .windowBackgroundColor

    // Prevent state restoration — avoids phantom windows on VirtualBox boot.
    self.isRestorable = false

    // Show immediately so the window is always visible from launch.
    self.makeKeyAndOrderFront(nil)
    NSApp.activate(ignoringOtherApps: true)

    RegisterGeneratedPlugins(registry: flutterViewController)

    super.awakeFromNib()
  }
}
