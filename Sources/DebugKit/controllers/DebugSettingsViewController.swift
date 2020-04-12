#if DEBUG
internal final class DebugSettingsViewController: DebugTableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Settings"

        dataSource = DataSource(model: [Section(
            title: "TODO",
            height: 33,
            items: [Section.Item(title: "TODO", height: 50)]
        )])
    }
}
#endif
