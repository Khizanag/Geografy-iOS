import Foundation
import Observation
import SwiftData
import UIKit

@Observable
final class TravelJournalService {
    private(set) var entries: [TravelJournalEntry] = []

    private let container: ModelContainer

    init() {
        let schema = Schema([TravelJournalEntry.self])
        let config = ModelConfiguration(
            "TravelJournal",
            schema: schema
        )
        do {
            container = try ModelContainer(
                for: schema,
                configurations: [config]
            )
        } catch {
            fatalError(
                "Failed to create TravelJournal container: "
                    + "\(error.localizedDescription)"
            )
        }
        loadEntries()
    }

    func addEntry(_ entry: TravelJournalEntry) {
        let context = makeContext()
        context.insert(entry)
        saveContext(context)
        loadEntries()
    }

    func updateEntry(_ entry: TravelJournalEntry) {
        let context = makeContext()
        saveContext(context)
        loadEntries()
    }

    func deleteEntry(_ entry: TravelJournalEntry) {
        deletePhotos(fileNames: entry.photoFileNames)
        let context = makeContext()
        let entryID = entry.id
        let predicate = #Predicate<TravelJournalEntry> {
            $0.id == entryID
        }
        let descriptor = FetchDescriptor(predicate: predicate)
        if let found = try? context.fetch(descriptor).first {
            context.delete(found)
            saveContext(context)
        }
        loadEntries()
    }

    func entries(
        for countryCode: String
    ) -> [TravelJournalEntry] {
        entries.filter { $0.countryCode == countryCode }
    }

    func savePhoto(_ imageData: Data) -> String? {
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

    func loadPhoto(named fileName: String) -> UIImage? {
        let url = photosDirectory
            .appendingPathComponent(fileName)
        guard let data = try? Data(contentsOf: url) else {
            return nil
        }
        return UIImage(data: data)
    }

    func deletePhotos(fileNames: [String]) {
        for fileName in fileNames {
            let url = photosDirectory
                .appendingPathComponent(fileName)
            try? FileManager.default.removeItem(at: url)
        }
    }
}

// MARK: - Statistics

extension TravelJournalService {
    var totalEntries: Int { entries.count }

    var totalPhotos: Int {
        entries.reduce(0) { $0 + $1.photoFileNames.count }
    }

    var uniqueCountries: Int {
        Set(entries.map(\.countryCode)).count
    }

    var favoriteCountryCode: String? {
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

    var averageRating: Double {
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

    func makeContext() -> ModelContext {
        ModelContext(container)
    }

    func saveContext(_ context: ModelContext) {
        do {
            try context.save()
        } catch {
            print(
                "Failed to save journal context: \(error)"
            )
        }
    }

    func loadEntries() {
        let context = makeContext()
        let descriptor = FetchDescriptor<TravelJournalEntry>(
            sortBy: [
                SortDescriptor(\.startDate, order: .reverse),
            ]
        )
        entries = (try? context.fetch(descriptor)) ?? []
    }

    func averageRating(
        for entries: [TravelJournalEntry]
    ) -> Double {
        guard !entries.isEmpty else { return 0 }
        let total = entries.reduce(0) { $0 + $1.rating }
        return Double(total) / Double(entries.count)
    }
}
