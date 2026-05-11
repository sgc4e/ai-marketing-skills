import SwiftUI
import SproutKit

struct StatsView: View {
    @Environment(AppModel.self) private var model

    var body: some View {
        NavigationStack {
            List {
                Section("Today") {
                    StatRow(label: "Streak", value: "\(model.garden.streakDays) day\(model.garden.streakDays == 1 ? "" : "s")")
                    StatRow(label: "Total focus", value: formatMinutes(model.garden.totalFocusMinutes))
                    StatRow(label: "Sessions", value: "\(model.garden.history.count)")
                }
                Section("Last 7 days") {
                    ForEach(last7Days, id: \.day) { entry in
                        HStack {
                            Text(entry.day)
                            Spacer()
                            Text(formatMinutes(entry.minutes))
                                .foregroundStyle(.secondary)
                                .monospacedDigit()
                        }
                    }
                }
            }
            .navigationTitle("Stats")
        }
    }

    private var last7Days: [(day: String, minutes: Int)] {
        let cal = Calendar.current
        let today = cal.startOfDay(for: Date())
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"
        var result: [(String, Int)] = []
        for offset in (0..<7).reversed() {
            let day = cal.date(byAdding: .day, value: -offset, to: today)!
            let minutes = model.garden.history
                .filter { $0.outcome == .completed && cal.isDate($0.startedAt, inSameDayAs: day) }
                .reduce(0) { $0 + $1.earnedMinutes }
            result.append((formatter.string(from: day), minutes))
        }
        return result
    }

    private func formatMinutes(_ m: Int) -> String {
        if m < 60 { return "\(m) min" }
        let h = m / 60
        let r = m % 60
        return r == 0 ? "\(h)h" : "\(h)h \(r)m"
    }
}

private struct StatRow: View {
    let label: String
    let value: String
    var body: some View {
        HStack {
            Text(label)
            Spacer()
            Text(value).foregroundStyle(.secondary).monospacedDigit()
        }
    }
}
