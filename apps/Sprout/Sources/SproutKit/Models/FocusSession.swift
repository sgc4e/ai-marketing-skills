import Foundation

public enum FocusOutcome: String, Codable, Sendable {
    case completed
    case abandoned
    case cancelled
}

public struct FocusSession: Identifiable, Codable, Sendable, Equatable {
    public let id: UUID
    public let sproutID: UUID
    public let startedAt: Date
    public let plannedSeconds: Int
    public var endedAt: Date?
    public var elapsedSeconds: Int
    public var outcome: FocusOutcome?

    public init(
        id: UUID = UUID(),
        sproutID: UUID,
        startedAt: Date,
        plannedSeconds: Int,
        endedAt: Date? = nil,
        elapsedSeconds: Int = 0,
        outcome: FocusOutcome? = nil
    ) {
        self.id = id
        self.sproutID = sproutID
        self.startedAt = startedAt
        self.plannedSeconds = plannedSeconds
        self.endedAt = endedAt
        self.elapsedSeconds = elapsedSeconds
        self.outcome = outcome
    }

    public var earnedMinutes: Int {
        guard outcome == .completed else { return 0 }
        return plannedSeconds / 60
    }
}
