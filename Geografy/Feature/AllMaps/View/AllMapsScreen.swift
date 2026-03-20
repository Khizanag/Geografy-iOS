import SwiftUI

struct AllMapsScreen: View {
    private let maps: [(name: String, icon: String)] = [
        ("World", "globe"),
        ("Europe", "globe.europe.africa"),
        ("Asia", "globe.asia.australia"),
        ("Africa", "globe.europe.africa"),
        ("North America", "globe.americas"),
        ("South America", "globe.americas"),
        ("Oceania", "globe.asia.australia"),
    ]

    private let columns = [
        GridItem(.flexible(), spacing: DesignSystem.Spacing.md),
        GridItem(.flexible(), spacing: DesignSystem.Spacing.md),
    ]

    var body: some View {
        ScrollView {
            mapGrid
        }
        .background(DesignSystem.Color.background)
        .navigationTitle("All Maps")
    }
}

// MARK: - Subviews

private extension AllMapsScreen {
    var mapGrid: some View {
        LazyVGrid(columns: columns, spacing: DesignSystem.Spacing.md) {
            ForEach(Array(maps.enumerated()), id: \.offset) { _, map in
                NavigationLink(value: NavigationRoute.map) {
                    mapCard(name: map.name, icon: map.icon)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(DesignSystem.Spacing.md)
    }

    func mapCard(name: String, icon: String) -> some View {
        GeoCard {
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
}
