import Foundation

public enum Entitlement: String, Codable, Sendable {
    case free
    case paid
}

public protocol EntitlementStore: Sendable {
    func current() -> Entitlement
    func set(_ entitlement: Entitlement)
}

public final class InMemoryEntitlementStore: EntitlementStore, @unchecked Sendable {
    private var value: Entitlement
    public init(_ initial: Entitlement = .free) { self.value = initial }
    public func current() -> Entitlement { value }
    public func set(_ entitlement: Entitlement) { value = entitlement }
}

public struct TrialPolicy: Sendable {
    public let freeSproutCap: Int
    public let freeTrialDays: Int

    public init(freeSproutCap: Int = 3, freeTrialDays: Int = 7) {
        self.freeSproutCap = freeSproutCap
        self.freeTrialDays = freeTrialDays
    }

    public static let `default` = TrialPolicy()
}
