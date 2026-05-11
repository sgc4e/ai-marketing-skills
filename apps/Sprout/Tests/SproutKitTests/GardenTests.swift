import XCTest
@testable import SproutKit

final class GardenTests: XCTestCase {

    func testHatchAddsSprout() {
        let (state, sprout) = Garden.hatch(in: GardenState(), nickname: "Pim", at: Date())
        XCTAssertEqual(state.sprouts.count, 1)
        XCTAssertEqual(sprout.nickname, "Pim")
        XCTAssertEqual(sprout.stage, .seed)
    }

    func testCompletedSessionGrantsFullXP() {
        var state = GardenState()
        let species = SpeciesCatalog.all[0]
        let hatched = Garden.hatch(in: state, nickname: "A", at: Date(), species: species)
        state = hatched.0
        let id = hatched.1.id

        let session = FocusSession(
            sproutID: id,
            startedAt: Date(),
            plannedSeconds: 25 * 60,
            endedAt: Date(),
            elapsedSeconds: 25 * 60,
            outcome: .completed
        )
        state = Garden.apply(session: session, to: state, at: Date())
        XCTAssertEqual(state.sprouts[0].focusMinutes, 25)
        XCTAssertEqual(state.sprouts[0].stage, .sprout)
        XCTAssertEqual(state.totalFocusMinutes, 25)
        XCTAssertEqual(state.streakDays, 1)
    }

    func testAbandonedSessionGrantsHalfAndDroops() {
        var state = GardenState()
        let hatched = Garden.hatch(in: state, nickname: "B", at: Date())
        state = hatched.0
        let id = hatched.1.id
        let now = Date()
        let session = FocusSession(
            sproutID: id,
            startedAt: now,
            plannedSeconds: 25 * 60,
            endedAt: now.addingTimeInterval(600),
            elapsedSeconds: 600,
            outcome: .abandoned
        )
        state = Garden.apply(session: session, to: state, at: now)
        XCTAssertEqual(state.sprouts[0].focusMinutes, 5) // 10min elapsed / 2
        XCTAssertEqual(state.sprouts[0].mood(at: now), .droopy)
        XCTAssertEqual(state.streakDays, 0)
    }

    func testCancelledSessionGrantsNothingNoDroop() {
        var state = GardenState()
        let hatched = Garden.hatch(in: state, nickname: "C", at: Date())
        state = hatched.0
        let id = hatched.1.id
        let now = Date()
        let session = FocusSession(
            sproutID: id,
            startedAt: now,
            plannedSeconds: 25 * 60,
            elapsedSeconds: 120,
            outcome: .cancelled
        )
        state = Garden.apply(session: session, to: state, at: now)
        XCTAssertEqual(state.sprouts[0].focusMinutes, 0)
        XCTAssertNil(state.sprouts[0].droopyUntil)
    }

    func testStreakContinuesNextDay() {
        let cal = Calendar(identifier: .gregorian)
        let day1 = Date(timeIntervalSince1970: 1_700_000_000)
        let day2 = cal.date(byAdding: .day, value: 1, to: day1)!

        var state = GardenState()
        let h = Garden.hatch(in: state, nickname: "S", at: day1)
        state = h.0
        let id = h.1.id

        let s1 = FocusSession(sproutID: id, startedAt: day1, plannedSeconds: 60,
                              endedAt: day1, elapsedSeconds: 60, outcome: .completed)
        state = Garden.apply(session: s1, to: state, at: day1, calendar: cal)

        let s2 = FocusSession(sproutID: id, startedAt: day2, plannedSeconds: 60,
                              endedAt: day2, elapsedSeconds: 60, outcome: .completed)
        state = Garden.apply(session: s2, to: state, at: day2, calendar: cal)

        XCTAssertEqual(state.streakDays, 2)
    }

    func testStreakResetsAfterGap() {
        let cal = Calendar(identifier: .gregorian)
        let day1 = Date(timeIntervalSince1970: 1_700_000_000)
        let day3 = cal.date(byAdding: .day, value: 2, to: day1)!

        var state = GardenState()
        let h = Garden.hatch(in: state, nickname: "S", at: day1)
        state = h.0
        let id = h.1.id

        let s1 = FocusSession(sproutID: id, startedAt: day1, plannedSeconds: 60,
                              endedAt: day1, elapsedSeconds: 60, outcome: .completed)
        state = Garden.apply(session: s1, to: state, at: day1, calendar: cal)

        let s2 = FocusSession(sproutID: id, startedAt: day3, plannedSeconds: 60,
                              endedAt: day3, elapsedSeconds: 60, outcome: .completed)
        state = Garden.apply(session: s2, to: state, at: day3, calendar: cal)

        XCTAssertEqual(state.streakDays, 1)
    }

    func testGrowthStageThresholds() {
        XCTAssertEqual(GrowthStage.stage(forMinutes: 0), .seed)
        XCTAssertEqual(GrowthStage.stage(forMinutes: 24), .seed)
        XCTAssertEqual(GrowthStage.stage(forMinutes: 25), .sprout)
        XCTAssertEqual(GrowthStage.stage(forMinutes: 119), .sprout)
        XCTAssertEqual(GrowthStage.stage(forMinutes: 120), .bloom)
        XCTAssertEqual(GrowthStage.stage(forMinutes: 600), .elder)
    }
}
