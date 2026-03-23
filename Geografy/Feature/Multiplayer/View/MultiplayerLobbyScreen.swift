import SwiftUI

struct MultiplayerLobbyScreen: View {
    @Environment(\.dismiss) private var dismiss

    let multiplayerService: MultiplayerService

    @State private var selectedType: QuizType = .flagQuiz
    @State private var selectedRegion: QuizRegion = .world
    @State private var isSearching = false
    @State private var searchProgress: CGFloat = 0
    @State private var opponent: MockOpponent?
    @State private var showMatch = false
    @State private var blobAnimating = false

    var body: some View {
        ScrollView {
            VStack(spacing: DesignSystem.Spacing.xl) {
                ratingHeader
                configurationSection
                if isSearching {
                    searchingView
                }
            }
            .padding(.vertical, DesignSystem.Spacing.lg)
        }
        .safeAreaInset(edge: .bottom) {
            if !isSearching {
                footerButton
            }
        }
        .background { ambientBlobs }
        .background(DesignSystem.Color.background.ignoresSafeArea())
        .navigationTitle("Multiplayer")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                CircleCloseButton { dismiss() }
            }
        }
        .onAppear { startBlobAnimation() }
        .fullScreenCover(isPresented: $showMatch) {
            matchDestination
        }
    }
}

// MARK: - Subviews

private extension MultiplayerLobbyScreen {
    var ratingHeader: some View {
        VStack(spacing: DesignSystem.Spacing.sm) {
            ratingBadge
            ratingStats
        }
        .padding(.horizontal, DesignSystem.Spacing.md)
    }

    var ratingBadge: some View {
        VStack(spacing: DesignSystem.Spacing.xs) {
            Image(systemName: multiplayerService.playerRating.rankIcon)
                .font(DesignSystem.IconSize.large)
                .foregroundStyle(DesignSystem.Color.accent)

            Text("\(multiplayerService.playerRating.rating)")
                .font(DesignSystem.Font.largeTitle)
                .foregroundStyle(DesignSystem.Color.textPrimary)

            Text(multiplayerService.playerRating.rankTitle)
                .font(DesignSystem.Font.subheadline)
                .foregroundStyle(DesignSystem.Color.textSecondary)
        }
    }

    var ratingStats: some View {
        HStack(spacing: DesignSystem.Spacing.lg) {
            statPill(
                label: "W",
                value: "\(multiplayerService.playerRating.wins)",
                color: DesignSystem.Color.success
            )
            statPill(
                label: "L",
                value: "\(multiplayerService.playerRating.losses)",
                color: DesignSystem.Color.error
            )
            statPill(
                label: "D",
                value: "\(multiplayerService.playerRating.draws)",
                color: DesignSystem.Color.warning
            )
        }
    }

    func statPill(label: String, value: String, color: Color) -> some View {
        HStack(spacing: DesignSystem.Spacing.xxs) {
            Text(label)
                .font(DesignSystem.Font.caption)
                .foregroundStyle(color)
            Text(value)
                .font(DesignSystem.Font.headline)
                .foregroundStyle(DesignSystem.Color.textPrimary)
        }
        .padding(.horizontal, DesignSystem.Spacing.sm)
        .padding(.vertical, DesignSystem.Spacing.xxs)
        .background(color.opacity(0.15), in: Capsule())
    }

    var configurationSection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
            SectionHeaderView(title: "Quiz Type", icon: "questionmark.circle")
                .padding(.horizontal, DesignSystem.Spacing.md)

            TypeSelectionGrid(
                items: QuizType.allCases.map { $0 },
                selectedIDs: [selectedType.id],
                onSelect: { selectedType = $0 }
            )

            SectionHeaderView(title: "Region", icon: "globe")
                .padding(.horizontal, DesignSystem.Spacing.md)

            RegionSelectionBar(
                items: QuizRegion.allCases.map { $0 },
                selectedID: selectedRegion.id,
                onSelect: { selectedRegion = $0 }
            )
        }
    }

    var footerButton: some View {
        GlassButton("Find Opponent", systemImage: "person.2.fill", fullWidth: true) {
            startSearching()
        }
        .padding(.horizontal, DesignSystem.Spacing.md)
        .padding(.bottom, DesignSystem.Spacing.md)
    }

    var searchingView: some View {
        VStack(spacing: DesignSystem.Spacing.lg) {
            PulsingCirclesView(icon: "magnifyingglass", isAnimating: isSearching)
                .frame(height: 200)

            Text("Searching for opponent...")
                .font(DesignSystem.Font.headline)
                .foregroundStyle(DesignSystem.Color.textPrimary)

            if let opponent {
                opponentFoundCard(opponent)
                    .transition(.scale(scale: 0.8).combined(with: .opacity))
            }

            Button { cancelSearch() } label: {
                Text("Cancel")
                    .font(DesignSystem.Font.subheadline)
                    .foregroundStyle(DesignSystem.Color.textSecondary)
            }
            .buttonStyle(.plain)
        }
    }

    func opponentFoundCard(_ foundOpponent: MockOpponent) -> some View {
        CardView {
            HStack(spacing: DesignSystem.Spacing.md) {
                OpponentAvatarView(
                    opponent: foundOpponent,
                    size: DesignSystem.Size.xxl
                )

                VStack(alignment: .leading, spacing: DesignSystem.Spacing.xxs) {
                    Text(foundOpponent.name)
                        .font(DesignSystem.Font.headline)
                        .foregroundStyle(DesignSystem.Color.textPrimary)
                        .lineLimit(1)

                    Text(skillLabel(for: foundOpponent.skillLevel))
                        .font(DesignSystem.Font.caption)
                        .foregroundStyle(DesignSystem.Color.textSecondary)
                }

                Spacer(minLength: 0)

                Image(systemName: "checkmark.circle.fill")
                    .font(DesignSystem.Font.title2)
                    .foregroundStyle(DesignSystem.Color.success)
            }
            .padding(DesignSystem.Spacing.md)
        }
    }

    @ViewBuilder
    var matchDestination: some View {
        if let opponent {
            let configuration = QuizConfiguration(
                type: selectedType,
                region: selectedRegion,
                difficulty: .medium,
                questionCount: .ten,
                answerMode: .multipleChoice,
            )
            MultiplayerMatchScreen(
                opponent: opponent,
                configuration: configuration,
                multiplayerService: multiplayerService,
            )
        }
    }
}

// MARK: - Background

private extension MultiplayerLobbyScreen {
    var ambientBlobs: some View {
        ZStack {
            Ellipse()
                .fill(
                    RadialGradient(
                        colors: [
                            DesignSystem.Color.accent.opacity(0.18),
                            DesignSystem.Color.background.opacity(0),
                        ],
                        center: .center,
                        startRadius: 0,
                        endRadius: 200
                    )
                )
                .frame(width: 400, height: 300)
                .blur(radius: 40)
                .offset(x: -60, y: -120)
                .scaleEffect(blobAnimating ? 1.08 : 0.92)

            Ellipse()
                .fill(
                    RadialGradient(
                        colors: [
                            DesignSystem.Color.purple.opacity(0.14),
                            DesignSystem.Color.background.opacity(0),
                        ],
                        center: .center,
                        startRadius: 0,
                        endRadius: 180
                    )
                )
                .frame(width: 350, height: 280)
                .blur(radius: 44)
                .offset(x: 120, y: 80)
                .scaleEffect(blobAnimating ? 0.90 : 1.08)
        }
        .allowsHitTesting(false)
        .ignoresSafeArea()
    }

    func startBlobAnimation() {
        withAnimation(
            .easeInOut(duration: 6).repeatForever(autoreverses: true)
        ) {
            blobAnimating = true
        }
    }
}

// MARK: - Actions

private extension MultiplayerLobbyScreen {
    func startSearching() {
        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
            isSearching = true
            opponent = nil
        }

        let searchDuration = Double.random(in: 2.0...3.5)

        Task { @MainActor in
            try? await Task.sleep(for: .seconds(searchDuration))

            guard isSearching else { return }

            let foundOpponent = MockOpponent.makeRandom()

            withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                opponent = foundOpponent
            }

            try? await Task.sleep(for: .seconds(1.2))

            guard isSearching else { return }

            showMatch = true
            isSearching = false
        }
    }

    func cancelSearch() {
        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
            isSearching = false
            opponent = nil
        }
    }
}

// MARK: - Helpers

private extension MultiplayerLobbyScreen {
    func skillLabel(for skillLevel: Double) -> String {
        if skillLevel >= 0.85 {
            "Expert Player"
        } else if skillLevel >= 0.75 {
            "Advanced Player"
        } else if skillLevel >= 0.65 {
            "Intermediate Player"
        } else {
            "Casual Player"
        }
    }
}
