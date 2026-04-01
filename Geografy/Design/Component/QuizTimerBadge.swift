import GeografyDesign
import SwiftUI

struct QuizTimerBadge: View {
    let seconds: Int
    var totalSeconds: Int?
    var style: Style = .pill

    var body: some View {
        badgeContent
            .foregroundStyle(timerColor)
            .padding(.horizontal, style == .compact ? DesignSystem.Spacing.xs : DesignSystem.Spacing.sm)
            .padding(.vertical, style == .compact ? 3 : DesignSystem.Spacing.xxs)
            .background(timerColor.opacity(0.15), in: Capsule())
            .overlay(Capsule().strokeBorder(timerColor.opacity(0.25), lineWidth: 1))
            .scaleEffect(isUrgent ? 1.06 : 1.0)
            .animation(.easeInOut(duration: 0.3), value: seconds)
            .animation(.easeInOut(duration: 0.3), value: timerColor)
    }
}

// MARK: - Style
extension QuizTimerBadge {
    enum Style {
        case pill
        case compact
    }
}

// MARK: - Subviews
private extension QuizTimerBadge {
    var badgeContent: some View {
        HStack(spacing: DesignSystem.Spacing.xxs) {
            if let totalSeconds {
                progressRing(progress: CGFloat(seconds) / CGFloat(max(totalSeconds, 1)))
            } else {
                Image(systemName: "timer")
                    .font(DesignSystem.Font.caption2)
            }

            Text(formattedTime)
                .font(style == .compact ? DesignSystem.Font.caption2 : DesignSystem.Font.caption)
                .fontWeight(.bold)
                .monospacedDigit()
                .contentTransition(.numericText())
        }
    }

    func progressRing(progress: CGFloat) -> some View {
        ZStack {
            Circle()
                .stroke(timerColor.opacity(0.2), lineWidth: 2)
            Circle()
                .trim(from: 0, to: progress)
                .stroke(timerColor, style: StrokeStyle(lineWidth: 2, lineCap: .round))
                .rotationEffect(.degrees(-90))
                .animation(.linear(duration: 1), value: progress)
        }
        .frame(width: 16, height: 16)
    }
}

// MARK: - Helpers
private extension QuizTimerBadge {
    var formattedTime: String {
        if seconds >= 60 {
            let minutes = seconds / 60
            let secs = seconds % 60
            return String(format: "%d:%02d", minutes, secs)
        }
        return "\(seconds)s"
    }

    var timerColor: Color {
        if seconds > 20 {
            DesignSystem.Color.success
        } else if seconds > 10 {
            DesignSystem.Color.warning
        } else {
            DesignSystem.Color.error
        }
    }

    var isUrgent: Bool {
        guard let totalSeconds else { return seconds <= 5 }
        return Double(seconds) <= Double(totalSeconds) * 0.25
    }
}
