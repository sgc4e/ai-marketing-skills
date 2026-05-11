import XCTest
@testable import SproutKit

final class FocusEngineTests: XCTestCase {

    func testCompletesAfterPlannedDuration() throws {
        let clock = TestClock()
        let engine = FocusEngine(clock: clock, abandonGraceSeconds: 5)
        let sproutID = UUID()

        _ = try engine.start(sproutID: sproutID, plannedSeconds: 60)
        clock.advance(by: 30)
        let mid = engine.tick()
        XCTAssertEqual(mid?.elapsedSeconds, 30)
        XCTAssertEqual(mid?.outcome, nil)

        clock.advance(by: 31)
        let done = engine.tick()
        XCTAssertEqual(done?.outcome, .completed)
        XCTAssertEqual(done?.elapsedSeconds, 60)

        if case .finished = engine.state {} else {
            XCTFail("Expected finished state, got \(engine.state)")
        }
    }

    func testBackgroundingBeforeEndMarksAbandoned() throws {
        let clock = TestClock()
        let engine = FocusEngine(clock: clock, abandonGraceSeconds: 5)
        _ = try engine.start(sproutID: UUID(), plannedSeconds: 60)
        clock.advance(by: 20)
        let s = engine.backgrounded()
        XCTAssertEqual(s?.outcome, .abandoned)
        XCTAssertEqual(s?.elapsedSeconds, 20)
    }

    func testBackgroundingInGraceCountsAsCompleted() throws {
        let clock = TestClock()
        let engine = FocusEngine(clock: clock, abandonGraceSeconds: 5)
        _ = try engine.start(sproutID: UUID(), plannedSeconds: 60)
        clock.advance(by: 57) // within 5s grace
        let s = engine.backgrounded()
        XCTAssertEqual(s?.outcome, .completed)
        XCTAssertEqual(s?.elapsedSeconds, 60)
    }

    func testCancelMarksCancelled() throws {
        let clock = TestClock()
        let engine = FocusEngine(clock: clock)
        _ = try engine.start(sproutID: UUID(), plannedSeconds: 60)
        clock.advance(by: 10)
        let s = try engine.cancel()
        XCTAssertEqual(s.outcome, .cancelled)
        XCTAssertEqual(s.earnedMinutes, 0)
    }

    func testCannotStartTwice() throws {
        let engine = FocusEngine(clock: TestClock())
        _ = try engine.start(sproutID: UUID(), plannedSeconds: 60)
        XCTAssertThrowsError(try engine.start(sproutID: UUID(), plannedSeconds: 60))
    }
}
