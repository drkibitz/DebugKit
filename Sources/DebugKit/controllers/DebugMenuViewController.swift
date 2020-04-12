#if DEBUG
import Foundation

internal final class DebugMenuViewController: DebugTableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Debug Menu"

        let items: [Section.Item] = [
            Section.Item(title: "Console", height: 50) { [weak self] _ in
                self?.navigationController?.pushViewController(DebugConsoleViewController(), animated: true)
            },
            Section.Item(title: "Network", height: 50) { [weak self] _ in
                self?.navigationController?.pushViewController(DebugNetworkViewController(), animated: true)
            },
            Section.Item(title: "Settings", height: 50) { [weak self] _ in
                self?.navigationController?.pushViewController(DebugSettingsViewController(), animated: true)
            }
        ]

        if let info = Bundle.main.infoDictionary,
            let name = info["CFBundleName"] as? String,
            let version = info["CFBundleShortVersionString"] as? String,
            let buildNumber = info["CFBundleVersion"] as? String {

            var title = "\(name) v\(version) (\(buildNumber))"
            if let debugInfo = Debug.info {
                title += ", \(debugInfo.buildConfiguration) \(debugInfo .compilationInfo)"
            }
            dataSource = DataSource(model: [Section(
                title: title,
                height: 33,
                items: items
            )])
        } else {
            dataSource = DataSource(model: [Section(items: items)])
        }
    }
}
#endif
