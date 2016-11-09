import Foundation

internal final class AtomicInt {

    private let lock: DispatchQueue
    private var current: Int

    init(label: String) {
        self.lock = DispatchQueue(label: label)
        self.current = 0
    }

    func incrementAndGet() -> Int {
        var res: Int = 0

        lock.sync {
            if current == Int.max {
                current = 0
            } else {
                current += 1
            }

            res = current
        }

        return res
    }

}
