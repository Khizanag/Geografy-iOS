import Geografy_Core_Common
import SwiftUI

public enum LevelBadgeSize {
    case small
    case large

    public var diameter: CGFloat {
        switch self {
        case .small: 44
        case .large: 96
        }
    }

    public var numberFont: Font {
        switch self {
        case .small: DesignSystem.Font.headline
        case .large: DesignSystem.Font.largeTitle.weight(.black)
        }
    }

    public var glowRadius: CGFloat {
        switch self {
        case .small: 6
        case .large: 18
        }
    }
}

public struct LevelBadgeView: View {
    // MARK: - Properties
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    public let level: UserLevel
    public var size: LevelBadgeSize = .small
    public var animated: Bool = false
    public var showsTitle: Bool = true

    @State private var glowPulse = false

    // MARK: - Init
    public init(
        level: UserLevel,
        size: LevelBadgeSize = .small,
        animated: Bool = false,
        showsTitle: Bool = true
    ) {
        self.level = level
        self.size = size
        self.animated = animated
        self.showsTitle = showsTitle
    }

    // MARK: - Body
    public var body: some View {
        VStack(spacing: DesignSystem.Spacing.xs) {
            badgeCircle
            if size == .large, showsTitle {
                levelTitle
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Level \(level.level), \(level.title)")
    }
}

// MARK: - Subviews
private extension LevelBadgeView {
    var badgeCircle: some View {
        ZStack {
            glow
                .opacity(glowPulse ? 0.85 : 0.45)
            Circle()
                .fill(levelGradient)
                .frame(width: size.diameter, height: size.diameter)
            Text("\(level.level)")
                .font(size.numberFont)
                .fontWeight(.black)
                .foregroundStyle(DesignSystem.Color.onAccent)
        }
        .animation(
            animated && !reduceMotion ? .easeInOut(duration: 1.6).repeatForever(autoreverses: true) : nil,
            value: glowPulse
        )
        .onAppear {
            guard animated else { return }
            glowPulse = true
        }
    }

    // A static gradient halo stands in for a shadow, so the pulse animates only opacity
    // instead of re-blurring a shadow every frame.
    var glow: some View {
        let radius = size.diameter / 2
        let outerRadius = radius + size.glowRadius
        let edge = radius / outerRadius
        let middle = (radius + size.glowRadius / 2) / outerRadius
        return Circle()
            .fill(
                RadialGradient(
                    stops: [
                        .init(color: glowColor.opacity(DesignSystem.Opacity.half), location: edge),
                        .init(color: glowColor.opacity(DesignSystem.Opacity.tint), location: middle),
                        .init(color: glowColor.opacity(0), location: 1),
                    ],
                    center: .center,
                    startRadius: 0,
                    endRadius: outerRadius
                )
            )
            .frame(width: outerRadius * 2, height: outerRadius * 2)
            .frame(width: size.diameter, height: size.diameter)
            .accessibilityHidden(true)
    }

    var levelTitle: some View {
        Text(level.title)
            .font(DesignSystem.Font.subheadline)
            .fontWeight(.semibold)
            .foregroundStyle(DesignSystem.Color.textPrimary)
    }
}

// MARK: - Helpers
private extension LevelBadgeView {
    var levelGradient: LinearGradient {
        LinearGradient(colors: level.tierColors, startPoint: .topLeading, endPoint: .bottomTrailing)
    }

    var glowColor: Color { level.tierColor }
}

// MARK: - Tier
public extension UserLevel {
    /// Bronze, silver, gold, emerald, then diamond, two levels each: the light and dark ends of the badge.
    var tierColors: [Color] {
        switch level {
        case 1, 2: [Color(hex: "CD7F32"), Color(hex: "8B4513")]
        case 3, 4: [Color(hex: "C0C0C0"), Color(hex: "707070")]
        case 5, 6: [Color(hex: "FFD700"), Color(hex: "FFA500")]
        case 7, 8: [Color(hex: "50C878"), Color(hex: "006400")]
        default: [Color(hex: "BF5FFF"), Color(hex: "6C3483")]
        }
    }

    /// The tier's light end, for glows and accents around the badge.
    var tierColor: Color { tierColors[0] }
}
