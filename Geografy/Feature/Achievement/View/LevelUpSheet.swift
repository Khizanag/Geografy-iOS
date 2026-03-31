import SwiftUI
import GeografyDesign
import GeografyCore

struct LevelUpSheet: View {
    @Environment(HapticsService.self) private var hapticsService

    let newLevel: UserLevel
    let onDismiss: () -> Void

    @State private var contentScale: CGFloat = 0.5
    @State private var contentOpacity: Double = 0
    @State private var particlesVisible = false

    var body: some View {
        ZStack {
            Color.black.opacity(0.88)
                .ignoresSafeArea()
            particleLayer
                .opacity(particlesVisible ? 1 : 0)
                .animation(.easeOut(duration: 0.3).delay(0.15), value: particlesVisible)
            mainContent
                .scaleEffect(contentScale)
                .opacity(contentOpacity)
                .animation(.spring(response: 0.5, dampingFraction: 0.65).delay(0.05), value: contentScale)
        }
        .onAppear {
            hapticsService.notification(.success)
            contentScale = 1.0
            contentOpacity = 1.0
            particlesVisible = true
        }
    }
}

// MARK: - Subviews
private extension LevelUpSheet {
    var mainContent: some View {
        VStack(spacing: DesignSystem.Spacing.xl) {
            levelUpHeadline
            LevelBadgeView(level: newLevel, size: .large, animated: true)
            levelDetails
            continueButton
        }
        .padding(.horizontal, DesignSystem.Spacing.xxl)
    }

    var levelUpHeadline: some View {
        VStack(spacing: DesignSystem.Spacing.xs) {
            Text("LEVEL UP!")
                .font(DesignSystem.IconSize.xLarge.weight(.black))
                .foregroundStyle(
                    LinearGradient(
                        colors: [.yellow, .orange],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
            Text("You've reached a new level")
                .font(DesignSystem.Font.subheadline)
                .foregroundStyle(DesignSystem.Color.textSecondary)
        }
    }

    var levelDetails: some View {
        VStack(spacing: DesignSystem.Spacing.xs) {
            Text("Level \(newLevel.level)")
                .font(DesignSystem.Font.title)
                .fontWeight(.bold)
                .foregroundStyle(DesignSystem.Color.textPrimary)
            Text(newLevel.title)
                .font(DesignSystem.Font.title2)
                .foregroundStyle(DesignSystem.Color.accent)
        }
    }

    var continueButton: some View {
        Button {
            onDismiss()
        } label: {
            Text("Continue")
                .font(DesignSystem.Font.headline)
                .fontWeight(.semibold)
                .foregroundStyle(DesignSystem.Color.onAccent)
                .frame(maxWidth: .infinity)
                .padding(.vertical, DesignSystem.Spacing.sm)
                .background(DesignSystem.Color.accent)
                .clipShape(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium))
        }
        .buttonStyle(PressButtonStyle())
    }

    var particleLayer: some View {
        ZStack {
            ForEach(0..<28, id: \.self) { index in
                SparkleParticle(
                    angle: Double(index) / 28.0 * 2.0 * .pi,
                    distance: 110 + CGFloat(index % 4) * 35,
                    color: sparkleColors[index % sparkleColors.count],
                    delay: Double(index) * 0.03
                )
            }
        }
    }

    var sparkleColors: [Color] {
        [.yellow, .orange, .pink, DesignSystem.Color.purple, DesignSystem.Color.blue, .green, .cyan, .red]
    }
}

// MARK: - Particle View
private struct SparkleParticle: View {
    let angle: Double
    let distance: CGFloat
    let color: Color
    let delay: Double

    @State private var active = false

    var body: some View {
        Circle()
            .fill(color)
            .frame(width: active ? 5 : 10, height: active ? 5 : 10)
            .offset(
                x: active ? cos(angle) * distance : 0,
                y: active ? sin(angle) * distance : 0
            )
            .opacity(active ? 0 : 0.9)
            .onAppear {
                withAnimation(.easeOut(duration: 1.1).delay(delay)) {
                    active = true
                }
            }
    }
}
