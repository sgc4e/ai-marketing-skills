import Foundation

public protocol FocusClock: Sendable {
    func now() -> Date
}

public struct SystemClock: FocusClock {
    public init() {}
    public func now() -> Date { Date() }
}

public final class TestClock: FocusClock, @unchecked Sendable {
    private let lock = NSLock()
    private var current: Date

    public init(_ start: Date = Date(timeIntervalSince1970: 0)) {
        self.current = start
    }

    public func now() -> Date {
        lock.lock(); defer { lock.unlock() }
        return current
    }

    public func advance(by seconds: TimeInterval) {
        lock.lock(); defer { lock.unlock() }
        current = current.addingTimeInterval(seconds)
    }
}
