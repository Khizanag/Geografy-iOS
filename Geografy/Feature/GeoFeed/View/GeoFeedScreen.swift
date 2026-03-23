import SwiftUI

struct GeoFeedScreen: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(TabCoordinator.self) private var coordinator

    @State private var feedService = GeoFeedService()
    @State private var countryDataService = CountryDataService()
    @State private var appeared = false
    @State private var isRefreshing = false

    var body: some View {
        scrollContent
            .background { backgroundGradient }
            .navigationTitle("Feed")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    CircleCloseButton()
                }
            }
            .task {
                countryDataService.loadCountries()
                feedService.loadFeed()
                withAnimation(.easeOut(duration: 0.5)) { appeared = true }
            }
    }
}

// MARK: - Content

private extension GeoFeedScreen {
    var scrollContent: some View {
        ScrollView(showsIndicators: false) {
            LazyVStack(spacing: DesignSystem.Spacing.md) {
                ForEach(Array(feedService.items.enumerated()), id: \.element.id) { index, item in
                    feedCard(for: item)
                        .padding(.horizontal, DesignSystem.Spacing.md)
                        .opacity(appeared ? 1 : 0)
                        .offset(y: appeared ? 0 : 24)
                        .animation(
                            .easeOut(duration: 0.4).delay(Double(index) * 0.03),
                            value: appeared
                        )
                }
            }
            .padding(.top, DesignSystem.Spacing.md)
            .padding(.bottom, DesignSystem.Spacing.xxl)
        }
        .refreshable {
            feedService.refresh()
        }
    }

    var backgroundGradient: some View {
        DesignSystem.Color.background.ignoresSafeArea()
    }

    func feedCard(for item: GeoFeedItem) -> some View {
        GeoFeedCard(
            item: item,
            isSaved: feedService.isSaved(item.id),
            country: country(for: item.countryCode),
            onSave: { feedService.toggleSaved(itemID: item.id) },
            onCountryTap: { country in
                coordinator.push(.countryDetail(country))
            }
        )
    }

    func country(for code: String?) -> Country? {
        guard let code else { return nil }
        return countryDataService.countries.first { $0.code == code }
    }
}
