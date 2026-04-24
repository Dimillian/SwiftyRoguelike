import Foundation

enum GameAction: Sendable {
    case move(Direction)
    case wait
    case rest
    case descend
    case usePotion
}

struct GameLogEntry: Identifiable, Sendable {
    let id = UUID()
    let turn: Int
    let message: String
    let level: LogLevel
}

enum LogLevel: Sendable {
    case info
    case combat
    case loot
    case danger
}
