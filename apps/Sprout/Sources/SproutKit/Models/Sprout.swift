import Foundation

public enum GrowthStage: Int, Codable, Sendable, CaseIterable {
    case seed = 0
    case sprout = 1
    case bloom = 2
    case elder = 3

    public var label: String {
        switch self {
        case .seed: return "Seed"
        case .sprout: return "Sprout"
        case .bloom: return "Bloom"
        case .elder: return "Elder"
        }
    }

    /// Minutes of cumulative focus required to reach this stage.
    public var thresholdMinutes: Int {
        switch self {
        case .seed: return 0
        case .sprout: return 25
        case .bloom: return 120
        case .elder: return 600
        }
    }

    public static func stage(forMinutes minutes: Int) -> GrowthStage {
        allCases.reversed().first { minutes >= $0.thresholdMinutes } ?? .seed
    }
}

public enum Mood: String, Codable, Sendable {
    case happy
    case content
    case droopy
}

public struct Sprout: Identifiable, Codable, Sendable, Equatable {
    public let id: UUID
    public let speciesID: String
    public let nickname: String
    public let hatchedAt: Date
    public var focusMinutes: Int
    public var droopyUntil: Date?

    public init(
        id: UUID = UUID(),
        speciesID: String,
        nickname: String,
        hatchedAt: Date = Date(),
        focusMinutes: Int = 0,
        droopyUntil: Date? = nil
    ) {
        self.id = id
        self.speciesID = speciesID
        self.nickname = nickname
        self.hatchedAt = hatchedAt
        self.focusMinutes = focusMinutes
        self.droopyUntil = droopyUntil
    }

    public var stage: GrowthStage {
        GrowthStage.stage(forMinutes: focusMinutes)
    }

    public func mood(at now: Date) -> Mood {
        if let until = droopyUntil, now < until {
            return .droopy
        }
        return focusMinutes >= GrowthStage.bloom.thresholdMinutes ? .happy : .content
    }

    public var species: Species {
        SpeciesCatalog.by(id: speciesID) ?? SpeciesCatalog.all[0]
    }
}
