import Geografy_Core_Common
#if !os(tvOS)
import Geografy_Core_DesignSystem
import Geografy_Core_Service
import MultipeerConnectivity
import SwiftUI

public struct LocalMultiplayerLobbyScreen: View {
    // MARK: - Properties
    @Environment(HapticsService.self) private var hapticsService
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.openURL) private var openURL

    @Bindable var coordinator: LocalMultiplayerCoordinator

    // MARK: - Body
    public var body: some View {
        scrollContent
            .screenBackground()
            .navigationTitle(coordinator.isHost ? "Host Lobby" : "Join Lobby")
            .navigationBarTitleDisplayMode(.inline)
            .safeAreaBar(edge: .bottom) { bottomAction }
    }
}

// MARK: - Subviews
private extension LocalMultiplayerLobbyScreen {
    var scrollContent: some View {
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
    }
}

// MARK: - Connection Status
private extension LocalMultiplayerLobbyScreen {
    var connectionStatus: some View {
        CardView(cornerRadius: DesignSystem.CornerRadius.medium) {
            connectionStatusContent
                .padding(DesignSystem.Spacing.sm)
        }
    }

    var connectionStatusContent: some View {
        HStack(spacing: DesignSystem.Spacing.sm) {
            Circle()
                .fill(statusColor)
                .frame(width: DesignSystem.Spacing.xs, height: DesignSystem.Spacing.xs)
                .accessibilityHidden(true)
            Text(statusTitle)
                .font(DesignSystem.Font.subheadline)
                .fontWeight(.semibold)
                .foregroundStyle(DesignSystem.Color.textPrimary)
            Spacer()
            if isDiscoveryBlocked {
                Button("Settings", action: openSettings)
                    .font(DesignSystem.Font.subheadline)
                    .fontWeight(.semibold)
            } else if coordinator.state == .advertising, let departed = coordinator.departedPlayerName {
                Text("\(departed) left")
                    .font(DesignSystem.Font.caption)
                    .foregroundStyle(DesignSystem.Color.textSecondary)
            } else if coordinator.state == .browsing {
                Text("\(coordinator.sessionManager.discoveredPeers.count) found")
                    .font(DesignSystem.Font.caption)
                    .foregroundStyle(DesignSystem.Color.textSecondary)
            }
        }
    }
}

// MARK: - Helpers
private extension LocalMultiplayerLobbyScreen {
    var isDiscoveryBlocked: Bool {
        coordinator.opponent == nil && coordinator.sessionManager.isDiscoveryBlocked
    }

    var statusTitle: LocalizedStringKey {
        if let opponent = coordinator.opponent { return "Connected to \(opponent.displayName)" }
        if isDiscoveryBlocked { return "Turn on Local Network for Geografy" }
        return coordinator.isHost ? "Waiting for a player" : "Searching..."
    }

    var statusColor: Color {
        if coordinator.opponent != nil { return DesignSystem.Color.success }
        return isDiscoveryBlocked ? DesignSystem.Color.error : DesignSystem.Color.warning
    }

    func openSettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
        openURL(url)
    }
}

// MARK: - Host Config
private extension LocalMultiplayerLobbyScreen {
    var hostConfigSection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            SectionHeaderView(title: "Game")
            Picker("Game", selection: $coordinator.game) {
                ForEach(LocalGame.allCases) { game in
                    Label(game.title, systemImage: game.systemImage).tag(game)
                }
            }
            .pickerStyle(.segmented)

            switch coordinator.game {
            case .quiz: quizSettings
            case .pinDrop: PinDropSettingsSections(configuration: $coordinator.pinDropConfiguration)
            }
        }
    }

    @ViewBuilder
    var quizSettings: some View {
        TypeSelectionGrid(
            items: QuizType.allCases,
            selectedIDs: [coordinator.quizType.id],
            color: LocalMultiplayerEntryScreen.color,
            layout: .grid,
            onSelect: { coordinator.quizType = $0 }
        )
        RegionPicker(selectedRegion: $coordinator.region, color: LocalMultiplayerEntryScreen.color)
        matchOptionsCard
    }

    var matchOptionsCard: some View {
        CardView {
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
                OptionPickerRow(
                    "Difficulty",
                    selection: $coordinator.difficulty,
                    options: QuizDifficulty.allCases,
                    label: \.displayName
                )
                OptionPickerRow(
                    "Questions",
                    selection: $coordinator.questionCount,
                    options: QuestionCount.allCases,
                    label: \.displayName
                )
                if coordinator.quizType.hasComparisonMetric {
                    OptionPickerRow(
                        "Metric",
                        selection: $coordinator.comparisonMetric,
                        options: ComparisonMetric.allCases,
                        style: .menu,
                        label: \.rawValue
                    )
                }
            }
            .padding(DesignSystem.Spacing.md)
        }
    }
}

// MARK: - Opponent & Waiting
private extension LocalMultiplayerLobbyScreen {
    func opponentCard(_ opponent: PeerPlayer) -> some View {
        CardView {
            HStack(spacing: DesignSystem.Spacing.md) {
                IconBadge("person.fill", color: DesignSystem.Color.blue, size: .medium)
                    .accessibilityHidden(true)

                VStack(alignment: .leading, spacing: DesignSystem.Spacing.xxs) {
                    Text(opponent.displayName)
                        .font(DesignSystem.Font.headline)
                        .fontWeight(.bold)
                        .foregroundStyle(DesignSystem.Color.textPrimary)
                    Text(opponentStatus(opponent))
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
                        .accessibilityHidden(true)
                }
            }
            .padding(DesignSystem.Spacing.md)
        }
        .accessibilityElement(children: .combine)
    }

    func opponentStatus(_ opponent: PeerPlayer) -> LocalizedStringKey {
        if !coordinator.isHost { return "Host" }
        return opponent.isReady ? "Ready" : "Getting ready..."
    }

    var waitingSection: some View {
        VStack(spacing: DesignSystem.Spacing.md) {
            if coordinator.state == .browsing {
                peerList
            } else {
                PulsingCirclesView(
                    icon: "antenna.radiowaves.left.and.right",
                    isAnimating: true,
                    color: LocalMultiplayerEntryScreen.color
                )
                    .scaleEffect(0.6)
                    .frame(height: 160)
                    .accessibilityHidden(true)
                VStack(spacing: DesignSystem.Spacing.xxs) {
                    Text("Waiting for a player to join...")
                        .font(DesignSystem.Font.subheadline)
                        .foregroundStyle(DesignSystem.Color.textSecondary)
                    Text("Nearby players see you as \(coordinator.playerName).")
                        .font(DesignSystem.Font.caption)
                        .foregroundStyle(DesignSystem.Color.textSecondary)
                }
                .multilineTextAlignment(.center)
            }
        }
    }

    var peerList: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            SectionHeaderView(title: "Nearby Hosts")
            if coordinator.sessionManager.discoveredPeers.isEmpty {
                searchingIndicator
            } else {
                discoveredPeerRows
            }
            if let failed = coordinator.failedJoinName {
                Text("Couldn't join \(failed). Their game may already be full.")
                    .font(DesignSystem.Font.caption)
                    .foregroundStyle(DesignSystem.Color.textSecondary)
            }
        }
    }

    var searchingIndicator: some View {
        LoadingView("Searching nearby...")
            .padding(.vertical, DesignSystem.Spacing.xl)
    }

    var discoveredPeerRows: some View {
        ForEach(coordinator.sessionManager.discoveredPeers, id: \.self) { peer in
            Button {
                hapticsService.impact(.light)
                coordinator.joinHost(peer)
            } label: {
                peerRow(peer)
            }
            .buttonStyle(PressButtonStyle())
            .disabled(coordinator.joiningPeer != nil)
            .accessibilityLabel("Join \(peer.displayName)")
        }
    }

    func peerRow(_ peer: MCPeerID) -> some View {
        CardView {
            HStack(spacing: DesignSystem.Spacing.md) {
                Image(systemName: "wifi")
                    .font(DesignSystem.Font.headline)
                    .foregroundStyle(LocalMultiplayerEntryScreen.color)
                    .accessibilityHidden(true)
                Text(peer.displayName)
                    .font(DesignSystem.Font.headline)
                    .foregroundStyle(DesignSystem.Color.textPrimary)
                Spacer()
                if coordinator.joiningPeer == peer {
                    ProgressView()
                    Text("Joining...")
                        .font(DesignSystem.Font.caption)
                        .foregroundStyle(DesignSystem.Color.textSecondary)
                } else {
                    Text("Join")
                        .font(DesignSystem.Font.caption)
                        .fontWeight(.semibold)
                        .foregroundStyle(LocalMultiplayerEntryScreen.color)
                }
            }
            .padding(DesignSystem.Spacing.md)
        }
    }
}

// MARK: - Guest Ready
private extension LocalMultiplayerLobbyScreen {
    var guestReadySection: some View {
        VStack(spacing: DesignSystem.Spacing.md) {
            if let config = coordinator.matchConfig {
                matchSettingsCard(config)
            }
            if coordinator.isReady {
                Label(
                    "You're ready. Waiting for \(coordinator.opponent?.displayName ?? "the host") to start.",
                    systemImage: "checkmark.circle.fill"
                )
                .font(DesignSystem.Font.subheadline)
                .foregroundStyle(DesignSystem.Color.textSecondary)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }

    func gameIcon(_ config: PeerMessage.MatchConfig) -> String {
        config.game == .quiz ? config.quizType.icon : LocalGame.pinDrop.systemImage
    }

    func gameTitle(_ config: PeerMessage.MatchConfig) -> String {
        config.game == .quiz ? config.quizType.displayName : String(localized: "Pin Drop", bundle: .module)
    }

    func settingsSummary(_ config: PeerMessage.MatchConfig) -> String {
        if config.game == .pinDrop {
            let pinDrop = config.pinDrop
            let map = pinDrop.showsBorders
                ? String(localized: "Borders", bundle: .module)
                : String(localized: "Coastlines only", bundle: .module)
            return String(
                localized: "\(pinDrop.region.displayName) · \(pinDrop.roundCount) rounds · \(map)",
                bundle: .module
            )
        }
        let region = config.region.displayName
        let difficulty = config.difficulty.displayName
        return String(localized: "\(region) · \(difficulty) · \(config.questionCount) questions", bundle: .module)
    }

    /// The host's choices, so the guest knows what they're about to play.
    func matchSettingsCard(_ config: PeerMessage.MatchConfig) -> some View {
        CardView {
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
                EyebrowLabel("Match Settings")
                Label(gameTitle(config), systemImage: gameIcon(config))
                    .font(DesignSystem.Font.headline)
                    .foregroundStyle(DesignSystem.Color.textPrimary)
                Text(settingsSummary(config))
                    .font(DesignSystem.Font.subheadline)
                    .foregroundStyle(DesignSystem.Color.textSecondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(DesignSystem.Spacing.md)
        }
        .accessibilityElement(children: .combine)
    }
}

// MARK: - Bottom Action
private extension LocalMultiplayerLobbyScreen {
    /// The lobby's next step, in thumb reach: the host starts once the guest is ready; the guest says they're ready.
    @ViewBuilder
    var bottomAction: some View {
        if coordinator.isHost, coordinator.opponent?.isReady == true {
            bottomButton("Start Match", systemImage: "play.fill") { coordinator.startMatch() }
        } else if !coordinator.isHost, coordinator.opponent != nil, !coordinator.isReady {
            bottomButton("I'm Ready", systemImage: "hand.thumbsup.fill") { coordinator.markReady() }
        }
    }

    func bottomButton(_ title: LocalizedStringKey, systemImage: String, action: @escaping () -> Void) -> some View {
        GlassButton(title, systemImage: systemImage, fullWidth: true) {
            hapticsService.impact(.light)
            action()
        }
        .padding(.horizontal, DesignSystem.Spacing.md)
        .padding(.bottom, DesignSystem.Spacing.md)
    }
}
#endif
