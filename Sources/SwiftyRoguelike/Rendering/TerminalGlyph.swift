import SwiftUI

struct TerminalGlyph: Sendable {
    var character: String
    var color: TerminalGlyphColor
    var isBright: Bool
}

enum TerminalGlyphColor: Sendable {
    case player
    case tile(DungeonTile)
    case monster(MonsterKind)
    case loot(LootKind)

    var color: Color {
        switch self {
        case .player:
            Color(red: 0.76, green: 1.0, blue: 0.78)
        case .tile(let tile):
            tile.color
        case .monster(let kind):
            kind.color
        case .loot(let kind):
            kind.color
        }
    }
}
