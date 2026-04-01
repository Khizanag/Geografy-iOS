import Combine
import Foundation
import GeografyCore
import Observation
import SwiftData

@Observable
@MainActor
final class XPService {
    private(set) var totalXP: Int = 0
    private(set) var currentLevel: UserLevel = UserLevel.thresholds[0]

    var xpInCurrentLevel: Int { totalXP - currentLevel.minXP }
    var xpRequiredForNextLevel: Int { currentLevel.maxXP - currentLevel.minXP }
    var progressFraction: Double {
        guard currentLevel.maxXP != Int.max else { return 1.0 }
        let range = Double(currentLevel.maxXP - currentLevel.minXP)
        return min(Double(xpInCurrentLevel) / range, 1.0)
    }

    let levelUpPublisher = PassthroughSubject<UserLevel, Never>()

    var currentUserID: String

    private let db: DatabaseManager

    init(db: DatabaseManager, userID: String) {
        self.db = db
        self.currentUserID = userID
    }

    func switchUser(id: String) {
        currentUserID = id
        refreshXP()
    }

    func award(_ amount: Int, source: XPSource, metadata: [String: String]? = nil) {
        let metadataString: String? = metadata.map { dict in
            (try? JSONSerialization.data(withJSONObject: dict)).flatMap { String(data: $0, encoding: .utf8) }
        } ?? nil

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
    func refreshXP() {
        let userID = currentUserID
        let descriptor = FetchDescriptor<XPRecord>(
            predicate: #Predicate { $0.userID == userID }
        )
        let records = (try? db.mainContext.fetch(descriptor)) ?? []
        totalXP = records.reduce(0) { $0 + $1.amount }
        currentLevel = UserLevel.level(for: totalXP)
    }
}
