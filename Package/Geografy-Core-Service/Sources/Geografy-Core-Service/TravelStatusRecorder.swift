import Foundation
import Geografy_Core_Common

/// Sets a country's travel status and grants what it earns: XP once per country and status, then achievement checks.
@MainActor
public struct TravelStatusRecorder {
    // MARK: - Properties
    let travelService: TravelService
    let xpService: XPService
    let achievementService: AchievementService

    public init(travelService: TravelService, xpService: XPService, achievementService: AchievementService) {
        self.travelService = travelService
        self.xpService = xpService
        self.achievementService = achievementService
    }

    private static let awardedKey = "travel_xp_awarded"

    // MARK: - Recording
    public func record(_ status: TravelStatus, for countryCode: String) {
        travelService.set(status: status, for: countryCode)
        awardXPOnce(for: status, countryCode: countryCode)
        achievementService.checkTravelAchievements(
            visitedCount: travelService.visitedCodes.count,
            wantCount: travelService.wantToVisitCodes.count
        )
    }
}

// MARK: - Helpers
private extension TravelStatusRecorder {
    func awardXPOnce(for status: TravelStatus, countryCode: String) {
        var awarded = Set(UserDefaults.standard.stringArray(forKey: UserScope.key(Self.awardedKey)) ?? [])
        let entryKey = "\(countryCode):\(status.rawValue)"
        guard !awarded.contains(entryKey) else { return }
        awarded.insert(entryKey)
        UserDefaults.standard.set(Array(awarded), forKey: UserScope.key(Self.awardedKey))
        switch status {
        case .visited:
            xpService.award(20, source: .travelVisited)
        case .wantToVisit:
            xpService.award(5, source: .travelWantToVisit)
        }
    }
}
