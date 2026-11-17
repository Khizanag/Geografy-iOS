#if !os(tvOS)
import Geografy_Core_DesignSystem
import Geografy_Core_Service
import SwiftUI

public struct LocalMultiplayerEntryScreen: View {
    // MARK: - Properties
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(CountryDataService.self) private var countryDataService

    // Created on the first Host or Join tap: building one opens a peer identity, so the
    // screen's init (re-run on every parent render) must not.
    @State private var coordinator: LocalMultiplayerCoordinator?
    @State private var appeared = false

    // MARK: - Init
    public init() {}

    // MARK: - Body
    public var body: some View {
        extractedContent
            .animation(.easeInOut(duration: 0.3), value: coordinator?.state)
            .onAppear { appeared = true }
    }
}

// MARK: - Subviews
private extension LocalMultiplayerEntryScreen {
    var extractedContent: some View {
        Group {
            if let coordinator, coordinator.state != .idle {
                matchFlowContent(coordinator)
            } else {
                entryContent
            }
        }
    }

    @ViewBuilder
    func matchFlowContent(_ coordinator: LocalMultiplayerCoordinator) -> some View {
        switch coordinator.state {
        case .idle:
            EmptyView()
        case .advertising, .browsing, .lobby:
            LocalMultiplayerLobbyScreen(coordinator: coordinator)
        case .countdown:
            LocalMultiplayerCountdownView(coordinator: coordinator)
        case .playing:
            LocalMultiplayerMatchScreen(coordinator: coordinator)
        case .finished:
            LocalMultiplayerResultScreen(coordinator: coordinator)
        case .disconnected:
            disconnectedView(coordinator)
        }
    }

    var entryContent: some View {
        ScrollView(showsIndicators: false) {
            heroSection
                .padding(.horizontal, DesignSystem.Spacing.md)
                .padding(.vertical, DesignSystem.Spacing.lg)
                .containerRelativeFrame(.vertical, alignment: .center) { length, _ in
                    max(length - DesignSystem.Spacing.xl, 0)
                }
        }
        .scrollBounceBehavior(.basedOnSize)
        .screenBackground()
        .navigationTitle("Local Play")
        .navigationBarTitleDisplayMode(.inline)
        .safeAreaBar(edge: .bottom) { roleButtons }
    }

    var heroSection: some View {
        VStack(spacing: DesignSystem.Spacing.lg) {
            IconBadge("antenna.radiowaves.left.and.right", color: Self.color, size: .hero)
                .symbolEffect(
                    .variableColor.iterative,
                    options: reduceMotion ? .nonRepeating : .repeating,
                    value: appeared
                )
                .accessibilityHidden(true)

            VStack(spacing: DesignSystem.Spacing.xs) {
                Text("Play Nearby")
                    .font(DesignSystem.Font.title)
                    .fontWeight(.bold)
                    .foregroundStyle(DesignSystem.Color.textPrimary)
                    .accessibilityAddTraits(.isHeader)
                Text("One of you hosts and picks the quiz. The other joins from their phone.")
                    .font(DesignSystem.Font.subheadline)
                    .foregroundStyle(DesignSystem.Color.textSecondary)
                    .multilineTextAlignment(.center)
            }

            InfoPill("Same Wi-Fi or Bluetooth", systemImage: "wifi", style: .neutral)
        }
        .frame(maxWidth: .infinity)
        .phaseEntrance()
    }

    var roleButtons: some View {
        VStack(spacing: DesignSystem.Spacing.sm) {
            GlassButton("Host Game", systemImage: "antenna.radiowaves.left.and.right", fullWidth: true) {
                resolvedCoordinator().startHosting()
            }
            GlassButton("Join Game", systemImage: "magnifyingglass", role: .secondary, fullWidth: true) {
                resolvedCoordinator().startBrowsing()
            }
        }
        .padding(.horizontal, DesignSystem.Spacing.md)
        .padding(.bottom, DesignSystem.Spacing.md)
    }

    func disconnectedView(_ coordinator: LocalMultiplayerCoordinator) -> some View {
        VStack(spacing: DesignSystem.Spacing.lg) {
            PulsingCirclesView(icon: "wifi.slash", isAnimating: true, color: Self.color)
                .accessibilityHidden(true)

            VStack(spacing: DesignSystem.Spacing.xs) {
                Text("Disconnected")
                    .font(DesignSystem.Font.title2)
                    .fontWeight(.bold)
                    .foregroundStyle(DesignSystem.Color.textPrimary)
                    .accessibilityAddTraits(.isHeader)
                Text("The connection to your opponent was lost.")
                    .font(DesignSystem.Font.subheadline)
                    .foregroundStyle(DesignSystem.Color.textSecondary)
                    .multilineTextAlignment(.center)
            }
        }
        .padding(.horizontal, DesignSystem.Spacing.md)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .screenBackground()
        .safeAreaBar(edge: .bottom) {
            GlassButton("Back to Menu", systemImage: "arrow.left", fullWidth: true) {
                coordinator.leave()
            }
            .padding(.horizontal, DesignSystem.Spacing.md)
            .padding(.bottom, DesignSystem.Spacing.md)
        }
    }
}

// MARK: - Game Color
extension LocalMultiplayerEntryScreen {
    /// Multiplayer's color, the same as its Play tile, shared by every multiplayer screen.
    static let color = DesignSystem.Color.teal
}

// MARK: - Actions
private extension LocalMultiplayerEntryScreen {
    func resolvedCoordinator() -> LocalMultiplayerCoordinator {
        if let coordinator {
            return coordinator
        }
        let created = LocalMultiplayerCoordinator(countryDataService: countryDataService)
        coordinator = created
        return created
    }
}
#endif
