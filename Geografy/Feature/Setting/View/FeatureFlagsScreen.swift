#if !os(tvOS)
import SwiftUI
import GeografyDesign

struct FeatureFlagsScreen: View {
    @Environment(FeatureFlagService.self) private var featureFlags
    @State private var searchText = ""

    var body: some View {
        listContent
            .searchable(text: $searchText, prompt: "Search features...")
            .navigationTitle("Feature Flags")
            .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Subviews
private extension FeatureFlagsScreen {
    var listContent: some View {
        List {
            ForEach(FeatureFlag.Category.allCases, id: \.rawValue) { category in
                let flags = filteredFlags(for: category)
                if !flags.isEmpty {
                    Section(category.rawValue) {
                        ForEach(flags) { flag in
                            flagRow(flag)
                        }
                    }
                }
            }

            Section {
                Button("Reset All to Default", role: .destructive) {
                    featureFlags.reset()
                }
            }
        }
    }

    func flagRow(_ flag: FeatureFlag) -> some View {
        Toggle(isOn: Binding(
            get: { featureFlags.isEnabled(flag) },
            set: { featureFlags.setEnabled(flag, enabled: $0) }
        )) {
            Label(flag.displayName, systemImage: flag.icon)
        }
    }

    func filteredFlags(for category: FeatureFlag.Category) -> [FeatureFlag] {
        let categoryFlags = FeatureFlag.allCases.filter { $0.category == category }
        guard !searchText.isEmpty else { return categoryFlags }
        let query = searchText.lowercased()
        return categoryFlags.filter { $0.displayName.lowercased().contains(query) }
    }
}
#endif
