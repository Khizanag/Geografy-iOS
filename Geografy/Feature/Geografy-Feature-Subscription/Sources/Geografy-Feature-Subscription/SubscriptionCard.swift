import Geografy_Core_DesignSystem
import StoreKit
import SwiftUI

public struct SubscriptionCard: View {
    // MARK: - Properties
    public let productID: String
    public let fallbackPrice: String
    public let period: String
    public let badge: String?
    public let savingsNote: String?
    public let isSelected: Bool
    public let product: Product?
    public let onTap: () -> Void

    // MARK: - Body
    public var body: some View {
        Button(action: onTap) {
            cardContent
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Subviews
private extension SubscriptionCard {
    var cardContent: some View {
        ZStack(alignment: .top) {
            cardBackground
            VStack(spacing: DesignSystem.Spacing.xs) {
                if badge != nil {
                    badgeRow
                        .padding(.top, DesignSystem.Spacing.md)
                } else {
                    Color.clear.frame(height: DesignSystem.Spacing.md)
                }
                Spacer()
                priceLabel
                periodLabel
                if let note = savingsNote {
                    Text(note)
                        .font(DesignSystem.Font.caption2)
                        .foregroundStyle(DesignSystem.Color.success)
                        .multilineTextAlignment(.center)
                }
                Spacer()
            }
            .padding(.horizontal, DesignSystem.Spacing.xs)
        }
        .frame(height: 148)
        .scaleEffect(isSelected ? 1.04 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
    }

    var cardBackground: some View {
        RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.large)
            .fill(.ultraThinMaterial)
            .overlay {
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.large)
                    .strokeBorder(
                        isSelected ? DesignSystem.Color.accent : DesignSystem.Color.dividerSubtle,
                        lineWidth: isSelected ? 2 : 1
                    )
            }
            .shadow(
                color: isSelected ? DesignSystem.Color.accent.opacity(0.35) : .clear,
                radius: 14, y: 5
            )
    }

    @ViewBuilder
    var badgeRow: some View {
        if let badge {
            Text(badge)
                .font(DesignSystem.Font.micro.bold())
                .foregroundStyle(DesignSystem.Color.onAccent)
                .padding(.horizontal, DesignSystem.Spacing.xs)
                .padding(.vertical, 3)
                .background(badgeColor, in: Capsule())
        }
    }

    var priceLabel: some View {
        Text(product?.displayPrice ?? fallbackPrice)
            .font(DesignSystem.Font.title3.bold())
            .foregroundStyle(DesignSystem.Color.textPrimary)
    }

    var periodLabel: some View {
        Text(period)
            .font(DesignSystem.Font.caption)
            .foregroundStyle(DesignSystem.Color.textSecondary)
            .multilineTextAlignment(.center)
    }

    var badgeColor: Color {
        switch badge {
        case "Best Value": DesignSystem.Color.accent
        case "Pay Once":   DesignSystem.Color.indigo
        default:           DesignSystem.Color.textSecondary
        }
    }
}
