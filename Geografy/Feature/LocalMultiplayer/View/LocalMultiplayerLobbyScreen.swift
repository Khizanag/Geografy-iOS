#if !os(tvOS)
import SwiftUI

struct LocalMultiplayerLobbyScreen: View {
    @Environment(HapticsService.self) private var hapticsService

    @Bindable var coordinator: LocalMultiplayerCoordinator

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: DesignSystem.Spacing.xl) {
                connectionStatus
                if coordinator.isHost {
                    hostConfigSection
                }
                if let opponent = coordinator.opponent {
                    opponentCard(opponent)
                } else {
                    waitingSection
                }
                if !coordinator.isHost, coordinator.opponent != nil {
                    guestReadySection
                }
            }
            .padding(.horizontal, DesignSystem.Spacing.md)
            .padding(.vertical, DesignSystem.Spacing.md)
        }
        .safeAreaInset(edge: .bottom) {
            if coordinator.isHost, coordinator.opponent?.isReady == true {
                startButton
            }
        }
        .background { AmbientBlobsView(.standard) }
        .background(DesignSystem.Color.background.ignoresSafeArea())
        .navigationTitle(coordinator.isHost ? "Host Lobby" : "Join Lobby")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Connection Status
private extension LocalMultiplayerLobbyScreen {
    var connectionStatus: some View {
        HStack(spacing: DesignSystem.Spacing.sm) {
            Circle()
                .fill(coordinator.opponent != nil ? DesignSystem.Color.success : DesignSystem.Color.warning)
                .frame(width: DesignSystem.Spacing.xs, height: DesignSystem.Spacing.xs)
            Text(coordinator.opponent != nil ? "Connected" : "Searching...")
                .font(DesignSystem.Font.subheadline)
                .fontWeight(.semibold)
                .foregroundStyle(DesignSystem.Color.textPrimary)
            Spacer()
            if coordinator.state == .browsing {
                Text("\(coordinator.sessionManager.discoveredPeers.count) found")
                    .font(DesignSystem.Font.caption)
                    .foregroundStyle(DesignSystem.Color.textSecondary)
            }
        }
        .padding(DesignSystem.Spacing.sm)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium))
    }
}

// MARK: - Host Config
private extension LocalMultiplayerLobbyScreen {
    var hostConfigSection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            SectionHeaderView(title: "Quiz Settings")

            TypeSelectionGrid(
                items: [QuizType.flagQuiz, .capitalQuiz, .reverseFlag, .reverseCapital],
                selectedIDs: [coordinator.quizType.id],
                onSelect: { coordinator.quizType = $0 }
            )

            RegionSelectionBar(
                items: QuizRegion.allCases.map { $0 },
                selectedID: coordinator.region.id,
                onSelect: { coordinator.region = $0 }
            )

            HStack(spacing: DesignSystem.Spacing.sm) {
                Picker("Difficulty", selection: $coordinator.difficulty) {
                    ForEach(QuizDifficulty.allCases) { difficulty in
                        Text(difficulty.displayName).tag(difficulty)
                    }
                }
                .pickerStyle(.segmented)

                Picker("Questions", selection: $coordinator.questionCount) {
                    ForEach(QuestionCount.allCases) { count in
                        Text(count.displayName).tag(count)
                    }
                }
                .pickerStyle(.menu)
                .tint(DesignSystem.Color.iconPrimary)
            }
        }
    }
}

// MARK: - Opponent & Waiting
private extension LocalMultiplayerLobbyScreen {
    func opponentCard(_ opponent: PeerPlayer) -> some View {
        CardView {
            HStack(spacing: DesignSystem.Spacing.md) {
                ZStack {
                    Circle()
                        .fill(DesignSystem.Color.blue.opacity(0.15))
                        .frame(width: DesignSystem.Size.xxl, height: DesignSystem.Size.xxl)
                    Image(systemName: "person.fill")
                        .font(DesignSystem.Font.title3)
                        .foregroundStyle(DesignSystem.Color.blue)
                }

                VStack(alignment: .leading, spacing: DesignSystem.Spacing.xxs) {
                    Text(opponent.displayName)
                        .font(DesignSystem.Font.headline)
                        .fontWeight(.bold)
                        .foregroundStyle(DesignSystem.Color.textPrimary)
                    Text(opponent.isReady ? "Ready" : "Waiting...")
                        .font(DesignSystem.Font.caption)
                        .foregroundStyle(
                            opponent.isReady
                                ? DesignSystem.Color.success
                                : DesignSystem.Color.textSecondary
                        )
                }

                Spacer()

                if opponent.isReady {
                    Image(systemName: "checkmark.circle.fill")
                        .font(DesignSystem.Font.title2)
                        .foregroundStyle(DesignSystem.Color.success)
                }
            }
            .padding(DesignSystem.Spacing.md)
        }
    }

    var waitingSection: some View {
        VStack(spacing: DesignSystem.Spacing.md) {
            if coordinator.state == .browsing {
                peerList
            } else {
                PulsingCirclesView(icon: "antenna.radiowaves.left.and.right", isAnimating: true)
                    .scaleEffect(0.6)
                    .frame(height: 160)
                Text("Waiting for a player to join...")
                    .font(DesignSystem.Font.subheadline)
                    .foregroundStyle(DesignSystem.Color.textSecondary)
            }
        }
    }

    var peerList: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            SectionHeaderView(title: "Nearby Hosts")
            if coordinator.sessionManager.discoveredPeers.isEmpty {
                HStack(spacing: DesignSystem.Spacing.sm) {
                    ProgressView()
                        .tint(DesignSystem.Color.accent)
                    Text("Searching nearby...")
                        .font(DesignSystem.Font.subheadline)
                        .foregroundStyle(DesignSystem.Color.textSecondary)
                }
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.vertical, DesignSystem.Spacing.xl)
            } else {
                ForEach(coordinator.sessionManager.discoveredPeers, id: \.displayName) { peer in
                    Button {
                        hapticsService.impact(.light)
                        coordinator.joinHost(peer)
                    } label: {
                        CardView {
                            HStack(spacing: DesignSystem.Spacing.md) {
                                Image(systemName: "wifi")
                                    .font(DesignSystem.Font.headline)
                                    .foregroundStyle(DesignSystem.Color.accent)
                                Text(peer.displayName)
                                    .font(DesignSystem.Font.headline)
                                    .foregroundStyle(DesignSystem.Color.textPrimary)
                                Spacer()
                                Text("Join")
                                    .font(DesignSystem.Font.caption)
                                    .fontWeight(.semibold)
                                    .foregroundStyle(DesignSystem.Color.accent)
                            }
                            .padding(DesignSystem.Spacing.md)
                        }
                    }
                    .buttonStyle(PressButtonStyle())
                }
            }
        }
    }
}

// MARK: - Guest Ready
private extension LocalMultiplayerLobbyScreen {
    var guestReadySection: some View {
        VStack(spacing: DesignSystem.Spacing.md) {
            if let config = coordinator.matchConfig {
                CardView {
                    VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
                        Text("Match Settings")
                            .font(DesignSystem.Font.caption)
                            .foregroundStyle(DesignSystem.Color.textSecondary)
                        HStack {
                            Label(config.quizType.displayName, systemImage: config.quizType.icon)
                            Spacer()
                            Text("\(config.questionCount) questions")
                        }
                        .font(DesignSystem.Font.subheadline)
                        .foregroundStyle(DesignSystem.Color.textPrimary)
                    }
                    .padding(DesignSystem.Spacing.md)
                }
            }

            GlassButton("I'm Ready", systemImage: "hand.thumbsup.fill", fullWidth: true) {
                hapticsService.impact(.medium)
                coordinator.markReady()
            }
        }
    }
}

// MARK: - Start
private extension LocalMultiplayerLobbyScreen {
    var startButton: some View {
        GlassButton("Start Match", systemImage: "play.fill", fullWidth: true) {
            hapticsService.impact(.heavy)
            coordinator.startMatch()
        }
        .padding(.horizontal, DesignSystem.Spacing.md)
        .padding(.bottom, DesignSystem.Spacing.md)
    }
}
#endif
