import SwiftUI

struct QuizOptionButton: View {
    let text: String?
    let flagCode: String?
    let state: OptionState
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            content
                .frame(maxWidth: .infinity)
                .padding(DesignSystem.Spacing.md)
                .background(backgroundColor)
                .clipShape(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium))
        }
        .buttonStyle(.plain)
        .disabled(state == .disabled || state == .correct || state == .incorrect)
        .opacity(state == .disabled ? 0.4 : 1)
        .animation(.easeInOut, value: state)
    }
}

// MARK: - OptionState

extension QuizOptionButton {
    enum OptionState: Equatable {
        case `default`
        case correct
        case incorrect
        case disabled
    }
}

// MARK: - Subviews

private extension QuizOptionButton {
    @ViewBuilder
    var content: some View {
        HStack(spacing: DesignSystem.Spacing.sm) {
            if let flagCode {
                FlagView(countryCode: flagCode, height: DesignSystem.Size.md)
            }

            if let text {
                Text(text)
                    .font(DesignSystem.Font.headline)
                    .foregroundStyle(textColor)
                    .frame(maxWidth: .infinity, alignment: flagCode != nil ? .leading : .center)
            }

            stateIcon
        }
    }

    @ViewBuilder
    var stateIcon: some View {
        switch state {
        case .correct:
            Image(systemName: "checkmark.circle.fill")
                .font(DesignSystem.Font.title2)
                .foregroundStyle(DesignSystem.Color.textPrimary)
        case .incorrect:
            Image(systemName: "xmark.circle.fill")
                .font(DesignSystem.Font.title2)
                .foregroundStyle(DesignSystem.Color.textPrimary)
        default:
            EmptyView()
        }
    }
}

// MARK: - Helpers

private extension QuizOptionButton {
    var backgroundColor: Color {
        switch state {
        case .default, .disabled:
            DesignSystem.Color.cardBackground
        case .correct:
            DesignSystem.Color.success
        case .incorrect:
            DesignSystem.Color.error
        }
    }

    var textColor: Color {
        switch state {
        case .default, .disabled:
            DesignSystem.Color.textPrimary
        case .correct, .incorrect:
            DesignSystem.Color.textPrimary
        }
    }
}
