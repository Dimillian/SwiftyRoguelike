import Foundation

struct DungeonGenerator {
    struct Room: Sendable {
        var x: Int
        var y: Int
        var width: Int
        var height: Int

        var center: GridPoint {
            GridPoint(x: x + width / 2, y: y + height / 2)
        }

        func intersects(_ other: Room) -> Bool {
            x - 1 < other.x + other.width &&
            x + width + 1 > other.x &&
            y - 1 < other.y + other.height &&
            y + height + 1 > other.y
        }

        func points() -> [GridPoint] {
            var result: [GridPoint] = []
            for yy in y..<(y + height) {
                for xx in x..<(x + width) {
                    result.append(GridPoint(x: xx, y: yy))
                }
            }
            return result
        }
    }

    var width = 64
    var height = 38
    var dungeonLevel: Int
    var rng: SeededRandomNumberGenerator

    mutating func generate() -> GeneratedDungeon {
        var map = DungeonMap(width: width, height: height, fill: .wall)
        var rooms: [Room] = []

        for _ in 0..<90 {
            let room = Room(
                x: rng.int(in: 2..<(width - 12)),
                y: rng.int(in: 2..<(height - 9)),
                width: rng.int(in: 6...12),
                height: rng.int(in: 4...8)
            )

            guard !rooms.contains(where: { room.intersects($0) }) else {
                continue
            }

            carve(room, in: &map)

            if let previous = rooms.last {
                carveCorridor(from: previous.center, to: room.center, in: &map)
            }

            rooms.append(room)

            if rooms.count >= 12 {
                break
            }
        }

        scatterFlavor(in: &map)

        let start = rooms.first?.center ?? GridPoint(x: width / 2, y: height / 2)
        let stairs = rooms.last?.center ?? GridPoint(x: width - 4, y: height - 4)
        map[stairs] = .stairs

        var monsters: [Monster] = []
        var loot: [Loot] = []
        let spawnRooms = rooms.dropFirst()

        for room in spawnRooms {
            if rng.chance(75), let point = randomFloorPoint(in: room, map: map, avoiding: [start, stairs]) {
                let kind = MonsterKind.allCases[rng.int(in: 0..<MonsterKind.allCases.count)]
                monsters.append(Monster(kind: kind, position: point))
            }

            if rng.chance(70), let point = randomFloorPoint(in: room, map: map, avoiding: [start, stairs]) {
                let kind = LootKind.allCases[rng.int(in: 0..<LootKind.allCases.count)]
                loot.append(Loot(kind: kind, position: point))
            }
        }

        reveal(around: start, in: &map)

        return GeneratedDungeon(
            map: map,
            playerStart: start,
            monsters: monsters,
            loot: loot
        )
    }

    private mutating func carve(_ room: Room, in map: inout DungeonMap) {
        for point in room.points() {
            map[point] = .floor
        }
    }

    private mutating func carveCorridor(from start: GridPoint, to end: GridPoint, in map: inout DungeonMap) {
        var current = start
        let horizontalFirst = rng.chance(50)

        if horizontalFirst {
            while current.x != end.x {
                map[current] = .floor
                current.x += current.x < end.x ? 1 : -1
            }
            while current.y != end.y {
                map[current] = .floor
                current.y += current.y < end.y ? 1 : -1
            }
        } else {
            while current.y != end.y {
                map[current] = .floor
                current.y += current.y < end.y ? 1 : -1
            }
            while current.x != end.x {
                map[current] = .floor
                current.x += current.x < end.x ? 1 : -1
            }
        }

        map[end] = .door
    }

    private mutating func scatterFlavor(in map: inout DungeonMap) {
        for y in 1..<(height - 1) {
            for x in 1..<(width - 1) {
                let point = GridPoint(x: x, y: y)
                guard map[point] == .floor else { continue }
                if rng.chance(2) {
                    map[point] = .water
                } else if rng.chance(3) {
                    map[point] = .foliage
                }
            }
        }
    }

    private mutating func randomFloorPoint(in room: Room, map: DungeonMap, avoiding: [GridPoint]) -> GridPoint? {
        for _ in 0..<20 {
            let point = GridPoint(
                x: rng.int(in: room.x..<(room.x + room.width)),
                y: rng.int(in: room.y..<(room.y + room.height))
            )
            if map[point].isWalkable && !avoiding.contains(point) {
                return point
            }
        }
        return nil
    }

    private func reveal(around center: GridPoint, in map: inout DungeonMap) {
        for y in (center.y - 7)...(center.y + 7) {
            for x in (center.x - 10)...(center.x + 10) {
                let point = GridPoint(x: x, y: y)
                if map.contains(point) {
                    map.discovered.insert(point)
                }
            }
        }
    }
}

struct GeneratedDungeon: Sendable {
    var map: DungeonMap
    var playerStart: GridPoint
    var monsters: [Monster]
    var loot: [Loot]
}
