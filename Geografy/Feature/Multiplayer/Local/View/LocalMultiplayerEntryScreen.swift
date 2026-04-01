#if !os(tvOS)
import SwiftUI
import GeografyDesign

struct LocalMultiplayerEntryScreen: View {
    @Environment(HapticsService.self) private var hapticsService

    @State private var coordinator = LocalMultiplayerCoordinator()
    @State private var appeared = false

    var body: some View {
        Group {
            switch coordinator.state {
            case .idle:
                entryContent
            case .advertising, .browsing, .lobby:
                LocalMultiplayerLobbyScreen(coordinator: coordinator)
            case .countdown:
                LocalMultiplayerCountdownView(coordinator: coordinator)
            case .playing:
                LocalMultiplayerMatchScreen(coordinator: coordinator)
            case .finished:
                LocalMultiplayerResultScreen(coordinator: coordinator)
            case .disconnected:
                disconnectedView
            }
        }
        .animation(.easeInOut(duration: 0.3), value: coordinator.state)
        .onAppear {
            appeared = true
        }
    }
}

// MARK: - Entry Content
private extension LocalMultiplayerEntryScreen {
    var entryContent: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: DesignSystem.Spacing.xl) {
                heroSection
                roleCards
                infoSection
            }
            .padding(.horizontal, DesignSystem.Spacing.md)
            .padding(.vertical, DesignSystem.Spacing.lg)
        }
        .background { AmbientBlobsView(.standard) }
        .background(DesignSystem.Color.background.ignoresSafeArea())
        .navigationTitle("Local Play")
        .navigationBarTitleDisplayMode(.inline)
    }

    var heroSection: some View {
        VStack(spacing: DesignSystem.Spacing.md) {
            ZStack {
                Circle()
                    .fill(DesignSystem.Color.accent.opacity(0.12))
                    .frame(width: 80, height: 80)
                Image(systemName: "antenna.radiowaves.left.and.right")
                    .font(DesignSystem.Font.iconXL)
                    .foregroundStyle(DesignSystem.Color.accent)
                    .symbolEffect(.variableColor.iterative, options: .repeating, value: appeared)
            }

            VStack(spacing: DesignSystem.Spacing.xs) {
                Text("Play Nearby")
                    .font(DesignSystem.Font.title)
                    .fontWeight(.bold)
                    .foregroundStyle(DesignSystem.Color.textPrimary)
                Text("Challenge a friend on the same network")
                    .font(DesignSystem.Font.subheadline)
                    .foregroundStyle(DesignSystem.Color.textSecondary)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity)
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 16)
    }

    var roleCards: some View {
        VStack(spacing: DesignSystem.Spacing.sm) {
            roleCard(
                title: "Host Game",
                subtitle: "Configure the quiz and wait for a friend to join",
                icon: "wifi",
                color: DesignSystem.Color.accent
            ) {
                hapticsService.impact(.medium)
                coordinator.startHosting()
            }

            roleCard(
                title: "Join Game",
                subtitle: "Find a nearby host and join their quiz",
                icon: "magnifyingglass",
                color: DesignSystem.Color.blue
            ) {
                hapticsService.impact(.medium)
                coordinator.startBrowsing()
            }
        }
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 12)
        .animation(.easeOut(duration: 0.5).delay(0.15), value: appeared)
    }

    func roleCard(
        title: String,
        subtitle: String,
        icon: String,
        color: Color,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            CardView {
                HStack(spacing: DesignSystem.Spacing.md) {
                    ZStack {
                        Circle()
                            .fill(color.opacity(0.15))
                            .frame(width: DesignSystem.Size.xxl, height: DesignSystem.Size.xxl)
                        Image(systemName: icon)
                            .font(DesignSystem.Font.title2)
                            .foregroundStyle(color)
                    }

                    VStack(alignment: .leading, spacing: DesignSystem.Spacing.xxs) {
                        Text(title)
                            .font(DesignSystem.Font.headline)
                            .fontWeight(.bold)
                            .foregroundStyle(DesignSystem.Color.textPrimary)
                        Text(subtitle)
                            .font(DesignSystem.Font.caption)
                            .foregroundStyle(DesignSystem.Color.textSecondary)
                            .lineLimit(2)
                    }

                    Spacer(minLength: 0)

                    Image(systemName: "chevron.right")
                        .font(DesignSystem.Font.caption)
                        .foregroundStyle(DesignSystem.Color.textTertiary)
                }
                .padding(DesignSystem.Spacing.md)
            }
        }
        .buttonStyle(PressButtonStyle())
    }

    var infoSection: some View {
        HStack(spacing: DesignSystem.Spacing.sm) {
            Image(systemName: "info.circle")
                .font(DesignSystem.Font.caption)
                .foregroundStyle(DesignSystem.Color.textTertiary)
            Text("Both devices must be nearby on the same Wi-Fi or with Bluetooth enabled.")
                .font(DesignSystem.Font.caption)
                .foregroundStyle(DesignSystem.Color.textTertiary)
        }
        .opacity(appeared ? 1 : 0)
        .animation(.easeOut(duration: 0.5).delay(0.3), value: appeared)
    }

    var disconnectedView: some View {
        VStack(spacing: DesignSystem.Spacing.lg) {
            Spacer()
            PulsingCirclesView(icon: "wifi.slash", isAnimating: true)

            VStack(spacing: DesignSystem.Spacing.xs) {
                Text("Disconnected")
                    .font(DesignSystem.Font.title2)
                    .fontWeight(.bold)
                    .foregroundStyle(DesignSystem.Color.textPrimary)
                Text("The connection to your opponent was lost.")
                    .font(DesignSystem.Font.subheadline)
                    .foregroundStyle(DesignSystem.Color.textSecondary)
                    .multilineTextAlignment(.center)
            }

            GlassButton("Back to Menu", systemImage: "arrow.left", fullWidth: true) {
                coordinator.leave()
            }
            .padding(.horizontal, DesignSystem.Spacing.xl)

            Spacer()
        }
        .padding(.horizontal, DesignSystem.Spacing.md)
        .background { AmbientBlobsView(.standard) }
        .background(DesignSystem.Color.background.ignoresSafeArea())
    }
}
#endif
