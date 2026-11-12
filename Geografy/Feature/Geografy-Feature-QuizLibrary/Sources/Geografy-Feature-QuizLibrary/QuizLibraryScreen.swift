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
            .safeAreaInset(edge: .top) { tabPicker }
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

    var tabPicker: some View {
        Picker("Quiz Library", selection: $tab) {
            ForEach(Self.availableTabs) { tab in
                Text(tab.title).tag(tab)
            }
        }
        .pickerStyle(.segmented)
        .padding(.horizontal, DesignSystem.Spacing.md)
        .padding(.vertical, DesignSystem.Spacing.xs)
    }

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
