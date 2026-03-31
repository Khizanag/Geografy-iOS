import SwiftUI
import AuthenticationServices
import GeografyDesign

struct SignInOptionsSheet: View {
    @Environment(AuthService.self) private var authService
    @Environment(TestingModeService.self) private var testingModeService
    @Environment(\.dismiss) private var dismiss

    @State private var showError = false
    @State private var errorMessage = ""
    @State private var appeared = false

    var body: some View {
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
        .background { AmbientBlobsView(.standard) }
        .background(DesignSystem.Color.background.ignoresSafeArea())
        .onAppear {
            appeared = true
        }
        .alert("Sign In Failed", isPresented: $showError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(errorMessage)
        }
    }
}

// MARK: - Hero
private extension SignInOptionsSheet {
    var heroSection: some View {
        VStack(spacing: DesignSystem.Spacing.md) {
            appIconBadge
                .opacity(appeared ? 1 : 0)
                .scaleEffect(appeared ? 1 : 0.6)
                .animation(.spring(response: 0.6, dampingFraction: 0.68), value: appeared)
            VStack(spacing: DesignSystem.Spacing.xs) {
                Text("Geografy")
                    .font(DesignSystem.Font.roundedBrand)
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
            .opacity(appeared ? 1 : 0)
            .offset(y: appeared ? 0 : 12)
            .animation(.easeOut(duration: 0.5).delay(0.1), value: appeared)
        }
    }

    var appIconBadge: some View {
        ZStack {
            DesignSystem.Color.accent.opacity(0.35)
                .frame(width: 110, height: 110)
                .blur(radius: 40)
                .clipShape(Rectangle())

            RoundedRectangle(cornerRadius: 24)
                .fill(
                    LinearGradient(
                        colors: [DesignSystem.Color.accent, DesignSystem.Color.accentDark],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 76, height: 76)
                .shadow(color: DesignSystem.Color.accent.opacity(0.55), radius: 20, x: 0, y: 8)
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .strokeBorder(.white.opacity(0.18), lineWidth: 1)
                )

            Image(systemName: "globe.americas.fill")
                .font(DesignSystem.Font.iconXL)
                .foregroundStyle(
                    LinearGradient(
                        colors: [.white, .white.opacity(0.82)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
        }
        .frame(width: 110, height: 110)
    }
}

// MARK: - Stats Row
private extension SignInOptionsSheet {
    var statsRow: some View {
        HStack(spacing: DesignSystem.Spacing.sm) {
            statPill(value: "197", label: "Countries", icon: "flag.fill", color: DesignSystem.Color.accent)
            statPill(value: "7", label: "Continents", icon: "globe.americas", color: DesignSystem.Color.blue)
            statPill(value: "∞", label: "Adventures", icon: "star.fill", color: DesignSystem.Color.indigo)
        }
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 16)
        .animation(.easeOut(duration: 0.5).delay(0.2), value: appeared)
    }

    func statPill(value: String, label: String, icon: String, color: Color) -> some View {
        VStack(spacing: 5) {
            Image(systemName: icon)
                .font(DesignSystem.Font.footnote)
                .foregroundStyle(color)
            Text(value)
                .font(DesignSystem.Font.roundedCaption)
                .foregroundStyle(DesignSystem.Color.textPrimary)
                .minimumScaleFactor(0.8)
            Text(label)
                .font(DesignSystem.Font.caption2)
                .foregroundStyle(DesignSystem.Color.textTertiary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, DesignSystem.Spacing.sm)
        .background(
            DesignSystem.Color.cardBackground,
            in: RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium)
        )
    }
}

// MARK: - Benefits
private extension SignInOptionsSheet {
    var benefitsSection: some View {
        VStack(spacing: DesignSystem.Spacing.xs) {
            ForEach(Array(benefits.enumerated()), id: \.offset) { index, benefit in
                benefitRow(benefit, delay: Double(index) * 0.06)
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
        _ benefit: (icon: String, color: Color, title: String, subtitle: String),
        delay: Double
    ) -> some View {
        HStack(spacing: DesignSystem.Spacing.md) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(benefit.color.opacity(0.16))
                    .frame(width: DesignSystem.Size.xl, height: DesignSystem.Size.xl)
                Image(systemName: benefit.icon)
                    .font(DesignSystem.Font.headline)
                    .foregroundStyle(benefit.color)
            }
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
        .background(
            DesignSystem.Color.cardBackground,
            in: RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium)
        )
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 20)
        .animation(.easeOut(duration: 0.5).delay(0.25 + delay), value: appeared)
    }
}

// MARK: - Actions
private extension SignInOptionsSheet {
    var actionsSection: some View {
        VStack(spacing: DesignSystem.Spacing.sm) {
            appleSignInButton
            googleSignInButton
            if testingModeService.isEnabled {
                debugSignInButton
            }
            continueAsGuestButton
        }
        .padding(.horizontal, DesignSystem.Spacing.md)
        .padding(.bottom, DesignSystem.Spacing.md)
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 16)
        .animation(.easeOut(duration: 0.5).delay(0.6), value: appeared)
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
        .clipShape(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.large))
        .shadow(color: .white.opacity(0.12), radius: 16, y: 4)
    }

    var googleSignInButton: some View {
        Button {
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
        } label: {
            HStack(spacing: 12) {
                GoogleGLogo()
                    .frame(width: 22, height: 22)
                Text("Sign in with Google")
                    .font(DesignSystem.Font.headline)
                    .foregroundStyle(Color(white: 0.18))
            }
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .background(.white)
            .clipShape(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.large))
            .geoShadow(.subtle)
        }
        .buttonStyle(.plain)
    }

    var continueAsGuestButton: some View {
        Button { dismiss() } label: {
            Text("Continue as Guest")
                .font(DesignSystem.Font.subheadline)
                .foregroundStyle(DesignSystem.Color.textTertiary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, DesignSystem.Spacing.xs)
        }
    }

    var debugSignInButton: some View {
        Button {
            authService.debugSignIn()
            dismiss()
        } label: {
            HStack(spacing: DesignSystem.Spacing.xs) {
                Image(systemName: "hammer.fill")
                    .font(DesignSystem.Font.footnote)
                Text("Debug Sign In")
                    .font(DesignSystem.Font.subheadline)
                    .fontWeight(.semibold)
            }
            .foregroundStyle(DesignSystem.Color.onAccent)
            .frame(maxWidth: .infinity)
            .padding(.vertical, DesignSystem.Spacing.sm)
            .background(
                LinearGradient(
                    colors: [Color(hex: "7B2FF7"), Color(hex: "F107A3")],
                    startPoint: .leading,
                    endPoint: .trailing
                ),
                in: RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium)
            )
        }
        .buttonStyle(PressButtonStyle())
    }
}

// MARK: - Google G Logo
private struct GoogleGLogo: View {
    private static let segments: [(CGFloat, CGFloat, Double, Double, Double)] = [
        (30, 90, 0.918, 0.263, 0.208),
        (90, 150, 0.984, 0.737, 0.016),
        (150, 210, 0.204, 0.659, 0.325),
        (210, 330, 0.259, 0.522, 0.957),
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

            for (startDeg, endDeg, rVal, gVal, bVal) in Self.segments {
                let arc = Path { builder in
                    builder.addArc(
                        center: center,
                        radius: midR,
                        startAngle: .degrees(startDeg),
                        endAngle: .degrees(endDeg),
                        clockwise: false
                    )
                }
                context.stroke(arc, with: .color(Color(red: rVal, green: gVal, blue: bVal)), style: style)
            }

            var crossbar = Path()
            crossbar.move(to: CGPoint(x: cx, y: cy))
            crossbar.addLine(to: CGPoint(x: size.width - strokeW * 0.2, y: cy))
            context.stroke(crossbar, with: .color(Color(red: 0.259, green: 0.522, blue: 0.957)), style: style)
        }
    }
}
