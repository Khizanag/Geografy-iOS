import AuthenticationServices
import Geografy_Core_DesignSystem
import Geografy_Core_Map
import Geografy_Core_Navigation
import Geografy_Core_Service
import SwiftUI

public struct SignInOptionsSheet: View {
    // MARK: - Properties
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    @Environment(AuthService.self) private var authService
    @Environment(TestingModeService.self) private var testingModeService

    @State private var showError = false
    @State private var errorMessage = ""

    // MARK: - Init
    public init() {}

    // MARK: - Body
    public var body: some View {
        scrollContent
            .screenBackground()
            .safeAreaBar(edge: .bottom) { actionsSection }
            .alert("Sign In Failed", isPresented: $showError) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(errorMessage)
            }
    }
}

// MARK: - Subviews
private extension SignInOptionsSheet {
    var scrollContent: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: DesignSystem.Spacing.lg) {
                SignInMapHero()
                    .phaseEntrance(index: 0)
                benefitsCard
                    .padding(.horizontal, DesignSystem.Spacing.md)
                    .phaseEntrance(index: 1)
            }
            .padding(.bottom, DesignSystem.Spacing.md)
            .readableContentWidth()
        }
        .ignoresSafeArea(.container, edges: .top)
    }
}

// MARK: - Benefits
private extension SignInOptionsSheet {
    struct Benefit: Identifiable {
        let icon: String
        let color: Color
        let title: LocalizedStringKey
        let subtitle: LocalizedStringKey

        var id: String { icon }
    }

    var benefits: [Benefit] {
        [
            Benefit(
                icon: "icloud.and.arrow.up.fill",
                color: DesignSystem.Color.blue,
                title: "Sync across devices",
                subtitle: "Progress follows you everywhere"
            ),
            Benefit(
                icon: "trophy.fill",
                color: DesignSystem.Color.warning,
                title: "Achievements & XP",
                subtitle: "Earn rewards as you explore"
            ),
            Benefit(
                icon: "person.2.fill",
                color: DesignSystem.Color.purple,
                title: "Global leaderboards",
                subtitle: "Compete with explorers worldwide"
            ),
        ]
    }

    var benefitsCard: some View {
        RowListCard(benefits, dividerInset: RowListCardLayout.iconBadgeWidth + DesignSystem.Spacing.md * 2) { benefit in
            HStack(spacing: DesignSystem.Spacing.md) {
                IconBadge(benefit.icon, color: benefit.color, size: .small)
                VStack(alignment: .leading, spacing: DesignSystem.Spacing.xxs) {
                    Text(benefit.title)
                        .font(DesignSystem.Font.subheadline)
                        .fontWeight(.semibold)
                        .foregroundStyle(DesignSystem.Color.textPrimary)
                    Text(benefit.subtitle)
                        .font(DesignSystem.Font.caption)
                        .foregroundStyle(DesignSystem.Color.textSecondary)
                }
                Spacer(minLength: 0)
            }
            .rowListCardRow()
            .accessibilityElement(children: .combine)
        }
    }
}

// MARK: - Actions
private extension SignInOptionsSheet {
    var actionsSection: some View {
        VStack(spacing: DesignSystem.Spacing.sm) {
            appleSignInButton
            #if DEBUG
            if testingModeService.isEnabled {
                debugSignInButton
            }
            #endif
            continueAsGuestButton
        }
        .padding(.horizontal, DesignSystem.Spacing.md)
        .padding(.top, DesignSystem.Spacing.sm)
        .readableContentWidth()
    }

    /// Apple's button at the size and shape the Human Interface Guidelines ask for.
    static let signInButtonHeight: CGFloat = 50
    static let signInButtonShape = RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.large, style: .continuous)

    var appleSignInButton: some View {
        SignInWithAppleButton(.signIn) { request in
            request.requestedScopes = [.fullName, .email]
        } onCompletion: { result in
            Task { @MainActor in
                switch result {
                case .success(let authorization):
                    authService.handleAppleSignIn(authorization)
                    dismiss()
                case .failure(let error):
                    let nsError = error as NSError
                    if nsError.code != ASAuthorizationError.canceled.rawValue {
                        errorMessage = error.localizedDescription
                        showError = true
                    }
                }
            }
        }
        .signInWithAppleButtonStyle(colorScheme == .dark ? .white : .black)
        .frame(height: Self.signInButtonHeight)
        .clipShape(Self.signInButtonShape)
    }

    var continueAsGuestButton: some View {
        Button { dismiss() } label: {
            Text("Continue as Guest")
                .font(DesignSystem.Font.subheadline)
                .fontWeight(.medium)
                .foregroundStyle(DesignSystem.Color.textSecondary)
                .frame(maxWidth: .infinity, minHeight: 44)
        }
        .buttonStyle(PressButtonStyle())
    }

    #if DEBUG
    var debugSignInButton: some View {
        Button {
            authService.debugSignIn()
            dismiss()
        } label: {
            HStack(spacing: DesignSystem.Spacing.xs) {
                Image(systemName: "hammer.fill")
                    .font(DesignSystem.Font.footnote)
                    .accessibilityHidden(true)
                Text("Debug Sign In")
                    .font(DesignSystem.Font.subheadline)
                    .fontWeight(.semibold)
            }
            .foregroundStyle(DesignSystem.Color.onAccent)
            .frame(maxWidth: .infinity)
            .padding(.vertical, DesignSystem.Spacing.sm)
            .background(
                LinearGradient(
                    colors: [DesignSystem.Color.purple, DesignSystem.Color.indigo],
                    startPoint: .leading,
                    endPoint: .trailing
                ),
                in: RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium, style: .continuous)
            )
        }
        .buttonStyle(PressButtonStyle())
    }
    #endif
}

// MARK: - Map Hero
/// The world map, fading into the page under the app's name.
private struct SignInMapHero: View {
    private static let mapHeight: CGFloat = 300

    var body: some View {
        ZStack(alignment: .bottom) {
            map
            title
        }
    }
}

// MARK: - Subviews
private extension SignInMapHero {
    var map: some View {
        WorldMapThumbnail()
            .frame(height: Self.mapHeight)
            .opacity(0.75)
            .mask {
                LinearGradient(
                    stops: [
                        .init(color: .black, location: 0.35),
                        .init(color: .clear, location: 1),
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
            }
    }

    var title: some View {
        VStack(spacing: DesignSystem.Spacing.xs) {
            Text(verbatim: "Geografy")
                .font(DesignSystem.Font.roundedHeadline)
                .foregroundStyle(DesignSystem.Color.textPrimary)
            Text("Your world, explored.")
                .font(DesignSystem.Font.callout)
                .foregroundStyle(DesignSystem.Color.textSecondary)
        }
        .multilineTextAlignment(.center)
        .padding(.horizontal, DesignSystem.Spacing.md)
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(.isHeader)
    }
}
