#if !os(tvOS)
import Foundation
import Geografy_Core_Common
import Observation

@Observable
final class HomeSectionOrderService {
    private(set) var sections: [HomeSection]

    private let storageKey = "home_section_order"

    init() {
        if let data = UserDefaults.standard.data(forKey: storageKey),
           let decoded = try? JSONDecoder().decode([HomeSection].self, from: data) {
            var result = decoded
            for section in HomeSection.allCases where !result.contains(section) {
                result.append(section)
            }
            sections = result
        } else {
            sections = Self.curatedDefault
        }
    }

    static let curatedDefault: [HomeSection] = {
        let featured: [HomeSection] = [
            .guestBanner,
            .carousel,
            .spotlight,
            .streak,
            .dailyChallenge,
            .progress,
            .flagGame,
            .worldRecords,
            .trivia,
            .organizations,
            .countryCompare,
            .travelBucketList,
            .landmarkQuiz,
            .comingSoon,
        ]
        let remaining = HomeSection.allCases.filter { !featured.contains($0) }
        return featured + remaining
    }()

    func reorder(to newOrder: [HomeSection]) {
        sections = newOrder
        persist()
    }

    func reset() {
        sections = Self.curatedDefault
        persist()
    }
}

// MARK: - Helpers
private extension HomeSectionOrderService {
    func persist() {
        guard let data = try? JSONEncoder().encode(sections) else { return }
        UserDefaults.standard.set(data, forKey: storageKey)
    }
}
#endif
