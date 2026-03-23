import AuthenticationServices
import SwiftUI

struct SignInOptionsSheet: View {
    @Environment(AuthService.self) private var authService
    @Environment(\.dismiss) private var dismiss

    @State private var showError = false
    @State private var errorMessage = ""
    @State private var blobAnimating = false
    @State private var appeared = false
    @State private var iconRotating = false

    var body: some View {
        ZStack {
            DesignSystem.Color.background.ignoresSafeArea()
            ambientBlobs
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    heroSection
                        .padding(.top, DesignSystem.Spacing.xxl)
                    statsRow
                        .padding(.top, DesignSystem.Spacing.lg)
                        .opacity(appeared ? 1 : 0)
                        .offset(y: appeared ? 0 : 16)
                        .animation(.easeOut(duration: 0.5).delay(0.2), value: appeared)
                    benefitsSection
                        .padding(.top, DesignSystem.Spacing.lg)
                    actionsSection
                        .padding(.top, DesignSystem.Spacing.xl)
                        .padding(.bottom, DesignSystem.Spacing.xxl)
                }
                .padding(.horizontal, DesignSystem.Spacing.lg)
            }
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 6).repeatForever(autoreverses: true)) {
                blobAnimating = true
            }
            withAnimation(.linear(duration: 20).repeatForever(autoreverses: false)) {
                iconRotating = true
            }
            withAnimation(.easeOut(duration: 0.6)) {
                appeared = true
            }
        }
        .alert("Sign In Failed", isPresented: $showError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(errorMessage)
        }
    }
}

// MARK: - Background

private extension SignInOptionsSheet {
    var ambientBlobs: some View {
        ZStack {
            Ellipse()
                .fill(
                    RadialGradient(
                        colors: [DesignSystem.Color.accent.opacity(0.28), .clear],
                        center: .center, startRadius: 0, endRadius: 240
                    )
                )
                .frame(width: 480, height: 360).blur(radius: 40)
                .offset(x: -90, y: 40)
                .scaleEffect(blobAnimating ? 1.10 : 0.90)
            Ellipse()
                .fill(
                    RadialGradient(
                        colors: [DesignSystem.Color.indigo.opacity(0.20), .clear],
                        center: .center, startRadius: 0, endRadius: 200
                    )
                )
                .frame(width: 380, height: 320).blur(radius: 48)
                .offset(x: 150, y: 200)
                .scaleEffect(blobAnimating ? 0.88 : 1.10)
            Ellipse()
                .fill(
                    RadialGradient(
                        colors: [DesignSystem.Color.blue.opacity(0.14), .clear],
                        center: .center, startRadius: 0, endRadius: 180
                    )
                )
                .frame(width: 340, height: 280).blur(radius: 44)
                .offset(x: -60, y: 750)
                .scaleEffect(blobAnimating ? 1.06 : 0.94)
        }
        .allowsHitTesting(false)
        .ignoresSafeArea()
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
                    .font(.system(size: 36, weight: .black, design: .rounded))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [DesignSystem.Color.textPrimary, DesignSystem.Color.accent],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .opacity(appeared ? 1 : 0)
                    .offset(y: appeared ? 0 : 12)
                    .animation(.easeOut(duration: 0.5).delay(0.1), value: appeared)
                Text("Your world, explored.")
                    .font(DesignSystem.Font.callout)
                    .foregroundStyle(DesignSystem.Color.textSecondary)
                    .opacity(appeared ? 1 : 0)
                    .offset(y: appeared ? 0 : 12)
                    .animation(.easeOut(duration: 0.5).delay(0.15), value: appeared)
            }
        }
    }

    var appIconBadge: some View {
        ZStack {
            // Ambient glow — fully blurred, no distinct shape
            DesignSystem.Color.accent.opacity(0.35)
                .frame(width: 140, height: 140)
                .blur(radius: 50)
                .clipShape(Rectangle())

            // Single app icon badge shape
            RoundedRectangle(cornerRadius: 28)
                .fill(
                    LinearGradient(
                        colors: [DesignSystem.Color.accent, DesignSystem.Color.accentDark],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 96, height: 96)
                .shadow(color: DesignSystem.Color.accent.opacity(0.55), radius: 28, x: 0, y: 10)
                .overlay(
                    RoundedRectangle(cornerRadius: 28)
                        .strokeBorder(.white.opacity(0.18), lineWidth: 1)
                )

            Image(systemName: "globe.americas.fill")
                .font(.system(size: 46))
                .foregroundStyle(
                    LinearGradient(
                        colors: [.white, .white.opacity(0.82)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
        }
        .frame(width: 140, height: 140)
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
    }

    func statPill(value: String, label: String, icon: String, color: Color) -> some View {
        VStack(spacing: 5) {
            Image(systemName: icon)
                .font(.system(size: 13))
                .foregroundStyle(color)
            Text(value)
                .font(.system(size: 18, weight: .black, design: .rounded))
                .foregroundStyle(DesignSystem.Color.textPrimary)
            Text(label)
                .font(DesignSystem.Font.caption2)
                .foregroundStyle(DesignSystem.Color.textTertiary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, DesignSystem.Spacing.sm)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium))
        .overlay(
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium)
                .strokeBorder(.white.opacity(0.06), lineWidth: 1)
        )
    }
}

// MARK: - Benefits

private struct SignInBenefit {
    let icon: String
    let color: Color
    let title: String
    let subtitle: String
}

private extension SignInOptionsSheet {
    var benefits: [SignInBenefit] {
        [
            SignInBenefit(
                icon: "icloud.and.arrow.up.fill",
                color: DesignSystem.Color.blue,
                title: "Sync across devices",
                subtitle: "Your progress follows you everywhere"
            ),
            SignInBenefit(
                icon: "trophy.fill",
                color: .yellow,
                title: "Achievements & XP",
                subtitle: "Earn rewards as you explore the world"
            ),
            SignInBenefit(
                icon: "airplane.departure",
                color: DesignSystem.Color.accent,
                title: "Track your travels",
                subtitle: "Pin countries you've visited or dream of"
            ),
            SignInBenefit(
                icon: "chart.line.uptrend.xyaxis",
                color: DesignSystem.Color.indigo,
                title: "Quiz history & streaks",
                subtitle: "See how much your knowledge grows"
            ),
            SignInBenefit(
                icon: "person.2.fill",
                color: DesignSystem.Color.purple,
                title: "Global leaderboards",
                subtitle: "Compete with explorers worldwide"
            ),
        ]
    }

    var benefitsSection: some View {
        VStack(spacing: DesignSystem.Spacing.xs) {
            ForEach(Array(benefits.enumerated()), id: \.offset) { index, benefit in
                benefitRow(benefit, delay: Double(index) * 0.07)
            }
        }
    }

    func benefitRow(_ benefit: SignInBenefit, delay: Double) -> some View {
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
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium))
        .overlay(
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium)
                .strokeBorder(.white.opacity(0.05), lineWidth: 1)
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
                .opacity(appeared ? 1 : 0)
                .offset(y: appeared ? 0 : 16)
                .animation(.easeOut(duration: 0.5).delay(0.65), value: appeared)
            googleSignInButton
                .opacity(appeared ? 1 : 0)
                .offset(y: appeared ? 0 : 16)
                .animation(.easeOut(duration: 0.5).delay(0.70), value: appeared)
#if DEBUG
            debugSignInButton
                .opacity(appeared ? 1 : 0)
                .animation(.easeOut(duration: 0.5).delay(0.75), value: appeared)
#endif
            continueAsGuestButton
                .opacity(appeared ? 1 : 0)
                .animation(.easeOut(duration: 0.5).delay(0.80), value: appeared)
        }
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
        .frame(height: 56)
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
            .frame(height: 56)
            .background(.white)
            .clipShape(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.large))
            .shadow(color: .black.opacity(0.14), radius: 12, y: 4)
        }
        .buttonStyle(.plain)
    }

    var continueAsGuestButton: some View {
        Button {
            dismiss()
        } label: {
            Text("Continue as Guest")
                .font(DesignSystem.Font.subheadline)
                .foregroundStyle(DesignSystem.Color.textTertiary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, DesignSystem.Spacing.sm)
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
                Text("Debug Sign In (Giga)")
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
#endif
}

// MARK: - Google G Logo

private struct GoogleGLogo: View {
    // (startDeg, endDeg, red, green, blue) — going visually clockwise (clockwise: false in screen coords)
    private static let segments: [(CGFloat, CGFloat, Double, Double, Double)] = [
        (30, 90, 0.918, 0.263, 0.208),   // Red: upper-right
        (90, 150, 0.984, 0.737, 0.016),  // Yellow: lower-right
        (150, 210, 0.204, 0.659, 0.325), // Green: bottom
        (210, 330, 0.259, 0.522, 0.957), // Blue: left + top (dominant)
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

            // Crossbar: horizontal bar from center to right edge (blue)
            var crossbar = Path()
            crossbar.move(to: CGPoint(x: cx, y: cy))
            crossbar.addLine(to: CGPoint(x: size.width - strokeW * 0.2, y: cy))
            context.stroke(crossbar, with: .color(Color(red: 0.259, green: 0.522, blue: 0.957)), style: style)
        }
    }
}
