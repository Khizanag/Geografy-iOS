import SwiftUI

struct CountryBannerView: View {
    let countryCode: String
    let name: String
    let flag: String
    let capital: String
    let onFlagTap: (() -> Void)?
    let onMoreInfo: (() -> Void)?
    let onDismiss: () -> Void

    @State private var dragOffset: CGFloat = 0

    var body: some View {
        HStack(spacing: DesignSystem.Spacing.sm) {
            flagView
            infoSection
            Spacer()
            if let onMoreInfo {
                moreInfoButton(action: onMoreInfo)
            }
            closeButton
        }
        .padding(.horizontal, DesignSystem.Spacing.sm)
        .padding(.vertical, DesignSystem.Spacing.xs)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.large))
        .padding(.horizontal, DesignSystem.Spacing.md)
        .offset(y: min(dragOffset, 0))
        .opacity(1 + Double(min(dragOffset, 0)) / 100)
        .gesture(swipeToDismiss)
    }
}

// MARK: - Subviews

private extension CountryBannerView {
    var flagView: some View {
        Button { onFlagTap?() } label: {
            FlagView(countryCode: countryCode, height: DesignSystem.Size.md)
        }
        .buttonStyle(.plain)
        .disabled(onFlagTap == nil)
    }

    var infoSection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.xxs) {
            Text(name)
                .font(DesignSystem.Font.headline)
                .foregroundStyle(DesignSystem.Color.textPrimary)

            HStack(spacing: DesignSystem.Spacing.xxs) {
                Image(systemName: "star.fill")
                    .font(DesignSystem.Font.caption2)
                    .foregroundStyle(DesignSystem.Color.accent)

                Text(capital)
                    .font(DesignSystem.Font.caption)
                    .foregroundStyle(DesignSystem.Color.textSecondary)
            }
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
        }
        .buttonStyle(.glass)
    }

    var closeButton: some View {
        Button(action: onDismiss) {
            Image(systemName: "xmark")
                .font(DesignSystem.Font.caption)
                .fontWeight(.semibold)
                .foregroundStyle(DesignSystem.Color.iconPrimary)
                .padding(DesignSystem.Spacing.xs)
        }
        .glassEffect(.regular.interactive(), in: .circle)
    }
}

// MARK: - Gestures

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
