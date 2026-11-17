import Foundation
import Geografy_Core_Common
import UIKit

@Observable
@MainActor
public final class FlashcardService {
    private(set) var spacedRepetitionStore: [String: SpacedRepetitionData] = [:]
    private let storageKey = "flashcard_spaced_repetition_data"
    private let saveDelay: Duration

    @ObservationIgnored private var dueCardsMemo: DueCardsMemo?
    @ObservationIgnored private var reviewsPerDayMemo: [Date: Int]?
    // Captured at load, so a save that lands after a user switch still goes to the user who reviewed.
    @ObservationIgnored private var loadedStorageKey: String?
    @ObservationIgnored private var pendingSave: Task<Void, Never>?
    @ObservationIgnored private var backgroundObserver: (any NSObjectProtocol)?

    /// Reviews are saved `saveDelay` after the last one, and right away when the app goes to the background.
    public init(saveDelay: Duration = .seconds(2)) {
        self.saveDelay = saveDelay
        backgroundObserver = NotificationCenter.default.addObserver(
            forName: UIApplication.didEnterBackgroundNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            MainActor.assumeIsolated { self?.persistPendingChanges() }
        }
    }

    isolated deinit {
        if let backgroundObserver {
            NotificationCenter.default.removeObserver(backgroundObserver)
        }
    }

    /// Loads the active user's review history; call again after the user changes.
    public func loadData() {
        persistPendingChanges()
        let key = UserScope.key(storageKey)
        loadedStorageKey = key
        spacedRepetitionStore = Self.decodedStore(from: UserDefaults.standard.data(forKey: key)) ?? [:]
        storeDidChange()
    }

    public func recordReview(cardID: String, result: FlashcardReviewResult) {
        let existing = spacedRepetitionStore[cardID] ?? .makeNew()
        spacedRepetitionStore[cardID] = existing.updated(with: result)
        storeDidChange()
        scheduleSave()
    }

    /// Records an answer from a game in the card for that country and question kind, so every game feeds the
    /// same reviews. A miss counts as Again; a right answer only moves a card that's new or due, so replaying a
    /// quiz can't push its reviews far into the future.
    public func recordGameAnswer(countryCode: String, type: FlashcardType, isCorrect: Bool) {
        let cardID = FlashcardItem.id(countryCode: countryCode, type: type)
        if isCorrect {
            guard spacedRepetitionStore[cardID]?.isDueForReview ?? true else { return }
            recordReview(cardID: cardID, result: .good)
        } else {
            recordReview(cardID: cardID, result: .again)
        }
    }

    /// Writes reviews still waiting on the save delay; call when a session ends.
    public func persistPendingChanges() {
        guard let pendingSave else { return }
        pendingSave.cancel()
        self.pendingSave = nil
        saveData()
    }

    public func spacedRepetitionData(for cardID: String) -> SpacedRepetitionData {
        spacedRepetitionStore[cardID] ?? .makeNew()
    }

    public func dueCards(from items: [FlashcardItem]) -> [FlashcardItem] {
        items.filter { spacedRepetitionData(for: $0.id).isDueForReview }
    }

    /// New cards that can start each day, so a first session is a handful of countries rather than all of them.
    public static let newCardsPerDay = 10

    /// The cards of `type` due now: every reviewed card that has come due, then new ones, most populous first, up
    /// to what's left of today's ``newCardsPerDay``. Kept until a review, a reload, midnight, or the moment the
    /// next card falls due, so reading it on every render is cheap.
    public func dueCards(of type: FlashcardType, in countries: [Country]) -> [FlashcardItem] {
        let store = spacedRepetitionStore
        let now = Date.now
        if let memo = dueCardsMemo, memo.type == type, memo.countryCount == countries.count, now < memo.validUntil {
            return memo.cards
        }
        let calendar = Calendar.current
        var validUntil = calendar.date(byAdding: .day, value: 1, to: calendar.startOfDay(for: now)) ?? .distantFuture
        var reviewedDue: [FlashcardItem] = []
        var unseen: [(population: Int, card: FlashcardItem)] = []
        for country in countries {
            let card = FlashcardItem.make(from: country, type: type)
            guard let data = store[card.id] else {
                unseen.append((country.population, card))
                continue
            }
            if data.nextReviewDate <= now {
                reviewedDue.append(card)
            } else {
                validUntil = min(validUntil, data.nextReviewDate)
            }
        }
        let startedToday = store.count { id, data in
            id.hasSuffix("_\(type.rawValue)") && data.firstReviewDate.map(calendar.isDateInToday) == true
        }
        let newCards = unseen.enumerated()
            .sorted { ($0.element.population, -$0.offset) > ($1.element.population, -$1.offset) }
            .prefix(max(Self.newCardsPerDay - startedToday, 0))
            .map(\.element.card)
        let cards = reviewedDue + newCards
        dueCardsMemo = DueCardsMemo(type: type, countryCount: countries.count, validUntil: validUntil, cards: cards)
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

    /// Cards reviewed often and easily enough to count as mastered.
    public var proficientCount: Int {
        spacedRepetitionStore.values.count { $0.proficiencyLevel == .proficient }
    }

    public func reviewedTodayCount() -> Int {
        reviewsPerDay()[Calendar.current.startOfDay(for: .now)] ?? 0
    }

    public func currentStreak() -> Int {
        let reviewDays = reviewsPerDay()
        let calendar = Calendar.current
        var streak = 0
        var day = calendar.startOfDay(for: .now)

        while reviewDays[day] != nil {
            streak += 1
            guard let previousDay = calendar.date(byAdding: .day, value: -1, to: day) else { break }
            day = calendar.startOfDay(for: previousDay)
        }

        return streak
    }
}

// MARK: - Memos
private extension FlashcardService {
    struct DueCardsMemo {
        let type: FlashcardType
        let countryCount: Int
        let validUntil: Date
        let cards: [FlashcardItem]
    }

    func storeDidChange() {
        dueCardsMemo = nil
        reviewsPerDayMemo = nil
    }

    /// How many cards were last reviewed on each day, keyed by the start of that day.
    func reviewsPerDay() -> [Date: Int] {
        let store = spacedRepetitionStore
        if let reviewsPerDayMemo {
            return reviewsPerDayMemo
        }
        let calendar = Calendar.current
        var counts: [Date: Int] = [:]
        for lastReview in store.values.compactMap(\.lastReviewDate) {
            counts[calendar.startOfDay(for: lastReview), default: 0] += 1
        }
        reviewsPerDayMemo = counts
        return counts
    }
}

// MARK: - Persistence
private extension FlashcardService {
    static func decodedStore(from data: Data?) -> [String: SpacedRepetitionData]? {
        guard let data else { return nil }
        return try? JSONDecoder().decode([String: SpacedRepetitionData].self, from: data)
    }

    // Encoding the whole history on every swipe cost a hitch per card, so a burst of reviews saves once.
    func scheduleSave() {
        pendingSave?.cancel()
        pendingSave = Task { [weak self, saveDelay] in
            try? await Task.sleep(for: saveDelay)
            guard !Task.isCancelled else { return }
            self?.persistPendingChanges()
        }
    }

    func saveData() {
        guard let encoded = try? JSONEncoder().encode(spacedRepetitionStore) else {
            return
        }
        UserDefaults.standard.set(encoded, forKey: loadedStorageKey ?? UserScope.key(storageKey))
    }
}
