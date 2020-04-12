import DebugKit
import UIKit

@UIApplicationMain
final class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        #if DEBUG
        let window = Debug.window(frame: UIScreen.main.bounds)
        Debug.info = ConfigurationConstants.debugInfo
        #else
        let window = UIWindow(frame: UIScreen.main.bounds)
        #endif
        self.window = window
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        window.rootViewController = storyboard.instantiateInitialViewController()
        window.makeKeyAndVisible()
        return true
    }
}
