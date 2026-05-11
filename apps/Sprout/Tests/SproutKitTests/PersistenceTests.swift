import XCTest
@testable import SproutKit

final class PersistenceTests: XCTestCase {

    func testFileStoreRoundTrip() throws {
        let tmp = FileManager.default.temporaryDirectory
            .appendingPathComponent("sprout-test-\(UUID()).json")
        defer { try? FileManager.default.removeItem(at: tmp) }

        let store = FileGardenStore(url: tmp)
        let empty = try store.load()
        XCTAssertEqual(empty.sprouts.count, 0)

        let (state, _) = Garden.hatch(in: empty, nickname: "Pim", at: Date())
        try store.save(state)

        let loaded = try store.load()
        XCTAssertEqual(loaded.sprouts.count, 1)
        XCTAssertEqual(loaded.sprouts[0].nickname, "Pim")
    }
}
