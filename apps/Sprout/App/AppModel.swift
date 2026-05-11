import Foundation
import Observation
import SwiftUI
import SproutKit

@MainActor
@Observable
final class AppModel {
    var garden: GardenState
    var plannedMinutes: Int = 25
    var activeSproutID: UUID?

    /// Mirrored from `engine` so SwiftUI can observe ticks.
    private(set) var currentSession: FocusSession?
    private(set) var isFocusing: Bool = false

    private let engine: FocusEngine
    private let store: GardenStore
    private let blocker: ScreenTimeBlocker
    private let entitlement: EntitlementStore
    private let trialPolicy: TrialPolicy
    private var tickTask: Task<Void, Never>?

    init(
        store: GardenStore,
        blocker: ScreenTimeBlocker = NoopScreenTimeBlocker(),
        entitlement: EntitlementStore = InMemoryEntitlementStore(),
        trialPolicy: TrialPolicy = .default
    ) {
        self.store = store
        self.blocker = blocker
        self.entitlement = entitlement
        self.trialPolicy = trialPolicy
        self.engine = FocusEngine()
        let loaded = (try? store.load()) ?? GardenState()
        self.garden = loaded
        self.activeSproutID = loaded.sprouts.first?.id
    }

    // MARK: - Garden

    var canHatchMore: Bool {
        Garden.canHatchMore(
            in: garden,
            entitlement: entitlement.current(),
            policy: trialPolicy,
            at: Date()
        )
    }

    @discardableResult
    func hatchSprout(nickname: String) -> Bool {
        guard canHatchMore else { return false }
        let (next, sprout) = Garden.hatch(in: garden, nickname: nickname, at: Date())
        garden = next
        activeSproutID = sprout.id
        persist()
        return true
    }

    var activeSprout: Sprout? {
        guard let id = activeSproutID else { return garden.sprouts.first }
        return garden.sprouts.first { $0.id == id }
    }

    // MARK: - Focus session

    func startFocus() {
        guard let sprout = activeSprout, !isFocusing else { return }
        let seconds = max(60, plannedMinutes * 60)
        do {
            let session = try engine.start(sproutID: sprout.id, plannedSeconds: seconds)
            currentSession = session
            isFocusing = true
            startTicking()
        } catch {
            // already running, ignore
        }
    }

    func cancelFocus() {
        guard let s = try? engine.cancel() else { return }
        applyFinished(s)
    }

    func handleScenePhase(_ phase: ScenePhase) {
        guard isFocusing else { return }
        if phase == .background || phase == .inactive {
            if let s = engine.backgrounded() {
                applyFinished(s)
            }
        }
    }

    private func applyFinished(_ session: FocusSession) {
        garden = Garden.apply(session: session, to: garden, at: Date())
        currentSession = session
        isFocusing = false
        stopTicking()
        persist()
    }

    private func startTicking() {
        stopTicking()
        tickTask = Task { @MainActor [weak self] in
            while !Task.isCancelled {
                try? await Task.sleep(nanoseconds: 500_000_000)
                guard let self else { return }
                guard let s = self.engine.tick() else { continue }
                if s.outcome == .completed {
                    self.applyFinished(s)
                    return
                } else {
                    self.currentSession = s
                }
            }
        }
    }

    private func stopTicking() {
        tickTask?.cancel()
        tickTask = nil
    }

    // MARK: - Persistence

    private func persist() {
        try? store.save(garden)
    }
}
