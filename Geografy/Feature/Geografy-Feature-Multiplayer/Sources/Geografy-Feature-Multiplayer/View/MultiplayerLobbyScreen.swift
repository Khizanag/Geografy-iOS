import Geografy_Core_Common
import Geografy_Core_DesignSystem
import Geografy_Core_Navigation
import Geografy_Core_Service
import Geografy_Feature_Quiz
import SwiftUI

public struct MultiplayerLobbyScreen: View {
    // MARK: - Properties
    @Environment(Navigator.self) private var coordinator
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    public let multiplayerService: MultiplayerService

    @State private var selectedType: QuizType = .flagQuiz
    @State private var selectedRegion: QuizRegion = .world
    @State private var isSearching = false
    @State private var searchProgress: CGFloat = 0
    @State private var opponent: MockOpponent?
    @State private var showMatch = false

    private let color = DesignSystem.Color.error

    // MARK: - Init
    public init(multiplayerService: MultiplayerService) {
        self.multiplayerService = multiplayerService
    }

    // MARK: - Body
    public var body: some View {
        scrollContent
            .screenBackground()
            .navigationTitle("Multiplayer")
            .navigationBarTitleDisplayMode(.inline)
            .safeAreaBar(edge: .bottom) {
                if !isSearching {
                    footerButton
                }
            }
            .fullScreenCover(isPresented: $showMatch) {
                matchDestination
            }
            .onAppear { multiplayerService.reload() }
    }
}

// MARK: - Subviews
private extension MultiplayerLobbyScreen {
    var scrollContent: some View {
        ScrollView {
            Group {
                if isSearching {
                    searchingView
                        .transition(.opacity)
                } else {
                    lobbyContent
                        .transition(.opacity)
                }
            }
            .padding(.top, DesignSystem.Spacing.xs)
            .padding(.bottom, DesignSystem.Spacing.lg)
            .readableContentWidth()
            .animation(reduceMotion ? nil : .smooth(duration: 0.3), value: isSearching)
        }
    }

    var lobbyContent: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.lg) {
            GameIntroHeader(
                title: "Multiplayer",
                subtitle: "Race an opponent through ten questions.",
                systemImage: "person.2.fill",
                color: color,
                facts: [
                    GameIntroHeader.Fact("10 questions", systemImage: "list.number"),
                    GameIntroHeader.Fact("Medium", systemImage: "gauge.with.dots.needle.50percent"),
                ]
            )
            .padding(.horizontal, DesignSystem.Spacing.md)
            ratingCard
                .padding(.horizontal, DesignSystem.Spacing.md)
            quizTypeSection
            regionSection
                .padding(.horizontal, DesignSystem.Spacing.md)
            nearbySection
                .padding(.horizontal, DesignSystem.Spacing.md)
        }
    }

    var ratingCard: some View {
        let rating = multiplayerService.playerRating
        return CardView {
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
                HStack(spacing: DesignSystem.Spacing.md) {
                    IconBadge(rating.rankIcon, color: DesignSystem.Color.warning, size: .medium)
                    VStack(alignment: .leading, spacing: DesignSystem.Spacing.xxs) {
                        Text("\(rating.rating)")
                            .font(DesignSystem.Font.title2)
                            .fontWeight(.bold)
                            .monospacedDigit()
                            .foregroundStyle(DesignSystem.Color.textPrimary)
                        Text(rating.rankTitle)
                            .font(DesignSystem.Font.caption)
                            .foregroundStyle(DesignSystem.Color.textSecondary)
                    }
                    Spacer(minLength: 0)
                }
                FlowLayout(spacing: DesignSystem.Spacing.xs) {
                    InfoPill("\(rating.wins) won", style: .tinted(DesignSystem.Color.success))
                    InfoPill("\(rating.losses) lost", style: .tinted(DesignSystem.Color.error))
                    InfoPill("\(rating.draws) drawn", style: .neutral)
                }
            }
            .padding(DesignSystem.Spacing.md)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .accessibilityElement(children: .combine)
    }

    var quizTypeSection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            SectionHeaderView(title: "Quiz Type")
                .padding(.horizontal, DesignSystem.Spacing.md)
            TypeSelectionGrid(
                items: QuizType.allCases,
                selectedIDs: [selectedType.id],
                color: color,
                onSelect: { selectedType = $0 }
            )
        }
    }

    var regionSection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            SectionHeaderView(title: "Region")
            RegionPicker(selectedRegion: $selectedRegion, color: color)
        }
    }

    var nearbySection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            SectionHeaderView(title: "With Friends")
            Button {
                coordinator.cover(.localMultiplayer)
            } label: {
                CardView {
                    HStack(spacing: DesignSystem.Spacing.sm) {
                        IconBadge("antenna.radiowaves.left.and.right", color: color, size: .small)
                        VStack(alignment: .leading, spacing: DesignSystem.Spacing.xxs) {
                            Text("Play Nearby")
                                .font(DesignSystem.Font.subheadline)
                                .fontWeight(.semibold)
                                .foregroundStyle(DesignSystem.Color.textPrimary)
                            Text("Challenge a friend on a device close by.")
                                .font(DesignSystem.Font.caption)
                                .foregroundStyle(DesignSystem.Color.textSecondary)
                        }
                        Spacer(minLength: 0)
                        RowChevron()
                    }
                    .padding(DesignSystem.Spacing.md)
                }
            }
            .buttonStyle(PressButtonStyle())
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

            GlassButton("Cancel", systemImage: "xmark", role: .secondary) {
                cancelSearch()
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, DesignSystem.Spacing.md)
        .padding(.top, DesignSystem.Spacing.xl)
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
                comparisonMetric: .population,
                gameMode: .standard,
            )
            MultiplayerMatchScreen(
                opponent: opponent,
                configuration: configuration,
                multiplayerService: multiplayerService,
            )
        }
    }
}

// MARK: - Actions
private extension MultiplayerLobbyScreen {
    func startSearching() {
        isSearching = true
        opponent = nil

        let searchDuration = Double.random(in: 2.0...3.5)

        Task { @MainActor in
            try? await Task.sleep(for: .seconds(searchDuration))

            guard isSearching else { return }

            let foundOpponent = MockOpponent.makeRandom()

            opponent = foundOpponent

            try? await Task.sleep(for: .seconds(1.2))

            guard isSearching else { return }

            showMatch = true
            isSearching = false
        }
    }

    func cancelSearch() {
        isSearching = false
        opponent = nil
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
