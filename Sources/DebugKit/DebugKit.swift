#if DEBUG
import UIKit
#endif

public enum Debug {
    #if DEBUG

    public struct Info {
        let buildConfiguration: String
        let compilationInfo: String

        public init(buildConfiguration: String, compilationInfo: String) {
            self.buildConfiguration = buildConfiguration
            self.compilationInfo = compilationInfo
        }
    }

    public static var console: DebugConsole = .textStorage()

    public static var info: Info?

    public static func window(frame: CGRect = .zero) -> UIWindow {
        return DebugWindow(frame: frame)
    }

    @available(iOS 13.0, *)
    public static func window(windowScene: UIWindowScene) -> UIWindow {
        return DebugWindow(windowScene: windowScene)
    }

    public static func toggle(window: UIWindow) {
        if let debugWindow = window as? DebugWindow {
            debugWindow.debugToggleWindowMode()
        }
    }
    #else
    public static var console: DebugConsole = .noop
    #endif
}
