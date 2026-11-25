import SwiftUI

/// The top of a game's setup screen: the game's icon in its own color, its name, one line on how to play,
/// and a few facts as pills. Compact, so the choices below stay above the fold.
public struct GameIntroHeader: View {
    // MARK: - Fact
    public struct Fact: Identifiable {
        public let title: String
        public let systemImage: String
        /// The setup section that changes this fact; tapping the fact scrolls there.
        public let section: AnyHashable?

        public var id: String { title }

        public init(_ title: String, systemImage: String) {
            self.title = title
            self.systemImage = systemImage
            self.section = nil
        }

        /// A fact the player can change: it's a button that scrolls to `section`, a view given the same `.id`
        /// inside a scroll view that has `.sectionScrolling()`.
        public init(_ title: String, systemImage: String, showing section: some Hashable) {
            self.title = title
            self.systemImage = systemImage
            self.section = AnyHashable(section)
        }
    }

    // MARK: - Properties
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @Environment(\.showSection) private var showSection
    @ScaledMetric(relativeTo: .title2) private var iconSize: CGFloat = 56

    private let title: Text
    private let subtitle: Text
    private let systemImage: String
    private let color: Color
    private let facts: [Fact]

    // MARK: - Init
    /// - Parameter color: The game's own color, as on its hub tile, so each game is recognizable.
    public init(
        title: LocalizedStringKey,
        subtitle: LocalizedStringKey,
        systemImage: String,
        color: Color,
        facts: [Fact] = []
    ) {
        self.title = Text(title)
        self.subtitle = Text(subtitle)
        self.systemImage = systemImage
        self.color = color
        self.facts = facts
    }

    /// A title and subtitle already in the reader's language, such as a pack's name and description from data.
    @_disfavoredOverload
    public init(
        title: some StringProtocol,
        subtitle: some StringProtocol,
        systemImage: String,
        color: Color,
        facts: [Fact] = []
    ) {
        self.title = Text(title)
        self.subtitle = Text(subtitle)
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
                        factPill(fact)
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

// MARK: - Subviews
private extension GameIntroHeader {
    @ViewBuilder
    func factPill(_ fact: Fact) -> some View {
        if let section = fact.section, let showSection {
            Button {
                showSection(section)
            } label: {
                InfoPill(
                    fact.title,
                    systemImage: fact.systemImage,
                    style: .tinted(color),
                    trailingSystemImage: "chevron.down"
                )
                .contentShape(.capsule)
            }
            .buttonStyle(.plain)
            .accessibilityHint("Shows this setting")
        } else {
            InfoPill(fact.title, systemImage: fact.systemImage, style: .tinted(color))
        }
    }

    var iconTile: some View {
        Image(systemName: systemImage)
            .font(DesignSystem.Font.title2)
            .fontWeight(.semibold)
            .foregroundStyle(color)
            .frame(width: iconSize, height: iconSize)
            .background(
                color.opacity(DesignSystem.Opacity.tint),
                in: RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.large, style: .continuous)
            )
            .accessibilityHidden(true)
    }

    var titleBlock: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.xxs) {
            title
                .font(DesignSystem.Font.title2)
                .fontWeight(.bold)
                .foregroundStyle(DesignSystem.Color.textPrimary)
                .accessibilityAddTraits(.isHeader)
            subtitle
                .font(DesignSystem.Font.subheadline)
                .foregroundStyle(DesignSystem.Color.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

// MARK: - Scrolling to a Section
public extension EnvironmentValues {
    /// Scrolls the screen to the section with the given id; set by `sectionScrolling()`.
    @Entry var showSection: ((AnyHashable) -> Void)?
}

public extension View {
    /// Lets what names a section inside this scroll view scroll to it: a `GameIntroHeader`'s facts, or a
    /// `StatTile` that counts what a section lists.
    func sectionScrolling() -> some View {
        modifier(SectionScrolling())
    }
}

private struct SectionScrolling: ViewModifier {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    func body(content: Content) -> some View {
        ScrollViewReader { proxy in
            content
                .environment(\.showSection) { section in
                    withAnimation(reduceMotion ? nil : .smooth) {
                        proxy.scrollTo(section, anchor: .top)
                    }
                }
        }
    }
}
