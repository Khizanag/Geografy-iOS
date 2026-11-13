import Geografy_Core_Common
import Geografy_Core_DesignSystem
import Geografy_Core_Service
import SwiftUI

public struct LevelUpSheet: View {
    // MARK: - Properties
    @Environment(HapticsService.self) private var hapticsService

    public let newLevel: UserLevel
    public let onDismiss: () -> Void

    @State private var contentScale: CGFloat = 0.5
    @State private var contentOpacity: Double = 0
    @State private var particlesVisible = false

    // MARK: - Init
    public init(newLevel: UserLevel, onDismiss: @escaping () -> Void) {
        self.newLevel = newLevel
        self.onDismiss = onDismiss
    }

    // MARK: - Body
    public var body: some View {
        extractedContent
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
    var extractedContent: some View {
        ZStack {
            DesignSystem.Color.overlayScrim
                .ignoresSafeArea()

            particleLayer
                .opacity(particlesVisible ? 1 : 0)
                .animation(.easeOut(duration: 0.3).delay(0.15), value: particlesVisible)

            card
                .scaleEffect(contentScale)
                .opacity(contentOpacity)
                .animation(.spring(response: 0.5, dampingFraction: 0.65).delay(0.05), value: contentScale)
        }
    }

    var card: some View {
        CardView {
            VStack(spacing: DesignSystem.Spacing.lg) {
                levelUpHeadline
                LevelBadgeView(level: newLevel, size: .large, animated: true)
                levelDetails
                continueButton
            }
            .padding(DesignSystem.Spacing.lg)
            .frame(maxWidth: 360)
        }
        .padding(.horizontal, DesignSystem.Spacing.lg)
        .accessibilityElement(children: .contain)
        .accessibilityAddTraits(.isModal)
    }

    var levelUpHeadline: some View {
        VStack(spacing: DesignSystem.Spacing.xs) {
            Text("LEVEL UP!")
                .font(DesignSystem.IconSize.xLarge.weight(.black))
                .foregroundStyle(
                    LinearGradient(
                        colors: [DesignSystem.Color.warning, DesignSystem.Color.orange],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
            Text("You've reached a new level")
                .font(DesignSystem.Font.subheadline)
                .foregroundStyle(DesignSystem.Color.textSecondary)
        }
    }

    // The badge already shows the level's title, so only the number goes here.
    var levelDetails: some View {
        Text("Level \(newLevel.level)")
            .font(DesignSystem.Font.title)
            .fontWeight(.bold)
            .foregroundStyle(DesignSystem.Color.textPrimary)
    }

    var continueButton: some View {
        GlassButton("Continue", fullWidth: true) {
            onDismiss()
        }
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
}

// MARK: - Helpers
private extension LevelUpSheet {
    var sparkleColors: [Color] {
        [
            DesignSystem.Color.warning,
            DesignSystem.Color.orange,
            .pink,
            DesignSystem.Color.purple,
            DesignSystem.Color.blue,
            DesignSystem.Color.success,
            .cyan,
            DesignSystem.Color.error,
        ]
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
