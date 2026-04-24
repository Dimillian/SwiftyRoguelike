import SwiftUI

struct TopHUDView: View {
    let game: GameStore

    var body: some View {
        GlassPanel(cornerRadius: 22) {
            HStack(spacing: 12) {
                Label("Dungeon \(String(format: "%02d", game.dungeonLevel))", systemImage: "square.grid.3x3")
                    .font(.headline)

                Spacer()

                CapsuleMetric(title: "Turn", value: "\(game.turn)", tint: .blue)
                CapsuleMetric(title: "HP", value: "\(game.player.hp)", tint: .red)
                CapsuleMetric(title: "MP", value: "\(game.player.mp)", tint: .cyan)
                CapsuleMetric(title: "XP", value: "\(game.player.xp)", tint: .green)
                CapsuleMetric(title: "Seed", value: game.seedLabel, tint: .purple)
            }
        }
    }
}

private struct CapsuleMetric: View {
    let title: String
    let value: String
    let tint: Color

    var body: some View {
        HStack(spacing: 5) {
            Text(title)
                .font(.caption2.weight(.bold))
                .foregroundStyle(.secondary)
            Text(value)
                .font(.caption.monospacedDigit().weight(.semibold))
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(tint.opacity(0.13), in: Capsule())
        .overlay {
            Capsule()
                .strokeBorder(tint.opacity(0.24), lineWidth: 1)
        }
    }
}
