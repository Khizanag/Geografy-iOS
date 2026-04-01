import Foundation
import SwiftData

@Model
public final class TravelJournalEntry {
    public var id: String
    public var countryCode: String
    public var title: String
    public var notes: String
    public var rating: Int
    public var startDate: Date
    public var endDate: Date
    public var photoFileNames: [String]
    public var createdAt: Date

    public init(
        id: String = UUID().uuidString,
        countryCode: String,
        title: String,
        notes: String = "",
        rating: Int = 3,
        startDate: Date = .now,
        endDate: Date = .now,
        photoFileNames: [String] = [],
        createdAt: Date = .now
    ) {
        self.id = id
        self.countryCode = countryCode
        self.title = title
        self.notes = notes
        self.rating = rating
        self.startDate = startDate
        self.endDate = endDate
        self.photoFileNames = photoFileNames
        self.createdAt = createdAt
    }
}

// MARK: - Computed Properties
extension TravelJournalEntry {
    public var durationDays: Int {
        let calendar = Calendar.current
        let components = calendar.dateComponents(
            [.day],
            from: startDate,
            to: endDate
        )
        return max(1, (components.day ?? 0) + 1)
    }

    public var formattedDateRange: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        let start = formatter.string(from: startDate)
        let end = formatter.string(from: endDate)
        if start == end {
            return start
        }
        return "\(start) - \(end)"
    }
}
