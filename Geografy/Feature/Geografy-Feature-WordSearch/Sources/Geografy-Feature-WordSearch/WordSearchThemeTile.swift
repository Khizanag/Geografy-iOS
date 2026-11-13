import Geografy_Core_Common
import Geografy_Core_DesignSystem
import SwiftUI

/// A theme choice on the setup screen: its icon, name, and a few of the words the puzzle will hide.
struct WordSearchThemeTile: View {
    // MARK: - Properties
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.colorSchemeContrast) private var contrast
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    let theme: WordSearchTheme
    let isSelected: Bool
    let action: () -> Void

    private let color = DesignSystem.Color.indigo

    // MARK: - Body
    var body: some View {
        Button(action: action) {
            content
        }
        .buttonStyle(PressButtonStyle())
        .animation(reduceMotion ? nil : .snappy(duration: 0.25), value: isSelected)
        .accessibilityLabel(theme.rawValue)
        .accessibilityValue(accessibilityValue)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}

// MARK: - Subviews
private extension WordSearchThemeTile {
    var content: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
            HStack(alignment: .top) {
                IconBadge(theme.icon, color: color, size: .small)
                Spacer(minLength: DesignSystem.Spacing.xs)
                checkmark
            }
            Text(theme.rawValue)
                .font(DesignSystem.Font.subheadline)
                .fontWeight(.semibold)
                .foregroundStyle(DesignSystem.Color.textPrimary)
                .fixedSize(horizontal: false, vertical: true)
            Text(summary.sampleWords.joined(separator: " · "))
                .font(DesignSystem.Font.caption)
                .foregroundStyle(DesignSystem.Color.textSecondary)
                .lineLimit(dynamicTypeSize.isAccessibilitySize ? nil : 2)
                .fixedSize(horizontal: false, vertical: true)
            Spacer(minLength: 0)
            Text("\(summary.wordCount) words")
                .font(DesignSystem.Font.caption2)
                .foregroundStyle(DesignSystem.Color.textTertiary)
        }
        .padding(DesignSystem.Spacing.sm)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background { background }
        .overlay { border }
        .contentShape(shape)
    }

    @ViewBuilder
    var checkmark: some View {
        if isSelected {
            Image(systemName: "checkmark.circle.fill")
                .font(DesignSystem.Font.title3)
                .foregroundStyle(color)
                .transition(reduceMotion ? .opacity : .scale.combined(with: .opacity))
                .accessibilityHidden(true)
        }
    }

    // The tint sits on the opaque card fill, so the tile stays solid under Reduce Transparency.
    var background: some View {
        shape
            .fill(DesignSystem.Color.cardBackground)
            .overlay {
                if isSelected {
                    shape.fill(color.opacity(0.12))
                }
            }
    }

    @ViewBuilder
    var border: some View {
        if isSelected {
            shape.strokeBorder(color, lineWidth: 2)
        } else if contrast == .increased {
            shape.strokeBorder(DesignSystem.Color.dividerSubtle, lineWidth: 1)
        }
    }
}

// MARK: - Helpers
private extension WordSearchThemeTile {
    var shape: RoundedRectangle {
        RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.large, style: .continuous)
    }

    var summary: WordSearchThemeSummary {
        WordSearchThemeSummary(theme: theme)
    }

    var accessibilityValue: String {
        let samples = summary.sampleWords.formatted(.list(type: .and))
        return String(localized: "\(summary.wordCount) words, such as \(samples)", bundle: .module)
    }
}
