import Foundation

public struct GardenState: Codable, Sendable, Equatable {
    public var sprouts: [Sprout]
    public var history: [FocusSession]
    public var totalFocusMinutes: Int
    public var streakDays: Int
    public var lastFocusDay: Date?

    public init(
        sprouts: [Sprout] = [],
        history: [FocusSession] = [],
        totalFocusMinutes: Int = 0,
        streakDays: Int = 0,
        lastFocusDay: Date? = nil
    ) {
        self.sprouts = sprouts
        self.history = history
        self.totalFocusMinutes = totalFocusMinutes
        self.streakDays = streakDays
        self.lastFocusDay = lastFocusDay
    }
}

/// Pure functions over `GardenState`. No I/O, no UI, easy to test.
public enum Garden {

    public static func hatch(
        in state: GardenState,
        nickname: String,
        at now: Date,
        species: Species? = nil
    ) -> (GardenState, Sprout) {
        let owned = Set(state.sprouts.map { $0.speciesID })
        let chosen = species ?? SpeciesCatalog.random(excluding: owned)
        let sprout = Sprout(
            speciesID: chosen.id,
            nickname: nickname.isEmpty ? chosen.name : nickname,
            hatchedAt: now
        )
        var s = state
        s.sprouts.append(sprout)
        return (s, sprout)
    }

    /// Apply the result of a finished session to the garden.
    public static func apply(
        session: FocusSession,
        to state: GardenState,
        at now: Date,
        calendar: Calendar = .current
    ) -> GardenState {
        var s = state
        s.history.append(session)

        guard let idx = s.sprouts.firstIndex(where: { $0.id == session.sproutID }) else {
            return s
        }

        switch session.outcome {
        case .completed:
            let earned = session.earnedMinutes
            s.sprouts[idx].focusMinutes += earned
            s.totalFocusMinutes += earned
            s.sprouts[idx].droopyUntil = nil
            s = updateStreak(s, completedAt: now, calendar: calendar)
        case .abandoned:
            // Half-credit for elapsed minutes, sprout droops for an hour.
            let partial = max(0, session.elapsedSeconds / 60 / 2)
            s.sprouts[idx].focusMinutes += partial
            s.totalFocusMinutes += partial
            s.sprouts[idx].droopyUntil = now.addingTimeInterval(60 * 60)
        case .cancelled, .none:
            // No XP, no droop. Just a sigh.
            break
        }
        return s
    }

    private static func updateStreak(
        _ state: GardenState,
        completedAt now: Date,
        calendar: Calendar
    ) -> GardenState {
        var s = state
        let today = calendar.startOfDay(for: now)
        if let last = s.lastFocusDay {
            let lastDay = calendar.startOfDay(for: last)
            if calendar.isDate(lastDay, inSameDayAs: today) {
                // Already counted today.
            } else if let yesterday = calendar.date(byAdding: .day, value: -1, to: today),
                      calendar.isDate(lastDay, inSameDayAs: yesterday) {
                s.streakDays += 1
            } else {
                s.streakDays = 1
            }
        } else {
            s.streakDays = 1
        }
        s.lastFocusDay = today
        return s
    }
}
