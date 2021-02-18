#if DEBUG
internal final class DebugNetworkViewController: DebugTableViewController<DataSource<Any>> {

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Network"

        dataSource = DataSource(model: [Self.Section(
            title: "TODO",
            height: 33,
            items: [Self.Section.Item(title: "TODO", height: 50)]
        )])
    }
}
#endif
