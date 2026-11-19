import Foundation

/// Ties a Pin Drop game to a match against another phone: both find the same countries, each locked-in round goes
/// to the other player, and a round only moves on once the other player has locked it in too.
@MainActor
protocol PinDropMatch: AnyObject {
    /// The countries to find, in order, chosen by the host.
    var pinDropCountryCodes: [String] { get }
    var pinDropOpponentName: String { get }
    var pinDropOpponentScore: Int { get }
    func hasOpponentLockedIn(round: Int) -> Bool
    func didLockIn(round: Int, points: Int)
    /// This player has seen the last round; the match ends once the other player has too.
    func didFinishRounds()
}
