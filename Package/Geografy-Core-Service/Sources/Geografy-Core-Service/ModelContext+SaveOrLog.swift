import os
import SwiftData

private let logger = Logger(subsystem: "com.khizanag.geografy", category: "persistence")

public extension ModelContext {
    /// Saves, logging a failure with where it happened instead of dropping it as `try? save()` did.
    /// Returns whether it saved, for a caller that shouldn't go on otherwise.
    @discardableResult
    func saveOrLog(_ operation: String = #function, fileID: String = #fileID) -> Bool {
        do {
            try save()
            return true
        } catch {
            logger.error("Save failed in \(fileID, privacy: .public) \(operation, privacy: .public): \(error)")
            return false
        }
    }
}
