import Foundation
import Geografy_Core_Common

@Observable
public final class FlashcardService {
    private(set) var spacedRepetitionStore: [String: SpacedRepetitionData] = [:]
    private let storageKey = "flashcard_spaced_repetition_data"

    public init() {}

    public func loadData() {
        guard let data = UserDefaults.standard.data(forKey: storageKey),
              let decoded = try? JSONDecoder().decode(
                  [String: SpacedRepetitionData].self,
                  from: data
              ) else {
            return
        }
        spacedRepetitionStore = decoded
    }

    public func recordReview(cardID: String, result: FlashcardReviewResult) {
        let existing = spacedRepetitionStore[cardID] ?? .makeNew()
        spacedRepetitionStore[cardID] = existing.updated(with: result)
        saveData()
    }

    public func spacedRepetitionData(for cardID: String) -> SpacedRepetitionData {
        spacedRepetitionStore[cardID] ?? .makeNew()
    }

    public func dueCards(from items: [FlashcardItem]) -> [FlashcardItem] {
        items.filter { spacedRepetitionData(for: $0.id).isDueForReview }
    }

    public func proficiencyPercentage(for items: [FlashcardItem]) -> Double {
        guard !items.isEmpty else { return 0 }
        let totalProficiency = items.reduce(0.0) { sum, item in
            sum + spacedRepetitionData(for: item.id).proficiencyPercentage
        }
        return totalProficiency / Double(items.count)
    }

    public func reviewedTodayCount() -> Int {
        let calendar = Calendar.current
        return spacedRepetitionStore.values.filter { data in
            guard let lastReview = data.lastReviewDate else { return false }
            return calendar.isDateInToday(lastReview)
        }.count
    }

    public func currentStreak() -> Int {
        let calendar = Calendar.current
        var streak = 0
        var checkDate = Date()

        while true {
            let hasReview = spacedRepetitionStore.values.contains { data in
                guard let lastReview = data.lastReviewDate else { return false }
                return calendar.isDate(lastReview, inSameDayAs: checkDate)
            }

            guard hasReview else { break }
            streak += 1

            guard let previousDay = calendar.date(
                byAdding: .day,
                value: -1,
                to: checkDate
            ) else {
                break
            }
            checkDate = previousDay
        }

        return streak
    }
}

// MARK: - Persistence
private extension FlashcardService {
    func saveData() {
        guard let encoded = try? JSONEncoder().encode(spacedRepetitionStore) else {
            return
        }
        UserDefaults.standard.set(encoded, forKey: storageKey)
    }
}
