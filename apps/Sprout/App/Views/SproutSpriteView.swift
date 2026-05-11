import SwiftUI
import SproutKit

struct SproutSpriteView: View {
    let sprout: Sprout
    var size: CGFloat = 140
    var animate: Bool = true

    @State private var breathe = false

    private var mood: Mood { sprout.mood(at: Date()) }

    var body: some View {
        ZStack {
            Circle()
                .fill(
                    RadialGradient(
                        colors: [accent.opacity(0.35), accent.opacity(0.05)],
                        center: .center,
                        startRadius: 0,
                        endRadius: size / 1.6
                    )
                )

            Text(sprout.species.emoji)
                .font(.system(size: size * 0.55))
                .scaleEffect(scale)
                .rotationEffect(.degrees(mood == .droopy ? 12 : 0))
                .scaleEffect(y: breathe ? 1.04 : 0.96, anchor: .bottom)
                .animation(
                    animate
                        ? .easeInOut(duration: mood == .droopy ? 2.2 : 1.6).repeatForever(autoreverses: true)
                        : .default,
                    value: breathe
                )
                .onAppear { breathe = animate }

            // Mood overlay
            if mood == .droopy {
                Text("💧")
                    .font(.system(size: size * 0.16))
                    .offset(x: size * 0.18, y: -size * 0.08)
            } else if mood == .happy {
                Text("✨")
                    .font(.system(size: size * 0.18))
                    .offset(x: -size * 0.22, y: -size * 0.22)
            }
        }
        .frame(width: size, height: size)
    }

    private var accent: Color {
        Color(hex: sprout.species.accentHex) ?? .green
    }

    private var scale: CGFloat {
        switch sprout.stage {
        case .seed: return 0.6
        case .sprout: return 0.8
        case .bloom: return 1.0
        case .elder: return 1.15
        }
    }
}

extension Color {
    init?(hex: String) {
        var s = hex
        if s.hasPrefix("#") { s.removeFirst() }
        guard s.count == 6, let value = UInt32(s, radix: 16) else { return nil }
        let r = Double((value >> 16) & 0xFF) / 255
        let g = Double((value >> 8) & 0xFF) / 255
        let b = Double(value & 0xFF) / 255
        self = Color(red: r, green: g, blue: b)
    }
}
