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

internal class DebugTableViewController: DebugViewController {

    // MARK: - Internal -

    struct ReuseIdentifier: RawRepresentable, ExpressibleByStringLiteral {
        typealias StringLiteralType = String
        typealias RawValue = String

        var rawValue: String

        static let `default`: ReuseIdentifier = "default"

        init(stringLiteral string: String) {
            rawValue = string
        }
        init?(rawValue: String) {
            self.init(stringLiteral: rawValue)
        }
    }

    struct Section {

        struct Item {
            let identifier: ReuseIdentifier?
            let title: String?
            let height: CGFloat
            let handler: ((IndexPath) -> Void)?

            init(identifier: ReuseIdentifier = .default, title: String? = nil, height: CGFloat = 0, handler: ((IndexPath) -> Void)? = nil) {
                self.identifier = identifier
                self.title = title
                self.height = height
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

    class DataSource: NSObject, UITableViewDataSource, UITableViewDelegate {

        var model: Model

        init(model: Model = []) {
            self.model = model
        }

        func numberOfSections(in tableView: UITableView) -> Int {
            return model.count
        }

        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return model[section].items.count
        }

        func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
            return model[section].title
        }

        func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
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
            return model[indexPath.section].items[indexPath.row].height
        }

        func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
            return model[section].height
        }

        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let item = model[indexPath.section].items[indexPath.row]

            let reuseIdentifier = item.identifier ?? ReuseIdentifier.default
            let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier.rawValue, for: indexPath)
            cell.backgroundColor = .black
            cell.textLabel?.textColor = .white
            cell.selectionStyle = .none
            cell.textLabel?.text = item.title

            if model[indexPath.section].items[indexPath.row].handler != nil {
                cell.accessoryType = .disclosureIndicator
            }
            return cell
        }

        func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            if let handler = model[indexPath.section].items[indexPath.row].handler {
                handler(indexPath)
            }
        }
    }

    // swiftlint:disable force_cast
    final var tableView: UITableView { return view as! UITableView }
    // swiftlint:enable force_cast
    final var dataSource: DataSource? {
        didSet {
            tableView.dataSource = dataSource
            tableView.delegate = dataSource
        }
    }

    override final func loadView() {
        let tableView = UITableView()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: ReuseIdentifier.default.rawValue)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = .black
        tableView.tintColor = .white
        tableView.indexDisplayMode = .automatic
        tableView.separatorStyle = .singleLine
        tableView.separatorColor = .darkGray
        tableView.separatorEffect = UIBlurEffect(style: .regular)
        view = tableView
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setToolbarHidden(true, animated: animated)
    }
}
#endif
