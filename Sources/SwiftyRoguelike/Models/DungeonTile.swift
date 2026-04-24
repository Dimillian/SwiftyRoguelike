import SwiftUI

enum DungeonTile: Equatable, Sendable {
    case void
    case wall
    case floor
    case door
    case water
    case foliage
    case stairs

    var isWalkable: Bool {
        switch self {
        case .floor, .door, .water, .foliage, .stairs:
            true
        case .void, .wall:
            false
        }
    }

    var glyph: String {
        switch self {
        case .void: " "
        case .wall: "#"
        case .floor: "."
        case .door: "+"
        case .water: "~"
        case .foliage: "\""
        case .stairs: ">"
        }
    }

    var color: Color {
        switch self {
        case .void: .clear
        case .wall: Color(red: 0.45, green: 0.48, blue: 0.50)
        case .floor: Color(red: 0.35, green: 0.38, blue: 0.36)
        case .door: Color(red: 0.86, green: 0.64, blue: 0.32)
        case .water: Color(red: 0.27, green: 0.78, blue: 0.92)
        case .foliage: Color(red: 0.34, green: 0.86, blue: 0.47)
        case .stairs: Color(red: 0.80, green: 0.70, blue: 0.98)
        }
    }
}

struct DungeonMap: Sendable {
    let width: Int
    let height: Int
    var tiles: [DungeonTile]
    var discovered: Set<GridPoint> = []

    init(width: Int, height: Int, fill: DungeonTile = .void) {
        self.width = width
        self.height = height
        self.tiles = Array(repeating: fill, count: width * height)
    }

    func contains(_ point: GridPoint) -> Bool {
        point.x >= 0 && point.y >= 0 && point.x < width && point.y < height
    }

    subscript(_ point: GridPoint) -> DungeonTile {
        get {
            guard contains(point) else { return .void }
            return tiles[point.y * width + point.x]
        }
        set {
            guard contains(point) else { return }
            tiles[point.y * width + point.x] = newValue
        }
    }
}
