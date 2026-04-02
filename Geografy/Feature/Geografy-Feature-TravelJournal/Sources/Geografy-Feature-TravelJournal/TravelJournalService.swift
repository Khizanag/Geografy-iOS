import Foundation
import Observation
import SwiftData
import SwiftUI
import UIKit

private struct SampleEntry {
    let code: String
    let title: String
    let notes: String
    let rating: Int
    let startOffset: Int
    let endOffset: Int
}

@Observable
public final class TravelJournalService {
    private(set) var entries: [TravelJournalEntry] = []

    private let container: ModelContainer

    public init() {
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

    public func addEntry(_ entry: TravelJournalEntry) {
        let context = makeContext()
        context.insert(entry)
        saveContext(context)
        loadEntries()
    }

    public func updateEntry(_ entry: TravelJournalEntry) {
        let context = makeContext()
        saveContext(context)
        loadEntries()
    }

    public func deleteEntry(_ entry: TravelJournalEntry) {
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
        if entries.isEmpty {
            seedSampleEntries()
        }
    }

    func seedSampleEntries() {
        let calendar = Calendar.current
        let samples: [SampleEntry] = [
            SampleEntry(
                code: "JP", title: "Tokyo & Kyoto Adventure",
                notes: "Explored ancient temples in Kyoto and the bustling streets of Shibuya."
                    + " The food was incredible — sushi, ramen, and matcha everything!",
                rating: 5, startOffset: -45, endOffset: -38
            ),
            SampleEntry(
                code: "IT", title: "Italian Dream",
                notes: "Rome's Colosseum took my breath away."
                    + " Venice canals at sunset were magical."
                    + " The gelato in Florence was the best I've ever had.",
                rating: 5, startOffset: -120, endOffset: -110
            ),
            SampleEntry(
                code: "GE", title: "Hidden Gem of the Caucasus",
                notes: "Tbilisi's old town charm, Kazbegi's mountain views,"
                    + " and the warmest hospitality I've experienced."
                    + " Georgian cuisine is underrated!",
                rating: 4, startOffset: -30, endOffset: -25
            ),
            SampleEntry(
                code: "BR", title: "Rio & Amazon",
                notes: "Christ the Redeemer at sunrise was unforgettable."
                    + " A boat trip through the Amazon rainforest showed me"
                    + " wildlife I'd only seen in documentaries.",
                rating: 4, startOffset: -90, endOffset: -83
            ),
        ]
        let context = makeContext()
        for (index, sample) in samples.enumerated() {
            let startDate = calendar.date(
                byAdding: .day,
                value: sample.startOffset,
                to: Date()
            ) ?? Date()
            let endDate = calendar.date(
                byAdding: .day,
                value: sample.endOffset,
                to: Date()
            ) ?? Date()
            let entry = TravelJournalEntry(
                countryCode: sample.code,
                title: sample.title,
                notes: sample.notes,
                rating: sample.rating,
                startDate: startDate,
                endDate: endDate,
                photoFileNames: []
            )
            entry.createdAt = calendar.date(
                byAdding: .day,
                value: sample.startOffset - index,
                to: Date()
            ) ?? Date()
            context.insert(entry)
        }
        saveContext(context)
        loadEntriesWithoutSeed()
    }

    func loadEntriesWithoutSeed() {
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
