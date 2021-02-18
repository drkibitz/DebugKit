#if DEBUG
import UIKit

public enum DebugConsole {

    case textStorage(NSTextStorage = NSTextStorage())

    // MARK: - Private -

    private static let defaultTextAttributes: [NSAttributedString.Key: Any] = [
        // swiftlint:disable force_unwrapping
        .font: UIFont(name: "Menlo", size: 10.0)!,
        // swiftlint:enable force_unwrapping
        .foregroundColor: UIColor.white
    ]

    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yy-MM-dd HH:mm:ss"
        return formatter
    }()

    private static var timestamp: String {
        return Self.dateFormatter.string(from: Date())
    }

    private func format(_ text: String, color: UIColor? = nil) -> NSAttributedString {
        let formatted = NSMutableAttributedString(string: text)
        let range = NSRange(location: 0, length: formatted.length)
        var attributes = Self.defaultTextAttributes
        if color != nil { attributes[.foregroundColor] = color }
        formatted.addAttributes(attributes, range: range)
        return formatted
    }

    // MARK: - Internal -

    func clear() {
        if case .textStorage(let storage) = self {
            DispatchQueue.main.async {
                storage.beginEditing()
                storage.setAttributedString(NSMutableAttributedString())
                storage.endEditing()
            }
        }
    }

    func print(_ text: NSAttributedString..., separator: String = " ", terminator: String = "\n") {
        if case .textStorage(let storage) = self {
            DispatchQueue.main.async {
                storage.beginEditing()
                storage.append(text[0])
                for index in 1..<text.count {
                    storage.append(NSAttributedString(string: separator))
                    storage.append(text[index])
                }
                storage.append(NSAttributedString(string: terminator))
                storage.endEditing()
            }
        }
    }
}

extension DebugConsole {

    // MARK: - Public -

    public func verbose(_ text: String) {
        self.print(format(Self.timestamp, color: .lightText), format("VERBOSE", color: #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1)), format(text))
    }

    public func debug(_ text: String) {
        self.print(format(Self.timestamp, color: .lightText), format("DEBUG", color: #colorLiteral(red: 0.3383780718, green: 0.8710207343, blue: 0.3861016631, alpha: 1)), format(text))
    }

    public func info(_ text: String) {
        self.print(format(Self.timestamp, color: .lightText), format("INFO", color: #colorLiteral(red: 0.03799040243, green: 0.6652550697, blue: 0.9694569707, alpha: 1)), format(text))
    }

    public func warning(_ text: String) {
        self.print(format(Self.timestamp, color: .lightText), format("WARNING", color: #colorLiteral(red: 0.9837539792, green: 0.5999872088, blue: 0, alpha: 1)), format(text))
    }

    public func error(_ text: String) {
        self.print(format(Self.timestamp, color: .lightText), format("ERROR", color: #colorLiteral(red: 0.9918593764, green: 0.3232502639, blue: 0.3038080037, alpha: 1)), format(text))
    }

    public func addMarker() {
        self.print(format(Self.timestamp, color: .lightText), format("–––––––––––––", color: #colorLiteral(red: 0.5568627715, green: 0.3529411852, blue: 0.9686274529, alpha: 1)))
    }
}
#else
public enum DebugConsole {
    case noop

    public func verbose(_ text: String) {}
    public func debug(_ text: String) {}
    public func info(_ text: String) {}
    public func warning(_ text: String) {}
    public func error(_ text: String) {}
    public func addMarker() {}
}
#endif
