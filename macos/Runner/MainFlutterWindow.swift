import Cocoa
import FlutterMacOS

class MainFlutterWindow: NSWindow {
  override func awakeFromNib() {
    let flutterViewController = FlutterViewController()
    let windowFrame = self.frame
    self.contentViewController = flutterViewController
    self.setFrame(windowFrame, display: true)

    // Show the window immediately from the native side.
    // window_manager.ensureInitialized() will hide it afterwards,
    // and either the lifecycle callback or the AppDelegate timer will
    // show it again. Having this here ensures the window exists and is
    // properly set up before window_manager touches it.
    self.makeKeyAndOrderFront(nil)

    RegisterGeneratedPlugins(registry: flutterViewController)

    super.awakeFromNib()
  }
}
