import Foundation

internal extension NSNumber {

    func isBoolNumber() -> Bool {
        return CFGetTypeID(self) == CFBooleanGetTypeID()
    }

    func isDoubleNumber() -> Bool {
        return stringValue.contains(".")
    }

}
