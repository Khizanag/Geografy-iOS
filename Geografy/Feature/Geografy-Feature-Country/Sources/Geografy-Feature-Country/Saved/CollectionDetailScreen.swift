import Geografy_Core_Common
import Geografy_Core_DesignSystem
import Geografy_Core_Navigation
import Geografy_Core_Service
import SwiftUI

public struct CollectionDetailScreen: View {
    // MARK: - Properties
    @Environment(Navigator.self) private var coordinator
    @Environment(CollectionService.self) private var collectionService
    @Environment(CountryDataService.self) private var countryDataService
    @Environment(HapticsService.self) private var hapticsService
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    let collectionName: String

    // MARK: - Init
    public init(collectionName: String) {
        self.collectionName = collectionName
    }

    // MARK: - Body
    public var body: some View {
        content
            .screenBackground()
            .navigationTitle(collectionName)
            .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Content
private extension CollectionDetailScreen {
    @ViewBuilder
    var content: some View {
        let items = collectionService.items(in: collectionName)
        if items.isEmpty {
            emptyState
        } else {
            itemList(groups: groupedByType(items))
        }
    }

    var emptyState: some View {
        EmptyStateView(
            icon: "folder",
            title: "Empty Collection",
            message: "Add items from country details, oceans, languages, and more.",
            actionTitle: "Browse Countries"
        ) {
            hapticsService.impact(.light)
            coordinator.push(CountryRoute.countries)
        }
    }

    func itemList(groups: [TypeGroup]) -> some View {
        ScrollView(showsIndicators: false) {
            LazyVStack(spacing: DesignSystem.Spacing.xs) {
                ForEach(groups, id: \.type) { group in
                    typeSection(group.type, items: group.items, isFirst: group.type == groups.first?.type)
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

    func groupedByType(_ items: [CollectionItem]) -> [TypeGroup] {
        let grouped = Dictionary(grouping: items, by: \.type)
        return CollectionItem.ItemType.allCases.compactMap { type in
            guard let items = grouped[type], !items.isEmpty else { return nil }
            return TypeGroup(type: type, items: items)
        }
    }

    // Rows sit directly in the lazy stack so they load as they scroll in; the header's top
    // padding restores the wider gap that used to separate sections.
    func typeSection(
        _ type: CollectionItem.ItemType,
        items: [CollectionItem],
        isFirst: Bool
    ) -> some View {
        Section {
            ForEach(items, id: \.itemID) { item in
                itemRow(item)
            }
        } header: {
            SectionHeaderView(title: type.pluralName, icon: type.icon)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top, isFirst ? 0 : DesignSystem.Spacing.sm - DesignSystem.Spacing.xs)
        }
    }

    func itemRow(_ item: CollectionItem) -> some View {
        CardView {
            HStack(spacing: DesignSystem.Spacing.sm) {
                itemIcon(item)

                VStack(alignment: .leading, spacing: DesignSystem.Spacing.xxxs) {
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
                    withAnimation(reduceMotion ? nil : .default) {
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
                .accessibilityLabel("Remove \(itemName(for: item)) from collection")
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
            IconBadge(item.type.icon, size: .small)
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
