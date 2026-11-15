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
