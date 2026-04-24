import SwiftUI

struct InspectorView: View {
    let game: GameStore

    var body: some View {
        VStack(spacing: 14) {
            GlassPanel {
                VStack(alignment: .leading, spacing: 12) {
                    SectionHeader(title: "Inventory", systemImage: "backpack")
                    ForEach(game.inventory) { item in
                        HStack(alignment: .top, spacing: 10) {
                            Image(systemName: "diamond")
                                .font(.caption)
                                .foregroundStyle(.cyan)
                            VStack(alignment: .leading, spacing: 2) {
                                Text(item.name)
                                    .font(.callout.weight(.medium))
                                Text(item.detail)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            Spacer()
                        }
                    }
                }
            }

            GlassPanel {
                VStack(alignment: .leading, spacing: 12) {
                    SectionHeader(title: "Loot", systemImage: "sparkle.magnifyingglass")
                    if nearbyLoot.isEmpty {
                        EmptyStateRow(text: "No loot in the immediate room.")
                    } else {
                        ForEach(nearbyLoot) { loot in
                            HStack {
                                Text(loot.kind.glyph)
                                    .font(.system(.body, design: .monospaced))
                                    .foregroundStyle(loot.kind.color)
                                Text(loot.kind.name)
                                Spacer()
                                Text(distance(to: loot.position))
                                    .font(.caption.monospacedDigit())
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                }
            }

            GlassPanel {
                VStack(alignment: .leading, spacing: 12) {
                    SectionHeader(title: "Combat Log", systemImage: "text.bubble")
                    ForEach(game.log) { entry in
                        HStack(alignment: .top, spacing: 8) {
                            Text("\(entry.turn)")
                                .font(.caption2.monospacedDigit())
                                .foregroundStyle(.secondary)
                                .frame(width: 26, alignment: .trailing)
                            Text(entry.message)
                                .font(.caption)
                                .foregroundStyle(color(for: entry.level))
                                .lineLimit(2)
                            Spacer(minLength: 0)
                        }
                    }
                }
            }

            Spacer(minLength: 0)
        }
    }

    private var nearbyLoot: [Loot] {
        game.loot
            .sorted { manhattan($0.position, game.player.position) < manhattan($1.position, game.player.position) }
            .prefix(5)
            .map { $0 }
    }

    private func distance(to point: GridPoint) -> String {
        "\(manhattan(point, game.player.position))t"
    }

    private func manhattan(_ lhs: GridPoint, _ rhs: GridPoint) -> Int {
        abs(lhs.x - rhs.x) + abs(lhs.y - rhs.y)
    }

    private func color(for level: LogLevel) -> Color {
        switch level {
        case .info: .secondary
        case .combat: .orange
        case .loot: .green
        case .danger: .red
        }
    }
}

private struct EmptyStateRow: View {
    let text: String

    var body: some View {
        Text(text)
            .font(.caption)
            .foregroundStyle(.secondary)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.vertical, 4)
    }
}
