import SwiftUI

struct BadgeUnlockAnimation: View {
    let badge: BadgeDefinition
    let onDismiss: () -> Void

    @State private var badgeScale: CGFloat = 0.3
    @State private var badgeOpacity: Double = 0
    @State private var confettiVisible = false
    @State private var bannerOffset: CGFloat = 40
    @State private var bannerOpacity: Double = 0
    @State private var shimmerActive = false

    var body: some View {
        ZStack {
            Color.black.opacity(0.85)
                .ignoresSafeArea()
                .onTapGesture { dismissAnimation() }
            confettiLayer
                .opacity(confettiVisible ? 1 : 0)
            mainContent
        }
        .onAppear { startAnimation() }
    }
}

// MARK: - Subviews

private extension BadgeUnlockAnimation {
    var mainContent: some View {
        VStack(spacing: DesignSystem.Spacing.xl) {
            Spacer()
            unlockLabel
            badgeHero
            badgeInfo
            rarityLabel
            Spacer()
            collectButton
        }
        .padding(.horizontal, DesignSystem.Spacing.xxl)
        .padding(.bottom, DesignSystem.Spacing.xxl)
    }

    var unlockLabel: some View {
        Text("BADGE UNLOCKED!")
            .font(DesignSystem.Font.title2)
            .fontWeight(.black)
            .foregroundStyle(
                LinearGradient(
                    colors: [
                        badge.rarity.borderColor,
                        badge.rarity.borderColor.opacity(0.7),
                    ],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .opacity(bannerOpacity)
            .offset(y: bannerOffset)
    }

    var badgeHero: some View {
        ZStack {
            shimmerRing
            Circle()
                .fill(badge.category.themeColor.opacity(0.2))
                .frame(width: 120, height: 120)
            Circle()
                .strokeBorder(
                    badge.rarity.borderGradient,
                    lineWidth: badge.rarity.borderWidth * 2
                )
                .frame(width: 120, height: 120)
            Image(systemName: badge.iconName)
                .font(.system(size: 52))
                .foregroundStyle(badge.category.themeColor)
        }
        .scaleEffect(badgeScale)
        .opacity(badgeOpacity)
    }

    var shimmerRing: some View {
        Circle()
            .strokeBorder(
                AngularGradient(
                    colors: [
                        badge.rarity.borderColor.opacity(0),
                        badge.rarity.borderColor.opacity(0.6),
                        badge.rarity.borderColor.opacity(0),
                    ],
                    center: .center,
                    startAngle: .degrees(shimmerActive ? 360 : 0),
                    endAngle: .degrees(shimmerActive ? 720 : 360)
                ),
                lineWidth: 3
            )
            .frame(width: 140, height: 140)
    }

    var badgeInfo: some View {
        VStack(spacing: DesignSystem.Spacing.xs) {
            Text(badge.title)
                .font(DesignSystem.Font.title)
                .fontWeight(.bold)
                .foregroundStyle(DesignSystem.Color.textPrimary)
            Text(badge.description)
                .font(DesignSystem.Font.subheadline)
                .foregroundStyle(DesignSystem.Color.textSecondary)
                .multilineTextAlignment(.center)
        }
        .opacity(bannerOpacity)
        .offset(y: bannerOffset)
    }

    var rarityLabel: some View {
        HStack(spacing: DesignSystem.Spacing.xxs) {
            Image(systemName: rarityIcon)
                .font(DesignSystem.Font.caption)
            Text(badge.rarity.displayName)
                .font(DesignSystem.Font.subheadline)
                .fontWeight(.bold)
        }
        .foregroundStyle(badge.rarity.borderColor)
        .padding(.horizontal, DesignSystem.Spacing.md)
        .padding(.vertical, DesignSystem.Spacing.xs)
        .background(
            badge.rarity.borderColor.opacity(0.15),
            in: Capsule()
        )
        .opacity(bannerOpacity)
    }

    var collectButton: some View {
        Button {
            dismissAnimation()
        } label: {
            Text("Collect")
                .font(DesignSystem.Font.headline)
                .fontWeight(.semibold)
                .foregroundStyle(DesignSystem.Color.onAccent)
                .frame(maxWidth: .infinity)
                .padding(.vertical, DesignSystem.Spacing.sm)
                .background(badge.category.themeColor)
                .clipShape(
                    RoundedRectangle(
                        cornerRadius: DesignSystem.CornerRadius.medium
                    )
                )
        }
        .buttonStyle(GeoPressButtonStyle())
        .opacity(bannerOpacity)
    }

    var confettiLayer: some View {
        ZStack {
            ForEach(0..<32, id: \.self) { index in
                ConfettiParticle(
                    angle: Double(index) / 32.0 * 2.0 * .pi,
                    distance: 130 + CGFloat(index % 5) * 30,
                    color: confettiColors[index % confettiColors.count],
                    delay: Double(index) * 0.025
                )
            }
        }
    }

    var confettiColors: [Color] {
        [
            badge.rarity.borderColor,
            badge.category.themeColor,
            DesignSystem.Color.accent,
            DesignSystem.Color.warning,
            DesignSystem.Color.success,
        ]
    }

    var rarityIcon: String {
        switch badge.rarity {
        case .common:    "circle.fill"
        case .rare:      "diamond.fill"
        case .epic:      "star.fill"
        case .legendary: "sparkle"
        }
    }
}

// MARK: - Actions

private extension BadgeUnlockAnimation {
    func startAnimation() {
        UINotificationFeedbackGenerator().notificationOccurred(.success)
        withAnimation(
            .spring(response: 0.5, dampingFraction: 0.65).delay(0.1)
        ) {
            badgeScale = 1.0
            badgeOpacity = 1.0
        }
        withAnimation(.easeOut(duration: 0.4).delay(0.35)) {
            bannerOffset = 0
            bannerOpacity = 1.0
        }
        withAnimation(.easeOut(duration: 0.3).delay(0.2)) {
            confettiVisible = true
        }
        withAnimation(
            .linear(duration: 2.0)
                .repeatForever(autoreverses: false)
                .delay(0.5)
        ) {
            shimmerActive = true
        }
    }

    func dismissAnimation() {
        withAnimation(.easeIn(duration: 0.25)) {
            badgeScale = 0.5
            badgeOpacity = 0
            bannerOpacity = 0
            confettiVisible = false
        }
        Task {
            try? await Task.sleep(for: .milliseconds(280))
            onDismiss()
        }
    }
}

// MARK: - Confetti Particle

private struct ConfettiParticle: View {
    let angle: Double
    let distance: CGFloat
    let color: Color
    let delay: Double

    @State private var active = false

    var body: some View {
        RoundedRectangle(cornerRadius: 2)
            .fill(color)
            .frame(
                width: active ? 4 : 8,
                height: active ? 4 : 8
            )
            .offset(
                x: active ? cos(angle) * distance : 0,
                y: active ? sin(angle) * distance : 0
            )
            .rotationEffect(.degrees(active ? 360 : 0))
            .opacity(active ? 0 : 0.85)
            .onAppear {
                withAnimation(
                    .easeOut(duration: 1.2).delay(delay)
                ) {
                    active = true
                }
            }
    }
}
