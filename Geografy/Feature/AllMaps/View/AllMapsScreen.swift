import SwiftUI

struct AllMapsScreen: View {
    @State private var showMap = false

    private let maps: [(name: String, icon: String)] = [
        ("World", "globe"),
        ("Europe", "globe.europe.africa"),
        ("Asia", "globe.asia.australia"),
        ("Africa", "globe.europe.africa"),
        ("North America", "globe.americas"),
        ("South America", "globe.americas"),
        ("Oceania", "globe.asia.australia"),
    ]

    var body: some View {
        ScrollView {
            mapGrid
        }
        .background(DesignSystem.Color.background)
        .navigationTitle("All Maps")
        .fullScreenCover(isPresented: $showMap) {
            NavigationStack {
                MapScreen()
                    .navigationDestination(for: Country.self) { country in
                        CountryDetailScreen(country: country)
                    }
            }
        }
    }
}

// MARK: - Subviews

private extension AllMapsScreen {
    var mapGrid: some View {
        LazyVGrid(
            columns: [GridItem(.adaptive(minimum: 140), spacing: DesignSystem.Spacing.md)],
            spacing: DesignSystem.Spacing.md
        ) {
            ForEach(Array(maps.enumerated()), id: \.offset) { _, map in
                Button { showMap = true } label: {
                    mapCard(name: map.name, icon: map.icon)
                }
                .buttonStyle(.glass)
            }
        }
        .padding(DesignSystem.Spacing.md)
    }

    func mapCard(name: String, icon: String) -> some View {
        VStack(spacing: DesignSystem.Spacing.sm) {
            Image(systemName: icon)
                .font(DesignSystem.IconSize.xLarge)
                .foregroundStyle(DesignSystem.Color.accent.opacity(0.7))
                .frame(height: DesignSystem.Size.xxxl)

            Text(name)
                .font(DesignSystem.Font.headline)
                .foregroundStyle(DesignSystem.Color.textPrimary)
        }
        .frame(maxWidth: .infinity)
        .padding(DesignSystem.Spacing.md)
    }
}
