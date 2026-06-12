import Foundation
import CoreMotion

// Pitch = head nod (forward tilt when hunching). Roll = left/right head tilt.
// CMHeadphoneMotionManager streams at ~100 Hz from AirPods motion sensors.

@available(macOS 12.0, *)
final class PostureMonitorApp {

    // MARK: - Config

    private let forwardHunchThreshold: Double = 0.25   // ~14° forward = bad posture
    private let slightTiltThreshold: Double   = 0.12   // ~7° forward = warning
    private let sideHeadTiltWarning: Double   = 0.30   // ~17° side tilt
    private let alertCooldown: TimeInterval   = 60.0   // seconds between macOS alerts
    private let checkInInterval: TimeInterval = 20 * 60 // 20-min neutral reminder
    private let displayRefreshHz: Int         = 5       // terminal refresh rate

    // MARK: - State

    private let motionManager = CMHeadphoneMotionManager()
    private var baselinePitch: Double?
    private var baselineRoll: Double?
    private var lastAlertTime: Date          = .distantPast
    private var lastCheckInTime: Date        = Date()
    private var badPostureCount: Int         = 0       // consecutive bad-posture samples
    private var updateCount: Int             = 0
    private var sessionStart: Date           = Date()

    // stats
    private var totalSamples: Int    = 0
    private var goodSamples: Int     = 0
    private var warnSamples: Int     = 0
    private var badSamples: Int      = 0

    // MARK: - Entry

    func run() {
        setupSignalHandler()
        printBanner()

        guard motionManager.isDeviceMotionAvailable else {
            fputs("""

            ❌  No AirPods motion data found.

                Checklist:
                • Connect AirPods Pro, AirPods (3rd gen+), or AirPods Max via Bluetooth
                • Put them in your ears — macOS only streams data while worn
                • macOS 12.0+ required (you have \(ProcessInfo.processInfo.operatingSystemVersionString))

            """, stderr)
            exit(1)
        }

        print("\n✅  AirPods motion sensors detected!")
        calibrate()
    }

    // MARK: - Calibration

    private func calibrate() {
        print("""

        📐  CALIBRATION
            Sit upright with good posture — the way you'd want to sit all day.
            Look straight ahead at your screen.

            Press ENTER when ready…
        """)

        _ = readLine()

        // Capture a short window of samples and average them for a stable baseline
        print("   Capturing baseline… hold still for 3 seconds")

        var pitchSamples: [Double] = []
        var rollSamples:  [Double] = []
        let captureEnd = Date().addingTimeInterval(3)

        motionManager.startDeviceMotionUpdates(to: .main) { [weak self] motion, error in
            guard let self = self, let motion = motion else { return }

            if Date() < captureEnd {
                pitchSamples.append(motion.attitude.pitch)
                rollSamples.append(motion.attitude.roll)
            } else if self.baselinePitch == nil {
                self.motionManager.stopDeviceMotionUpdates()
                self.baselinePitch = pitchSamples.reduce(0, +) / Double(max(pitchSamples.count, 1))
                self.baselineRoll  = rollSamples.reduce(0, +)  / Double(max(rollSamples.count, 1))
                self.startMonitoring()
            }
        }

        RunLoop.main.run()
    }

    // MARK: - Monitoring

    private func startMonitoring() {
        print("""

        ✅  Baseline locked!
            Pitch: \(String(format: "%.3f", baselinePitch!)) rad   Roll: \(String(format: "%.3f", baselineRoll!)) rad

        🔍  Monitoring posture — Ctrl+C to stop and see summary
        """)
        print(String(repeating: "─", count: 62))

        sessionStart = Date()
        lastCheckInTime = Date()

        motionManager.startDeviceMotionUpdates(to: .main) { [weak self] motion, error in
            guard let self = self else { return }

            if let error = error {
                fputs("\n⚠️  Motion error: \(error.localizedDescription)\n", stderr)
                return
            }
            guard let motion = motion else { return }

            self.updateCount += 1
            self.totalSamples += 1

            // Display at ~displayRefreshHz (motion arrives at ~100 Hz)
            let skip = max(1, 100 / self.displayRefreshHz)
            if self.updateCount % skip == 0 {
                self.tick(motion: motion)
            }
        }
    }

    // MARK: - Per-frame analysis

    private func tick(motion: CMDeviceMotion) {
        guard let baseline = baselinePitch else { return }

        let pitch = motion.attitude.pitch - baseline
        let roll  = motion.attitude.roll  - (baselineRoll ?? 0)
        let status = classify(pitch: pitch, roll: roll)

        switch status.level {
        case .good:    goodSamples += 1
        case .slight:  warnSamples += 1
        case .bad:     badSamples  += 1
        }

        renderStatusLine(pitch: pitch, roll: roll, status: status)

        // Bad-posture alert (only fires after sustained slouching)
        if status.level == .bad {
            badPostureCount += 1
        } else {
            badPostureCount = max(0, badPostureCount - 2)
        }

        let now = Date()
        let sustainedBad = badPostureCount >= (displayRefreshHz * 30) // 30 s
        let canAlert     = now.timeIntervalSince(lastAlertTime) > alertCooldown

        if sustainedBad && canAlert {
            sendAlert(title: "Posture Alert 🪑",
                      body: "\(status.emoji) \(status.label) — Head tilted \(String(format: "%.0f", abs(pitch) * 180 / .pi))° forward. Sit up straight!")
            lastAlertTime = now
            badPostureCount = 0
        }

        // Periodic 20-min check-in (even when posture is fine)
        if now.timeIntervalSince(lastCheckInTime) >= checkInInterval {
            sendAlert(title: "Posture Check-in 🕐",
                      body: "20-minute reminder: how's your posture? \(scoreEmoji())")
            lastCheckInTime = now
        }
    }

    // MARK: - Classification

    enum PostureLevel { case good, slight, bad }

    struct PostureStatus {
        let level: PostureLevel
        let emoji: String
        let label: String
    }

    private func classify(pitch: Double, roll: Double) -> PostureStatus {
        if pitch > forwardHunchThreshold {
            return PostureStatus(level: .bad,    emoji: "🔴", label: "HUNCHING FORWARD")
        } else if pitch > slightTiltThreshold {
            return PostureStatus(level: .slight,  emoji: "🟡", label: "SLIGHT FORWARD TILT")
        } else if pitch < -forwardHunchThreshold {
            return PostureStatus(level: .slight,  emoji: "🔵", label: "HEAD BACK / LEANING")
        } else if abs(roll) > sideHeadTiltWarning {
            return PostureStatus(level: .slight,  emoji: "🟠", label: "HEAD TILTED SIDEWAYS")
        } else {
            return PostureStatus(level: .good,    emoji: "🟢", label: "GOOD POSTURE")
        }
    }

    // MARK: - Rendering

    private func renderStatusLine(pitch: Double, roll: Double, status: PostureStatus) {
        let pitchDeg = pitch * 180 / .pi
        let rollDeg  = roll  * 180 / .pi
        let bar = postureBar(pitch: pitch)
        let elapsed = formatElapsed(Date().timeIntervalSince(sessionStart))
        let score   = scoreEmoji()

        // \r rewrites same terminal line
        let line = "\r\(status.emoji) \(status.label.padding(toLength: 21, withPad: " ", startingAt: 0)) \(bar)  \(String(format: "%+5.1f°", pitchDeg)) fwd  \(String(format: "%+5.1f°", rollDeg)) side  [\(elapsed)] \(score)"
        print(line, terminator: "")
        fflush(stdout)
    }

    private func postureBar(pitch: Double) -> String {
        let width = 20
        let center = width / 2
        // Clamp ±0.5 rad → full bar width
        let offset = Int((pitch / 0.5) * Double(center))
        let pos    = max(0, min(width - 1, center + offset))

        var chars  = [Character](repeating: "─", count: width)
        chars[center] = "┼"
        chars[pos]    = pos == center ? "◉" : "●"
        return "[" + String(chars) + "]"
    }

    private func scoreEmoji() -> String {
        guard totalSamples > 0 else { return "─" }
        let pct = Double(goodSamples) / Double(totalSamples)
        switch pct {
        case 0.85...: return "A+"
        case 0.70...: return "B "
        case 0.55...: return "C "
        default:      return "D "
        }
    }

    private func formatElapsed(_ s: TimeInterval) -> String {
        let m = Int(s) / 60
        let sec = Int(s) % 60
        return String(format: "%02d:%02d", m, sec)
    }

    // MARK: - Notifications

    private func sendAlert(title: String, body: String) {
        // Print a visible break in the terminal
        print("\n")
        print("┌─────────────────────────────────────────────┐")
        print("│ \(title.padding(toLength: 43, withPad: " ", startingAt: 0)) │")
        print("│ \(body.prefix(43).padding(toLength: 43, withPad: " ", startingAt: 0)) │")
        print("└─────────────────────────────────────────────┘")
        print(String(repeating: "─", count: 62))

        // macOS system notification via osascript (no entitlement needed for CLI tools)
        let safeTitle = title.replacingOccurrences(of: "\"", with: "'")
        let safeBody  = body.replacingOccurrences(of: "\"", with: "'")
        let script    = "display notification \"\(safeBody)\" with title \"\(safeTitle)\" sound name \"Funk\""

        let proc = Process()
        proc.launchPath = "/usr/bin/osascript"
        proc.arguments  = ["-e", script]
        proc.standardOutput = FileHandle.nullDevice
        proc.standardError  = FileHandle.nullDevice
        try? proc.run()

        // Terminal bell
        print("\a", terminator: "")
        fflush(stdout)
    }

    // MARK: - Session summary

    private func printSummary() {
        let elapsed = Date().timeIntervalSince(sessionStart)
        let total   = max(totalSamples, 1)
        let goodPct = Int(Double(goodSamples) / Double(total) * 100)
        let warnPct = Int(Double(warnSamples) / Double(total) * 100)
        let badPct  = Int(Double(badSamples)  / Double(total) * 100)

        print("""


        ╔════════════════════════════════════════╗
        ║           SESSION SUMMARY              ║
        ╠════════════════════════════════════════╣
        ║  Duration : \(formatElapsed(elapsed).padding(toLength: 26, withPad: " ", startingAt: 0))║
        ║  Grade    : \(scoreEmoji().padding(toLength: 26, withPad: " ", startingAt: 0))║
        ║                                        ║
        ║  🟢 Good posture   : \(("\(goodPct)%").padding(toLength: 17, withPad: " ", startingAt: 0))║
        ║  🟡 Slight tilt    : \(("\(warnPct)%").padding(toLength: 17, withPad: " ", startingAt: 0))║
        ║  🔴 Hunching/bad   : \(("\(badPct)%").padding(toLength: 17, withPad: " ", startingAt: 0))║
        ╚════════════════════════════════════════╝
        """)

        if badPct > 30 {
            print("  Tip: You were hunching frequently. Try raising your monitor or")
            print("  using a chair with better lumbar support.\n")
        } else if goodPct > 85 {
            print("  Great work! Excellent posture today. 🏆\n")
        } else {
            print("  Tip: Short standing breaks every 30 minutes help reduce forward head posture.\n")
        }
    }

    // MARK: - Signals

    private func setupSignalHandler() {
        let source = DispatchSource.makeSignalSource(signal: SIGINT, queue: .main)
        signal(SIGINT, SIG_IGN)
        source.setEventHandler { [weak self] in
            self?.motionManager.stopDeviceMotionUpdates()
            self?.printSummary()
            exit(0)
        }
        source.resume()
    }

    // MARK: - Banner

    private func printBanner() {
        print("""
        ╔══════════════════════════════════════════════╗
        ║      🎧  AirPods Posture Monitor  🪑         ║
        ║   Real-time head-motion posture tracking     ║
        ║   Requires: AirPods Pro / AirPods 3+  ║
        ╚══════════════════════════════════════════════╝
        """)
    }
}
