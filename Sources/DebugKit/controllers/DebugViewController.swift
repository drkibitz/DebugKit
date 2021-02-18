#if DEBUG
import UIKit

internal class DebugViewController: UIViewController {

    @objc
    private final func toggleDebugWindow() {
        viewIfLoaded?.debugWindow?.debugToggleWindowMode()
    }

    @objc
    private final func hideDebugWindow() {
        viewIfLoaded?.debugWindow?.debugHide()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.leftItemsSupplementBackButton = true
        navigationItem.leftBarButtonItem =
            UIBarButtonItem(title: "☰", style: .plain, target: self, action: #selector(toggleDebugWindow))
        navigationItem.rightBarButtonItem =
            UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(hideDebugWindow))
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
}

struct DebugTableCellReuseId: RawRepresentable, ExpressibleByStringLiteral {
    typealias StringLiteralType = String
    typealias RawValue = String

    var rawValue: String

    static let `default`: DebugTableCellReuseId = "default"

    init(stringLiteral string: String) {
        rawValue = string
    }
    init?(rawValue: String) {
        self.init(stringLiteral: rawValue)
    }
}

// MARK: - Internal -

protocol DataSourceProtocol: UITableViewDataSource, UITableViewDelegate {
    associatedtype Section
    associatedtype Model
    associatedtype DataType
}

class DataSource<DataType>: NSObject, DataSourceProtocol {

    struct Section {

        struct Item {
            let reuseId: DebugTableCellReuseId?
            let title: String?
            let height: CGFloat
            let handler: ((IndexPath) -> Void)?
            let data: DataType?

            init(reuseId: DebugTableCellReuseId = .default, title: String? = nil, height: CGFloat = 0, data: DataType? = nil, handler: ((IndexPath) -> Void)? = nil) {
                self.reuseId = reuseId
                self.title = title
                self.height = height
                self.data = data;
                self.handler = handler
            }
        }

        let title: String?
        let height: CGFloat
        let items: [Item]

        init(title: String? = nil, height: CGFloat = 0, items: [Item] = []) {
            self.title = title
            self.height = height
            self.items = items
        }
    }
    typealias Model = [Section]

    var model: Model

    init(model: Model = []) {
        self.model = model
    }

    func isValid(section: Int) -> Bool {
        return section < model.count &&
            model[section].items.count > 0
    }

    func isValid(indexPath: IndexPath) -> Bool {
        return isValid(section: indexPath.section) &&
            indexPath.item < model[indexPath.section].items.count
    }

    func itemAt(indexPath: IndexPath) -> Section.Item {
        return model[indexPath.section].items[indexPath.row]
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return model.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard isValid(section: section) else { return 0 }
        return model[section].items.count
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        guard isValid(section: section) else { return nil }
        return model[section].title
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard isValid(section: section) else { return nil }

        let label = UILabel()
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.1
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: UIFont.systemFontSize)
        label.text = self.tableView(tableView, titleForHeaderInSection: section)
        label.textColor = .lightText

        let view = UIView()
        view.addSubview(label)
        view.backgroundColor = UIColor(white: 0.05, alpha: 1)
        let guide = view.layoutMarginsGuide
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: guide.topAnchor),
            label.bottomAnchor.constraint(equalTo: guide.bottomAnchor),
            label.leftAnchor.constraint(equalTo: guide.leftAnchor),
            label.rightAnchor.constraint(equalTo: guide.rightAnchor)
        ])
        return view
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return isValid(indexPath: indexPath)
            ? model[indexPath.section].items[indexPath.row].height
            : 0
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return isValid(section: section) ? model[section].height : 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell
        if isValid(indexPath: indexPath) {
            let item = itemAt(indexPath: indexPath)
            let reuseId = item.reuseId ?? DebugTableCellReuseId.default
            cell = tableView.dequeueReusableCell(withIdentifier: reuseId.rawValue, for: indexPath)
            cell.textLabel?.text = item.title
        } else {
            let reuseId = DebugTableCellReuseId.default
            cell = tableView.dequeueReusableCell(withIdentifier: reuseId.rawValue, for: indexPath)
        }
        if model[indexPath.section].items[indexPath.row].handler != nil {
            cell.accessoryType = .disclosureIndicator
        }
        cell.backgroundColor = .black
        cell.textLabel?.textColor = .lightText
        cell.selectionStyle = .none
        cell.tintColor = .lightText
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let handler = model[indexPath.section].items[indexPath.row].handler {
            handler(indexPath)
        }
    }
}

internal class DebugTableViewController<DS: DataSourceProtocol>: DebugViewController {

    typealias Model = DS.Model
    typealias Section = DS.Section

    // swiftlint:disable force_cast
    final var tableView: UITableView { return view as! UITableView }
    // swiftlint:enable force_cast
    final var dataSource: DS? {
        didSet {
            tableView.dataSource = dataSource
            tableView.delegate = dataSource
        }
    }

    override final func loadView() {
        let tableView = UITableView()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: DebugTableCellReuseId.default.rawValue)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = .black
        tableView.tintColor = .lightText
        tableView.indexDisplayMode = .automatic
        tableView.separatorStyle = .singleLine
        tableView.separatorColor = .darkGray
        tableView.separatorEffect = UIBlurEffect(style: .regular)
        tableView.tableFooterView = UIView(frame: CGRect.zero) // removes extra cells
        view = tableView
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setToolbarHidden(true, animated: animated)
    }
}
#endif
