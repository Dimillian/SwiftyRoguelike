import SwiftUI

struct SidebarView: View {
    let game: GameStore

    var body: some View {
        VStack(spacing: 14) {
            GlassPanel {
                VStack(alignment: .leading, spacing: 16) {
                    HStack(spacing: 12) {
                        ZStack {
                            Circle()
                                .fill(.thinMaterial)
                                .frame(width: 58, height: 58)
                                .glassEffect(.regular.interactive(), in: .circle)
                            Text("@")
                                .font(.system(size: 34, weight: .bold, design: .monospaced))
                                .foregroundStyle(Color(red: 0.76, green: 1, blue: 0.78))
                        }

                        VStack(alignment: .leading, spacing: 3) {
                            Text("Swifty Roguelike")
                                .font(.headline)
                            Text("Level \(game.player.level) Delver")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }

                    StatBar(title: "HP", value: game.player.hp, maximum: game.player.maxHP, tint: .red)
                    StatBar(title: "MP", value: game.player.mp, maximum: game.player.maxMP, tint: .cyan)
                    StatBar(title: "XP", value: game.player.xp, maximum: game.player.xpForNextLevel, tint: .green)
                }
            }

            GlassPanel {
                VStack(alignment: .leading, spacing: 13) {
                    SectionHeader(title: "Equipment", systemImage: "shield.lefthalf.filled")
                    EquipmentRow(title: "Weapon", value: game.player.weapon, icon: "wand.and.stars")
                    EquipmentRow(title: "Armor", value: game.player.armorName, icon: "shield")
                    EquipmentRow(title: "Gold", value: "\(game.player.gold)", icon: "dollarsign.circle")
                }
            }

            GlassPanel {
                VStack(alignment: .leading, spacing: 12) {
                    SectionHeader(title: "Run", systemImage: "map")
                    MetricRow(title: "Dungeon", value: String(format: "%02d", game.dungeonLevel))
                    MetricRow(title: "Turn", value: "\(game.turn)")
                    MetricRow(title: "Seed", value: game.seedLabel)
                    MetricRow(title: "Hostiles", value: "\(game.remainingMonsters)")
                }
            }

            Spacer(minLength: 0)
        }
    }
}

private struct EquipmentRow: View {
    let title: String
    let value: String
    let icon: String

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .frame(width: 18)
                .foregroundStyle(.secondary)
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                Text(value)
                    .font(.callout)
                    .lineLimit(1)
            }
            Spacer()
        }
    }
}

private struct MetricRow: View {
    let title: String
    let value: String

    var body: some View {
        HStack {
            Text(title)
                .foregroundStyle(.secondary)
            Spacer()
            Text(value)
                .font(.system(.callout, design: .monospaced))
        }
        .font(.callout)
    }
}
