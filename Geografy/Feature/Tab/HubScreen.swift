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
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    @State private var blobAnimating = false
    @State private var testChecklistSheet: HubItem?

    let title: String
    let sections: [HubSection]
    @ViewBuilder let header: () -> Header

    private let testChecklistService = TestChecklistService()

    // MARK: - Body
    var body: some View {
        itemList
            .background(DesignSystem.Color.background.ignoresSafeArea())
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.large)
            .onAppear {
                blobAnimating = true
            }
            .sheet(item: $testChecklistSheet) { item in
                TestChecklistSheet(
                    title: item.label,
                    checklist: testChecklistService.checklist(for: item.testKey)
                )
                .presentationDetents([.medium])
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
    var blobConfigs: [BlobConfig] {
        [
            BlobConfig(
                color: DesignSystem.Color.accent, opacity: 0.28,
                endRadius: 220, width: 440, height: 320, blur: 32,
                offset: (-80, -80), scale: blobAnimating ? 1.10 : 0.90
            ),
            BlobConfig(
                color: DesignSystem.Color.indigo, opacity: 0.20,
                endRadius: 180, width: 360, height: 300, blur: 40,
                offset: (140, 80), scale: blobAnimating ? 0.88 : 1.10
            ),
            BlobConfig(
                color: DesignSystem.Color.blue, opacity: 0.14,
                endRadius: 160, width: 320, height: 260, blur: 36,
                offset: (-100, 400), scale: blobAnimating ? 1.06 : 0.94
            ),
            BlobConfig(
                color: DesignSystem.Color.purple, opacity: 0.12,
                endRadius: 160, width: 320, height: 280, blur: 44,
                offset: (160, 700), scale: blobAnimating ? 0.92 : 1.08
            ),
            BlobConfig(
                color: DesignSystem.Color.accent, opacity: 0.10,
                endRadius: 200, width: 400, height: 300, blur: 40,
                offset: (-120, 1_050), scale: blobAnimating ? 1.05 : 0.95
            ),
            BlobConfig(
                color: DesignSystem.Color.indigo, opacity: 0.14,
                endRadius: 180, width: 360, height: 280, blur: 36,
                offset: (140, 1_400), scale: blobAnimating ? 0.90 : 1.10
            ),
            BlobConfig(
                color: DesignSystem.Color.blue, opacity: 0.10,
                endRadius: 160, width: 320, height: 260, blur: 40,
                offset: (-80, 1_800), scale: blobAnimating ? 1.08 : 0.92
            ),
            BlobConfig(
                color: DesignSystem.Color.purple, opacity: 0.10,
                endRadius: 160, width: 320, height: 280, blur: 44,
                offset: (120, 2_200), scale: blobAnimating ? 0.94 : 1.06
            ),
        ]
    }

    var scrollableBlobs: some View {
        ZStack {
            ForEach(Array(blobConfigs.enumerated()), id: \.offset) { _, config in
                blobEllipse(config)
            }
        }
        .allowsHitTesting(false)
        .animation(reduceMotion ? nil : .easeInOut(duration: 6).repeatForever(autoreverses: true), value: blobAnimating)
    }

    struct BlobConfig {
        let color: Color
        let opacity: Double
        let endRadius: CGFloat
        let width: CGFloat
        let height: CGFloat
        let blur: CGFloat
        let offset: (CGFloat, CGFloat)
        let scale: CGFloat
    }

    func blobEllipse(_ config: BlobConfig) -> some View {
        Ellipse()
            .fill(
                RadialGradient(
                    colors: [config.color.opacity(config.opacity), .clear],
                    center: .center,
                    startRadius: 0,
                    endRadius: config.endRadius
                )
            )
            .frame(width: config.width, height: config.height)
            .blur(radius: config.blur)
            .offset(x: config.offset.0, y: config.offset.1)
            .scaleEffect(config.scale)
    }

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
            .background(alignment: .top) { scrollableBlobs }
        }
        .scrollEdgeEffectStyle(.soft, for: .top)
    }

    func hubSection(title: String, items: [HubItem]) -> some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            SectionHeaderView(title: title)
            AdaptiveGrid(compactMinimum: 100, regularMinimum: 150) {
                ForEach(items, id: \.id) { sheet in
                    gridTile(for: sheet)
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
                .lineLimit(2)
                .minimumScaleFactor(0.65)
                .multilineTextAlignment(.center)
                .padding(.horizontal, DesignSystem.Spacing.xxs)

            Text(sheet.subtitle)
                .font(tileSubtitleFont)
                .foregroundStyle(DesignSystem.Color.textTertiary)
                .lineLimit(1)
                .minimumScaleFactor(0.6)
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
    }

    func testBadge(for sheet: HubItem) -> some View {
        Button {
            testChecklistSheet = sheet
        } label: {
            Image(systemName: "ladybug.fill")
                .font(DesignSystem.Font.micro)
                .foregroundStyle(DesignSystem.Color.onAccent)
                .padding(4)
                .background(DesignSystem.Color.orange, in: Circle())
        }
        .buttonStyle(.plain)
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

    var tileIconSize: CGFloat { isWide ? 52 : 36 }

    var tileIconFontSize: CGFloat { isWide ? 22 : 14 }

    var tileLabelFont: Font { isWide ? DesignSystem.Font.subheadline : DesignSystem.Font.caption }

    var tileSubtitleFont: Font { isWide ? DesignSystem.Font.caption : .system(size: 10) }

    var tileSpacing: CGFloat { isWide ? DesignSystem.Spacing.sm : DesignSystem.Spacing.xs }

    var tilePadding: CGFloat { isWide ? DesignSystem.Spacing.md : DesignSystem.Spacing.sm }
}
