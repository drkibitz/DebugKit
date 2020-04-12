#if DEBUG
import UIKit

internal final class DebugConsoleViewController: DebugViewController {

    // MARK: - Private -

    private class MessageWithSubject: NSObject, UIActivityItemSource {

        let subject: String
        let message: String

        init(subject: String, message: String) {
            var sub = subject
            if let info = Bundle.main.infoDictionary {
                if let name = info["CFBundleName"] as? String,
                    let version = info["CFBundleShortVersionString"] as? String,
                    let buildNumber: String = info["CFBundleVersion"] as? String {
                    sub = "\(name) \(version)-\(buildNumber): \(subject)"
                }
            }
            let deviceInfo = "\(UIDevice.current.model), \(UIDevice.current.systemName) \(UIDevice.current.systemVersion)"

            self.subject = sub
            if let debugInfo = Debug.info {
                let buildInfo = "\(debugInfo.buildConfiguration) \(debugInfo.compilationInfo)"
                self.message = "\(sub)\nBuild: \(buildInfo)\nDevice: \(deviceInfo)\n\n---\n\n\(message)"
            } else {
                self.message = "\(sub)\nDevice: \(deviceInfo)\n\n---\n\n\(message)"
            }

            super.init()
        }

        func activityViewControllerPlaceholderItem(_ activityViewController: UIActivityViewController) -> Any {
            return ""
        }

        func activityViewController(_ activityViewController: UIActivityViewController,
                                    itemForActivityType activityType: UIActivity.ActivityType?) -> Any? {
            return message
        }

        func activityViewController(_ activityViewController: UIActivityViewController,
                                    subjectForActivityType activityType: UIActivity.ActivityType?) -> String {
            return subject
        }
    }

    private weak var textView: UITextView?
    private var isScrollPositionLockedToBottom: Bool = true
    private var isScrollPositionTracked: Bool = false

    private func scrollToBottom(_ animated: Bool = false) {
        guard let textView = textView else { return }
        textView.layoutManager.ensureLayout(for: textView.textContainer)
        textView.layoutIfNeeded()

        let bottomInset = textView.adjustedContentInset.bottom
        let bottomEdge = max(0, textView.bounds.height - bottomInset)
        let diff = textView.contentSize.height - bottomEdge
        if diff > 0 {
            textView.setContentOffset(CGPoint(x: 0, y: diff), animated: animated)
        }
    }

    @objc
    private func addMarker() {
        Debug.console.addMarker()
    }

    @objc
    private func customText() {
        let alert = UIAlertController(title: "Add Log", message: nil, preferredStyle: .alert)
        alert.addTextField {
            $0.keyboardType = .alphabet
            $0.placeholder = "Hello World!"
        }
        alert.addAction(UIAlertAction(title: "Verbose", style: .default) { _ in
            if let text = alert.textFields?.first?.text {
                Debug.console.verbose(text.isEmpty ? "." : text)
            }
        })
        alert.addAction(UIAlertAction(title: "Debug", style: .default) { _ in
            if let text = alert.textFields?.first?.text {
                Debug.console.debug(text.isEmpty ? "." : text)
            }
        })
        alert.addAction(UIAlertAction(title: "Info", style: .default) { _ in
            if let text = alert.textFields?.first?.text {
                Debug.console.info(text.isEmpty ? "." : text)
            }
        })
        alert.addAction(UIAlertAction(title: "Warning", style: .default) { _ in
            if let text = alert.textFields?.first?.text {
                Debug.console.warning(text.isEmpty ? "." : text)
            }
        })
        alert.addAction(UIAlertAction(title: "Error", style: .default) { _ in
            if let text = alert.textFields?.first?.text {
                Debug.console.error(text.isEmpty ? "." : text)
            }
        })
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }

    @objc
    private func share() {
        var items: [Any] = []
        if case .textStorage(let storage) = Debug.console {
            items.append(MessageWithSubject(subject: "Console Log", message: storage.string))
        }
        if let image = viewIfLoaded?.debugWindow?.debugScreenshot() {
            items.append(image)
        }
        let activityVC = UIActivityViewController(activityItems: items, applicationActivities: nil)
        activityVC.excludedActivityTypes = [
            .postToFacebook,
            .postToTwitter,
            .postToWeibo,
            .assignToContact,
            .addToReadingList,
            .postToFlickr,
            .postToVimeo,
            .postToTencentWeibo,
            .openInIBooks
        ]
        present(activityVC, animated: true, completion: nil)
    }

    @objc
    private func clear() {
        Debug.console.clear()
    }

    // MARK: - Internal -

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Console"

        toolbarItems = [
            UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addMarker)),
            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
            UIBarButtonItem(barButtonSystemItem: .compose, target: self, action: #selector(customText)),
            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
            UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(share)),
            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
            UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(clear))
        ]

        // gestures

        let addMarkerGesture = UISwipeGestureRecognizer(target: self, action: #selector(addMarker))
        viewIfLoaded?.addGestureRecognizer(addMarkerGesture)

        let addCustomTextGesture = UITapGestureRecognizer(target: self, action: #selector(customText))
        addCustomTextGesture.numberOfTouchesRequired = 2
        viewIfLoaded?.addGestureRecognizer(addCustomTextGesture)

        // text view

        let layoutManager = NSLayoutManager()
        layoutManager.delegate = self
        if case .textStorage(let storage) = Debug.console {
            storage.addLayoutManager(layoutManager)
        }

        let container = NSTextContainer(size: .zero)
        container.widthTracksTextView = true
        container.heightTracksTextView = true
        layoutManager.addTextContainer(container)

        let textView = UITextView(frame: .zero, textContainer: container)
        textView.backgroundColor = .black
        textView.isEditable = false
        textView.delaysContentTouches = false
        textView.alwaysBounceVertical = true
        textView.alwaysBounceHorizontal = false
        textView.delegate = self

        view.addSubview(textView)
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        textView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        textView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        textView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true

        self.textView = textView
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        guard isScrollPositionLockedToBottom else { return }
        scrollToBottom()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        textView?.scrollsToTop = viewIfLoaded?.debugWindow?.debugWindowMode == .fullscreen
        guard isScrollPositionLockedToBottom else { return }
        scrollToBottom()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setToolbarHidden(false, animated: animated)
    }

    deinit {
        guard let layoutManager = textView?.layoutManager else { return }
        if case .textStorage(let storage) = Debug.console {
            storage.removeLayoutManager(layoutManager)
        }
    }
}

extension DebugConsoleViewController: NSLayoutManagerDelegate {

    func layoutManager(_ layoutManager: NSLayoutManager, didCompleteLayoutFor textContainer: NSTextContainer?, atEnd layoutFinishedFlag: Bool) {
        guard isScrollPositionLockedToBottom else { return }
        DispatchQueue.main.async { self.scrollToBottom(true) }
    }
}

extension DebugConsoleViewController: UITextViewDelegate {

    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        isScrollPositionLockedToBottom = false
        isScrollPositionTracked = true
    }

    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        isScrollPositionTracked = decelerate
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        isScrollPositionTracked = false
    }

    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        isScrollPositionTracked = false
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard isScrollPositionTracked else { return }
        let bottomInset = scrollView.adjustedContentInset.bottom
        let height = scrollView.bounds.height - bottomInset
        let bottomEdge = scrollView.contentOffset.y + height
        isScrollPositionLockedToBottom = (height == 0 || bottomEdge >= scrollView.contentSize.height)
    }
}
#endif
