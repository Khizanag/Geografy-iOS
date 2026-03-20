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
        GridItem(.flexible(), spacing: GeoSpacing.md),
        GridItem(.flexible(), spacing: GeoSpacing.md),
    ]

    var body: some View {
        ScrollView {
            mapGrid
        }
        .background(GeoColors.background)
        .navigationTitle("All Maps")
    }
}

// MARK: - Subviews

private extension AllMapsScreen {
    var mapGrid: some View {
        LazyVGrid(columns: columns, spacing: GeoSpacing.md) {
            ForEach(Array(maps.enumerated()), id: \.offset) { _, map in
                NavigationLink(value: NavigationRoute.map) {
                    mapCard(name: map.name, icon: map.icon)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(GeoSpacing.md)
    }

    func mapCard(name: String, icon: String) -> some View {
        GeoCard {
            VStack(spacing: GeoSpacing.sm) {
                Image(systemName: icon)
                    .font(.system(size: 40, weight: .thin))
                    .foregroundStyle(GeoColors.accent.opacity(0.7))
                    .frame(height: 60)

                Text(name)
                    .font(GeoFont.headline)
                    .foregroundStyle(GeoColors.textPrimary)
            }
            .frame(maxWidth: .infinity)
            .padding(GeoSpacing.md)
        }
    }
}
