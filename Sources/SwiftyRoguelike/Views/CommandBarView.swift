import SwiftUI

struct CommandBarView: View {
    let game: GameStore

    var body: some View {
        GlassPanel(cornerRadius: 22) {
            HStack(spacing: 10) {
                CompactDirectionButton(direction: .west, key: "A", game: game)
                CompactDirectionButton(direction: .north, key: "W", game: game)
                CompactDirectionButton(direction: .south, key: "S", game: game)
                CompactDirectionButton(direction: .east, key: "D", game: game)

                Divider()
                    .frame(height: 28)
                    .padding(.horizontal, 2)

                ActionButton(title: "Wait", systemImage: "hourglass", tint: .secondary, key: ".") {
                    game.perform(.wait)
                }
                .keyboardShortcut(".", modifiers: [])

                ActionButton(title: "Rest", systemImage: "bed.double", tint: .green, key: "R") {
                    game.perform(.rest)
                }
                .keyboardShortcut("r", modifiers: [])

                ActionButton(title: "Potion", systemImage: "cross.vial", tint: .red, key: "P") {
                    game.perform(.usePotion)
                }
                .keyboardShortcut("p", modifiers: [])

                ActionButton(title: "Descend", systemImage: "arrow.down.to.line.compact", tint: .purple, key: ">") {
                    game.perform(.descend)
                }
                .disabled(game.map[game.player.position] != .stairs)

                Spacer()

                Text(game.isGameOver ? "Run ended" : "WASD or arrows move. Bump enemies to attack.")
                    .font(.caption)
                    .foregroundStyle(game.isGameOver ? .red : .secondary)
            }
        }
    }
}

private struct CompactDirectionButton: View {
    let direction: Direction
    let key: String
    let game: GameStore

    var body: some View {
        Button {
            game.perform(.move(direction))
        } label: {
            HStack(spacing: 6) {
                Image(systemName: direction.symbol)
                Text(key)
                    .font(.caption2.monospaced().weight(.bold))
                    .foregroundStyle(.secondary)
            }
            .frame(width: 50, height: 30)
        }
        .buttonStyle(.bordered)
        .buttonBorderShape(.roundedRectangle(radius: 12))
        .controlSize(.small)
        .help("Move \(direction.title)")
    }
}

private struct ActionButton: View {
    let title: String
    let systemImage: String
    let tint: Color
    let key: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 7) {
                Image(systemName: systemImage)
                Text(key)
                    .font(.caption2.monospaced().weight(.bold))
            }
            .frame(width: 54, height: 30)
        }
        .buttonStyle(.bordered)
        .tint(tint)
        .buttonBorderShape(.roundedRectangle(radius: 12))
        .controlSize(.small)
        .help(title)
    }
}
