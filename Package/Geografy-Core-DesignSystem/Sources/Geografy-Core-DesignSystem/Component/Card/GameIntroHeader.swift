import SwiftUI

/// The top of a game's setup screen: the game's icon in its own color, its name, one line on how to play,
/// and a few facts as pills. Compact, so the choices below stay above the fold.
public struct GameIntroHeader: View {
    // MARK: - Fact
    public struct Fact: Identifiable {
        public let title: String
        public let systemImage: String

        public var id: String { title }

        public init(_ title: String, systemImage: String) {
            self.title = title
            self.systemImage = systemImage
        }
    }

    // MARK: - Properties
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @ScaledMetric(relativeTo: .title2) private var iconSize: CGFloat = 56

    private let title: String
    private let subtitle: String
    private let systemImage: String
    private let color: Color
    private let facts: [Fact]

    // MARK: - Init
    /// - Parameter color: The game's own color, as on its hub tile, so each game is recognizable.
    public init(
        title: String,
        subtitle: String,
        systemImage: String,
        color: Color,
        facts: [Fact] = []
    ) {
        self.title = title
        self.subtitle = subtitle
        self.systemImage = systemImage
        self.color = color
        self.facts = facts
    }

    // MARK: - Body
    public var body: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            let layout = dynamicTypeSize.isAccessibilitySize
                ? AnyLayout(VStackLayout(alignment: .leading, spacing: DesignSystem.Spacing.sm))
                : AnyLayout(HStackLayout(alignment: .center, spacing: DesignSystem.Spacing.md))
            layout {
                iconTile
                titleBlock
            }
            if !facts.isEmpty {
                FlowLayout(spacing: DesignSystem.Spacing.xs) {
                    ForEach(facts) { fact in
                        InfoPill(fact.title, systemImage: fact.systemImage, style: .tinted(color))
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

// MARK: - Subviews
private extension GameIntroHeader {
    var iconTile: some View {
        Image(systemName: systemImage)
            .font(DesignSystem.Font.title2)
            .fontWeight(.semibold)
            .foregroundStyle(color)
            .frame(width: iconSize, height: iconSize)
            .background(
                color.opacity(0.15),
                in: RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.large, style: .continuous)
            )
            .accessibilityHidden(true)
    }

    var titleBlock: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.xxs) {
            Text(title)
                .font(DesignSystem.Font.title2)
                .fontWeight(.bold)
                .foregroundStyle(DesignSystem.Color.textPrimary)
                .accessibilityAddTraits(.isHeader)
            Text(subtitle)
                .font(DesignSystem.Font.subheadline)
                .foregroundStyle(DesignSystem.Color.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}
