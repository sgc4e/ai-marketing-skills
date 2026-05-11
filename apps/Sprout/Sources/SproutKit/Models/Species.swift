import Foundation

public struct Species: Hashable, Codable, Sendable, Identifiable {
    public let id: String
    public let name: String
    public let emoji: String
    public let accentHex: String
    public let blurb: String

    public init(id: String, name: String, emoji: String, accentHex: String, blurb: String) {
        self.id = id
        self.name = name
        self.emoji = emoji
        self.accentHex = accentHex
        self.blurb = blurb
    }
}

public enum SpeciesCatalog {
    public static let all: [Species] = [
        Species(id: "mossie", name: "Mossie",
                emoji: "🌱", accentHex: "#7CB342",
                blurb: "A shy moss-pup. Loves quiet mornings."),
        Species(id: "pip", name: "Pip",
                emoji: "🍄", accentHex: "#E57373",
                blurb: "A wobbly mushroom. Believes in you."),
        Species(id: "fern", name: "Fern",
                emoji: "🌿", accentHex: "#43A047",
                blurb: "Stretches a little taller each day."),
        Species(id: "lumen", name: "Lumen",
                emoji: "✨", accentHex: "#FFD54F",
                blurb: "A spark that hums when you focus."),
        Species(id: "bramble", name: "Bramble",
                emoji: "🌾", accentHex: "#A1887F",
                blurb: "Scruffy. Loyal. A little stubborn.")
    ]

    public static func random(excluding owned: Set<String> = []) -> Species {
        let pool = all.filter { !owned.contains($0.id) }
        return (pool.isEmpty ? all : pool).randomElement()!
    }

    public static func by(id: String) -> Species? {
        all.first { $0.id == id }
    }
}
