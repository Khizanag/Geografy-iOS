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
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    public let level: UserLevel
    public var size: LevelBadgeSize = .small
    public var animated: Bool = false

    @State private var glowPulse = false

    public init(
        level: UserLevel,
        size: LevelBadgeSize = .small,
        animated: Bool = false
    ) {
        self.level = level
        self.size = size
        self.animated = animated
    }

    public var body: some View {
        VStack(spacing: DesignSystem.Spacing.xs) {
            badgeCircle
            if size == .large {
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
            Circle()
                .fill(levelGradient)
                .frame(width: size.diameter, height: size.diameter)
                .shadow(
                    color: glowColor.opacity(glowPulse ? 0.85 : 0.45),
                    radius: size.glowRadius,
                    x: 0,
                    y: 0
                )
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
        LinearGradient(colors: levelColors, startPoint: .topLeading, endPoint: .bottomTrailing)
    }

    var levelColors: [Color] {
        switch level.level {
        case 1, 2:  return [Color(hex: "CD7F32"), Color(hex: "8B4513")]  // Bronze
        case 3, 4:  return [Color(hex: "C0C0C0"), Color(hex: "707070")]  // Silver
        case 5, 6:  return [Color(hex: "FFD700"), Color(hex: "FFA500")]  // Gold
        case 7, 8:  return [Color(hex: "50C878"), Color(hex: "006400")]  // Emerald
        default:    return [Color(hex: "BF5FFF"), Color(hex: "6C3483")]  // Diamond
        }
    }

    var glowColor: Color {
        switch level.level {
        case 1, 2:  Color(hex: "CD7F32")
        case 3, 4:  Color(hex: "C0C0C0")
        case 5, 6:  Color(hex: "FFD700")
        case 7, 8:  Color(hex: "50C878")
        default:    Color(hex: "BF5FFF")
        }
    }
}
