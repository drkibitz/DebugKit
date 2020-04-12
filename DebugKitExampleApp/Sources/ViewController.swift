import DebugKit
import UIKit

final class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        Debug.console.addMarker()
        Debug.console.info("Thanks for trying DebugKit!")
        Debug.console.addMarker()
        Debug.console.info("To go fullscreen, shake again.")
        Debug.console.info("Or tap the debugger's NavigationBar.")
        Debug.console.addMarker()
    }

    @IBAction func showDebugger(sender: UIButton) {
        #if DEBUG
        if let window = viewIfLoaded?.window {
            Debug.toggle(window: window)
        }
        #endif
    }
}
