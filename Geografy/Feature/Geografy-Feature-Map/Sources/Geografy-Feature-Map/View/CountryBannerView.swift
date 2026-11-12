import Geografy_Core_DesignSystem
import SwiftUI

public struct CountryBannerView: View {
    // MARK: - Properties
    /// Fixed so the banner keeps one width as the selected country changes; fits beside the toolbar buttons on the smallest landscape iPhone.
    public static let landscapeWidth: CGFloat = 460

    public let countryCode: String
    public let name: String
    public let flag: String
    public let capital: String
    public let namespace: Namespace.ID
    public let isFlagHidden: Bool
    public let onFlagTap: (() -> Void)?
    public let onMoreInfo: (() -> Void)?
    public let onDismiss: () -> Void
    public let isCompact: Bool

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
        isCompact: Bool = false,
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
        self.isCompact = isCompact
    }

    // MARK: - Body
    public var body: some View {
        bannerCard
            #if !os(tvOS)
            .offset(y: max(dragOffset, 0))
            .opacity(1 - Double(max(dragOffset, 0)) / 100)
            .gesture(swipeToDismiss)
            #endif
    }
}

// MARK: - Subviews
private extension CountryBannerView {
    var bannerCard: some View {
        HStack(spacing: DesignSystem.Spacing.sm) {
            flagButton

            infoSection

            Spacer(minLength: DesignSystem.Spacing.xxs)

            if let onMoreInfo {
                moreInfoButton(action: onMoreInfo)
            }
        }
        .padding(.leading, DesignSystem.Spacing.md)
        .padding(.trailing, Self.buttonInset)
        .frame(height: barHeight)
        .glassEffect(.regular, in: .capsule)
        .padding(.horizontal, isCompact ? 0 : Self.tabBarSideInset)
    }

    var flagButton: some View {
        Button { onFlagTap?() } label: {
            FlagView(countryCode: countryCode, height: flagHeight, fixedWidth: true)
                .matchedGeometryEffect(id: countryCode, in: namespace)
                .opacity(isFlagHidden ? 0 : 1)
        }
        .buttonStyle(.plain)
        .disabled(onFlagTap == nil)
    }

    var infoSection: some View {
        VStack(alignment: .leading, spacing: isCompact ? 0 : DesignSystem.Spacing.xxs / 2) {
            Text(name)
                .font(isCompact ? DesignSystem.Font.subheadline : DesignSystem.Font.headline)
                .fontWeight(.semibold)
                .foregroundStyle(DesignSystem.Color.textPrimary)
                .lineLimit(1)
                .minimumScaleFactor(0.7)

            if !capital.isEmpty {
                capitalLabel
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(capital.isEmpty ? name : "\(name), capital \(capital)")
    }

    var capitalLabel: some View {
        HStack(alignment: .center, spacing: DesignSystem.Spacing.xxs) {
            Image(systemName: "star.fill")
                .foregroundStyle(DesignSystem.Color.accent)
                .imageScale(.small)
                .accessibilityHidden(true)
            Text(capital)
                .foregroundStyle(DesignSystem.Color.textSecondary)
                .lineLimit(1)
        }
        .font(isCompact ? DesignSystem.Font.caption2 : DesignSystem.Font.caption)
    }

    func moreInfoButton(action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: DesignSystem.Spacing.xxs) {
                Text("More info")
                    .font(DesignSystem.Font.subheadline)
                    .fontWeight(.semibold)
                Image(systemName: "chevron.right")
                    .font(DesignSystem.Font.caption)
                    .fontWeight(.bold)
                    .accessibilityHidden(true)
            }
            .foregroundStyle(DesignSystem.Color.onAccent)
            .padding(.horizontal, DesignSystem.Spacing.md)
            .frame(height: barHeight - Self.buttonInset * 2)
            .background(DesignSystem.Color.accent, in: Capsule())
            .fixedSize()
        }
        .buttonStyle(PressButtonStyle())
    }
}

// MARK: - Metrics
private extension CountryBannerView {
    // The floating tab bar's side inset and height, so the banner reads as part of it.
    static let tabBarSideInset: CGFloat = 21
    static let buttonInset: CGFloat = DesignSystem.Spacing.xs

    var barHeight: CGFloat { isCompact ? DesignSystem.Size.xl : DesignSystem.Size.xxxl }
    var flagHeight: CGFloat { isCompact ? DesignSystem.Size.Icon.lg : DesignSystem.Size.md }
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
                if value.translation.height > 30 {
                    withAnimation(.easeOut(duration: 0.2)) {
                        dragOffset = 200
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
