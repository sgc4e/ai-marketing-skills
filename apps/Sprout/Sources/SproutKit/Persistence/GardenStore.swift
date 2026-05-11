import Foundation

public protocol GardenStore: Sendable {
    func load() throws -> GardenState
    func save(_ state: GardenState) throws
}

public final class InMemoryGardenStore: GardenStore, @unchecked Sendable {
    private let lock = NSLock()
    private var state: GardenState

    public init(_ initial: GardenState = GardenState()) {
        self.state = initial
    }

    public func load() throws -> GardenState {
        lock.lock(); defer { lock.unlock() }
        return state
    }

    public func save(_ state: GardenState) throws {
        lock.lock(); defer { lock.unlock() }
        self.state = state
    }
}

public final class FileGardenStore: GardenStore, @unchecked Sendable {
    private let url: URL
    private let encoder: JSONEncoder
    private let decoder: JSONDecoder

    public init(url: URL) {
        self.url = url
        self.encoder = JSONEncoder()
        self.encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        self.encoder.dateEncodingStrategy = .iso8601
        self.decoder = JSONDecoder()
        self.decoder.dateDecodingStrategy = .iso8601
    }

    public func load() throws -> GardenState {
        guard FileManager.default.fileExists(atPath: url.path) else {
            return GardenState()
        }
        let data = try Data(contentsOf: url)
        return try decoder.decode(GardenState.self, from: data)
    }

    public func save(_ state: GardenState) throws {
        let data = try encoder.encode(state)
        try FileManager.default.createDirectory(
            at: url.deletingLastPathComponent(),
            withIntermediateDirectories: true
        )
        try data.write(to: url, options: .atomic)
    }

    public static func defaultURL() -> URL {
        let base = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first
            ?? FileManager.default.temporaryDirectory
        return base.appendingPathComponent("Sprout/garden.json")
    }
}
