import Foundation

struct SeededRandomNumberGenerator: RandomNumberGenerator, Sendable {
    private var state: UInt64

    init(seed: UInt64) {
        self.state = seed == 0 ? 0xA7F2 : seed
    }

    mutating func next() -> UInt64 {
        state &+= 0x9E3779B97F4A7C15
        var value = state
        value = (value ^ (value >> 30)) &* 0xBF58476D1CE4E5B9
        value = (value ^ (value >> 27)) &* 0x94D049BB133111EB
        return value ^ (value >> 31)
    }

    mutating func int(in range: ClosedRange<Int>) -> Int {
        Int.random(in: range, using: &self)
    }

    mutating func int(in range: Range<Int>) -> Int {
        Int.random(in: range, using: &self)
    }

    mutating func chance(_ percent: Int) -> Bool {
        int(in: 1...100) <= percent
    }
}
