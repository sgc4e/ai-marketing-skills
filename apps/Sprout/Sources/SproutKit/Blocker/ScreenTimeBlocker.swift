import Foundation

/// Abstraction over Apple's Screen Time stack (FamilyControls + ManagedSettings
/// + DeviceActivity). The MVP ships with `NoopScreenTimeBlocker`; once we have
/// the FamilyControls entitlement we add a `FamilyControlsBlocker` conforming
/// type and swap it in at the app composition root.
public protocol ScreenTimeBlocker: Sendable {
    var isAvailable: Bool { get }
    func requestAuthorization() async throws
    func startBlocking(durationSeconds: Int) async throws
    func stopBlocking() async
}

public struct NoopScreenTimeBlocker: ScreenTimeBlocker {
    public init() {}
    public var isAvailable: Bool { false }
    public func requestAuthorization() async throws {}
    public func startBlocking(durationSeconds: Int) async throws {}
    public func stopBlocking() async {}
}
