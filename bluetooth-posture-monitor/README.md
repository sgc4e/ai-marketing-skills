# AirPods Posture Monitor

Real-time posture tracking using your AirPods' built-in motion sensors via macOS `CMHeadphoneMotionManager`.

## How it works

AirPods Pro, AirPods (3rd gen+), and AirPods Max contain accelerometers and gyroscopes used for Spatial Audio head-tracking. This tool reads the **pitch** (forward/back head tilt) and **roll** (left/right tilt) via CoreMotion and uses deviations from your calibrated baseline to detect poor posture.

| Posture state | Condition |
|---|---|
| 🟢 Good | Within ±7° of baseline |
| 🟡 Slight tilt | 7–14° forward |
| 🔴 Hunching | >14° forward for 30+ seconds → alert fires |
| 🔵 Leaning back | >14° backward |
| 🟠 Head tilted | >17° sideways |

## Requirements

- **macOS 12.0+** (Monterey or later)
- **AirPods Pro** (any gen), **AirPods 3rd gen+**, or **AirPods Max**
- AirPods connected via Bluetooth and **worn in your ears** (macOS only streams motion data while worn)
- Xcode Command Line Tools: `xcode-select --install`

## Build & Run

```bash
# Clone the repo and enter the package directory
git clone https://github.com/sgc4e/ai-marketing-skills.git
cd ai-marketing-skills/bluetooth-posture-monitor

# Build (release mode = no debug output, faster)
swift build -c release

# Run
.build/release/posture-monitor
```

Or build-and-run in one step:

```bash
swift run -c release
```

## Usage

1. Connect your AirPods and put them in your ears
2. Run the tool
3. Sit up straight and press **ENTER** to calibrate your baseline posture
4. The tool monitors in real-time and:
   - Shows a live status line in your terminal
   - Fires a **macOS system notification + sound** after 30 seconds of sustained bad posture (max once per minute)
   - Sends a **20-minute check-in reminder** even when posture is fine
5. Press **Ctrl+C** to stop and see your session summary with a posture grade

## Terminal output

```
🟢 GOOD POSTURE        [────────────◉────────]   +0.0° fwd   -1.2° side  [04:32] A+
```

- The bar shows your head's forward tilt relative to baseline; the marker moves right as you hunch
- Grade (A+/B/C/D) updates live based on the fraction of time spent in good posture

## Troubleshooting

**"No AirPods motion data found"**
- Make sure AirPods are in your ears, not just connected
- Try removing and re-inserting them
- Check Bluetooth in System Settings → Bluetooth

**Notifications not appearing**
- System Settings → Notifications → Terminal (or the built app name) → Allow
