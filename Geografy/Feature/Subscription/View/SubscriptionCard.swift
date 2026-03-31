import SwiftUI
import StoreKit
import GeografyDesign

struct SubscriptionCard: View {
    let productID: String
    let fallbackPrice: String
    let period: String
    let badge: String?
    let savingsNote: String?
    let isSelected: Bool
    let product: Product?
    let onTap: () -> Void

    var body: some View {
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
                        isSelected ? DesignSystem.Color.accent : Color.white.opacity(0.10),
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
                .foregroundStyle(.white)
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
