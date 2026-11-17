import SwiftUI

/// The picture a shared result carries: the game, the score, and its details on the brand gradient.
struct ResultShareCard: View {
    // MARK: - Properties
    static let width: CGFloat = 360

    let share: ResultShare

    // MARK: - Body
    var body: some View {
        VStack(spacing: DesignSystem.Spacing.lg) {
            header
            scoreBlock
            if !share.details.isEmpty {
                detailsRow
            }
            Text(share.date.formatted(date: .abbreviated, time: .omitted))
                .font(DesignSystem.Font.caption2)
                .foregroundStyle(DesignSystem.Color.onAccent.opacity(DesignSystem.Opacity.strong))
        }
        .padding(DesignSystem.Spacing.lg)
        .frame(width: Self.width)
        .background(gradient)
        .clipShape(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.large, style: .continuous))
    }
}

// MARK: - Subviews
private extension ResultShareCard {
    var header: some View {
        VStack(spacing: DesignSystem.Spacing.xs) {
            Label {
                Text(verbatim: "Geografy")
                    .fontWeight(.bold)
            } icon: {
                Image(systemName: "globe.americas.fill")
            }
            .font(DesignSystem.Font.headline)
            .foregroundStyle(DesignSystem.Color.onAccent)
            Text(share.game)
                .font(DesignSystem.Font.caption)
                .foregroundStyle(DesignSystem.Color.onAccent.opacity(DesignSystem.Opacity.heavy))
        }
    }

    var scoreBlock: some View {
        VStack(spacing: DesignSystem.Spacing.xs) {
            Text(share.score)
                .font(DesignSystem.Font.roundedHero)
                .foregroundStyle(DesignSystem.Color.onAccent)
                .lineLimit(1)
                .minimumScaleFactor(0.5)
            if let caption = share.caption {
                Text(caption)
                    .font(DesignSystem.Font.subheadline)
                    .foregroundStyle(DesignSystem.Color.onAccent.opacity(DesignSystem.Opacity.strong))
            }
        }
    }

    var detailsRow: some View {
        HStack(spacing: DesignSystem.Spacing.lg) {
            ForEach(share.details, id: \.self) { detail in
                Label(detail.text, systemImage: detail.systemImage)
                    .font(DesignSystem.Font.caption)
                    .fontWeight(.medium)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
                    .foregroundStyle(DesignSystem.Color.onAccent.opacity(DesignSystem.Opacity.heavy))
            }
        }
    }

    var gradient: some View {
        LinearGradient(
            colors: [DesignSystem.Color.accent, DesignSystem.Color.indigo],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}

// MARK: - Share Button
#if !os(tvOS)
/// Shares a result as its card image with the text alongside, or as text alone until the image is drawn.
struct ResultShareButton: View {
    // MARK: - Properties
    @Environment(\.displayScale) private var displayScale

    let share: ResultShare
    /// Spells out "Share Result" when it's the only action beside Done; otherwise just the icon.
    let showsTitle: Bool

    @State private var image: Image?

    // MARK: - Body
    var body: some View {
        Group {
            if let image {
                ShareLink(
                    item: image,
                    message: Text(share.text),
                    preview: SharePreview(share.game, image: image)
                ) { label }
            } else {
                ShareLink(item: share.text) { label }
            }
        }
        .buttonStyle(.glass)
        // ShareLink doesn't report what happens in the share sheet, so opening it counts as sharing.
        .simultaneousGesture(TapGesture().onEnded { share.onShare() })
        .task { render() }
    }
}

private extension ResultShareButton {
    @ViewBuilder
    var label: some View {
        if showsTitle {
            Label("Share Result", systemImage: "square.and.arrow.up")
                .font(DesignSystem.Font.headline)
                .foregroundStyle(DesignSystem.Color.textPrimary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, DesignSystem.Spacing.xxs)
        } else {
            Image(systemName: "square.and.arrow.up")
                .font(DesignSystem.Font.headline)
                .foregroundStyle(DesignSystem.Color.textPrimary)
                .padding(.vertical, DesignSystem.Spacing.xxs)
                .accessibilityLabel("Share Result")
        }
    }

    func render() {
        let renderer = ImageRenderer(content: ResultShareCard(share: share))
        renderer.scale = displayScale
        if let uiImage = renderer.uiImage {
            image = Image(uiImage: uiImage)
        }
    }
}
#endif
