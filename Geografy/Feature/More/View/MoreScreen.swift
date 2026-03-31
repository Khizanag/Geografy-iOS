import SwiftUI
import GeografyDesign

struct MoreScreen: View {
    @Environment(\.horizontalSizeClass) private var sizeClass
    @Environment(Navigator.self) private var coordinator
    @Environment(HapticsService.self) private var hapticsService
    @Environment(TestingModeService.self) private var testingModeService
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    @State private var blobAnimating = false
    @State private var searchText = ""
    @State private var testChecklistSheet: MoreSheet?

    private let testChecklistService = TestChecklistService()

    var body: some View {
        itemList
            .background(DesignSystem.Color.background.ignoresSafeArea())
            .navigationTitle("More")
            .navigationBarTitleDisplayMode(.large)
            .searchable(text: $searchText, prompt: "Find a feature…")
            .sheet(item: $testChecklistSheet) { sheet in
                TestChecklistSheet(
                    title: sheet.label,
                    checklist: testChecklistService.checklist(for: sheet.testKey)
                )
                .presentationDetents([.medium])
            }
            .onAppear {
                blobAnimating = true
            }
    }
}

// MARK: - Subviews
private extension MoreScreen {
    var scrollableBlobs: some View {
        ZStack {
            blobEllipse(
                BlobConfig(
                    color: DesignSystem.Color.accent, opacity: 0.28,
                    endRadius: 220, width: 440, height: 320, blur: 32,
                    offset: (-80, -80), scale: blobAnimating ? 1.10 : 0.90
                )
            )
            blobEllipse(
                BlobConfig(
                    color: DesignSystem.Color.indigo, opacity: 0.20,
                    endRadius: 180, width: 360, height: 300, blur: 40,
                    offset: (140, 80), scale: blobAnimating ? 0.88 : 1.10
                )
            )
            blobEllipse(
                BlobConfig(
                    color: DesignSystem.Color.blue, opacity: 0.14,
                    endRadius: 160, width: 320, height: 260, blur: 36,
                    offset: (-100, 400), scale: blobAnimating ? 1.06 : 0.94
                )
            )
            blobEllipse(
                BlobConfig(
                    color: DesignSystem.Color.purple, opacity: 0.12,
                    endRadius: 160, width: 320, height: 280, blur: 44,
                    offset: (160, 700), scale: blobAnimating ? 0.92 : 1.08
                )
            )
            blobEllipse(
                BlobConfig(
                    color: DesignSystem.Color.accent, opacity: 0.10,
                    endRadius: 200, width: 400, height: 300, blur: 40,
                    offset: (-120, 1050), scale: blobAnimating ? 1.05 : 0.95
                )
            )
            blobEllipse(
                BlobConfig(
                    color: DesignSystem.Color.indigo, opacity: 0.14,
                    endRadius: 180, width: 360, height: 280, blur: 36,
                    offset: (140, 1400), scale: blobAnimating ? 0.90 : 1.10
                )
            )
            blobEllipse(
                BlobConfig(
                    color: DesignSystem.Color.blue, opacity: 0.10,
                    endRadius: 160, width: 320, height: 260, blur: 40,
                    offset: (-80, 1800), scale: blobAnimating ? 1.08 : 0.92
                )
            )
            blobEllipse(
                BlobConfig(
                    color: DesignSystem.Color.purple, opacity: 0.10,
                    endRadius: 160, width: 320, height: 280, blur: 44,
                    offset: (120, 2200), scale: blobAnimating ? 0.94 : 1.06
                )
            )
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
            if isSearching {
                searchResults
                    .readableContentWidth()
            } else {
                VStack(alignment: .leading, spacing: DesignSystem.Spacing.lg) {
                    hubSection(title: "You", items: youItems)
                    hubSection(title: "Play", items: playItems)
                    hubSection(title: "Explore", items: exploreItems)
                    hubSection(title: "Travel", items: travelItems)
                    hubSection(title: "App", items: appItems)
                }
                .padding(.horizontal, DesignSystem.Spacing.md)
                .padding(.vertical, DesignSystem.Spacing.sm)
                .readableContentWidth()
                .background(alignment: .top) { scrollableBlobs }
            }
        }
    }

    var isSearching: Bool {
        !searchText.trimmingCharacters(in: .whitespaces).isEmpty
    }

    var filteredItems: [MoreSheet] {
        let query = searchText.lowercased()
        let allItems = youItems + playItems + exploreItems + travelItems + appItems
        return allItems.filter {
            $0.label.lowercased().contains(query) ||
            $0.subtitle.lowercased().contains(query)
        }
    }

    var searchResults: some View {
        AdaptiveGrid(compactMinimum: 100, regularMinimum: 150) {
            ForEach(filteredItems, id: \.id) { sheet in
                gridTile(for: sheet)
            }
        }
        .padding(.horizontal, DesignSystem.Spacing.md)
        .padding(.vertical, DesignSystem.Spacing.sm)
    }

    func hubSection(title: String, items: [MoreSheet]) -> some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            SectionHeaderView(title: title)
            AdaptiveGrid(compactMinimum: 100, regularMinimum: 150) {
                ForEach(items, id: \.id) { sheet in
                    gridTile(for: sheet)
                }
            }
        }
    }

    func gridTile(for sheet: MoreSheet) -> some View {
        Button {
            hapticsService.impact(.light)
            coordinator.sheet(sheet.toDestination)
        } label: {
            VStack(spacing: tileSpacing) {
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
            .frame(maxWidth: .infinity)
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
        .buttonStyle(PressButtonStyle())
    }

    func testBadge(for sheet: MoreSheet) -> some View {
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

    var youItems: [MoreSheet] {
        [.profile, .favorites]
    }

    var playItems: [MoreSheet] {
        [
            .dailyChallenge, .exploreGame, .speedRun,
            .multiplayer, .quizPacks, .customQuiz,
            .flagGame, .trivia,
            .spellingBee, .landmarkQuiz, .wordSearch,
            .borderChallenge, .challengeRoom,
            .countryNicknames,
        ]
    }

    var exploreItems: [MoreSheet] {
        [
            .search, .compare, .distanceCalculator,
            .currencyConverter, .timeZones, .timeline,
            .orgs, .quotes, .feed, .learningPath,
        ]
    }

    var travelItems: [MoreSheet] {
        [.travel, .travelJournal, .travelBucketList]
    }

    var appItems: [MoreSheet] {
        [.achievements, .leaderboards, .srsStudy, .themes, .settings]
    }
}

// MARK: - Adaptive Tile Sizing
private extension MoreScreen {
    var isWide: Bool { sizeClass == .regular }

    var tileIconSize: CGFloat { isWide ? 52 : 36 }

    var tileIconFontSize: CGFloat { isWide ? 22 : 14 }

    var tileLabelFont: Font { isWide ? DesignSystem.Font.subheadline : DesignSystem.Font.caption }

    var tileSubtitleFont: Font { isWide ? DesignSystem.Font.caption : .system(size: 10) }

    var tileSpacing: CGFloat { isWide ? DesignSystem.Spacing.sm : DesignSystem.Spacing.xs }

    var tilePadding: CGFloat { isWide ? DesignSystem.Spacing.md : DesignSystem.Spacing.sm }
}
