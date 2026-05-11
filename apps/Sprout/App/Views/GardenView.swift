import SwiftUI
import SproutKit

struct GardenView: View {
    @Environment(AppModel.self) private var model
    @State private var showHatchSheet = false
    @State private var newNickname = ""

    private let columns = [GridItem(.adaptive(minimum: 130), spacing: 16)]

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 16) {
                    ForEach(model.garden.sprouts) { sprout in
                        SproutCard(sprout: sprout, isActive: sprout.id == model.activeSproutID)
                            .onTapGesture { model.activeSproutID = sprout.id }
                    }
                }
                .padding()
            }
            .navigationTitle("Garden")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        newNickname = ""
                        showHatchSheet = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showHatchSheet) {
                HatchSheet(nickname: $newNickname) {
                    model.hatchSprout(nickname: newNickname)
                    showHatchSheet = false
                }
                .presentationDetents([.medium])
            }
        }
    }
}

private struct SproutCard: View {
    let sprout: Sprout
    let isActive: Bool

    var body: some View {
        VStack(spacing: 8) {
            SproutSpriteView(sprout: sprout, size: 96, animate: false)
            Text(sprout.nickname)
                .font(.headline)
                .lineLimit(1)
            Text("\(sprout.focusMinutes) min · \(sprout.stage.label)")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(isActive ? Color.accentColor.opacity(0.12) : Color(.secondarySystemBackground))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(isActive ? Color.accentColor : Color.clear, lineWidth: 2)
        )
    }
}

private struct HatchSheet: View {
    @Binding var nickname: String
    var onHatch: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            Text("🥚")
                .font(.system(size: 80))
                .padding(.top, 24)
            Text("Name your new Sprout")
                .font(.headline)
            TextField("Nickname", text: $nickname)
                .textFieldStyle(.roundedBorder)
                .padding(.horizontal, 32)
            Button(action: onHatch) {
                Text("Hatch")
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
            }
            .buttonStyle(.borderedProminent)
            .padding(.horizontal, 32)
            .disabled(nickname.trimmingCharacters(in: .whitespaces).isEmpty)
            Spacer()
        }
    }
}
