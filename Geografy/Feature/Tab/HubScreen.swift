import Geografy_Core_DesignSystem
import Geografy_Core_Navigation
import Geografy_Core_Service
import SwiftUI

#if DEBUG
// One for the app: tab roots rebuild this screen often, and the checklists never change.
@MainActor private let testChecklistService = TestChecklistService()
#endif

/// A tab root: a large title over a ``HubGrid``.
struct HubScreen<Header: View>: View {
    let title: String
    let sections: [HubSection]
    @ViewBuilder let header: () -> Header

    var body: some View {
        HubGrid(sections: sections, header: header)
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.large)
    }
}

/// An optional header above titled grids of feature tiles.
struct HubGrid<Header: View>: View {
    // MARK: - Properties
    @Environment(\.horizontalSizeClass) private var sizeClass
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @Environment(Navigator.self) private var coordinator
    @Environment(TestingModeService.self) private var testingModeService

    @State private var testChecklistSheet: HubItem?

    let sections: [HubSection]
    @ViewBuilder let header: () -> Header

    // MARK: - Body
    var body: some View {
        itemList
            #if DEBUG
            .sheet(item: $testChecklistSheet) { item in
                CoordinatedNavigationStack(showCloseButton: true) {
                    TestChecklistSheet(
                        item: item,
                        checklist: testChecklistService.checklist(for: item.testKey)
                    ) {
                        testChecklistSheet = nil
                        open(item)
                    }
                    .presentationDetents([.medium, .large])
                }
            }
            #endif
    }
}

// MARK: - Section
struct HubSection: Identifiable {
    let title: String
    let items: [HubItem]

    var id: String { title }
}

// MARK: - Subviews
private extension HubGrid {
    var itemList: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.lg) {
                header()
                ForEach(sections) { section in
                    hubSection(title: section.title, items: section.items)
                }
            }
            .padding(.horizontal, DesignSystem.Spacing.md)
            .padding(.vertical, DesignSystem.Spacing.sm)
            .readableContentWidth()
        }
        .scrollEdgeEffectStyle(.soft, for: .top)
        .screenBackground()
    }

    func hubSection(title: String, items: [HubItem]) -> some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            SectionHeaderView(title: title)
            GlassEffectContainer {
                tileGrid(items)
            }
            // Over the container rather than on each tile: the container draws every tile's glass in one layer,
            // which would cover a badge hanging over a tile's corner.
            .overlayPreferenceValue(TestBadgeAnchorKey.self) { anchors in
                testBadges(for: items, at: anchors)
            }
        }
    }

    func gridTile(for sheet: HubItem) -> some View {
        Button {
            open(sheet)
        } label: {
            gridTileLabel(for: sheet)
        }
        .buttonStyle(PressButtonStyle())
    }

    func gridTileLabel(for sheet: HubItem) -> some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            IconBadge(sheet.icon, color: sheet.color, size: isWide ? .large : .medium)

            VStack(alignment: .leading, spacing: DesignSystem.Spacing.xxs) {
                Text(sheet.label)
                    .font(isWide ? DesignSystem.Font.headline : DesignSystem.Font.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(DesignSystem.Color.textPrimary)
                    .lineLimit(2)

                Text(sheet.subtitle)
                    .font(isWide ? DesignSystem.Font.subheadline : DesignSystem.Font.caption)
                    .foregroundStyle(DesignSystem.Color.textSecondary)
                    .lineLimit(2)
            }
            .multilineTextAlignment(.leading)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .padding(isWide ? DesignSystem.Spacing.lg : DesignSystem.Spacing.md)
        .glassEffect(
            .regular,
            in: .rect(cornerRadius: DesignSystem.CornerRadius.extraLarge)
        )
        // The glass doesn't take touches, so without this only the icon and text would.
        .contentShape(.rect(cornerRadius: DesignSystem.CornerRadius.extraLarge))
        .accessibilityElement(children: .combine)
        .anchorPreference(key: TestBadgeAnchorKey.self, value: .topTrailing) { [sheet: $0] }
    }

    /// Testing Mode is a debug tool, so release builds never draw the badges.
    @ViewBuilder
    func testBadges(for items: [HubItem], at anchors: [HubItem: Anchor<CGPoint>]) -> some View {
        #if DEBUG
        if testingModeService.isEnabled {
            GeometryReader { proxy in
                ForEach(items) { item in
                    if let anchor = anchors[item] {
                        let corner = proxy[anchor]
                        // A point just past the corner, with the badge's top-trailing corner hung on it.
                        Color.clear
                            .frame(width: 0, height: 0)
                            .overlay(alignment: .topTrailing) {
                                testBadge(for: item).fixedSize()
                            }
                            .position(x: corner.x + 4, y: corner.y - 4)
                    }
                }
            }
        }
        #endif
    }

    /// A glass button half over the tile's top-trailing corner.
    func testBadge(for sheet: HubItem) -> some View {
        Button {
            testChecklistSheet = sheet
        } label: {
            Image(systemName: "ladybug.fill")
                .font(DesignSystem.Font.caption)
        }
        .buttonStyle(.glassProminent)
        .buttonBorderShape(.circle)
        .controlSize(.small)
        .tint(DesignSystem.Color.orange)
        .accessibilityLabel("Test checklist for \(sheet.label)")
    }
}

// MARK: - Navigation
private extension HubGrid {
    /// Every game opens on its own setup page, with its guide, before anything starts.
    func open(_ item: HubItem) {
        coordinator.push(item.destination)
    }
}

// MARK: - Adaptive Tile Sizing
private extension HubGrid {
    var isWide: Bool { sizeClass == .regular }

    /// Two tiles a row on a phone, so names fit on a line or two beside a readable icon, with a last tile on its
    /// own taking the full width; one at accessibility text sizes, and as many as fit on a wide screen.
    @ViewBuilder
    func tileGrid(_ items: [HubItem]) -> some View {
        let spacing = DesignSystem.Spacing.sm
        if isWide {
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 200), spacing: spacing)], spacing: spacing) {
                ForEach(items) { item in
                    gridTile(for: item)
                }
            }
        } else {
            let columnCount = dynamicTypeSize.isAccessibilitySize ? 1 : 2
            Grid(horizontalSpacing: spacing, verticalSpacing: spacing) {
                ForEach(rows(of: items, columnCount: columnCount), id: \.self) { row in
                    GridRow {
                        ForEach(row) { item in
                            gridTile(for: item)
                                .gridCellColumns(columnCount - row.count + 1)
                        }
                    }
                }
            }
        }
    }

    func rows(of items: [HubItem], columnCount: Int) -> [[HubItem]] {
        stride(from: 0, to: items.count, by: columnCount).map { start in
            Array(items[start..<min(start + columnCount, items.count)])
        }
    }
}

// MARK: - Test Badge Anchors
/// Each tile's top-trailing corner, so its test badge can be drawn above the glass container.
private struct TestBadgeAnchorKey: PreferenceKey {
    static let defaultValue: [HubItem: Anchor<CGPoint>] = [:]

    static func reduce(value: inout [HubItem: Anchor<CGPoint>], nextValue: () -> [HubItem: Anchor<CGPoint>]) {
        value.merge(nextValue()) { $1 }
    }
}
