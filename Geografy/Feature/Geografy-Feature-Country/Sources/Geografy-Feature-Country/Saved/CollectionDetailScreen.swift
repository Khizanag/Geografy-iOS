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
            .haptic(.impact(weight: .light), trigger: collectionService.items(in: collectionName).count)
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
            coordinator.push(CountryRoute.countries)
        }
    }

    func itemList(groups: [TypeGroup]) -> some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.lg) {
                ForEach(groups, id: \.type) { group in
                    typeSection(group)
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

    func typeSection(_ group: TypeGroup) -> some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            SectionHeaderView(title: group.type.pluralName, icon: group.type.icon)
            if group.type == .country {
                CountryRowListCard(
                    group.items.compactMap { countryDataService.country(for: $0.itemID) },
                    open: { coordinator.push(CountryRoute.countryDetail($0)) },
                    remove: { remove(itemID: $0.code, type: .country) }
                )
            } else {
                RowListCard(group.items, dividerInset: Self.itemDividerInset, menu: itemMenu) { item in
                    itemRow(item)
                }
            }
        }
    }

    /// A saved ocean, language, or organization: it opens where it has a page of its own.
    @ViewBuilder
    func itemRow(_ item: CollectionItem) -> some View {
        if let open = opener(for: item) {
            Button(action: open) {
                itemLabel(item) { RowChevron() }
            }
            .buttonStyle(PressButtonStyle())
            .accessibilityElement(children: .combine)
        } else {
            itemLabel(item) { EmptyView() }
                .accessibilityElement(children: .combine)
        }
    }

    func itemLabel(_ item: CollectionItem, @ViewBuilder trailing: () -> some View) -> some View {
        HStack(spacing: DesignSystem.Spacing.sm) {
            IconBadge(item.type.icon, size: .small)
            CollectionItemTitle(name: itemName(for: item), type: item.type)
            Spacer(minLength: 0)
            trailing()
        }
        .rowListCardRow()
    }

    var itemMenu: RowListMenu<CollectionItem> {
        let name = itemName(for:)
        return RowListMenu(
            open: nil,
            text: name,
            remove: { remove(itemID: $0.itemID, type: $0.type) },
            preview: { item in CollectionItemPreview(name: name(item), type: item.type) }
        )
    }

    static let itemDividerInset = RowListCardLayout.dividerInset(after: IconBadge.Size.small.diameter)
}

// MARK: - Actions
private extension CollectionDetailScreen {
    func remove(itemID: String, type: CollectionItem.ItemType) {
        withAnimation(reduceMotion ? nil : .default) {
            collectionService.remove(itemID: itemID, type: type, from: collectionName)
        }
    }

    func opener(for item: CollectionItem) -> (() -> Void)? {
        guard item.type == .organization, let organization = Organization.find(item.itemID) else { return nil }
        return { coordinator.push(DiscoverRoute.organizationDetail(organization)) }
    }
}

// MARK: - Helpers
private extension CollectionDetailScreen {
    func itemName(for item: CollectionItem) -> String {
        switch item.type {
        case .country:
            countryDataService.country(for: item.itemID)?.name ?? item.itemID
        case .organization:
            Organization.find(item.itemID)?.displayName ?? item.itemID
        case .ocean, .language:
            item.itemID
        }
    }
}

// MARK: - Item Preview
/// What a long press on a saved item lifts: its badge, name, and kind.
private struct CollectionItemPreview: View {
    let name: String
    let type: CollectionItem.ItemType

    var body: some View {
        HStack(spacing: DesignSystem.Spacing.sm) {
            IconBadge(type.icon, size: .medium)
            CollectionItemTitle(name: name, type: type)
            Spacer(minLength: 0)
        }
        .padding(DesignSystem.Spacing.md)
    }
}

// MARK: - Item Title
/// A saved item's name over its kind.
private struct CollectionItemTitle: View {
    let name: String
    let type: CollectionItem.ItemType

    var body: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.xxxs) {
            Text(name)
                .font(DesignSystem.Font.subheadline)
                .fontWeight(.semibold)
                .foregroundStyle(DesignSystem.Color.textPrimary)
            Text(type.displayName)
                .font(DesignSystem.Font.caption)
                .foregroundStyle(DesignSystem.Color.textSecondary)
        }
    }
}
