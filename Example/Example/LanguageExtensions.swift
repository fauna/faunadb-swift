import UIKit

extension String {
    // A handy trim function that returns nil if the resulting string is empty
    func trim() -> String? {
        let trimmed = trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return nil }

        return trimmed
    }
}

extension CALayer {
    // This property allows us to set the border color any CALayer from
    // XCode's "User Defined Runtime Attributes" settings.
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
