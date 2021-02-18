#if DEBUG
import UIKit

private final class DebugAssociateWindow: UIWindow {

    weak var mainDebugWindow: DebugWindow?

    override public var next: UIResponder? {
        return mainDebugWindow ?? super.next
    }

    override public var canBecomeFirstResponder: Bool {
        return false
    }

    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let view = super.hitTest(point, with: event)
        if view == self {
            return mainDebugWindow?.hitTest(point, with: event) ?? view
        }
        return view
    }
}

internal enum DebugWindowMode {
    case hidden
    case partial
    case fullscreen
}

internal final class DebugWindow: UIWindow {

    // MARK: - Private -

    private final class DebugRootNavController: UINavigationController {
        private var _preferredStatusBarStyle: UIStatusBarStyle = .default
        override var preferredStatusBarStyle: UIStatusBarStyle {
            get { return _preferredStatusBarStyle }
            set { _preferredStatusBarStyle = newValue }
        }
    }

    private var debugAssociateWindow: DebugAssociateWindow?

    private var debugHeight: CGFloat = 0 {
        willSet {
            guard newValue != debugHeight else { return }
            let bounds = screen.bounds
            frame = CGRect(
                x: bounds.minX,
                y: bounds.minY,
                width: bounds.width,
                height: bounds.height - newValue
            )
            debugAssociateWindow?.frame = bounds
            debugAssociateWindow?.rootViewController?.view.frame = CGRect(
                x: bounds.minX,
                y: bounds.maxY - newValue,
                width: bounds.width,
                height: newValue
            )
        }
    }

    var debugWindowMode: DebugWindowMode = .hidden {
        willSet {
            guard newValue != debugWindowMode else { return }
            switch newValue {
            case .hidden:
                debugHeight = 0.0
            case .partial:
                debugHeight = round(screen.bounds.size.height / 2)
            case .fullscreen:
                debugHeight = screen.bounds.size.height
            }
        }
    }

    private func createDebugAssociateWindow() -> DebugAssociateWindow {
        let bounds = screen.bounds
        let window: DebugAssociateWindow
        if #available(iOS 13.0, *) {
            if let scene = windowScene {
                window = DebugAssociateWindow(windowScene: scene)
            } else {
                window = DebugAssociateWindow(frame: bounds)
            }
        } else {
            window = DebugAssociateWindow(frame: bounds)
        }
        window.windowLevel = windowLevel + 1
        window.mainDebugWindow = self

        let nav = DebugRootNavController(rootViewController: DebugMenuViewController())
        nav.pushViewController(DebugConsoleViewController(), animated: false)
        nav.view.clipsToBounds = true
        nav.view.backgroundColor = .black
        nav.navigationBar.barStyle = .black
        nav.navigationBar.barTintColor = .black
        nav.navigationBar.tintColor = .lightText
        nav.toolbar.barStyle = .black
        nav.toolbar.tintColor = .lightText
        nav.isNavigationBarHidden = true
        nav.isToolbarHidden = true
        nav.preferredStatusBarStyle = rootViewController?.preferredStatusBarStyle ?? .default
        nav.modalPresentationCapturesStatusBarAppearance = false

        let toggleWindowGesture = UITapGestureRecognizer(target: self, action: #selector(debugToggleWindowMode))
        nav.navigationBar.addGestureRecognizer(toggleWindowGesture)

        UIView.performWithoutAnimation {
            window.rootViewController = nav
            window.isHidden = false
            nav.view.frame = CGRect(x: bounds.minX, y: bounds.maxY, width: bounds.width, height: 0)
            nav.view.layoutIfNeeded()
        }
        return window
    }

    private func configureWindowsForStatusBarUpdates(_ mode: DebugWindowMode, _ oldMode: DebugWindowMode) {
        guard let nav = self.debugAssociateWindow?.rootViewController as? DebugRootNavController else { return }
        if mode == .fullscreen {
            nav.preferredStatusBarStyle = .lightContent
            nav.setNeedsStatusBarAppearanceUpdate()
        } else if oldMode == .fullscreen {
            nav.preferredStatusBarStyle = self.rootViewController?.preferredStatusBarStyle ?? .default
            nav.setNeedsStatusBarAppearanceUpdate()
        }
    }

    private func setDebugWindowMode(_ mode: DebugWindowMode, animated: Bool = false) {
        let oldMode = debugWindowMode
        guard mode != oldMode else { return }

        if oldMode == .fullscreen {
            self.isHidden = false
        } else if oldMode == .hidden && self.debugAssociateWindow == nil {
            self.debugAssociateWindow = self.createDebugAssociateWindow()
        }

        let animations = {
            self.debugWindowMode = mode
            self.layoutIfNeeded()
            self.debugAssociateWindow?.layoutIfNeeded()
            self.configureWindowsForStatusBarUpdates(mode, oldMode)
        }
        let completion: ((Bool) -> Void) = { finished in
            guard finished, mode == self.debugWindowMode else { return }
            if mode == .fullscreen {
                self.isHidden = true
            } else if mode == .hidden {
                self.debugAssociateWindow?.isHidden = true
                self.debugAssociateWindow = nil
            }
        }
        if animated {
            UIView.animate(withDuration: 0.33, animations: animations, completion: completion)
        } else {
            animations()
            completion(true)
        }
    }

    // MARK: - Internal -

    override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        guard motion == .motionShake else {
            return super.motionEnded(motion, with: event)
        }
        debugToggleWindowMode()
    }

    @objc
    func debugToggleWindowMode() {
        let toggled: DebugWindowMode = debugWindowMode == .partial ? .fullscreen : .partial
        setDebugWindowMode(toggled, animated: true)
    }

    func debugHide() {
        setDebugWindowMode(.hidden, animated: true)
    }

    func debugScreenshot() -> UIImage? {
        let oldMode = debugWindowMode
        UIView.performWithoutAnimation {
            debugWindowMode = .hidden
        }
        let renderer = UIGraphicsImageRenderer(bounds: self.bounds)
        let image = renderer.image { context in
            self.layer.render(in: context.cgContext)
        }
        UIView.performWithoutAnimation {
            debugWindowMode = oldMode
        }
        return image
    }
}

internal extension UIView {
    var debugWindow: DebugWindow? {
        switch window {
        case let window as DebugAssociateWindow:
            return window.mainDebugWindow
        case let window as DebugWindow:
            return window
        default:
            return nil
        }
    }
}
#endif
