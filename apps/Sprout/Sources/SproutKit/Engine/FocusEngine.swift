import Foundation

public enum FocusEngineState: Equatable, Sendable {
    case idle
    case running(FocusSession)
    case finished(FocusSession)
}

public enum FocusEngineError: Error, Equatable {
    case alreadyRunning
    case notRunning
}

/// Plain-Foundation state machine for a focus session.
/// UI code drives `tick(at:)` on a timer and reports lifecycle events
/// (`backgrounded`, `foregrounded`) so we can record the outcome.
public final class FocusEngine: @unchecked Sendable {
    public private(set) var state: FocusEngineState = .idle

    private let clock: FocusClock
    private let abandonGraceSeconds: TimeInterval

    public init(clock: FocusClock = SystemClock(), abandonGraceSeconds: TimeInterval = 5) {
        self.clock = clock
        self.abandonGraceSeconds = abandonGraceSeconds
    }

    @discardableResult
    public func start(sproutID: UUID, plannedSeconds: Int) throws -> FocusSession {
        if case .running = state { throw FocusEngineError.alreadyRunning }
        let session = FocusSession(
            sproutID: sproutID,
            startedAt: clock.now(),
            plannedSeconds: plannedSeconds
        )
        state = .running(session)
        return session
    }

    /// Returns the up-to-date session (elapsedSeconds refreshed).
    @discardableResult
    public func tick() -> FocusSession? {
        guard case .running(var session) = state else { return nil }
        session.elapsedSeconds = Int(clock.now().timeIntervalSince(session.startedAt))
        if session.elapsedSeconds >= session.plannedSeconds {
            session.elapsedSeconds = session.plannedSeconds
            session.endedAt = clock.now()
            session.outcome = .completed
            state = .finished(session)
            return session
        }
        state = .running(session)
        return session
    }

    /// User explicitly gave up before the timer finished.
    public func cancel() throws -> FocusSession {
        guard case .running(var session) = state else {
            throw FocusEngineError.notRunning
        }
        session.elapsedSeconds = Int(clock.now().timeIntervalSince(session.startedAt))
        session.endedAt = clock.now()
        session.outcome = .cancelled
        state = .finished(session)
        return session
    }

    /// App went to background or another app came forward.
    /// If we're within the grace period of the session end, treat as completed.
    public func backgrounded() -> FocusSession? {
        guard case .running(var session) = state else { return nil }
        let elapsed = clock.now().timeIntervalSince(session.startedAt)
        session.elapsedSeconds = Int(elapsed)
        session.endedAt = clock.now()
        if elapsed >= Double(session.plannedSeconds) - abandonGraceSeconds {
            session.elapsedSeconds = session.plannedSeconds
            session.outcome = .completed
        } else {
            session.outcome = .abandoned
        }
        state = .finished(session)
        return session
    }

    public func reset() {
        state = .idle
    }
}
