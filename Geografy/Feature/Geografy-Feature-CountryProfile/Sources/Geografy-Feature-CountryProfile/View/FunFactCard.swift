import Geografy_Core_DesignSystem
import SwiftUI

public struct FunFactCard: View {
    // MARK: - Properties
    public let fact: CountryFunFact
    public let index: Int

    // MARK: - Body
    public var body: some View {
        CardView {
            HStack(alignment: .top, spacing: DesignSystem.Spacing.sm) {
                emojiCircle
                factText
            }
            .padding(DesignSystem.Spacing.md)
        }
    }
}

// MARK: - Subviews
private extension FunFactCard {
    var emojiCircle: some View {
        Text(fact.emoji)
            .font(DesignSystem.Font.iconMedium)
            .frame(
                width: DesignSystem.Size.lg,
                height: DesignSystem.Size.lg
            )
            .background(DesignSystem.Color.accent.opacity(0.1))
            .clipShape(Circle())
    }

    var factText: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.xxs) {
            Text("Fact #\(index + 1)")
                .font(DesignSystem.Font.caption)
                .foregroundStyle(DesignSystem.Color.accent)
            Text(fact.text)
                .font(DesignSystem.Font.subheadline)
                .foregroundStyle(DesignSystem.Color.textPrimary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}
