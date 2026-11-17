import Foundation

/// A finished game as it's shared: a card image and a line of text, the same for every game.
public struct ResultShare {
    /// One fact under the score, such as the region or the time taken.
    public struct Detail: Hashable {
        let systemImage: String
        let text: String

        public init(_ text: String, systemImage: String) {
            self.text = text
            self.systemImage = systemImage
        }
    }

    let game: String
    let score: String
    let caption: String?
    /// How full the score is, from 0 to 1, drawn as a row of squares in the text; nil for open-ended scores.
    let fraction: Double?
    let details: [Detail]
    let date: Date
    let onShare: () -> Void

    /// - Parameters:
    ///   - game: The game's name, already in the reader's language.
    ///   - score: The big number, such as "8/10" or "2,450".
    ///   - onShare: Runs when the share sheet opens, which is as close as iOS lets an app know about sharing.
    public init(
        game: String,
        score: String,
        caption: String? = nil,
        fraction: Double? = nil,
        details: [Detail] = [],
        date: Date = .now,
        onShare: @escaping () -> Void = {}
    ) {
        self.game = game
        self.score = score
        self.caption = caption
        self.fraction = fraction.map { min(max($0, 0), 1) }
        self.details = details
        self.date = date
        self.onShare = onShare
    }
}

// MARK: - Text
extension ResultShare {
    static let blockCount = 10

    var text: String {
        let heading = "Geografy · \(game)"
        let scoreLine = [score, caption].compactMap(\.self).joined(separator: " · ")
        let lines = [heading, scoreLine, blocks].compactMap(\.self) + details.map(\.text)
        return lines.joined(separator: "\n")
    }

    var blocks: String? {
        guard let fraction else { return nil }
        let filled = Int((fraction * Double(Self.blockCount)).rounded())
        return String(repeating: "🟩", count: filled) + String(repeating: "⬛", count: Self.blockCount - filled)
    }
}
