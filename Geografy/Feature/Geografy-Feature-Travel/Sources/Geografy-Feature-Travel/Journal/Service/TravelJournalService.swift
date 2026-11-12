import Foundation
import Observation
import OSLog
import SwiftData
import SwiftUI
import UIKit

@MainActor
@Observable
public final class TravelJournalService {
    private(set) var entries: [TravelJournalEntry] = []

    private let context: ModelContext

    public convenience init() {
        self.init(isStoredInMemoryOnly: false)
    }

    init(isStoredInMemoryOnly: Bool) {
        context = ModelContext(Self.makeContainer(isStoredInMemoryOnly: isStoredInMemoryOnly))
        loadEntries()
    }

    public func addEntry(_ entry: TravelJournalEntry) {
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

    static func makeContainer(isStoredInMemoryOnly: Bool) -> ModelContainer {
        let schema = Schema(versionedSchema: TravelJournalSchemaV1.self)
        do {
            let configuration = ModelConfiguration(
                "TravelJournal",
                schema: schema,
                isStoredInMemoryOnly: isStoredInMemoryOnly,
                cloudKitDatabase: .none
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

    func loadEntries() {
        let descriptor = FetchDescriptor<TravelJournalEntry>(
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

    func averageRating(
        for entries: [TravelJournalEntry]
    ) -> Double {
        guard !entries.isEmpty else { return 0 }
        let total = entries.reduce(0) { $0 + $1.rating }
        return Double(total) / Double(entries.count)
    }
}
