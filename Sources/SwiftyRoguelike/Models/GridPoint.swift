import Foundation

struct GridPoint: Hashable, Sendable {
    var x: Int
    var y: Int

    func moved(_ direction: Direction) -> GridPoint {
        GridPoint(x: x + direction.delta.x, y: y + direction.delta.y)
    }
}

enum Direction: String, CaseIterable, Identifiable, Sendable {
    case north
    case south
    case west
    case east

    var id: String { rawValue }

    var title: String {
        switch self {
        case .north: "North"
        case .south: "South"
        case .west: "West"
        case .east: "East"
        }
    }

    var symbol: String {
        switch self {
        case .north: "arrow.up"
        case .south: "arrow.down"
        case .west: "arrow.left"
        case .east: "arrow.right"
        }
    }

    var delta: (x: Int, y: Int) {
        switch self {
        case .north: (0, -1)
        case .south: (0, 1)
        case .west: (-1, 0)
        case .east: (1, 0)
        }
    }
}
