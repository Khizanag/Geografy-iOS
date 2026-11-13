import Geografy_Core_Common
import Geografy_Core_DesignSystem
import SwiftUI

/// A card of tappable rows separated by inset dividers; the one list style Compare uses.
struct CompareRowList<Item: Identifiable, Row: View>: View {
    let items: [Item]
    let leadingWidth: CGFloat
    @ViewBuilder let row: (Item) -> Row

    var body: some View {
        CardView(cornerRadius: DesignSystem.CornerRadius.large) {
            VStack(spacing: 0) {
                ForEach(items) { item in
                    row(item)
                    if item.id != items.last?.id {
                        Divider()
                            .padding(.leading, CompareRowLayout.dividerInset(after: leadingWidth))
                    }
                }
            }
        }
    }
}

/// Two flags and "France vs Germany": a ready-made comparison.
struct CompareMatchupRow: View {
    let pair: ComparisonPair
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: DesignSystem.Spacing.sm) {
                HStack(spacing: DesignSystem.Spacing.xxs) {
                    FlagView(countryCode: pair.leftCode, height: CompareRowLayout.flagHeight, fixedWidth: true)
                    FlagView(countryCode: pair.rightCode, height: CompareRowLayout.flagHeight, fixedWidth: true)
                }
                .accessibilityHidden(true)

                Text("\(pair.leftName) vs \(pair.rightName)")
                    .font(DesignSystem.Font.body)
                    .foregroundStyle(DesignSystem.Color.textPrimary)
                    .multilineTextAlignment(.leading)

                Spacer(minLength: 0)
                RowChevron()
            }
            .compareRowPadding()
        }
        .buttonStyle(PressButtonStyle())
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(pair.leftName) versus \(pair.rightName)")
    }
}

/// A suggested opponent: flag, name and the reason it's a good match.
struct CompareSuggestionRow: View {
    let suggestion: CompareSuggestion
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: DesignSystem.Spacing.sm) {
                FlagView(countryCode: suggestion.country.code, height: CompareRowLayout.flagHeight, fixedWidth: true)
                    .accessibilityHidden(true)

                VStack(alignment: .leading, spacing: 2) {
                    Text(suggestion.country.name)
                        .font(DesignSystem.Font.body)
                        .foregroundStyle(DesignSystem.Color.textPrimary)
                    Text(suggestion.reason.title)
                        .font(DesignSystem.Font.caption)
                        .foregroundStyle(DesignSystem.Color.textSecondary)
                }

                Spacer(minLength: 0)
                RowChevron()
            }
            .compareRowPadding()
        }
        .buttonStyle(PressButtonStyle())
        .accessibilityElement(children: .combine)
    }
}

// MARK: - Layout
enum CompareRowLayout {
    static let flagHeight = DesignSystem.Size.Flag.inline
    /// Matches `FlagView`'s fixed-width slot.
    static let flagWidth = flagHeight * 1.6
    static let pairWidth = flagWidth * 2 + DesignSystem.Spacing.xxs

    /// Dividers start under the text, not under the flags.
    static func dividerInset(after leadingWidth: CGFloat) -> CGFloat {
        DesignSystem.Spacing.md + leadingWidth + DesignSystem.Spacing.sm
    }
}

private extension View {
    func compareRowPadding() -> some View {
        padding(.horizontal, DesignSystem.Spacing.md)
            .padding(.vertical, DesignSystem.Spacing.sm)
            .frame(minHeight: 44)
            .contentShape(Rectangle())
    }
}
