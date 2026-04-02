import Combine
import Foundation
import Geografy_Core_Common
import Observation
import SwiftData

@Observable
@MainActor
public final class XPService {
    public private(set) var totalXP: Int = 0
    public private(set) var currentLevel: UserLevel = UserLevel.thresholds[0]

    public var xpInCurrentLevel: Int { totalXP - currentLevel.minXP }
    public var xpRequiredForNextLevel: Int { currentLevel.maxXP - currentLevel.minXP }
    public var progressFraction: Double {
        guard currentLevel.maxXP != Int.max else { return 1.0 }
        let range = Double(currentLevel.maxXP - currentLevel.minXP)
        return min(Double(xpInCurrentLevel) / range, 1.0)
    }

    public let levelUpPublisher = PassthroughSubject<UserLevel, Never>()

    public var currentUserID: String

    private let db: DatabaseManager

    public init(db: DatabaseManager, userID: String) {
        self.db = db
        self.currentUserID = userID
    }

    public func switchUser(id: String) {
        currentUserID = id
        refreshXP()
    }

    public func award(_ amount: Int, source: XPSource, metadata: [String: String]? = nil) {
        let metadataString: String? = metadata.flatMap { dict in
            (try? JSONSerialization.data(withJSONObject: dict)).flatMap { String(data: $0, encoding: .utf8) }
        }

        let record = XPRecord(
            userID: currentUserID,
            amount: amount,
            source: source.rawValue,
            metadata: metadataString
        )
        db.mainContext.insert(record)
        try? db.mainContext.save()

        let previousLevel = currentLevel
        refreshXP()

        if currentLevel.level > previousLevel.level {
            levelUpPublisher.send(currentLevel)
        }
    }
}

// MARK: - Helpers
extension XPService {
    public func refreshXP() {
        let userID = currentUserID
        let descriptor = FetchDescriptor<XPRecord>(
            predicate: #Predicate { $0.userID == userID }
        )
        let records = (try? db.mainContext.fetch(descriptor)) ?? []
        totalXP = records.reduce(0) { $0 + $1.amount }
        currentLevel = UserLevel.level(for: totalXP)
    }
}
