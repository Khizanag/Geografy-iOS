import SwiftUI

struct MoreScreen: View {
    @Environment(TabCoordinator.self) private var coordinator
    @Environment(HapticsService.self) private var hapticsService

    @State private var blobAnimating = false

    var body: some View {
        itemList
            .background {
                ambientBlobs
            }
            .background(DesignSystem.Color.background.ignoresSafeArea())
            .navigationTitle("More")
            .navigationBarTitleDisplayMode(.large)
            .onAppear {
                withAnimation(.easeInOut(duration: 6).repeatForever(autoreverses: true)) {
                    blobAnimating = true
                }
            }
    }
}

// MARK: - Subviews

private extension MoreScreen {
    var ambientBlobs: some View {
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
                    offset: (160, 650), scale: blobAnimating ? 0.92 : 1.08
                )
            )
        }
        .allowsHitTesting(false)
        .ignoresSafeArea()
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
                hubSection(title: "You", items: youItems)
                hubSection(title: "Play", items: playItems)
                hubSection(title: "Explore", items: exploreItems)
                hubSection(title: "Travel", items: travelItems)
                hubSection(title: "App", items: appItems)
            }
            .padding(.horizontal, DesignSystem.Spacing.md)
            .padding(.vertical, DesignSystem.Spacing.sm)
        }
    }

    func hubSection(title: String, items: [MoreSheet]) -> some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            SectionHeaderView(title: title)
            LazyVGrid(
                columns: [
                    GridItem(
                        .adaptive(minimum: 120),
                        spacing: DesignSystem.Spacing.sm
                    ),
                ],
                spacing: DesignSystem.Spacing.sm
            ) {
                ForEach(items, id: \.id) { sheet in
                    gridTile(for: sheet)
                }
            }
        }
    }

    func gridTile(for sheet: MoreSheet) -> some View {
        Button {
            hapticsService.impact(.light)
            coordinator.present(sheet.toSheet)
        } label: {
            VStack(spacing: DesignSystem.Spacing.xs) {
                ZStack {
                    RoundedRectangle(
                        cornerRadius: DesignSystem.CornerRadius.small
                    )
                    .fill(sheet.color.opacity(0.15))
                    .frame(width: 36, height: 36)
                    Image(systemName: sheet.icon)
                        .font(DesignSystem.Font.subheadline)
                        .foregroundStyle(sheet.color)
                }
                Text(sheet.label)
                    .font(DesignSystem.Font.caption)
                    .fontWeight(.medium)
                    .foregroundStyle(DesignSystem.Color.textPrimary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, DesignSystem.Spacing.sm)
            .background(DesignSystem.Color.cardBackground)
            .clipShape(
                RoundedRectangle(
                    cornerRadius: DesignSystem.CornerRadius.medium
                )
            )
            .overlay(
                RoundedRectangle(
                    cornerRadius: DesignSystem.CornerRadius.medium
                )
                .strokeBorder(sheet.color.opacity(0.12), lineWidth: 1)
            )
        }
        .buttonStyle(PressButtonStyle())
    }

    var youItems: [MoreSheet] {
        [.profile, .countries, .favorites, .badges]
    }

    var playItems: [MoreSheet] {
        [
            .dailyChallenge, .exploreGame, .speedRun,
            .multiplayer, .quizPacks, .customQuiz,
        ]
    }

    var exploreItems: [MoreSheet] {
        [.search, .compare, .distanceCalculator, .currencyConverter, .timeZones, .timeline, .orgs]
    }

    var travelItems: [MoreSheet] {
        [.travel, .travelJournal]
    }

    var appItems: [MoreSheet] {
        [.achievements, .leaderboards, .themes, .settings]
    }

}
