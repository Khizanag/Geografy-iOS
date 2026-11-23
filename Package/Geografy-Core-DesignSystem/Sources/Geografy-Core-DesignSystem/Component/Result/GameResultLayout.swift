import SwiftUI

/// The end of any game, laid out the same way: the game's own hero, a title and a line, the XP earned, a row of
/// stats, the game's details, and Done beside the main action at the bottom. It draws no background, so a screen
/// sets one, or a panel over a map puts it on glass.
public struct GameResultLayout<Hero: View, Stats: View, Details: View>: View {
    // MARK: - Properties
    @Environment(SoundService.self) private var soundService

    private let title: Text
    private let message: Text?
    private let xpEarned: Int
    private let primaryAction: GameResultAction?
    private let share: ResultShare?
    private let sound: SoundEffect
    private let onDone: () -> Void
    private let hero: Hero
    private let stats: Stats
    private let details: Details

    // MARK: - Init
    /// - Parameters:
    ///   - xpEarned: Shown as a badge when above zero.
    ///   - primaryAction: Beside Done, nearest the thumb; usually ``GameResultAction/playAgain(_:)``.
    ///   - share: Adds a share button before Done, which takes the main place when there's no `primaryAction`.
    ///   - sound: Plays when the result appears.
    public init(
        title: Text,
        message: Text? = nil,
        xpEarned: Int = 0,
        primaryAction: GameResultAction?,
        share: ResultShare? = nil,
        sound: SoundEffect = .complete,
        onDone: @escaping () -> Void,
        @ViewBuilder hero: () -> Hero,
        @ViewBuilder stats: () -> Stats,
        @ViewBuilder details: () -> Details
    ) {
        self.title = title
        self.message = message
        self.xpEarned = xpEarned
        self.primaryAction = primaryAction
        self.share = share
        self.sound = sound
        self.onDone = onDone
        self.hero = hero()
        self.stats = stats()
        self.details = details()
    }

    // MARK: - Body
    public var body: some View {
        ScrollView {
            VStack(spacing: DesignSystem.Spacing.lg) {
                hero
                heading
                if xpEarned > 0 {
                    XPBadge(xp: xpEarned)
                }
                StatTileRow { stats }
                details
            }
            .padding(.horizontal, DesignSystem.Spacing.md)
            .padding(.vertical, DesignSystem.Spacing.lg)
            .readableContentWidth()
        }
        .scrollBounceBehavior(.basedOnSize)
        .bottomActionBar { buttons }
        .onAppear { soundService.play(sound) }
    }
}

public extension GameResultLayout where Details == EmptyView {
    init(
        title: Text,
        message: Text? = nil,
        xpEarned: Int = 0,
        primaryAction: GameResultAction?,
        share: ResultShare? = nil,
        sound: SoundEffect = .complete,
        onDone: @escaping () -> Void,
        @ViewBuilder hero: () -> Hero,
        @ViewBuilder stats: () -> Stats
    ) {
        self.init(
            title: title,
            message: message,
            xpEarned: xpEarned,
            primaryAction: primaryAction,
            share: share,
            sound: sound,
            onDone: onDone,
            hero: hero,
            stats: stats,
            details: { EmptyView() }
        )
    }
}

// MARK: - Subviews
private extension GameResultLayout {
    var heading: some View {
        VStack(spacing: DesignSystem.Spacing.xs) {
            title
                .font(DesignSystem.Font.title2)
                .fontWeight(.bold)
                .foregroundStyle(DesignSystem.Color.textPrimary)
                .accessibilityAddTraits(.isHeader)
            if let message {
                message
                    .font(DesignSystem.Font.subheadline)
                    .foregroundStyle(DesignSystem.Color.textSecondary)
            }
        }
        .multilineTextAlignment(.center)
    }

    var buttons: some View {
        ButtonRow {
            #if !os(tvOS)
            if let share, primaryAction != nil {
                ResultShareButton(share: share, showsTitle: false)
            }
            #endif
            GlassButton("Done", systemImage: "checkmark", role: .secondary, fullWidth: true, action: onDone)
            #if !os(tvOS)
            if let share, primaryAction == nil {
                ResultShareButton(share: share, showsTitle: true)
            }
            #endif
            if let primaryAction {
                GlassButton(
                    primaryAction.title,
                    systemImage: primaryAction.systemImage,
                    fullWidth: true,
                    action: primaryAction.action
                )
            }
        }
    }
}

// MARK: - Action
/// The main button under a result, beside Done.
public struct GameResultAction {
    let title: LocalizedStringKey
    let systemImage: String
    let action: () -> Void

    public init(_ title: LocalizedStringKey, systemImage: String, action: @escaping () -> Void) {
        self.title = title
        self.systemImage = systemImage
        self.action = action
    }

    public static func playAgain(_ action: @escaping () -> Void) -> Self {
        Self("Play Again", systemImage: "arrow.counterclockwise", action: action)
    }
}
