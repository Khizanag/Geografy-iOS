import Foundation
import Geografy_Core_Common
import Observation
import SwiftData

@MainActor
@Observable
public final class CollectionService {
    // MARK: - Properties
    public private(set) var items: [CollectionItem] = []
    private var modelContext: ModelContext?

    // MARK: - Init
    public init() {}

    public func configure(container: ModelContainer) {
        modelContext = ModelContext(container)
        fetchItems()
    }
}

// MARK: - Queries
public extension CollectionService {
    var collectionNames: [String] {
        Array(Set(items.map(\.collectionName))).sorted()
    }

    func items(in collection: String) -> [CollectionItem] {
        items.filter { $0.collectionName == collection }
    }

    func itemCount(in collection: String) -> Int {
        items(in: collection).count
    }

    func typeCounts(in collection: String) -> [CollectionItem.ItemType: Int] {
        let collectionItems = items(in: collection)
        var counts: [CollectionItem.ItemType: Int] = [:]
        for item in collectionItems {
            counts[item.type, default: 0] += 1
        }
        return counts
    }

    func isSaved(itemID: String, type: CollectionItem.ItemType) -> Bool {
        items.contains { $0.itemID == itemID && $0.type == type }
    }

    func collections(
        containing itemID: String,
        type: CollectionItem.ItemType
    ) -> [String] {
        items
            .filter { $0.itemID == itemID && $0.type == type }
            .map(\.collectionName)
    }
}

// MARK: - Mutations
public extension CollectionService {
    func add(
        itemID: String,
        type: CollectionItem.ItemType,
        to collection: String
    ) {
        guard !items.contains(where: {
            $0.itemID == itemID && $0.type == type && $0.collectionName == collection
        }) else { return }

        let item = CollectionItem(
            itemID: itemID,
            itemType: type,
            collectionName: collection
        )
        modelContext?.insert(item)
        save()
        fetchItems()
    }

    func remove(
        itemID: String,
        type: CollectionItem.ItemType,
        from collection: String
    ) {
        guard let item = items.first(where: {
            $0.itemID == itemID && $0.type == type && $0.collectionName == collection
        }) else { return }

        modelContext?.delete(item)
        save()
        fetchItems()
    }

    func toggle(
        itemID: String,
        type: CollectionItem.ItemType,
        in collection: String
    ) {
        if items.contains(where: {
            $0.itemID == itemID && $0.type == type && $0.collectionName == collection
        }) {
            remove(itemID: itemID, type: type, from: collection)
        } else {
            add(itemID: itemID, type: type, to: collection)
        }
    }

    func deleteCollection(_ name: String) {
        let toDelete = items.filter { $0.collectionName == name }
        for item in toDelete {
            modelContext?.delete(item)
        }
        save()
        fetchItems()
    }

    func renameCollection(from oldName: String, to newName: String) {
        let toRename = items.filter { $0.collectionName == oldName }
        for item in toRename {
            item.collectionName = newName
        }
        save()
        fetchItems()
    }
}

// MARK: - Persistence
private extension CollectionService {
    func fetchItems() {
        guard let modelContext else { return }
        let descriptor = FetchDescriptor<CollectionItem>(
            sortBy: [SortDescriptor(\CollectionItem.addedAt, order: .reverse)]
        )
        items = (try? modelContext.fetch(descriptor)) ?? []
    }

    func save() {
        try? modelContext?.save()
    }
}
