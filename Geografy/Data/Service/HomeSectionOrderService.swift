import Foundation
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
            sections = HomeSection.allCases.map { $0 }
        }
    }

    func reorder(to newOrder: [HomeSection]) {
        sections = newOrder
        persist()
    }

    func reset() {
        sections = HomeSection.allCases.map { $0 }
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
