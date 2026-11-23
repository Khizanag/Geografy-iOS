import Geografy_Core_Common
import Geografy_Core_DesignSystem
import Geografy_Core_Service
import SwiftUI

/// Celebrates a new level over whatever is on screen: the tier badge, the level's title, and how far the next
/// level is. Drawn above the whole app rather than as a sheet, so it still shows when a game's full-screen
/// session is the one that earned it.
public struct LevelUpSheet: View {
    // MARK: - Properties
    @Environment(SoundService.self) private var soundService
    @Environment(XPService.self) private var xpService
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.locale) private var locale

    @ScaledMetric(relativeTo: .body) private var cardWidth: CGFloat = 360

    public let newLevel: UserLevel
    public let onDismiss: () -> Void

    @State private var isShown = false

    // MARK: - Init
    public init(newLevel: UserLevel, onDismiss: @escaping () -> Void) {
        self.newLevel = newLevel
        self.onDismiss = onDismiss
    }

    // MARK: - Body
    public var body: some View {
        ZStack {
            DesignSystem.Color.overlayScrim
                .ignoresSafeArea()
                .accessibilityHidden(true)
            card
                .scaleEffect(isShown || reduceMotion ? 1 : 0.85)
                .opacity(isShown ? 1 : 0)
        }
        .haptic(.success, trigger: isShown)
        .onAppear {
            soundService.play(.celebrate)
            withAnimation(reduceMotion ? .easeOut(duration: 0.2) : .spring(response: 0.45, dampingFraction: 0.75)) {
                isShown = true
            }
            AccessibilityNotification.Announcement(announcement).post()
        }
    }
}

// MARK: - Subviews
private extension LevelUpSheet {
    var card: some View {
        VStack(spacing: DesignSystem.Spacing.lg) {
            hero
            headline
            nextLevel
            GlassButton("Continue", fullWidth: true, action: onDismiss)
        }
        .padding(DesignSystem.Spacing.lg)
        .frame(maxWidth: cardWidth)
        .glassEffect(.regular, in: .rect(cornerRadius: DesignSystem.CornerRadius.extraLarge))
        .padding(.horizontal, DesignSystem.Spacing.lg)
        .accessibilityElement(children: .contain)
        .accessibilityAddTraits(.isModal)
    }

    var hero: some View {
        ZStack {
            if !reduceMotion {
                SparkleBurst(colors: newLevel.tierColors + [DesignSystem.Color.warning])
                    .accessibilityHidden(true)
            }
            LevelBadgeView(level: newLevel, size: .large, animated: true, showsTitle: false)
        }
        .padding(.top, DesignSystem.Spacing.sm)
    }

    var headline: some View {
        VStack(spacing: DesignSystem.Spacing.xxs) {
            EyebrowLabel("Level up")
            Text(newLevel.title)
                .font(DesignSystem.Font.title)
                .fontWeight(.bold)
                .foregroundStyle(DesignSystem.Color.textPrimary)
                .accessibilityAddTraits(.isHeader)
            Text("You reached level \(newLevel.level)")
                .font(DesignSystem.Font.subheadline)
                .foregroundStyle(DesignSystem.Color.textSecondary)
        }
        .multilineTextAlignment(.center)
    }

    @ViewBuilder
    var nextLevel: some View {
        if let next = nextThreshold {
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
                Text("Next: \(next.title)")
                    .font(DesignSystem.Font.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(DesignSystem.Color.textPrimary)
                XPProgressBar(
                    currentLevelNumber: newLevel.level,
                    nextLevelNumber: next.level,
                    xpInCurrentLevel: max(xpService.totalXP - newLevel.minXP, 0),
                    xpRequiredForNextLevel: newLevel.maxXP - newLevel.minXP,
                    progressFraction: progressFraction
                )
            }
            .padding(DesignSystem.Spacing.md)
            .background(
                DesignSystem.Color.cardBackgroundHighlighted.opacity(DesignSystem.Opacity.half),
                in: .rect(cornerRadius: DesignSystem.CornerRadius.large)
            )
        } else {
            Text("That's the top level. Well travelled.")
                .font(DesignSystem.Font.subheadline)
                .foregroundStyle(DesignSystem.Color.textSecondary)
                .multilineTextAlignment(.center)
        }
    }
}

// MARK: - Helpers
private extension LevelUpSheet {
    var nextThreshold: UserLevel? {
        UserLevel.thresholds.first { $0.level == newLevel.level + 1 }
    }

    var progressFraction: Double {
        let range = Double(newLevel.maxXP - newLevel.minXP)
        guard range > 0 else { return 1 }
        return min(max(Double(xpService.totalXP - newLevel.minXP) / range, 0), 1)
    }

    var announcement: String {
        String(localized: "Level up. You’re now level \(newLevel.level), \(newLevel.title).", in: locale)
    }
}

// MARK: - Sparkle Burst
/// Dots that fly out from behind the badge once and fade.
private struct SparkleBurst: View {
    let colors: [Color]

    @State private var isBurst = false

    private static let count = 24

    var body: some View {
        ZStack {
            ForEach(0..<Self.count, id: \.self) { index in
                let angle = Double(index) / Double(Self.count) * 2 * .pi
                let distance = 90 + CGFloat(index % 3) * 22
                Circle()
                    .fill(colors[index % colors.count])
                    .frame(width: isBurst ? 4 : 8, height: isBurst ? 4 : 8)
                    .offset(
                        x: isBurst ? cos(angle) * distance : 0,
                        y: isBurst ? sin(angle) * distance : 0
                    )
                    .opacity(isBurst ? 0 : 0.9)
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 1.1).delay(0.1)) {
                isBurst = true
            }
        }
    }
}
