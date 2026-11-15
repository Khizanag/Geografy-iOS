import Geografy_Core_DesignSystem
import Geografy_Core_Navigation
import Geografy_Core_Service
import SwiftUI

// One for the app: tab roots rebuild this screen often, and the checklists never change.
@MainActor private let testChecklistService = TestChecklistService()

/// A tab root: an optional header above titled grids of feature tiles.
struct HubScreen<Header: View>: View {
    // MARK: - Properties
    @Environment(\.horizontalSizeClass) private var sizeClass
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @Environment(Navigator.self) private var coordinator
    @Environment(HapticsService.self) private var hapticsService
    @Environment(TestingModeService.self) private var testingModeService

    @State private var testChecklistSheet: HubItem?

    let title: String
    let sections: [HubSection]
    @ViewBuilder let header: () -> Header

    // MARK: - Body
    var body: some View {
        itemList
            .screenBackground()
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.large)
            .sheet(item: $testChecklistSheet) { item in
                CoordinatedNavigationStack(showCloseButton: true) {
                    TestChecklistSheet(
                        title: item.label,
                        checklist: testChecklistService.checklist(for: item.testKey)
                    )
                    .presentationDetents([.medium])
                }
            }
    }
}

// MARK: - Section
struct HubSection: Identifiable {
    let title: String
    let items: [HubItem]

    var id: String { title }
}

// MARK: - Subviews
private extension HubScreen {
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
                LazyVGrid(columns: gridColumns, spacing: DesignSystem.Spacing.sm) {
                    ForEach(items, id: \.id) { sheet in
                        gridTile(for: sheet)
                    }
                }
            }
        }
    }

    func gridTile(for sheet: HubItem) -> some View {
        Button {
            hapticsService.impact(.light)
            open(sheet.toDestination)
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
            in: .rect(cornerRadius: DesignSystem.CornerRadius.large)
        )
        .accessibilityElement(children: .combine)
        .overlay(alignment: .topTrailing) {
            if testingModeService.isEnabled {
                testBadge(for: sheet)
            }
        }
    }

    func testBadge(for sheet: HubItem) -> some View {
        Button {
            testChecklistSheet = sheet
        } label: {
            Image(systemName: "ladybug.fill")
                .font(DesignSystem.Font.micro)
                .foregroundStyle(DesignSystem.Color.onAccent)
                .padding(DesignSystem.Spacing.xxs)
                .background(DesignSystem.Color.orange, in: Circle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Test checklist for \(sheet.label)")
        .offset(x: 4, y: -4)
    }
}

// MARK: - Navigation
private extension HubScreen {
    // Games run full screen; everything else opens inside the tab.
    func open(_ destination: Destination) {
        if case .quizSession = destination {
            coordinator.cover(destination)
        } else {
            coordinator.push(destination)
        }
    }
}

// MARK: - Adaptive Tile Sizing
private extension HubScreen {
    var isWide: Bool { sizeClass == .regular }

    /// Two tiles a row on a phone, so names fit on a line or two beside a readable icon;
    /// one at accessibility text sizes, and as many as fit on a wide screen.
    var gridColumns: [GridItem] {
        let spacing = DesignSystem.Spacing.sm
        if isWide {
            return [GridItem(.adaptive(minimum: 200), spacing: spacing)]
        }
        let count = dynamicTypeSize.isAccessibilitySize ? 1 : 2
        return Array(repeating: GridItem(.flexible(), spacing: spacing), count: count)
    }
}
