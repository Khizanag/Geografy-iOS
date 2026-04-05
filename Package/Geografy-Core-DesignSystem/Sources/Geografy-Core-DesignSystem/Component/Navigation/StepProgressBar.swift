import SwiftUI

public struct StepProgressBar: View {
    // MARK: - Properties
    public let steps: [String]
    public let currentStep: Int

    // MARK: - Init
    public init(steps: [String], currentStep: Int) {
        self.steps = steps
        self.currentStep = currentStep
    }

    // MARK: - Body
    public var body: some View {
        HStack(spacing: 0) {
            ForEach(Array(steps.enumerated()), id: \.offset) { index, title in
                stepView(index: index, title: title)

                if index < steps.count - 1 {
                    connector(after: index)
                }
            }
        }
        .padding(.horizontal, DesignSystem.Spacing.md)
        .padding(.vertical, DesignSystem.Spacing.sm)
        .animation(.easeInOut(duration: 0.3), value: currentStep)
    }
}

// MARK: - Subviews
private extension StepProgressBar {
    func stepView(index: Int, title: String) -> some View {
        let state = stepState(for: index)

        return VStack(spacing: DesignSystem.Spacing.xs) {
            ZStack {
                Circle()
                    .fill(state.backgroundColor)
                    .frame(width: 28, height: 28)

                if state == .completed {
                    Image(systemName: "checkmark")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(DesignSystem.Color.onAccent)
                } else {
                    Text("\(index + 1)")
                        .font(.system(size: 12, weight: .bold, design: .rounded))
                        .foregroundStyle(state.numberColor)
                }
            }

            Text(title)
                .font(DesignSystem.Font.caption2)
                .fontWeight(state == .active ? .semibold : .regular)
                .foregroundStyle(state.titleColor)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
        .frame(width: 70)
    }

    func connector(after index: Int) -> some View {
        let isCompleted = index < currentStep

        return Capsule()
            .fill(
                isCompleted
                    ? DesignSystem.Color.accent
                    : DesignSystem.Color.cardBackgroundHighlighted
            )
            .frame(height: 3)
            .frame(maxWidth: .infinity)
            .padding(.bottom, DesignSystem.Spacing.lg)
    }
}

// MARK: - Step State
private extension StepProgressBar {
    enum StepState {
        case completed
        case active
        case upcoming

        var backgroundColor: Color {
            switch self {
            case .completed: DesignSystem.Color.accent
            case .active: DesignSystem.Color.accent.opacity(0.2)
            case .upcoming: DesignSystem.Color.cardBackgroundHighlighted
            }
        }

        var numberColor: Color {
            switch self {
            case .completed: DesignSystem.Color.onAccent
            case .active: DesignSystem.Color.accent
            case .upcoming: DesignSystem.Color.textTertiary
            }
        }

        var titleColor: Color {
            switch self {
            case .completed: DesignSystem.Color.accent
            case .active: DesignSystem.Color.accent
            case .upcoming: DesignSystem.Color.textTertiary
            }
        }
    }

    func stepState(for index: Int) -> StepState {
        if index < currentStep {
            .completed
        } else if index == currentStep {
            .active
        } else {
            .upcoming
        }
    }
}
