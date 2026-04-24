import Foundation
import SwiftUI

struct Player: Sendable {
    var position: GridPoint
    var level = 1
    var xp = 0
    var hp = 28
    var maxHP = 28
    var mp = 8
    var maxMP = 8
    var attack = 6
    var armor = 1
    var gold = 0
    var weapon = "Copper Saber"
    var armorName = "Glassmail Vest"

    var xpForNextLevel: Int { 14 + level * 8 }
}

struct Monster: Identifiable, Sendable {
    let id: UUID
    var kind: MonsterKind
    var position: GridPoint
    var hp: Int

    init(kind: MonsterKind, position: GridPoint) {
        self.id = UUID()
        self.kind = kind
        self.position = position
        self.hp = kind.maxHP
    }
}

enum MonsterKind: String, CaseIterable, Sendable {
    case rat
    case slime
    case wraith
    case sentinel

    var name: String {
        switch self {
        case .rat: "Cave Rat"
        case .slime: "Azure Slime"
        case .wraith: "Static Wraith"
        case .sentinel: "Iron Sentinel"
        }
    }

    var glyph: String {
        switch self {
        case .rat: "r"
        case .slime: "s"
        case .wraith: "w"
        case .sentinel: "S"
        }
    }

    var color: Color {
        switch self {
        case .rat: Color(red: 0.96, green: 0.50, blue: 0.42)
        case .slime: Color(red: 0.22, green: 0.86, blue: 0.95)
        case .wraith: Color(red: 0.74, green: 0.62, blue: 1.0)
        case .sentinel: Color(red: 1.0, green: 0.38, blue: 0.34)
        }
    }

    var maxHP: Int {
        switch self {
        case .rat: 8
        case .slime: 12
        case .wraith: 16
        case .sentinel: 24
        }
    }

    var attack: Int {
        switch self {
        case .rat: 3
        case .slime: 4
        case .wraith: 5
        case .sentinel: 7
        }
    }

    var xp: Int {
        switch self {
        case .rat: 5
        case .slime: 7
        case .wraith: 10
        case .sentinel: 16
        }
    }
}

struct Loot: Identifiable, Sendable {
    let id: UUID
    var kind: LootKind
    var position: GridPoint

    init(kind: LootKind, position: GridPoint) {
        self.id = UUID()
        self.kind = kind
        self.position = position
    }
}

enum LootKind: String, CaseIterable, Sendable {
    case gold
    case potion
    case shard

    var name: String {
        switch self {
        case .gold: "Gold Cache"
        case .potion: "Crimson Potion"
        case .shard: "Runic Shard"
        }
    }

    var glyph: String {
        switch self {
        case .gold: "$"
        case .potion: "!"
        case .shard: "*"
        }
    }

    var color: Color {
        switch self {
        case .gold: Color(red: 1.0, green: 0.78, blue: 0.28)
        case .potion: Color(red: 1.0, green: 0.32, blue: 0.44)
        case .shard: Color(red: 0.58, green: 0.92, blue: 1.0)
        }
    }
}

struct InventoryItem: Identifiable, Sendable {
    let id = UUID()
    var name: String
    var detail: String
}
