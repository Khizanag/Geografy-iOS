import SwiftUI

public extension View {
    /// Puts a segmented picker of `tabs` in the navigation bar, for screens that switch between a few views,
    /// and gives the whole screen the app background.
    ///
    /// The picker takes the title's place, so the bar stays inline. A bar of its own under the navigation bar
    /// moved with every scroll and fought a large title collapsing, which made the bar shake.
    func segmentedTabs<Tab: Hashable & Identifiable>(
        _ title: LocalizedStringKey,
        selection: Binding<Tab>,
        tabs: [Tab],
        tabTitle: @escaping (Tab) -> LocalizedStringKey
    ) -> some View {
        toolbar {
            ToolbarItem(placement: .principal) {
                SegmentedTabPicker(title: title, selection: selection, tabs: tabs, tabTitle: tabTitle)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .screenBackground()
    }
}

// MARK: - Picker
private struct SegmentedTabPicker<Tab: Hashable & Identifiable>: View {
    let title: LocalizedStringKey
    @Binding var selection: Tab
    let tabs: [Tab]
    let tabTitle: (Tab) -> LocalizedStringKey

    var body: some View {
        Picker(title, selection: $selection) {
            ForEach(tabs) { tab in
                Text(tabTitle(tab)).tag(tab)
            }
        }
        .pickerStyle(.segmented)
    }
}

// MARK: - Content
/// The page for the selected tab of `segmentedTabs`, sliding in from the side of the tab it comes from,
/// the way a push does: right when moving to a tab further along, left when moving back.
public struct SegmentedTabContent<Tab: Hashable, Content: View>: View {
    // MARK: - Properties
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private let selection: Tab
    private let tabs: [Tab]
    @ViewBuilder private let content: (Tab) -> Content

    /// Trails `selection` by a moment, so the direction is set before the page changes:
    /// a page leaving reads its transition from the last time it was drawn.
    @State private var shownTab: Tab
    @State private var isForward = true

    // MARK: - Init
    public init(
        selection: Tab,
        tabs: [Tab],
        @ViewBuilder content: @escaping (Tab) -> Content
    ) {
        self.selection = selection
        self.tabs = tabs
        self.content = content
        _shownTab = State(initialValue: selection)
    }

    // MARK: - Body
    public var body: some View {
        ZStack {
            content(shownTab)
                .id(shownTab)
                .transition(transition)
        }
        .onChange(of: selection) { oldTab, newTab in
            isForward = position(of: newTab) > position(of: oldTab)
            Task { @MainActor in
                withAnimation(reduceMotion ? .easeInOut(duration: 0.2) : .smooth(duration: 0.4)) {
                    shownTab = newTab
                }
            }
        }
    }
}

// MARK: - Helpers
private extension SegmentedTabContent {
    var transition: AnyTransition {
        guard !reduceMotion else { return .opacity }
        return .push(from: isForward ? .trailing : .leading)
    }

    func position(of tab: Tab) -> Int {
        tabs.firstIndex(of: tab) ?? 0
    }
}
