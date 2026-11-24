#if !os(tvOS)
import Foundation

/// What the host picked for a match, sent once at the start, so both phones play exactly the same game.
public enum LocalGameSetup: Codable {
    /// The countries to find, in order.
    case pinDrop(countryCodes: [String])
    /// The country each round highlights, with its answers in the order they're shown.
    case mapPuzzle(rounds: [MapPuzzleRound])
    /// The region comes with the match's settings; there's nothing else to share.
    case speedRun
    case wordSearch(WordSearchPuzzle)
}
#endif
