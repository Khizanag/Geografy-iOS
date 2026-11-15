import Foundation

/// The best score for each way a Pin Drop game can be set up.
struct PinDropRecords {
    private let defaults: UserDefaults

    /// - Parameter defaults: Tests pass their own, so a run never touches the player's records.
    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    func best(for configuration: PinDropConfiguration) -> Int {
        defaults.integer(forKey: key(for: configuration))
    }

    /// Keeps `score` if it beats the record, and says whether it did.
    @discardableResult
    func record(_ score: Int, for configuration: PinDropConfiguration) -> Bool {
        guard score > best(for: configuration) else { return false }
        defaults.set(score, forKey: key(for: configuration))
        return true
    }

    /// Games without borders are harder, so they keep a record of their own.
    private func key(for configuration: PinDropConfiguration) -> String {
        let base = "pinDrop.best.\(configuration.region.rawValue).\(configuration.difficulty.rawValue)"
        return "\(base).\(configuration.roundCount)" + (configuration.showsBorders ? "" : ".noBorders")
    }
}
