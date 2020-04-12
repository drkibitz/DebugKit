import DebugKit
import SwiftUI

struct ContentView: View {

    var body: some View {
        VStack(alignment: .center) {
            Text("Shake to Show Debug Window").onAppear {
                Debug.console.addMarker()
                Debug.console.info("Thanks for trying DebugKit!")
                Debug.console.addMarker()
                Debug.console.info("To go fullscreen, shake again.")
                Debug.console.info("Or tap the debugger's NavigationBar.")
                Debug.console.addMarker()
            }
            Button(action: {
                if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                    let window = scene.windows.first {
                    Debug.toggle(window: window)
                } else {
                    assert(false)
                }
            }) {
                Text("Or Tap Here")
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
