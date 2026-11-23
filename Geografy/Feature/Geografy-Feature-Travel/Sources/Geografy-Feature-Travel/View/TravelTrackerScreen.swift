import Geografy_Core_Common
import Geografy_Core_DesignSystem
import Geografy_Core_Navigation
import Geografy_Core_Service
import SwiftUI

public struct TravelTrackerScreen: View {
    // MARK: - Properties
    @Environment(CountryDataService.self) var countryDataService
    @Environment(Navigator.self) private var coordinator
    @Environment(TravelService.self) var travelService
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    @State var selectedFilter: TravelStatus?
    @State var searchText = ""
    @State var showCountryPicker = false
    @State var selectedCountry: Country?

    // MARK: - Init
    public init() {}

    // MARK: - Body
    public var body: some View {
        extractedContent
            .screenBackground()
            .closeButtonPlacementLeading()
            .searchable(text: $searchText, prompt: "Search countries…")
            .toolbar { toolbarContent }
            .sheet(isPresented: $showCountryPicker) {
                CoordinatedNavigationStack(showCloseButton: true) {
                    TravelCountryPickerSheet(
                        countries: countryDataService.countries,
                        preferredStatus: selectedFilter
                    )
                }
            }
            .sheet(item: $selectedCountry) { country in
                TravelStatusPickerSheet(country: country)
            }
    }
}

// MARK: - Subviews
private extension TravelTrackerScreen {
    @ViewBuilder
    var extractedContent: some View {
        if countryDataService.countries.isEmpty {
            LoadingView()
        } else {
            mainContent
        }
    }

    var mainContent: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 0) {
                statsSection
                    .padding(.horizontal, DesignSystem.Spacing.md)
                    .padding(.top, DesignSystem.Spacing.md)
                    .phaseEntrance(index: 0)

                viewOnMapSection
                    .padding(.top, DesignSystem.Spacing.lg)
                    .padding(.horizontal, DesignSystem.Spacing.md)
                    .phaseEntrance(index: 1)

                filterTabs
                    .padding(.top, DesignSystem.Spacing.lg)
                    .phaseEntrance(index: 2)

                countryList
                    .padding(.top, DesignSystem.Spacing.sm)
                    .padding(.horizontal, DesignSystem.Spacing.md)
                    .phaseEntrance(index: 3)
            }
            .padding(.bottom, DesignSystem.Spacing.xxl)
            .readableContentWidth()
        }
        .screenBackground()
    }

    var statsSection: some View {
        TravelStatsCard(
            visitedCount: travelService.visitedCodes.count,
            wantToVisitCount: travelService.wantToVisitCodes.count,
            totalCountries: countryDataService.countries.count,
            continentBreakdown: continentBreakdown
        )
    }

    var viewOnMapSection: some View {
        Button {
            coordinator.cover(TravelLocalRoute.travelMap(currentTravelMapFilter))
        } label: {
            CardView {
                HStack(spacing: DesignSystem.Spacing.sm) {
                    Image(systemName: "map.fill")
                        .font(DesignSystem.Font.title2)
                        .foregroundStyle(DesignSystem.Color.iconPrimary)
                        .accessibilityHidden(true)

                    VStack(alignment: .leading, spacing: DesignSystem.Spacing.xxs) {
                        Text("View on Map")
                            .font(DesignSystem.Font.headline)
                            .foregroundStyle(DesignSystem.Color.textPrimary)
                        Text(currentFilterLabel)
                            .font(DesignSystem.Font.caption)
                            .foregroundStyle(DesignSystem.Color.textSecondary)
                    }

                    Spacer()

                    RowChevron()
                }
                .padding(DesignSystem.Spacing.md)
            }
        }
        .buttonStyle(PressButtonStyle())
        .accessibilityLabel("View on Map")
        .accessibilityHint(currentFilterLabel)
    }
}

// MARK: - Toolbar
private extension TravelTrackerScreen {
    @ToolbarContentBuilder
    var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .primaryAction) {
            Button {
                coordinator.push(CountryRoute.saved(.wantToVisit))
            } label: {
                Label("Bucket List", systemImage: "list.star")
                    .foregroundStyle(DesignSystem.Color.iconPrimary)
            }
        }

        ToolbarItem(placement: .primaryAction) {
            Button {
                showCountryPicker = true
            } label: {
                Label("Add", systemImage: "plus")
                    .fontWeight(.semibold)
                    .foregroundStyle(DesignSystem.Color.iconPrimary)
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Add Country")
        }
    }
}

// MARK: - Filters
private extension TravelTrackerScreen {
    var filterTabs: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: DesignSystem.Spacing.xs) {
                filterTab(nil, icon: "globe", label: "All")
                ForEach(TravelStatus.allCases) { status in
                    filterTab(status, icon: status.icon, label: status.label)
                }
            }
            .padding(.horizontal, DesignSystem.Spacing.md)
        }
    }

    /// A glass chip: prominent in the status's own colour while it filters the list, plain glass otherwise.
    @ViewBuilder
    func filterTab(_ filter: TravelStatus?, icon: String, label: String) -> some View {
        let isActive = selectedFilter == filter && !isSearching
        let button = Button {
            withAnimation(reduceMotion ? nil : .spring(response: 0.3, dampingFraction: 0.75)) {
                selectedFilter = filter
            }
        } label: {
            filterTabLabel(filter, icon: icon, label: label, isActive: isActive)
        }
        .buttonBorderShape(.capsule)
        .accessibilityAddTraits(isActive ? .isSelected : [])

        if isActive {
            button
                .buttonStyle(.glassProminent)
                .tint(filter?.color ?? DesignSystem.Color.accent)
        } else {
            button
                .buttonStyle(.glass)
        }
    }

    func filterTabLabel(_ filter: TravelStatus?, icon: String, label: String, isActive: Bool) -> some View {
        HStack(spacing: DesignSystem.Spacing.xxs) {
            Image(systemName: icon)
                .font(DesignSystem.Font.caption)
                .accessibilityHidden(true)
            Text(label)
                .font(DesignSystem.Font.subheadline)
                .fontWeight(.semibold)
            if isActive, let count = filteredCount(for: filter), count > 0 {
                Text("\(count)")
                    .font(DesignSystem.Font.caption2)
                    .fontWeight(.bold)
                    .monospacedDigit()
                    .padding(.horizontal, 5)
                    .padding(.vertical, 1)
                    .background(.primary.opacity(DesignSystem.Opacity.tint), in: Capsule())
            }
        }
        .foregroundStyle(isActive ? DesignSystem.Color.onAccent : DesignSystem.Color.textPrimary)
    }

    func filteredCount(for filter: TravelStatus?) -> Int? {
        guard let filter else { return travelService.entries.count }
        return switch filter {
        case .visited: travelService.visitedCodes.count
        case .wantToVisit: travelService.wantToVisitCodes.count
        }
    }
}

// MARK: - Country List
private extension TravelTrackerScreen {
    @ViewBuilder
    var countryList: some View {
        if isSearching {
            searchResultsList
        } else {
            trackedCountryList
        }
    }

    var trackedCountryList: some View {
        let countries = filteredCountries
        return Group {
            if countries.isEmpty {
                emptyState
            } else {
                LazyVStack(spacing: DesignSystem.Spacing.sm) {
                    RowListCard(
                        countries,
                        dividerInset: RowListCardLayout.dividerInset(after: RowListCardLayout.flagWidth)
                    ) { country in
                        if let status = travelService.status(for: country.code) {
                            TravelCountryRow(country: country, status: status)
                                .transition(.opacity)
                        }
                    }
                    addCountryFooter
                }
                .animation(
                    reduceMotion ? nil : .spring(response: 0.35, dampingFraction: 0.75),
                    value: travelService.entries.count
                )
            }
        }
    }

    var addCountryFooter: some View {
        Button {
            showCountryPicker = true
        } label: {
            HStack(spacing: DesignSystem.Spacing.xs) {
                Image(systemName: "plus.circle.fill")
                    .font(DesignSystem.Font.subheadline)
                Text("Add Country")
                    .font(DesignSystem.Font.subheadline)
                    .fontWeight(.semibold)
            }
            .foregroundStyle(DesignSystem.Color.textPrimary)
            .frame(maxWidth: .infinity)
            .padding(.vertical, DesignSystem.Spacing.md)
        }
        .buttonStyle(PressButtonStyle())
        .padding(.top, DesignSystem.Spacing.xs)
    }
}
