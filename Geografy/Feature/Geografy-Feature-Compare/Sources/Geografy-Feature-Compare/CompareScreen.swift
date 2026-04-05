import Geografy_Core_Common
import Geografy_Core_DesignSystem
import Geografy_Core_Service
import SwiftUI

public struct CompareScreen: View {
    #if !os(tvOS)
    // MARK: - Properties
    @Environment(HapticsService.self) private var hapticsService
    #endif
    @Environment(CountryDataService.self) private var countryDataService

    @State private var leftCountry: Country?
    @State private var rightCountry: Country?
    @State private var activeSheet: CompareSheet?
    @State private var recentPairs: [ComparisonPair] = []

    private let preselectedCountry: Country?

    // MARK: - Init
    public init(preselectedCountry: Country? = nil) {
        self.preselectedCountry = preselectedCountry
    }

    // MARK: - Body
    public var body: some View {
        contentScrollView
            .background(DesignSystem.Color.background)
            .navigationTitle("Compare")
            .onAppear {
                loadRecentPairs()
                if let preselected = preselectedCountry, leftCountry == nil {
                    leftCountry = preselected
                }
            }
            .sheet(item: $activeSheet) { sheetContent(for: $0) }
    }
}

// MARK: - Sheet
private extension CompareScreen {
    enum CompareSheet: Identifiable {
        case pickLeft
        case pickRight

        var id: String {
            switch self {
            case .pickLeft: "pickLeft"
            case .pickRight: "pickRight"
            }
        }
    }

    @ViewBuilder
    func sheetContent(for sheet: CompareSheet) -> some View {
        let excluded: Country? = switch sheet {
        case .pickLeft: rightCountry
        case .pickRight: leftCountry
        }

        NavigationStack {
            CompareCountryPicker(
                countries: countryDataService.countries,
                excludedCountry: excluded
            ) { selected in
                withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                    switch sheet {
                    case .pickLeft: leftCountry = selected
                    case .pickRight: rightCountry = selected
                    }
                    saveIfBothSelected()
                }
            }
        }
    }
}

// MARK: - Subviews
private extension CompareScreen {
    var contentScrollView: some View {
        ScrollView {
            VStack(spacing: DesignSystem.Spacing.lg) {
                slotsRow
                swapButton
                if let left = leftCountry, let right = rightCountry {
                    metricsSection(left: left, right: right)
                } else {
                    emptyPrompt
                }
                if !recentPairs.isEmpty {
                    recentSection
                }
            }
            .padding(.horizontal, DesignSystem.Spacing.md)
            .padding(.bottom, DesignSystem.Spacing.xxl)
            .readableContentWidth()
        }
    }

    var slotsRow: some View {
        HStack(spacing: DesignSystem.Spacing.md) {
            CompareCountrySlot(
                country: leftCountry,
                label: "Country A"
            ) {
                activeSheet = .pickLeft
            }

            vsLabel

            CompareCountrySlot(
                country: rightCountry,
                label: "Country B"
            ) {
                activeSheet = .pickRight
            }
        }
    }

    var vsLabel: some View {
        Text("VS")
            .font(DesignSystem.Font.headline)
            .foregroundStyle(DesignSystem.Color.accent)
    }

    @ViewBuilder
    var swapButton: some View {
        if leftCountry != nil, rightCountry != nil {
            Button {
                #if !os(tvOS)
                hapticsService.impact(.light)
                #endif
                withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                    let temp = leftCountry
                    leftCountry = rightCountry
                    rightCountry = temp
                }
            } label: {
                Label("Swap", systemImage: "arrow.left.arrow.right")
                    .font(DesignSystem.Font.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(DesignSystem.Color.accent)
                    .padding(.horizontal, DesignSystem.Spacing.sm)
                    .padding(.vertical, DesignSystem.Spacing.xxs)
            }
            .buttonStyle(.plain)
        }
    }

    var emptyPrompt: some View {
        CardView {
            VStack(spacing: DesignSystem.Spacing.sm) {
                Image(systemName: "arrow.triangle.swap")
                    .font(DesignSystem.Font.title)
                    .foregroundStyle(DesignSystem.Color.accent)
                    .accessibilityHidden(true)
                Text("Select two countries to compare")
                    .font(DesignSystem.Font.subheadline)
                    .foregroundStyle(DesignSystem.Color.textSecondary)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .padding(DesignSystem.Spacing.xl)
        }
    }
}

// MARK: - Metrics
private extension CompareScreen {
    func metricsSection(left: Country, right: Country) -> some View {
        VStack(spacing: DesignSystem.Spacing.sm) {
            SectionHeaderView(title: "Comparison")
                .accessibilityAddTraits(.isHeader)

            numericCharts(left: left, right: right)
            textMetrics(left: left, right: right)
            commonOrganizationsRow(left: left, right: right)
        }
    }

    func numericCharts(left: Country, right: Country) -> some View {
        Group {
            populationChart(left: left, right: right)
            areaChart(left: left, right: right)
            gdpChart(left: left, right: right)
            densityChart(left: left, right: right)
        }
    }

    func populationChart(left: Country, right: Country) -> some View {
        CompareBarChart(
            title: "Population",
            icon: "person.2.fill",
            leftValue: Double(left.population),
            rightValue: Double(right.population),
            leftLabel: left.population.formatPopulation(),
            rightLabel: right.population.formatPopulation()
        )
    }

    func areaChart(left: Country, right: Country) -> some View {
        CompareBarChart(
            title: "Area",
            icon: "map.fill",
            leftValue: left.area,
            rightValue: right.area,
            leftLabel: left.area.formatArea(),
            rightLabel: right.area.formatArea()
        )
    }

    @ViewBuilder
    func gdpChart(left: Country, right: Country) -> some View {
        if let leftGDP = left.gdp, let rightGDP = right.gdp {
            CompareBarChart(
                title: "GDP",
                icon: "chart.bar.fill",
                leftValue: leftGDP,
                rightValue: rightGDP,
                leftLabel: leftGDP.formatGDP(),
                rightLabel: rightGDP.formatGDP()
            )
        }
    }

    func densityChart(left: Country, right: Country) -> some View {
        CompareBarChart(
            title: "Density",
            icon: "person.crop.square",
            leftValue: left.populationDensity,
            rightValue: right.populationDensity,
            leftLabel: densityLabel(left.populationDensity),
            rightLabel: densityLabel(right.populationDensity)
        )
    }

    func textMetrics(left: Country, right: Country) -> some View {
        Group {
            CompareMetricRow(
                title: "Capital",
                icon: "mappin.and.ellipse",
                leftValue: left.capital,
                rightValue: right.capital
            )

            CompareMetricRow(
                title: "Continent",
                icon: "globe.americas.fill",
                leftValue: left.continent.displayName,
                rightValue: right.continent.displayName,
                match: left.continent == right.continent
            )

            CompareMetricRow(
                title: "Currency",
                icon: "dollarsign.circle.fill",
                leftValue: "\(left.currency.name) (\(left.currency.code))",
                rightValue: "\(right.currency.name) (\(right.currency.code))",
                match: left.currency.code == right.currency.code
            )

            CompareMetricRow(
                title: "Languages",
                icon: "globe",
                leftValue: languagesSummary(left.languages),
                rightValue: languagesSummary(right.languages)
            )
        }
    }

    func commonOrganizationsRow(left: Country, right: Country) -> some View {
        let common = Set(left.organizations).intersection(Set(right.organizations))
        let summary = common.isEmpty
            ? "None"
            : common.sorted().joined(separator: ", ")
        return CompareMetricRow(
            title: "Common Orgs",
            icon: "building.2.fill",
            leftValue: "\(left.organizations.count) memberships",
            rightValue: "\(right.organizations.count) memberships",
            footer: "\(common.count) in common: \(summary)"
        )
    }
}

// MARK: - Recent Comparisons
private extension CompareScreen {
    var recentSection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            SectionHeaderView(title: "Recent", icon: "clock")
                .accessibilityAddTraits(.isHeader)

            ForEach(recentPairs) { pair in
                recentPairRow(pair)
            }
        }
    }

    func recentPairRow(_ pair: ComparisonPair) -> some View {
        Button {
            #if !os(tvOS)
            hapticsService.impact(.light)
            #endif
            withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                leftCountry = countryDataService.country(for: pair.leftCode)
                rightCountry = countryDataService.country(for: pair.rightCode)
            }
        } label: {
            CardView {
                HStack(spacing: DesignSystem.Spacing.xs) {
                    HStack(spacing: DesignSystem.Spacing.xs) {
                        FlagView(countryCode: pair.leftCode, height: 24)
                        Text(pair.leftName)
                            .font(DesignSystem.Font.caption)
                            .foregroundStyle(DesignSystem.Color.textPrimary)
                            .lineLimit(2)
                            .minimumScaleFactor(0.8)
                    }
                    .frame(maxWidth: .infinity, alignment: .trailing)

                    Text("VS")
                        .font(DesignSystem.Font.caption2)
                        .foregroundStyle(DesignSystem.Color.textTertiary)
                        .fixedSize()

                    HStack(spacing: DesignSystem.Spacing.xs) {
                        Text(pair.rightName)
                            .font(DesignSystem.Font.caption)
                            .foregroundStyle(DesignSystem.Color.textPrimary)
                            .lineLimit(2)
                            .minimumScaleFactor(0.8)
                        FlagView(countryCode: pair.rightCode, height: 24)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding(DesignSystem.Spacing.sm)
                .accessibilityElement(children: .combine)
                .accessibilityLabel("\(pair.leftName) versus \(pair.rightName)")
            }
        }
        .buttonStyle(PressButtonStyle())
    }
}

// MARK: - Helpers
private extension CompareScreen {
    func densityLabel(_ value: Double) -> String {
        String(format: "%.1f/km\u{00B2}", value)
    }

    func languagesSummary(_ languages: [Country.Language]) -> String {
        let names = languages
            .sorted { $0.percentage > $1.percentage }
            .prefix(3)
            .map(\.name)
        if names.isEmpty { return "N/A" }
        let suffix = languages.count > 3 ? " +\(languages.count - 3)" : ""
        return names.joined(separator: ", ") + suffix
    }
}

// MARK: - Actions
private extension CompareScreen {
    func saveIfBothSelected() {
        guard let left = leftCountry, let right = rightCountry else { return }
        let pair = ComparisonPair(
            leftCode: left.code,
            leftName: left.name,
            rightCode: right.code,
            rightName: right.name
        )
        recentPairs.removeAll { $0.leftCode == pair.leftCode && $0.rightCode == pair.rightCode }
        recentPairs.removeAll { $0.leftCode == pair.rightCode && $0.rightCode == pair.leftCode }
        recentPairs.insert(pair, at: 0)
        if recentPairs.count > 10 { recentPairs = Array(recentPairs.prefix(10)) }
        saveRecentPairs()
    }

    func saveRecentPairs() {
        guard let data = try? JSONEncoder().encode(recentPairs) else { return }
        UserDefaults.standard.set(data, forKey: "compare_recent_pairs")
    }

    func loadRecentPairs() {
        guard let data = UserDefaults.standard.data(forKey: "compare_recent_pairs"),
              let decoded = try? JSONDecoder().decode([ComparisonPair].self, from: data) else {
            return
        }
        recentPairs = decoded
    }
}

// MARK: - ComparisonPair
public struct ComparisonPair: Identifiable, Codable {
    public var id: String { "\(leftCode)-\(rightCode)" }

    public let leftCode: String
    public let leftName: String
    public let rightCode: String
    public let rightName: String
}
