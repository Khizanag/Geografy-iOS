import AuthenticationServices
import Geografy_Core_Common
import Geografy_Core_DesignSystem
import Geografy_Core_Navigation
import Geografy_Core_Service
import Geografy_Feature_Map
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
            googleSignInButton
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

    /// Both sign-in buttons share Apple's button size and shape, as the Human Interface Guidelines ask.
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
            .frame(minHeight: Self.signInButtonHeight)
            .background(Color.white, in: Self.signInButtonShape)
            .overlay {
                // Edges the white button on the light background, as Google's own button does.
                Self.signInButtonShape.strokeBorder(Color(white: 0.75), lineWidth: colorScheme == .dark ? 0 : 1)
            }
        }
        .buttonStyle(PressButtonStyle())
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
/// The world map, with the countries the person has visited lit up, fading into the page under the app's name.
private struct SignInMapHero: View {
    // MARK: - Properties
    @Environment(GeoJSONCache.self) private var geoJSONCache
    @Environment(TravelService.self) private var travelService
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    @State private var shapes: [CountryShape] = []

    /// How far the map sits below center, as a share of its height, so the northern lands most people live on show.
    private static let northwardShift: CGFloat = 0.1
    private static let mapHeight: CGFloat = 300

    // MARK: - Body
    var body: some View {
        ZStack(alignment: .bottom) {
            map
            title
        }
        .task { await loadShapes() }
    }
}

// MARK: - Subviews
private extension SignInMapHero {
    var map: some View {
        GeometryReader { geometry in
            let scale = geometry.size.width / MapProjection.mapWidth
            MapCanvasView(
                countryShapes: shapes,
                scale: scale,
                offset: CGSize(width: 0, height: MapProjection.mapHeight * scale * Self.northwardShift),
                selectedCountryCode: nil,
                showLabels: false,
                canvasSize: geometry.size,
                highlightedCodes: travelService.visitedCodes,
                wrapsHorizontally: false
            )
        }
        .frame(height: Self.mapHeight)
        .opacity(shapes.isEmpty ? 0 : 0.75)
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
        .allowsHitTesting(false)
        .accessibilityHidden(true)
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

    func loadShapes() async {
        let loaded = await geoJSONCache.loadShapes()
        withAnimation(reduceMotion ? nil : .easeOut(duration: 0.4)) {
            shapes = loaded
        }
    }
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
