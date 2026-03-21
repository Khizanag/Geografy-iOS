import Foundation

extension Array {
    /// Deterministic shuffle using a seeded xorshift64 PRNG.
    /// Same seed always produces the same permutation — different seed gives a different order.
    /// Used for "Country of the Day" so all users see the same country on the same date.
    func seededShuffle(seed: UInt64) -> [Element] {
        guard count > 1 else { return self }
        var random = SeededRandomGenerator(seed: seed)
        var result = self
        for index in stride(from: result.count - 1, through: 1, by: -1) {
            let swapIndex = Int(random.next() % UInt64(index + 1))
            result.swapAt(index, swapIndex)
        }
        return result
    }
}

// MARK: - Seeded PRNG

private struct SeededRandomGenerator: RandomNumberGenerator {
    private var state: UInt64

    init(seed: UInt64) {
        state = seed == 0 ? 1 : seed
    }

    mutating func next() -> UInt64 {
        state ^= state << 13
        state ^= state >> 7
        state ^= state << 17
        return state
    }
}
