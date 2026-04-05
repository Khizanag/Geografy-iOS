import Geografy_Core_Common
import Geografy_Core_DesignSystem
import Geografy_Core_Navigation
import Geografy_Core_Service
import SwiftUI

public struct TravelTrackerScreen: View {
    // MARK: - Properties
    @Environment(CountryDataService.self) var countryDataService
    @Environment(HapticsService.self) var hapticsService
    @Environment(Navigator.self) private var coordinator
    @Environment(TravelService.self) var travelService

    @State var selectedFilter: TravelStatus?
    @State var searchText = ""
    @State var showCountryPicker = false
    @State var selectedCountry: Country?
    @State private var appeared = false

    // MARK: - Init
    public init() {}

    // MARK: - Body
    public var body: some View {
        extractedContent
            .navigationTitle("Travel Tracker")
            .closeButtonPlacementLeading()
            .searchable(text: $searchText, prompt: "Search countries…")
            .toolbar { toolbarContent }
            .onAppear {
                appeared = true
            }
            .sheet(isPresented: $showCountryPicker) {
                TravelCountryPickerSheet(
                    countries: countryDataService.countries,
                    isPresented: $showCountryPicker,
                    preferredStatus: selectedFilter
                )
            }
            .sheet(item: $selectedCountry) { country in
                TravelStatusPickerSheet(
                    country: country,
                    isPresented: Binding(
                        get: { selectedCountry != nil },
                        set: { if !$0 { selectedCountry = nil } }
                    )
                )
            }
    }
}

// MARK: - Subviews
private extension TravelTrackerScreen {
    @ViewBuilder
    var extractedContent: some View {
        if countryDataService.countries.isEmpty {
            loadingView
        } else {
            mainContent
        }
    }

    var loadingView: some View {
        ProgressView()
            .tint(DesignSystem.Color.accent)
    }

    var mainContent: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 0) {
                statsSection
                    .padding(.horizontal, DesignSystem.Spacing.md)
                    .padding(.top, DesignSystem.Spacing.md)
                    .offset(y: appeared ? 0 : 20)
                    .animation(.easeOut(duration: 0.5), value: appeared)

                viewOnMapSection
                    .padding(.top, DesignSystem.Spacing.lg)
                    .padding(.horizontal, DesignSystem.Spacing.md)
                    .offset(y: appeared ? 0 : 20)
                    .animation(.easeOut(duration: 0.5).delay(0.08), value: appeared)

                filterTabs
                    .padding(.top, DesignSystem.Spacing.lg)
                    .animation(.easeOut(duration: 0.5).delay(0.1), value: appeared)

                countryList
                    .padding(.top, DesignSystem.Spacing.sm)
                    .padding(.horizontal, DesignSystem.Spacing.md)
                    .animation(.easeOut(duration: 0.5).delay(0.15), value: appeared)
            }
            .opacity(appeared ? 1 : 0)
            .padding(.bottom, DesignSystem.Spacing.xxl)
            .readableContentWidth()
        }
        .background { AmbientBlobsView(.travel) }
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
            coordinator.cover(.travelMap(currentTravelMapFilter))
        } label: {
            CardView {
                HStack(spacing: DesignSystem.Spacing.sm) {
                    Image(systemName: "map.fill")
                        .font(DesignSystem.Font.title2)
                        .foregroundStyle(DesignSystem.Color.accent)
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

                    Image(systemName: "chevron.right")
                        .font(DesignSystem.Font.caption)
                        .foregroundStyle(DesignSystem.Color.textTertiary)
                        .accessibilityHidden(true)
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
                hapticsService.impact(.light)
                coordinator.sheet(.travelBucketList)
            } label: {
                Label("Bucket List", systemImage: "list.star")
                    .foregroundStyle(DesignSystem.Color.accent)
            }
        }

        ToolbarItem(placement: .primaryAction) {
            Button {
                hapticsService.impact(.light)
                showCountryPicker = true
            } label: {
                Label("Add", systemImage: "plus")
                    .fontWeight(.semibold)
                    .foregroundStyle(DesignSystem.Color.accent)
            }
            .tint(Color.clear)
            .buttonStyle(.glassProminent)
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

    func filterTab(_ filter: TravelStatus?, icon: String, label: String) -> some View {
        let isActive = selectedFilter == filter && !isSearching
        let activeColor: Color = filter?.color ?? DesignSystem.Color.accent
        return Button {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.75)) {
                selectedFilter = filter
            }
        } label: {
            HStack(spacing: DesignSystem.Spacing.xxs) {
                Image(systemName: icon)
                    .font(DesignSystem.Font.caption)
                Text(label)
                    .font(DesignSystem.Font.subheadline)
                    .fontWeight(.semibold)
                if isActive, let count = filteredCount(for: filter), count > 0 {
                    Text("\(count)")
                        .font(DesignSystem.Font.caption2)
                        .fontWeight(.bold)
                        .padding(.horizontal, 5)
                        .padding(.vertical, 1)
                        .background(.primary.opacity(0.15), in: Capsule())
                }
            }
            .foregroundStyle(isActive ? DesignSystem.Color.onAccent : DesignSystem.Color.textSecondary)
            .padding(.horizontal, DesignSystem.Spacing.sm)
            .padding(.vertical, DesignSystem.Spacing.xs)
            .background(
                Capsule().fill(isActive ? activeColor : DesignSystem.Color.cardBackgroundHighlighted)
            )
        }
        .buttonStyle(PressButtonStyle())
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
                LazyVStack(spacing: DesignSystem.Spacing.xs) {
                    ForEach(countries) { country in
                        if let status = travelService.status(for: country.code) {
                            TravelCountryRow(country: country, status: status)
                                .transition(.asymmetric(
                                    insertion: .push(from: .trailing),
                                    removal: .push(from: .leading)
                                ))
                        }
                    }
                    addCountryFooter
                }
                .animation(.spring(response: 0.35, dampingFraction: 0.75), value: travelService.entries.count)
            }
        }
    }

    var addCountryFooter: some View {
        Button {
            hapticsService.impact(.light)
            showCountryPicker = true
        } label: {
            HStack(spacing: DesignSystem.Spacing.xs) {
                Image(systemName: "plus.circle.fill")
                    .font(DesignSystem.Font.subheadline)
                Text("Add Country")
                    .font(DesignSystem.Font.subheadline)
                    .fontWeight(.semibold)
            }
            .foregroundStyle(DesignSystem.Color.accent)
            .frame(maxWidth: .infinity)
            .padding(.vertical, DesignSystem.Spacing.md)
        }
        .buttonStyle(PressButtonStyle())
        .padding(.top, DesignSystem.Spacing.xs)
    }
}
