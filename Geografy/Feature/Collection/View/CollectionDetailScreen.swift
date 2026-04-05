import Geografy_Core_Common
import Geografy_Core_DesignSystem
import Geografy_Core_Navigation
import Geografy_Core_Service
import SwiftUI

struct CollectionDetailScreen: View {
    // MARK: - Properties
    @Environment(Navigator.self) private var coordinator
    @Environment(CollectionService.self) private var collectionService
    @Environment(CountryDataService.self) private var countryDataService
    @Environment(HapticsService.self) private var hapticsService

    let collectionName: String

    // MARK: - Body
    var body: some View {
        content
            .background(DesignSystem.Color.background.ignoresSafeArea())
            .navigationTitle(collectionName)
            .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Content
private extension CollectionDetailScreen {
    var items: [CollectionItem] {
        collectionService.items(in: collectionName)
    }

    @ViewBuilder
    var content: some View {
        if items.isEmpty {
            emptyState
        } else {
            itemList
        }
    }

    var emptyState: some View {
        ContentUnavailableView {
            Label("Empty Collection", systemImage: "folder")
        } description: {
            Text("Add items from country details, oceans, languages, and more.")
        }
    }

    var itemList: some View {
        ScrollView(showsIndicators: false) {
            LazyVStack(spacing: DesignSystem.Spacing.sm) {
                ForEach(groupedByType, id: \.type) { group in
                    typeSection(group.type, items: group.items)
                }
            }
            .padding(.horizontal, DesignSystem.Spacing.md)
            .padding(.vertical, DesignSystem.Spacing.md)
            .readableContentWidth()
        }
    }
}

// MARK: - Sections
private extension CollectionDetailScreen {
    struct TypeGroup {
        let type: CollectionItem.ItemType
        let items: [CollectionItem]
    }

    var groupedByType: [TypeGroup] {
        let grouped = Dictionary(grouping: items, by: \.type)
        return CollectionItem.ItemType.allCases.compactMap { type in
            guard let items = grouped[type], !items.isEmpty else { return nil }
            return TypeGroup(type: type, items: items)
        }
    }

    func typeSection(
        _ type: CollectionItem.ItemType,
        items: [CollectionItem]
    ) -> some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
            SectionHeaderView(title: type.pluralName, icon: type.icon)

            ForEach(items, id: \.itemID) { item in
                itemRow(item)
            }
        }
    }

    func itemRow(_ item: CollectionItem) -> some View {
        CardView {
            HStack(spacing: DesignSystem.Spacing.sm) {
                itemIcon(item)

                VStack(alignment: .leading, spacing: 2) {
                    Text(itemName(for: item))
                        .font(DesignSystem.Font.subheadline)
                        .fontWeight(.semibold)
                        .foregroundStyle(DesignSystem.Color.textPrimary)

                    Text(item.type.displayName)
                        .font(DesignSystem.Font.caption)
                        .foregroundStyle(DesignSystem.Color.textSecondary)
                }

                Spacer()

                Button {
                    hapticsService.impact(.light)
                    withAnimation {
                        collectionService.remove(
                            itemID: item.itemID,
                            type: item.type,
                            from: collectionName
                        )
                    }
                } label: {
                    Image(systemName: "minus.circle.fill")
                        .font(DesignSystem.Font.title3)
                        .foregroundStyle(DesignSystem.Color.error)
                }
                .buttonStyle(.plain)
            }
            .padding(DesignSystem.Spacing.sm)
        }
    }
}

// MARK: - Helpers
private extension CollectionDetailScreen {
    @ViewBuilder
    func itemIcon(_ item: CollectionItem) -> some View {
        switch item.type {
        case .country:
            FlagView(countryCode: item.itemID, height: DesignSystem.Size.lg, fixedWidth: true)
        default:
            ZStack {
                Circle()
                    .fill(DesignSystem.Color.accent.opacity(0.15))
                    .frame(width: 36, height: 36)
                Image(systemName: item.type.icon)
                    .font(DesignSystem.Font.iconSmall)
                    .foregroundStyle(DesignSystem.Color.accent)
            }
        }
    }

    func itemName(for item: CollectionItem) -> String {
        switch item.type {
        case .country:
            countryDataService.country(for: item.itemID)?.name ?? item.itemID
        case .ocean:
            item.itemID
        case .language:
            item.itemID
        case .organization:
            item.itemID
        }
    }
}
