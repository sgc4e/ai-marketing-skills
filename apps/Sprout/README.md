# Sprout

A small iOS app that helps you reduce screen time by growing little creatures
that thrive on focused minutes. Endearing, not punishing: abandon a session and
your Sprout droops for an hour, but it doesn't die.

## Status

MVP scaffold — soft enforcement (in-app detection) ships first; Screen Time API
integration (FamilyControls / ManagedSettings / DeviceActivity) is stubbed
behind the `ScreenTimeBlocker` protocol and will land in a later milestone.

## Layout

```
apps/Sprout
├── Package.swift                  # SproutKit Swift Package
├── Sources/SproutKit/             # Pure-Foundation core, fully testable
│   ├── Models/                    # Sprout, Species, FocusSession
│   ├── Engine/                    # FocusEngine state machine + Garden rules
│   ├── Persistence/               # GardenStore protocol + JSON file store
│   └── Blocker/                   # ScreenTimeBlocker protocol (noop for now)
├── Tests/SproutKitTests/          # XCTest suites
└── App/                           # SwiftUI app target
    ├── SproutApp.swift
    ├── AppModel.swift
    └── Views/
```

## Build & test the core

From `apps/Sprout/`:

```sh
swift build
swift test
```

This works on macOS or Linux with a Swift 5.9+ toolchain — no Xcode required.

## Run the app

There's no `.xcodeproj` checked in (they're noisy and rarely round-trip well).
To run on a device or simulator:

1. Open Xcode → **File → New → Project… → iOS App**.
   - Product Name: `Sprout`
   - Interface: SwiftUI
   - Language: Swift
   - Storage: None
2. Save the project anywhere outside this repo (or at `apps/Sprout/Sprout.xcodeproj`
   if you want it co-located).
3. Delete the auto-generated `ContentView.swift` and `<Name>App.swift`.
4. **Add the package**: File → Add Package Dependencies → Add Local… → pick
   `apps/Sprout`. Add `SproutKit` to the app target.
5. **Add the app sources**: drag every file under `apps/Sprout/App/` into the
   Xcode target (uncheck "Copy items if needed" — keep them in place).
6. Set the deployment target to **iOS 17.0** (uses `@Observable` and the
   modern `onChange` signature).
7. Build & run.

## Design notes

- **Mechanic**: each Sprout has a species, a nickname, and cumulative focus
  minutes. Stages: Seed → Sprout → Bloom → Elder, at 0 / 25 / 120 / 600 minutes.
- **Outcomes**: a completed session grants `plannedMinutes` of XP. Backgrounding
  the app mid-session is abandonment: half-credit for elapsed minutes and the
  Sprout droops for an hour. Cancelling (via the "Give up" button) grants
  nothing but doesn't droop — explicit choices aren't punished.
- **Grace period**: backgrounding within 5 seconds of the timer end counts as
  completion (so the haptic finish doesn't have to fight iOS's notification
  shade).
- **Streaks**: rolled forward on completed sessions; reset after a one-day gap.

## Extending: Screen Time enforcement

`ScreenTimeBlocker` is the seam. When the FamilyControls entitlement is
available:

1. Add `FamilyControls.framework`, `ManagedSettings.framework`,
   `DeviceActivity.framework` to the app target.
2. Implement a `FamilyControlsBlocker: ScreenTimeBlocker` that calls
   `AuthorizationCenter.shared.requestAuthorization(for: .individual)` in
   `requestAuthorization()` and applies a `ManagedSettingsStore` shield in
   `startBlocking(durationSeconds:)`.
3. Inject it into `AppModel` instead of `NoopScreenTimeBlocker`.
4. Add a UI for picking apps via `FamilyActivityPicker`.
