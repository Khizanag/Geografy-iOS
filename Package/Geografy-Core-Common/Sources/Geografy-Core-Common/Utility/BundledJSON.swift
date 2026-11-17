import Foundation
import os

/// Data the app ships as JSON, such as flag meanings or fun facts, decoded from a bundle.
public enum BundledJSON {
    private static let logger = Logger(subsystem: "com.khizanag.geografy", category: "bundled-data")

    /// `<name>.json` in `bundle`, decoded. A missing or mismatched file is a build mistake, so a debug build
    /// stops on it; a release build logs it and gets nil.
    public static func decode<Value: Decodable>(_ type: Value.Type, named name: String, in bundle: Bundle) -> Value? {
        guard let url = bundle.url(forResource: name, withExtension: "json") else {
            logger.fault("Missing bundled \(name, privacy: .public).json")
            assertionFailure("Missing bundled \(name).json")
            return nil
        }
        do {
            return try JSONDecoder().decode(Value.self, from: Data(contentsOf: url))
        } catch {
            logger.fault("Bundled \(name, privacy: .public).json doesn't decode: \(error, privacy: .public)")
            assertionFailure("Bundled \(name).json doesn't decode: \(error)")
            return nil
        }
    }
}
