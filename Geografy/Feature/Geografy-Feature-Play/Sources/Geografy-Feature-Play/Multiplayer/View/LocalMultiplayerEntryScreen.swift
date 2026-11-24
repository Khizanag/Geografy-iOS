#if !os(tvOS)
import Geografy_Core_DesignSystem
import Geografy_Core_Service
import SwiftUI

public struct LocalMultiplayerEntryScreen: View {
    // MARK: - Properties
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(AuthService.self) private var authService
    @Environment(CountryDataService.self) private var countryDataService
    @Environment(DatabaseManager.self) private var database
    @Environment(GeoJSONCache.self) private var geoJSONCache

    // Created on each Host or Join tap: building one opens a peer identity under the name typed here, so the
    // screen's init (re-run on every parent render) must not.
    @State private var coordinator: LocalMultiplayerCoordinator?
    @State private var appeared = false
    @State private var playerName = ""

    // MARK: - Init
    public init() {}

    // MARK: - Body
    public var body: some View {
        extractedContent
            .animation(.easeInOut(duration: 0.3), value: coordinator?.state)
            .onAppear {
                appeared = true
                if playerName.isEmpty { playerName = savedName }
            }
    }
}

// MARK: - Subviews
private extension LocalMultiplayerEntryScreen {
    var extractedContent: some View {
        Group {
            if let coordinator, coordinator.state != .idle {
                LocalMultiplayerFlowView(coordinator: coordinator)
            } else {
                entryContent
            }
        }
    }

    var entryContent: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: DesignSystem.Spacing.xl) {
                heroSection
                nameField
            }
            .padding(.horizontal, DesignSystem.Spacing.md)
            .padding(.vertical, DesignSystem.Spacing.lg)
            .readableContentWidth()
            .containerRelativeFrame(.vertical, alignment: .center) { length, _ in
                max(length - DesignSystem.Spacing.xl, 0)
            }
        }
        .scrollBounceBehavior(.basedOnSize)
        .scrollDismissesKeyboard(.interactively)
        .screenBackground()
        .navigationTitle("Multiplayer")
        .navigationBarTitleDisplayMode(.inline)
        .gameGuide(.multiplayer)
        .bottomActionBar { roleButtons }
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
                Text("One of you hosts and picks the game. The other joins from their phone.")
                    .font(DesignSystem.Font.subheadline)
                    .foregroundStyle(DesignSystem.Color.textSecondary)
                    .multilineTextAlignment(.center)
            }

            InfoPill("Same Wi-Fi or Bluetooth", systemImage: "wifi", style: .neutral)
        }
        .frame(maxWidth: .infinity)
        .phaseEntrance()
    }

    var nameField: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
            EyebrowLabel("Your Name")
                .accessibilityHidden(true)
            FormField("Enter your name", text: $playerName)
                .textContentType(.nickname)
                .autocorrectionDisabled()
                .textInputAutocapitalization(.words)
                .submitLabel(.done)
                .accessibilityLabel("Your name")
            Text("The other player sees this name.")
                .font(DesignSystem.Font.caption)
                .foregroundStyle(DesignSystem.Color.textSecondary)
        }
    }

    var roleButtons: some View {
        VStack(spacing: DesignSystem.Spacing.sm) {
            GlassButton("Host Game", systemImage: "antenna.radiowaves.left.and.right", fullWidth: true) {
                start(hosting: true)
            }
            GlassButton("Join Game", systemImage: "magnifyingglass", role: .secondary, fullWidth: true) {
                start(hosting: false)
            }
        }
        .disabled(trimmedName.isEmpty)
    }
}

// MARK: - Game Color
extension LocalMultiplayerEntryScreen {
    /// Multiplayer's color, the same as its Play tile, shared by every multiplayer screen.
    static let color = DesignSystem.Color.teal
}

// MARK: - Helpers
private extension LocalMultiplayerEntryScreen {
    var trimmedName: String {
        playerName.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    /// The profile's name, unless it's still the default every new profile gets, which would give both players
    /// the same name.
    var savedName: String {
        guard let name = authService.currentProfile?.displayName, name != AuthService.defaultDisplayName else {
            return ""
        }
        return name
    }

    func start(hosting: Bool) {
        let name = trimmedName
        guard !name.isEmpty else { return }
        if let profile = authService.currentProfile, profile.displayName != name {
            profile.displayName = name
            database.mainContext.saveOrLog()
        }
        let created = LocalMultiplayerCoordinator(
            playerName: name,
            countryDataService: countryDataService,
            geoJSONCache: geoJSONCache
        )
        coordinator = created
        if hosting {
            created.startHosting()
        } else {
            created.startBrowsing()
        }
    }
}
#endif
