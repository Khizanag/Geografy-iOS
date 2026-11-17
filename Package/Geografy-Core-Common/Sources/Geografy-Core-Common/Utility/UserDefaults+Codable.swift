import Foundation
import os

private let logger = Logger(subsystem: "com.khizanag.geografy", category: "defaults")

public extension UserDefaults {
    /// The value stored as JSON under `key`, or nil when there's none. Data that no longer decodes, such as
    /// one saved by an older model, is logged rather than dropped silently.
    func decoded<Value: Decodable>(_ type: Value.Type, forKey key: String) -> Value? {
        guard let data = data(forKey: key) else { return nil }
        do {
            return try JSONDecoder().decode(Value.self, from: data)
        } catch {
            logger.error("Stored \(key, privacy: .public) doesn't decode as \(Value.self): \(error)")
            return nil
        }
    }

    /// Stores `value` as JSON under `key`.
    func setEncoded(_ value: some Encodable, forKey key: String) {
        do {
            set(try JSONEncoder().encode(value), forKey: key)
        } catch {
            logger.error("Couldn't encode \(key, privacy: .public): \(error)")
        }
    }
}
