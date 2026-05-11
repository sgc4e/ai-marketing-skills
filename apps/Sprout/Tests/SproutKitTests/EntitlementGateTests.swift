import XCTest
@testable import SproutKit

final class EntitlementGateTests: XCTestCase {

    func testFreeUserCanHatchUntilCap() {
        var state = GardenState()
        let now = Date()
        XCTAssertTrue(Garden.canHatchMore(in: state, entitlement: .free, at: now))

        state.sprouts = (0..<3).map { i in
            Sprout(speciesID: "mossie", nickname: "S\(i)", hatchedAt: now)
        }
        XCTAssertFalse(Garden.canHatchMore(in: state, entitlement: .free, at: now))
    }

    func testFreeUserBlockedAfterTrialWindow() {
        let firstHatched = Date(timeIntervalSince1970: 1_700_000_000)
        let dayEight = firstHatched.addingTimeInterval(8 * 24 * 60 * 60)
        let state = GardenState(sprouts: [
            Sprout(speciesID: "mossie", nickname: "A", hatchedAt: firstHatched)
        ])
        XCTAssertTrue(Garden.canHatchMore(in: state, entitlement: .free, at: firstHatched))
        XCTAssertFalse(Garden.canHatchMore(in: state, entitlement: .free, at: dayEight))
    }

    func testPaidUserAlwaysCanHatch() {
        let now = Date()
        let state = GardenState(sprouts: (0..<10).map { i in
            Sprout(speciesID: "mossie", nickname: "S\(i)", hatchedAt: now.addingTimeInterval(-100_000_000))
        })
        XCTAssertTrue(Garden.canHatchMore(in: state, entitlement: .paid, at: now))
    }
}
