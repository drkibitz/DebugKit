#if DEBUG
internal final class DebugNetworkViewController: DebugTableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Network"

        dataSource = DataSource(model: [Section(
            title: "TODO",
            height: 33,
            items: [Section.Item(title: "TODO", height: 50)]
        )])
    }
}
#endif
