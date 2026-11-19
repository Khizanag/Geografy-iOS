#if !os(tvOS)
import Foundation

/// Why a match or lobby ended before its result, so the screen can say what happened.
public enum LocalMatchEnding: Equatable {
    /// The other player gave up during the countdown or the match.
    case opponentGaveUp(name: String)
    /// The host closed the lobby before the match started.
    case hostClosedLobby(name: String)
    /// The connection dropped without a goodbye.
    case connectionLost(name: String)
    /// The host's questions didn't load on this phone.
    case questionsFailed
}
#endif
