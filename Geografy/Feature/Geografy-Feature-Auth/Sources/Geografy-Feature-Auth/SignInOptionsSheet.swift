import AuthenticationServices
import Geografy_Core_DesignSystem
import Geografy_Core_Navigation
import Geografy_Core_Service
import SwiftUI

public struct SignInOptionsSheet: View {
    // MARK: - Properties
    @Environment(\.dismiss) private var dismiss
    @Environment(AuthService.self) private var authService
    @Environment(TestingModeService.self) private var testingModeService
    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    @State private var showError = false
    @State private var errorMessage = ""

    // MARK: - Init
    public init() {}

    // MARK: - Body
    public var body: some View {
        extractedContent
            .screenBackground()
            .alert("Sign In Failed", isPresented: $showError) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(errorMessage)
            }
    }
}

// MARK: - Subviews
private extension SignInOptionsSheet {
    var extractedContent: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: DesignSystem.Spacing.xl) {
                heroSection
                statsRow
                benefitsSection
                actionsSection
            }
            .padding(.horizontal, DesignSystem.Spacing.md)
            .padding(.top, DesignSystem.Spacing.xl)
        }
    }
}

// MARK: - Hero
private extension SignInOptionsSheet {
    var heroSection: some View {
        VStack(spacing: DesignSystem.Spacing.md) {
            appIconBadge
                .phaseEntrance(index: 0)
            heroText
                .phaseEntrance(index: 1)
        }
    }

    var heroText: some View {
        VStack(spacing: DesignSystem.Spacing.xs) {
            Text("Geografy")
                .font(DesignSystem.Font.roundedHeadline)
                .minimumScaleFactor(0.8)
                .foregroundStyle(
                    LinearGradient(
                        colors: [DesignSystem.Color.textPrimary, DesignSystem.Color.accent],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
            Text("Your world, explored.")
                .font(DesignSystem.Font.callout)
                .foregroundStyle(DesignSystem.Color.textSecondary)
        }
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(.isHeader)
    }

    var appIconBadge: some View {
        ZStack {
            if !reduceTransparency {
                DesignSystem.Color.accent.opacity(0.35)
                    .frame(width: 110, height: 110)
                    .blur(radius: 40)
            }

            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.extraLarge, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [DesignSystem.Color.accent, DesignSystem.Color.accentDark],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 76, height: 76)
                .geoShadow(.elevated)
                .overlay(
                    RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.extraLarge, style: .continuous)
                        .strokeBorder(DesignSystem.Color.onAccent.opacity(0.18), lineWidth: 1)
                )

            Image(systemName: "globe.americas.fill")
                .font(DesignSystem.Font.iconXL)
                .foregroundStyle(
                    LinearGradient(
                        colors: [DesignSystem.Color.onAccent, DesignSystem.Color.onAccent.opacity(0.82)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
        }
        .frame(width: 110, height: 110)
        .accessibilityHidden(true)
    }
}

// MARK: - Stats Row
private extension SignInOptionsSheet {
    var statsRow: some View {
        let layout = dynamicTypeSize.isAccessibilitySize
            ? AnyLayout(VStackLayout(spacing: DesignSystem.Spacing.sm))
            : AnyLayout(HStackLayout(spacing: DesignSystem.Spacing.sm))
        return layout {
            statPill(value: "197", label: "Countries", icon: "flag.fill", color: DesignSystem.Color.accent)
            statPill(value: "7", label: "Continents", icon: "globe.americas", color: DesignSystem.Color.blue)
            statPill(value: "∞", label: "Adventures", icon: "star.fill", color: DesignSystem.Color.indigo)
        }
        .phaseEntrance(index: 2)
    }

    func statPill(value: String, label: String, icon: String, color: Color) -> some View {
        CardView(cornerRadius: DesignSystem.CornerRadius.medium) {
            VStack(spacing: 5) {
                Image(systemName: icon)
                    .font(DesignSystem.Font.footnote)
                    .foregroundStyle(color)
                    .accessibilityHidden(true)
                Text(value)
                    .font(DesignSystem.Font.roundedCaption)
                    .foregroundStyle(DesignSystem.Color.textPrimary)
                    .minimumScaleFactor(0.8)
                Text(label)
                    .font(DesignSystem.Font.caption2)
                    .foregroundStyle(DesignSystem.Color.textSecondary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, DesignSystem.Spacing.sm)
        }
        .accessibilityElement(children: .combine)
    }
}

// MARK: - Benefits
private extension SignInOptionsSheet {
    var benefitsSection: some View {
        VStack(spacing: DesignSystem.Spacing.xs) {
            ForEach(Array(benefits.enumerated()), id: \.offset) { index, benefit in
                benefitRow(benefit)
                    .phaseEntrance(index: 3 + index)
            }
        }
    }

    var benefits: [(icon: String, color: Color, title: String, subtitle: String)] {
        [
            ("icloud.and.arrow.up.fill", DesignSystem.Color.blue, "Sync across devices",
             "Progress follows you everywhere"),
            ("trophy.fill", DesignSystem.Color.warning, "Achievements & XP",
             "Earn rewards as you explore"),
            ("airplane.departure", DesignSystem.Color.accent, "Track your travels",
             "Pin countries you've visited"),
            ("chart.line.uptrend.xyaxis", DesignSystem.Color.indigo, "Quiz history & streaks",
             "Watch your knowledge grow"),
            ("person.2.fill", DesignSystem.Color.purple, "Global leaderboards",
             "Compete with explorers worldwide"),
        ]
    }

    func benefitRow(
        _ benefit: (icon: String, color: Color, title: String, subtitle: String)
    ) -> some View {
        CardView(cornerRadius: DesignSystem.CornerRadius.medium) {
            HStack(spacing: DesignSystem.Spacing.md) {
                IconBadge(benefit.icon, color: benefit.color, size: .medium)
                VStack(alignment: .leading, spacing: 2) {
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
            .padding(DesignSystem.Spacing.sm)
        }
        .accessibilityElement(children: .combine)
    }
}

// MARK: - Actions
private extension SignInOptionsSheet {
    var actionsSection: some View {
        VStack(spacing: DesignSystem.Spacing.sm) {
            appleSignInButton
            googleSignInButton
            #if DEBUG
            if testingModeService.isEnabled {
                debugSignInButton
            }
            #endif
            continueAsGuestButton
        }
        .padding(.bottom, DesignSystem.Spacing.md)
        .phaseEntrance(index: 8)
    }

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
        .signInWithAppleButtonStyle(.white)
        .frame(height: 50)
        .clipShape(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.large, style: .continuous))
        .geoShadow(.subtle)
    }

    var googleSignInButton: some View {
        Button {
            #if !os(tvOS)
            Task { @MainActor in
                await authService.signInWithGoogle()
                switch authService.state {
                case .authenticated:
                    dismiss()
                case .error(let error):
                    errorMessage = error.localizedDescription
                    showError = true
                default:
                    break
                }
            }
            #endif
        } label: {
            HStack(spacing: DesignSystem.Spacing.sm) {
                GoogleGLogo()
                    .frame(width: 22, height: 22)
                    .accessibilityHidden(true)
                Text("Sign in with Google")
                    .font(DesignSystem.Font.headline)
                    .foregroundStyle(Color(white: 0.18))
            }
            .frame(maxWidth: .infinity)
            .frame(minHeight: 50)
            .background(DesignSystem.Color.onAccent)
            .clipShape(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.large, style: .continuous))
            .geoShadow(.subtle)
        }
        .buttonStyle(.plain)
    }

    var continueAsGuestButton: some View {
        Button { dismiss() } label: {
            Text("Continue as Guest")
                .font(DesignSystem.Font.subheadline)
                .foregroundStyle(DesignSystem.Color.textSecondary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, DesignSystem.Spacing.xs)
        }
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

// MARK: - Google G Logo
private struct ArcSegment {
    let startDeg: CGFloat
    let endDeg: CGFloat
    let red: Double
    let green: Double
    let blue: Double
}

private struct GoogleGLogo: View {
    private static let segments: [ArcSegment] = [
        ArcSegment(startDeg: 30, endDeg: 90, red: 0.918, green: 0.263, blue: 0.208),
        ArcSegment(startDeg: 90, endDeg: 150, red: 0.984, green: 0.737, blue: 0.016),
        ArcSegment(startDeg: 150, endDeg: 210, red: 0.204, green: 0.659, blue: 0.325),
        ArcSegment(startDeg: 210, endDeg: 330, red: 0.259, green: 0.522, blue: 0.957),
    ]

    var body: some View {
        Canvas { context, size in
            let cx = size.width / 2
            let cy = size.height / 2
            let outerR = min(size.width, size.height) / 2
            let strokeW = outerR * 0.36
            let midR = outerR - strokeW / 2
            let center = CGPoint(x: cx, y: cy)
            let style = StrokeStyle(lineWidth: strokeW, lineCap: .butt)

            for segment in Self.segments {
                let arc = Path { builder in
                    builder.addArc(
                        center: center,
                        radius: midR,
                        startAngle: .degrees(segment.startDeg),
                        endAngle: .degrees(segment.endDeg),
                        clockwise: false
                    )
                }
                context.stroke(
                    arc,
                    with: .color(Color(red: segment.red, green: segment.green, blue: segment.blue)),
                    style: style
                )
            }

            var crossbar = Path()
            crossbar.move(to: CGPoint(x: cx, y: cy))
            crossbar.addLine(to: CGPoint(x: size.width - strokeW * 0.2, y: cy))
            context.stroke(crossbar, with: .color(Color(red: 0.259, green: 0.522, blue: 0.957)), style: style)
        }
    }
}
