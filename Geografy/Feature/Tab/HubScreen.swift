import Geografy_Core_DesignSystem
import Geografy_Core_Navigation
import Geografy_Core_Service
import SwiftUI

/// A tab root: an optional header above titled grids of feature tiles.
struct HubScreen<Header: View>: View {
    // MARK: - Properties
    @Environment(\.horizontalSizeClass) private var sizeClass
    @Environment(Navigator.self) private var coordinator
    @Environment(HapticsService.self) private var hapticsService
    @Environment(TestingModeService.self) private var testingModeService
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    @ScaledMetric(relativeTo: .caption) private var iconScale: CGFloat = 1

    @State private var testChecklistSheet: HubItem?

    let title: String
    let sections: [HubSection]
    @ViewBuilder let header: () -> Header

    private let testChecklistService = TestChecklistService()

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
                AdaptiveGrid(
                    compactMinimum: dynamicTypeSize.isAccessibilitySize ? 160 : 100,
                    regularMinimum: dynamicTypeSize.isAccessibilitySize ? 240 : 150
                ) {
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
        VStack(spacing: tileSpacing) {
            gridTileIcon(for: sheet)

            Text(sheet.label)
                .font(tileLabelFont)
                .fontWeight(.medium)
                .foregroundStyle(DesignSystem.Color.textPrimary)
                .lineLimit(3)
                .minimumScaleFactor(0.8)
                .multilineTextAlignment(.center)
                .padding(.horizontal, DesignSystem.Spacing.xxs)

            Text(sheet.subtitle)
                .font(tileSubtitleFont)
                .foregroundStyle(DesignSystem.Color.textSecondary)
                .lineLimit(2)
                .minimumScaleFactor(0.8)
                .multilineTextAlignment(.center)
                .padding(.horizontal, DesignSystem.Spacing.xxs)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .padding(.vertical, tilePadding)
        .glassEffect(
            .regular,
            in: .rect(cornerRadius: DesignSystem.CornerRadius.medium)
        )
        .overlay(alignment: .topTrailing) {
            if testingModeService.isEnabled {
                testBadge(for: sheet)
            }
        }
    }

    func gridTileIcon(for sheet: HubItem) -> some View {
        ZStack {
            RoundedRectangle(
                cornerRadius: DesignSystem.CornerRadius.small
            )
            .fill(sheet.color.opacity(0.15))
            .frame(width: tileIconSize, height: tileIconSize)
            Image(systemName: sheet.icon)
                .font(DesignSystem.Font.system(size: tileIconFontSize))
                .foregroundStyle(sheet.color)
        }
        .accessibilityHidden(true)
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

    var tileIconSize: CGFloat { (isWide ? 52 : 36) * iconScale }

    var tileIconFontSize: CGFloat { (isWide ? 22 : 14) * iconScale }

    var tileLabelFont: Font { isWide ? DesignSystem.Font.subheadline : DesignSystem.Font.caption }

    var tileSubtitleFont: Font { isWide ? DesignSystem.Font.caption : DesignSystem.Font.micro }

    var tileSpacing: CGFloat { isWide ? DesignSystem.Spacing.sm : DesignSystem.Spacing.xs }

    var tilePadding: CGFloat { isWide ? DesignSystem.Spacing.md : DesignSystem.Spacing.sm }
}
