import SwiftUI

/// Premium-gated section preview. Wraps the real content behind a blur and
/// places a floating "Unlock with Premium" pill over the top. The blur gives
/// users a taste of what's behind the gate — so they understand what they're
/// paying for — instead of the old grey rectangle.
///
/// Usage:
/// ```swift
/// LockedSectionPeek(
///     title: "Religion breakdown",
///     price: subscription.monthlyPriceDisplay,
///     onUnlock: { showPaywall = true }
/// ) {
///     ReligionChartView(data: country.religions)
/// }
/// ```
public struct LockedSectionPeek<Content: View>: View {
    private let title: String
    private let subtitle: String?
    private let price: String?
    private let onUnlock: () -> Void
    private let content: Content

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency

    public init(
        title: String,
        subtitle: String? = nil,
        price: String? = nil,
        onUnlock: @escaping () -> Void,
        @ViewBuilder content: () -> Content
    ) {
        self.title = title
        self.subtitle = subtitle
        self.price = price
        self.onUnlock = onUnlock
        self.content = content()
    }

    public var body: some View {
        ZStack {
            blurredContent
            overlay
        }
        .clipShape(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.large, style: .continuous))
    }
}

// MARK: - Subviews
private extension LockedSectionPeek {
    var blurredContent: some View {
        content
            .allowsHitTesting(false)
            .blur(radius: blurRadius)
            .overlay(dimmer)
    }

    var overlay: some View {
        VStack(spacing: DesignSystem.Spacing.sm) {
            lockCircle
            titleBlock
            unlockButton
        }
        .padding(DesignSystem.Spacing.md)
    }

    var lockCircle: some View {
        Image(systemName: "lock.fill")
            .font(DesignSystem.Font.iconLarge)
            .foregroundStyle(DesignSystem.Color.onAccent)
            .padding(DesignSystem.Spacing.sm)
            .background(Circle().fill(DesignSystem.Color.accent))
    }

    @ViewBuilder
    var titleBlock: some View {
        VStack(spacing: 4) {
            Text(title)
                .font(DesignSystem.Font.headline)
                .foregroundStyle(DesignSystem.Color.textPrimary)
            if let subtitle {
                Text(subtitle)
                    .font(DesignSystem.Font.caption)
                    .foregroundStyle(DesignSystem.Color.textSecondary)
                    .multilineTextAlignment(.center)
            }
        }
    }

    var unlockButton: some View {
        Button(action: onUnlock) {
            HStack(spacing: 6) {
                Text(buttonLabel)
                    .font(DesignSystem.Font.callout.weight(.semibold))
                Image(systemName: "chevron.right")
                    .font(DesignSystem.Font.caption)
            }
            .padding(.horizontal, DesignSystem.Spacing.md)
            .padding(.vertical, DesignSystem.Spacing.sm)
            .background(Capsule(style: .continuous).fill(DesignSystem.Color.accent))
            .foregroundStyle(DesignSystem.Color.onAccent)
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Unlock \(title)")
    }

    @ViewBuilder
    var dimmer: some View {
        if reduceTransparency {
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.large, style: .continuous)
                .fill(DesignSystem.Color.cardBackground)
        } else {
            LinearGradient(
                colors: [
                    DesignSystem.Color.background.opacity(0.6),
                    DesignSystem.Color.background.opacity(0.9),
                ],
                startPoint: .top,
                endPoint: .bottom
            )
        }
    }
}

// MARK: - Helpers
private extension LockedSectionPeek {
    var blurRadius: CGFloat {
        reduceTransparency ? 0 : 12
    }

    var buttonLabel: String {
        if let price { "Unlock — \(price)" } else { "Unlock with Premium" }
    }
}
