import UIKit

extension String {
    func trim() -> String? {
        let trimmed = trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return nil }

        return trimmed
    }
}

extension CALayer {
    var uiBorderColor: UIColor? {
        get {
            guard let color = borderColor else { return nil }
            return UIColor(cgColor: color)
        }
        set {
            borderColor = newValue?.cgColor
        }
    }
}
