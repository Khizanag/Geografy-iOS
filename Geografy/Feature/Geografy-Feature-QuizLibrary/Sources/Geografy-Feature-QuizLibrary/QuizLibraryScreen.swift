import Geografy_Core_DesignSystem
import Geografy_Core_Navigation
import SwiftUI

/// Themed quiz packs and the user's own quizzes in one place.
public struct QuizLibraryScreen: View {
    // MARK: - Properties
    @State private var tab: QuizLibraryTab

    // MARK: - Init
    public init(tab: QuizLibraryTab = .packs) {
        _tab = State(initialValue: tab)
    }

    // MARK: - Body
    public var body: some View {
        tabContent
            .segmentedTabs("Quiz Library", selection: $tab, tabs: Self.availableTabs) { $0.title }
            .navigationTitle("Quiz Library")
            #if !os(tvOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .closeButtonPlacementLeading()
    }
}

// MARK: - Subviews
private extension QuizLibraryScreen {
    // Building custom quizzes is iOS-only.
    #if os(tvOS)
    static let availableTabs: [QuizLibraryTab] = [.packs]
    #else
    static let availableTabs = QuizLibraryTab.allCases
    #endif

    @ViewBuilder
    var tabContent: some View {
        switch tab {
        case .packs: QuizPackBrowserScreen()
        case .custom:
            #if os(tvOS)
            QuizPackBrowserScreen()
            #else
            CustomQuizLibraryScreen()
            #endif
        }
    }
}
