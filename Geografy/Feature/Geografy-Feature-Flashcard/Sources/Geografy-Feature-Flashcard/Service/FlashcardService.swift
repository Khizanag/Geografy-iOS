import Foundation
import Geografy_Core_Common

@Observable
@MainActor
public final class FlashcardService {
    private(set) var spacedRepetitionStore: [String: SpacedRepetitionData] = [:]
    private let storageKey = "flashcard_spaced_repetition_data"

    @ObservationIgnored private var dueCardsMemo: DueCardsMemo?

    public init() {}

    /// Loads the active user's review history; call again after the user changes.
    public func loadData() {
        dueCardsMemo = nil
        guard let data = UserDefaults.standard.data(forKey: UserScope.key(storageKey)),
              let decoded = try? JSONDecoder().decode(
                  [String: SpacedRepetitionData].self,
                  from: data
              ) else {
            spacedRepetitionStore = [:]
            return
        }
        spacedRepetitionStore = decoded
    }

    public func recordReview(cardID: String, result: FlashcardReviewResult) {
        let existing = spacedRepetitionStore[cardID] ?? .makeNew()
        spacedRepetitionStore[cardID] = existing.updated(with: result)
        dueCardsMemo = nil
        saveData()
    }

    public func spacedRepetitionData(for cardID: String) -> SpacedRepetitionData {
        spacedRepetitionStore[cardID] ?? .makeNew()
    }

    public func dueCards(from items: [FlashcardItem]) -> [FlashcardItem] {
        items.filter { spacedRepetitionData(for: $0.id).isDueForReview }
    }

    /// The cards of `type` due now, one per country. Kept until a review, a reload,
    /// or the moment the next card falls due, so reading it on every render is cheap.
    public func dueCards(of type: FlashcardType, in countries: [Country]) -> [FlashcardItem] {
        let store = spacedRepetitionStore
        let now = Date.now
        if let memo = dueCardsMemo, memo.type == type, memo.countryCount == countries.count, now < memo.validUntil {
            return memo.cards
        }
        var nextDueDate = Date.distantFuture
        let cards = countries.compactMap { country -> FlashcardItem? in
            let card = FlashcardItem.make(from: country, type: type)
            guard let data = store[card.id], data.nextReviewDate > now else { return card }
            nextDueDate = min(nextDueDate, data.nextReviewDate)
            return nil
        }
        dueCardsMemo = DueCardsMemo(type: type, countryCount: countries.count, validUntil: nextDueDate, cards: cards)
        return cards
    }

    public func dueCount(of type: FlashcardType, in countries: [Country]) -> Int {
        dueCards(of: type, in: countries).count
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

// MARK: - Due Cards Memo
private extension FlashcardService {
    struct DueCardsMemo {
        let type: FlashcardType
        let countryCount: Int
        let validUntil: Date
        let cards: [FlashcardItem]
    }
}

// MARK: - Persistence
private extension FlashcardService {
    func saveData() {
        guard let encoded = try? JSONEncoder().encode(spacedRepetitionStore) else {
            return
        }
        UserDefaults.standard.set(encoded, forKey: UserScope.key(storageKey))
    }
}
