import SwiftUI

struct EconomyExplorerScreen: View {
    @Environment(TabCoordinator.self) private var coordinator

    @State private var countryDataService = CountryDataService()
    @State private var searchText = ""
    @State private var blobAnimating = false

    private var rankedCountries: [Country] {
        countryDataService.countries
            .filter { $0.gdpPerCapita != nil }
            .sorted { ($0.gdpPerCapita ?? 0) > ($1.gdpPerCapita ?? 0) }
    }

    private var filteredCountries: [Country] {
        guard !searchText.isEmpty else { return rankedCountries }
        return rankedCountries.filter {
            $0.name.localizedCaseInsensitiveContains(searchText)
        }
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: DesignSystem.Spacing.lg) {
                headerStats
                rankingList
            }
            .padding(.horizontal, DesignSystem.Spacing.md)
            .padding(.vertical, DesignSystem.Spacing.md)
        }
        .searchable(text: $searchText, prompt: "Search countries")
        .background { ambientBlobs }
        .background(DesignSystem.Color.background.ignoresSafeArea())
        .navigationTitle("Economy Explorer")
        .navigationBarTitleDisplayMode(.inline)
        .task { countryDataService.loadCountries() }
        .onAppear { blobAnimating = true }
    }
}

// MARK: - Subviews

private extension EconomyExplorerScreen {
    var headerStats: some View {
        HStack(spacing: DesignSystem.Spacing.sm) {
            statCard(
                icon: "chart.bar.fill",
                label: "Ranked",
                value: "\(rankedCountries.count)",
                color: DesignSystem.Color.accent
            )
            statCard(
                icon: "dollarsign.circle.fill",
                label: "Top GDP/capita",
                value: rankedCountries.first?.gdpPerCapita.map { "$\(Int($0 / 1000))K" } ?? "—",
                color: DesignSystem.Color.success
            )
        }
    }

    func statCard(icon: String, label: String, value: String, color: Color) -> some View {
        CardView {
            HStack(spacing: DesignSystem.Spacing.sm) {
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundStyle(color)
                VStack(alignment: .leading, spacing: 2) {
                    Text(label)
                        .font(DesignSystem.Font.caption)
                        .foregroundStyle(DesignSystem.Color.textSecondary)
                    Text(value)
                        .font(DesignSystem.Font.headline)
                        .fontWeight(.bold)
                        .foregroundStyle(DesignSystem.Color.textPrimary)
                }
                Spacer(minLength: 0)
            }
            .padding(DesignSystem.Spacing.sm)
        }
    }

    var rankingList: some View {
        VStack(spacing: DesignSystem.Spacing.xs) {
            ForEach(Array(filteredCountries.enumerated()), id: \.element.id) { index, country in
                rankRow(
                    country: country,
                    rank: rankedCountries.firstIndex(where: { $0.id == country.id }).map { $0 + 1 } ?? index + 1
                )
                .onTapGesture { coordinator.push(.countryDetail(country)) }
            }
        }
    }

    func rankRow(country: Country, rank: Int) -> some View {
        let maxPerCapita = rankedCountries.first?.gdpPerCapita ?? 1
        let perCapita = country.gdpPerCapita ?? 0
        let ratio = perCapita / maxPerCapita
        return CardView {
            VStack(spacing: DesignSystem.Spacing.xs) {
                HStack(spacing: DesignSystem.Spacing.sm) {
                    rankBadge(rank: rank)
                    FlagView(countryCode: country.code, height: 28)
                        .clipShape(RoundedRectangle(cornerRadius: 4))
                    countryInfo(country: country, perCapita: perCapita)
                    Spacer(minLength: 0)
                    Image(systemName: "chevron.right")
                        .font(DesignSystem.Font.caption)
                        .foregroundStyle(DesignSystem.Color.textTertiary)
                }
                gdpBar(ratio: ratio, rank: rank)
            }
            .padding(DesignSystem.Spacing.sm)
        }
        .buttonStyle(PressButtonStyle())
    }

    func rankBadge(rank: Int) -> some View {
        Text("#\(rank)")
            .font(DesignSystem.Font.caption)
            .fontWeight(.bold)
            .foregroundStyle(rankColor(rank: rank))
            .frame(width: 32)
    }

    func rankColor(rank: Int) -> Color {
        if rank <= 20 { return DesignSystem.Color.warning }
        if rank <= 50 { return DesignSystem.Color.textSecondary }
        return DesignSystem.Color.textTertiary
    }

    func countryInfo(country: Country, perCapita: Double) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(country.name)
                .font(DesignSystem.Font.subheadline)
                .fontWeight(.semibold)
                .foregroundStyle(DesignSystem.Color.textPrimary)
                .lineLimit(1)
            Text(perCapita.formatCurrency())
                .font(DesignSystem.Font.caption)
                .foregroundStyle(DesignSystem.Color.textSecondary)
        }
    }

    func gdpBar(ratio: Double, rank: Int) -> some View {
        GeometryReader { geometryReader in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 3)
                    .fill(DesignSystem.Color.cardBackground)
                    .frame(height: 6)
                RoundedRectangle(cornerRadius: 3)
                    .fill(rankBarColor(rank: rank))
                    .frame(width: geometryReader.size.width * ratio, height: 6)
            }
        }
        .frame(height: 6)
    }

    func rankBarColor(rank: Int) -> Color {
        if rank <= 20 { return DesignSystem.Color.warning }
        if rank <= 50 { return DesignSystem.Color.accent.opacity(0.7) }
        return DesignSystem.Color.accent.opacity(0.4)
    }

    var ambientBlobs: some View {
        ZStack {
            RadialGradient(
                colors: [DesignSystem.Color.success.opacity(0.15), .clear],
                center: .topTrailing,
                startRadius: 0,
                endRadius: 300
            )
            RadialGradient(
                colors: [DesignSystem.Color.accent.opacity(0.12), .clear],
                center: .bottomLeading,
                startRadius: 0,
                endRadius: 280
            )
        }
        .ignoresSafeArea()
        .scaleEffect(blobAnimating ? 1.05 : 0.95)
        .animation(.easeInOut(duration: 4.5).repeatForever(autoreverses: true), value: blobAnimating)
    }
}
