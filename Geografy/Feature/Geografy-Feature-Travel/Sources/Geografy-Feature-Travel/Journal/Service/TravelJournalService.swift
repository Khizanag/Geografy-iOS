import Foundation
import Geografy_Core_Common
import Observation
import OSLog
import SwiftData
import SwiftUI
import UIKit

@MainActor
@Observable
public final class TravelJournalService {
    private(set) var entries: [TravelJournalEntry] = []
    /// The user whose journal this shows; read once, as the service lives only as long as its screen.
    let userID: String

    private let context: ModelContext

    public convenience init() {
        self.init(isStoredInMemoryOnly: false)
    }

    init(isStoredInMemoryOnly: Bool, storeURL: URL? = nil, userID: String = UserScope.currentUserID) {
        self.userID = userID
        context = ModelContext(Self.makeContainer(isStoredInMemoryOnly: isStoredInMemoryOnly, storeURL: storeURL))
        loadEntries()
    }

    public func addEntry(_ entry: TravelJournalEntry) {
        entry.userID = userID
        context.insert(entry)
        saveContext()
        loadEntries()
    }

    // Entries come from `context`, so edits made by the editor are already tracked there.
    public func updateEntry(_ entry: TravelJournalEntry) {
        saveContext()
        loadEntries()
    }

    public func deleteEntry(_ entry: TravelJournalEntry) {
        deletePhotos(fileNames: entry.photoFileNames)
        context.delete(entry)
        saveContext()
        loadEntries()
    }

    public func entries(
        for countryCode: String
    ) -> [TravelJournalEntry] {
        entries.filter { $0.countryCode == countryCode }
    }

    public func savePhoto(_ imageData: Data) -> String? {
        let fileName = UUID().uuidString + ".jpg"
        let url = photosDirectory
            .appendingPathComponent(fileName)
        do {
            try imageData.write(to: url)
            return fileName
        } catch {
            return nil
        }
    }

    public func loadPhoto(named fileName: String) -> UIImage? {
        let url = photosDirectory
            .appendingPathComponent(fileName)
        guard let data = try? Data(contentsOf: url) else {
            return nil
        }
        return UIImage(data: data)
    }

    public func deletePhotos(fileNames: [String]) {
        for fileName in fileNames {
            let url = photosDirectory
                .appendingPathComponent(fileName)
            try? FileManager.default.removeItem(at: url)
        }
    }
}

// MARK: - Statistics
extension TravelJournalService {
    public var totalEntries: Int { entries.count }

    public var totalPhotos: Int {
        entries.reduce(0) { $0 + $1.photoFileNames.count }
    }

    public var uniqueCountries: Int {
        Set(entries.map(\.countryCode)).count
    }

    public var favoriteCountryCode: String? {
        let grouped = Dictionary(
            grouping: entries,
            by: \.countryCode
        )
        return grouped
            .max { first, second in
                averageRating(for: first.value)
                    < averageRating(for: second.value)
            }?
            .key
    }

    public var averageRating: Double {
        guard !entries.isEmpty else { return 0 }
        let total = entries.reduce(0) { $0 + $1.rating }
        return Double(total) / Double(entries.count)
    }
}

// MARK: - Helpers
private extension TravelJournalService {
    var photosDirectory: URL {
        let directory = FileManager.default
            .urls(
                for: .documentDirectory,
                in: .userDomainMask
            )[0]
            .appendingPathComponent("TravelJournalPhotos")
        if !FileManager.default
            .fileExists(atPath: directory.path) {
            try? FileManager.default.createDirectory(
                at: directory,
                withIntermediateDirectories: true
            )
        }
        return directory
    }

    static let logger = Logger(subsystem: "com.khizanag.geografy", category: "TravelJournal")

    static func makeContainer(isStoredInMemoryOnly: Bool, storeURL: URL?) -> ModelContainer {
        let schema = Schema(versionedSchema: TravelJournalSchemaV2.self)
        do {
            let configuration = makeConfiguration(
                schema: schema,
                isStoredInMemoryOnly: isStoredInMemoryOnly,
                storeURL: storeURL
            )
            return try ModelContainer(
                for: schema,
                migrationPlan: TravelJournalMigrationPlan.self,
                configurations: [configuration]
            )
        } catch {
            logger.error("Journal store failed to open, using memory: \(error.localizedDescription)")
            return makeInMemoryContainer(schema: schema)
        }
    }

    static func makeConfiguration(schema: Schema, isStoredInMemoryOnly: Bool, storeURL: URL?) -> ModelConfiguration {
        if let storeURL {
            return ModelConfiguration(schema: schema, url: storeURL, cloudKitDatabase: .none)
        }
        return ModelConfiguration(
            "TravelJournal",
            schema: schema,
            isStoredInMemoryOnly: isStoredInMemoryOnly,
            cloudKitDatabase: .none
        )
    }

    static func makeInMemoryContainer(schema: Schema) -> ModelContainer {
        let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true, cloudKitDatabase: .none)
        do {
            return try ModelContainer(for: schema, configurations: [configuration])
        } catch {
            // An in-memory store with a schema that just compiled cannot fail to open.
            fatalError("In-memory journal store failed to open: \(error)")
        }
    }

    func saveContext() {
        do {
            try context.save()
        } catch {
            Self.logger.error("Journal save failed: \(error.localizedDescription)")
        }
    }

    /// Loads this user's entries, first giving them any saved before the journal was per user.
    func loadEntries() {
        claimUnownedEntries()
        let userID = self.userID
        let descriptor = FetchDescriptor<TravelJournalEntry>(
            predicate: #Predicate { $0.userID == userID },
            sortBy: [
                SortDescriptor(\.startDate, order: .reverse),
            ]
        )
        do {
            entries = try context.fetch(descriptor)
        } catch {
            Self.logger.error("Journal fetch failed: \(error.localizedDescription)")
        }
    }

    func claimUnownedEntries() {
        guard !userID.isEmpty else { return }
        let descriptor = FetchDescriptor<TravelJournalEntry>(predicate: #Predicate { $0.userID.isEmpty })
        do {
            let unowned = try context.fetch(descriptor)
            guard !unowned.isEmpty else { return }
            for entry in unowned {
                entry.userID = userID
            }
            saveContext()
        } catch {
            Self.logger.error("Journal claim failed: \(error.localizedDescription)")
        }
    }

    func averageRating(
        for entries: [TravelJournalEntry]
    ) -> Double {
        guard !entries.isEmpty else { return 0 }
        let total = entries.reduce(0) { $0 + $1.rating }
        return Double(total) / Double(entries.count)
    }
}
