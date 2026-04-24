import Foundation
import Observation

@Observable
final class GameStore {
    private static let initialInventory = [
        InventoryItem(name: "Crimson Potion", detail: "Restores 12 HP"),
        InventoryItem(name: "Survey Lens", detail: "+1 tile awareness")
    ]
    private static let maxLogEntries = 12
    private static let revealRadiusX = 11
    private static let revealRadiusY = 7

    private(set) var seed: UInt64
    private(set) var dungeonLevel = 1
    private(set) var turn = 1
    private(set) var map = DungeonMap(width: 64, height: 38, fill: .wall)
    private(set) var player = Player(position: GridPoint(x: 2, y: 2))
    private(set) var monsters: [Monster] = []
    private(set) var loot: [Loot] = []
    private(set) var inventory = GameStore.initialInventory
    private(set) var log: [GameLogEntry] = []

    private var rng = SeededRandomNumberGenerator(seed: 0xA7F2)

    var isGameOver: Bool { player.hp <= 0 }
    var seedLabel: String { String(seed, radix: 16, uppercase: true) }
    var remainingMonsters: Int { monsters.count }

    init(seed: UInt64) {
        self.seed = seed
        rebuildDungeon(seed: seed, level: 1)
        append("You wake beneath a glass-black ruin.", .info)
    }

    func newRun() {
        seed = UInt64(Date().timeIntervalSince1970) ^ 0xA7F2
        dungeonLevel = 1
        turn = 1
        inventory = Self.initialInventory
        rebuildDungeon(seed: seed, level: dungeonLevel)
        log.removeAll()
        append("New run seeded \(seedLabel).", .info)
    }

    func perform(_ action: GameAction) {
        guard !isGameOver else {
            append("The run is over. Start a new run.", .danger)
            return
        }

        switch action {
        case .move(let direction):
            movePlayer(direction)
        case .wait:
            append("You wait and listen.", .info)
            advanceTurn(monstersAct: true)
        case .rest:
            let healed = min(4, player.maxHP - player.hp)
            player.hp += healed
            append(healed > 0 ? "You rest and recover \(healed) HP." : "You are already steady.", .info)
            advanceTurn(monstersAct: true)
        case .descend:
            if map[player.position] == .stairs {
                dungeonLevel += 1
                rebuildDungeon(seed: seed &+ UInt64(dungeonLevel * 491), level: dungeonLevel)
                append("You descend to Dungeon \(dungeonLevel).", .info)
            } else {
                append("There are no stairs underfoot.", .info)
            }
        case .usePotion:
            usePotion()
        }
    }

    func glyph(at point: GridPoint) -> TerminalGlyph {
        if player.position == point {
            return TerminalGlyph(character: "@", color: .player, isBright: true)
        }

        if let monster = monsters.first(where: { $0.position == point }) {
            return TerminalGlyph(character: monster.kind.glyph, color: .monster(monster.kind), isBright: true)
        }

        if let loot = loot.first(where: { $0.position == point }) {
            return TerminalGlyph(character: loot.kind.glyph, color: .loot(loot.kind), isBright: true)
        }

        let tile = map[point]
        return TerminalGlyph(character: tile.glyph, color: .tile(tile), isBright: tile != .floor)
    }

    private func rebuildDungeon(seed: UInt64, level: Int) {
        var generator = DungeonGenerator(dungeonLevel: level, rng: SeededRandomNumberGenerator(seed: seed))
        let generated = generator.generate()
        rng = generator.rng
        map = generated.map
        player = Player(position: generated.playerStart)
        player.level = max(1, level)
        player.maxHP = 28 + (level - 1) * 4
        player.hp = player.maxHP
        player.maxMP = 8 + (level - 1)
        player.mp = player.maxMP
        player.attack = 6 + (level - 1)
        monsters = generated.monsters
        loot = generated.loot
        revealAroundPlayer()
    }

    private func movePlayer(_ direction: Direction) {
        let target = player.position.moved(direction)

        guard map.contains(target), map[target].isWalkable else {
            append("Stone refuses the move \(direction.title.lowercased()).", .info)
            return
        }

        if let monsterIndex = monsters.firstIndex(where: { $0.position == target }) {
            attackMonster(at: monsterIndex)
            advanceTurn(monstersAct: true)
            return
        }

        player.position = target
        revealAroundPlayer()
        pickUpLootIfNeeded()

        if map[target] == .stairs {
            append("A stairwell drops into colder dark.", .info)
        }

        advanceTurn(monstersAct: true)
    }

    private func attackMonster(at index: Int) {
        let damage = max(1, player.attack + rng.int(in: 0...3) - monsters[index].kind.attack / 3)
        monsters[index].hp -= damage
        append("You hit \(monsters[index].kind.name) for \(damage).", .combat)

        if monsters[index].hp <= 0 {
            let defeated = monsters.remove(at: index)
            player.xp += defeated.kind.xp
            append("\(defeated.kind.name) collapses. +\(defeated.kind.xp) XP.", .combat)
            checkLevelUp()
        }
    }

    private func monstersTakeTurns() {
        guard !monsters.isEmpty else { return }

        for index in monsters.indices {
            guard monsters.indices.contains(index), player.hp > 0 else { continue }
            let distance = abs(monsters[index].position.x - player.position.x) + abs(monsters[index].position.y - player.position.y)

            if distance == 1 {
                let damage = max(1, monsters[index].kind.attack - player.armor + rng.int(in: 0...2))
                player.hp -= damage
                append("\(monsters[index].kind.name) strikes for \(damage).", .danger)
                if player.hp <= 0 {
                    player.hp = 0
                    append("You fall on turn \(turn).", .danger)
                }
            } else if distance < 8 {
                stepMonsterTowardPlayer(index)
            }
        }
    }

    private func stepMonsterTowardPlayer(_ index: Int) {
        let monster = monsters[index]
        let dx = player.position.x.compare(to: monster.position.x)
        let dy = player.position.y.compare(to: monster.position.y)
        let horizontalStep = GridPoint(x: monster.position.x + dx, y: monster.position.y)
        let verticalStep = GridPoint(x: monster.position.x, y: monster.position.y + dy)
        let options = rng.chance(50) ? [horizontalStep, verticalStep] : [verticalStep, horizontalStep]

        for target in options {
            if map.contains(target),
               map[target].isWalkable,
               target != player.position,
               !monsters.contains(where: { $0.position == target }) {
                monsters[index].position = target
                return
            }
        }
    }

    private func pickUpLootIfNeeded() {
        guard let index = loot.firstIndex(where: { $0.position == player.position }) else {
            return
        }

        let found = loot.remove(at: index)
        switch found.kind {
        case .gold:
            let amount = rng.int(in: 8...24)
            player.gold += amount
            append("Looted \(amount) gold.", .loot)
        case .potion:
            inventory.append(InventoryItem(name: found.kind.name, detail: "Restores 12 HP"))
            append("Packed a Crimson Potion.", .loot)
        case .shard:
            player.xp += 5
            append("Absorbed a runic shard. +5 XP.", .loot)
            checkLevelUp()
        }
    }

    private func usePotion() {
        guard let index = inventory.firstIndex(where: { $0.name == "Crimson Potion" }) else {
            append("No potion remains.", .info)
            return
        }

        inventory.remove(at: index)
        let healed = min(12, player.maxHP - player.hp)
        player.hp += healed
        append("Crimson Potion restores \(healed) HP.", .loot)
        advanceTurn(monstersAct: true)
    }

    private func checkLevelUp() {
        while player.xp >= player.xpForNextLevel {
            player.xp -= player.xpForNextLevel
            player.level += 1
            player.maxHP += 5
            player.hp = player.maxHP
            player.maxMP += 2
            player.mp = player.maxMP
            player.attack += 1
            append("Level up! You are now level \(player.level).", .loot)
        }
    }

    private func advanceTurn(monstersAct: Bool) {
        turn += 1
        if monstersAct {
            monstersTakeTurns()
        }
    }

    private func revealAroundPlayer() {
        for y in (player.position.y - Self.revealRadiusY)...(player.position.y + Self.revealRadiusY) {
            for x in (player.position.x - Self.revealRadiusX)...(player.position.x + Self.revealRadiusX) {
                let point = GridPoint(x: x, y: y)
                if map.contains(point) {
                    map.discovered.insert(point)
                }
            }
        }
    }

    private func append(_ message: String, _ level: LogLevel) {
        log.insert(GameLogEntry(turn: turn, message: message, level: level), at: 0)
        if log.count > Self.maxLogEntries {
            log.removeLast()
        }
    }
}

private extension Int {
    func compare(to other: Int) -> Int {
        if self == other { return 0 }
        return self > other ? 1 : -1
    }
}
