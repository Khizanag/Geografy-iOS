import Geografy_Core_DesignSystem
import SwiftUI

public struct CountryBannerView: View {
    // MARK: - Properties
    public let countryCode: String
    public let name: String
    public let flag: String
    public let capital: String
    public let namespace: Namespace.ID
    public let isFlagHidden: Bool
    public let onFlagTap: (() -> Void)?
    public let onMoreInfo: (() -> Void)?
    public let onDismiss: () -> Void

    @State private var dragOffset: CGFloat = 0

    // MARK: - Init
    public init(
        countryCode: String,
        name: String,
        flag: String,
        capital: String,
        namespace: Namespace.ID,
        isFlagHidden: Bool,
        onFlagTap: (() -> Void)?,
        onMoreInfo: (() -> Void)?,
        onDismiss: @escaping () -> Void
    ) {
        self.countryCode = countryCode
        self.name = name
        self.flag = flag
        self.capital = capital
        self.namespace = namespace
        self.isFlagHidden = isFlagHidden
        self.onFlagTap = onFlagTap
        self.onMoreInfo = onMoreInfo
        self.onDismiss = onDismiss
    }

    // MARK: - Body
    public var body: some View {
        bannerCard
            #if !os(tvOS)
            .offset(y: min(dragOffset, 0))
            .opacity(1 + Double(min(dragOffset, 0)) / 100)
            .gesture(swipeToDismiss)
            #endif
    }
}

// MARK: - Subviews
private extension CountryBannerView {
    var bannerCard: some View {
        HStack(spacing: DesignSystem.Spacing.xs) {
            flagButton

            infoSection

            Spacer(minLength: DesignSystem.Spacing.xxs)

            if let onMoreInfo {
                moreInfoButton(action: onMoreInfo)
            }
        }
        .padding(.horizontal, DesignSystem.Spacing.sm)
        .padding(.vertical, DesignSystem.Spacing.xs)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.large))
        .padding(.horizontal, DesignSystem.Spacing.md)
    }

    var flagButton: some View {
        Button { onFlagTap?() } label: {
            FlagView(countryCode: countryCode, height: DesignSystem.Size.xl)
                .matchedGeometryEffect(id: countryCode, in: namespace)
                .opacity(isFlagHidden ? 0 : 1)
        }
        .buttonStyle(.plain)
        .disabled(onFlagTap == nil)
    }

    var infoSection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.xxs) {
            Text(name)
                .font(DesignSystem.Font.headline)
                .foregroundStyle(DesignSystem.Color.textPrimary)
                .lineLimit(2)
                .minimumScaleFactor(0.8)

            capitalLabel
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(name), capital \(capital)")
    }

    var capitalLabel: some View {
        HStack(alignment: .top, spacing: DesignSystem.Spacing.xxs) {
            Image(systemName: "star.fill")
                .font(DesignSystem.Font.caption2)
                .foregroundStyle(DesignSystem.Color.accent)
                .padding(.top, 2)
                .accessibilityHidden(true)

            Text(capital)
                .font(DesignSystem.Font.caption)
                .foregroundStyle(DesignSystem.Color.textSecondary)
        }
    }

    func moreInfoButton(action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: DesignSystem.Spacing.xxs) {
                Text("More info")
                    .font(DesignSystem.Font.caption)
                Image(systemName: "chevron.right")
                    .font(DesignSystem.Font.caption2)
            }
            .foregroundStyle(DesignSystem.Color.textPrimary)
            .padding(.horizontal, DesignSystem.Spacing.sm)
            .padding(.vertical, DesignSystem.Spacing.xs)
            .fixedSize()
        }
        .buttonStyle(.glass)
    }
}

// MARK: - Gestures
#if !os(tvOS)
private extension CountryBannerView {
    var swipeToDismiss: some Gesture {
        DragGesture(minimumDistance: 10)
            .onChanged { value in
                dragOffset = value.translation.height
            }
            .onEnded { value in
                if value.translation.height < -30 {
                    withAnimation(.easeOut(duration: 0.2)) {
                        dragOffset = -200
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                        onDismiss()
                    }
                } else {
                    withAnimation(.spring(response: 0.3)) {
                        dragOffset = 0
                    }
                }
            }
    }
}
#endif
