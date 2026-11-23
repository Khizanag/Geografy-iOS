import SwiftUI

/// What a game is about and how it plays: the pages of its guide, in the game's own symbol and color.
public struct GameGuide: Sendable {
    // MARK: - Properties
    /// Names the game for remembering whether its guide has been shown, such as "mapPuzzle".
    public let id: String
    /// The game's name, shown as the guide's title.
    public let title: String
    public let systemImage: String
    public let color: Color
    public let pages: [GuidePage]

    // MARK: - Init
    public init(id: String, title: String, systemImage: String, color: Color, pages: [GuidePage]) {
        self.id = id
        self.title = title
        self.systemImage = systemImage
        self.color = color
        self.pages = pages
    }
}

// MARK: - Modifier
public extension View {
    /// Gives a game screen its guide: a Guide button in the toolbar, and the guide shown by itself the first time the
    /// game is opened, so a new player learns the rules before the first round.
    func gameGuide(_ guide: GameGuide) -> some View {
        gameGuide(id: guide.id) {
            GuideSheet(title: guide.title, pages: guide.pages, color: guide.color) { _ in
                IconBadge(guide.systemImage, color: guide.color, size: .hero)
                    .frame(height: 180)
                    .accessibilityHidden(true)
            }
        }
    }

    /// The same, for a game whose guide draws its own illustrations.
    func gameGuide(id: String, @ViewBuilder sheet: @escaping () -> some View) -> some View {
        modifier(GameGuideModifier(id: id, sheet: sheet))
    }
}

/// The Guide button, the sheet, and the first-time showing every game guide shares.
private struct GameGuideModifier<Sheet: View>: ViewModifier {
    // MARK: - Properties
    @AppStorage private var hasSeenGuide: Bool
    @State private var isPresented = false

    let sheet: () -> Sheet

    // MARK: - Init
    init(id: String, sheet: @escaping () -> Sheet) {
        _hasSeenGuide = AppStorage(wrappedValue: false, "gameGuide_seen_\(id)")
        self.sheet = sheet
    }

    // MARK: - Body
    func body(content: Content) -> some View {
        content
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button("Guide", systemImage: "questionmark.circle") { isPresented = true }
                }
            }
            .sheet(isPresented: $isPresented) { sheet() }
            .onAppear {
                guard !hasSeenGuide else { return }
                hasSeenGuide = true
                isPresented = true
            }
    }
}
