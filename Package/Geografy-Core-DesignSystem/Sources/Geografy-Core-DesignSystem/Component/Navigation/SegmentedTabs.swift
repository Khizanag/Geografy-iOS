import SwiftUI

public extension View {
    /// Puts a segmented picker of `tabs` above this content, for screens that switch between a few views,
    /// and gives the whole screen the app background.
    func segmentedTabs<Tab: Hashable & Identifiable>(
        _ title: String,
        selection: Binding<Tab>,
        tabs: [Tab],
        tabTitle: @escaping (Tab) -> String
    ) -> some View {
        safeAreaInset(edge: .top) {
            SegmentedTabPicker(title: title, selection: selection, tabs: tabs, tabTitle: tabTitle)
        }
        .screenBackground()
    }
}

// MARK: - Picker
private struct SegmentedTabPicker<Tab: Hashable & Identifiable>: View {
    let title: String
    @Binding var selection: Tab
    let tabs: [Tab]
    let tabTitle: (Tab) -> String

    var body: some View {
        Picker(title, selection: $selection) {
            ForEach(tabs) { tab in
                Text(tabTitle(tab)).tag(tab)
            }
        }
        .pickerStyle(.segmented)
        .padding(.horizontal, DesignSystem.Spacing.md)
        .padding(.vertical, DesignSystem.Spacing.xs)
    }
}
