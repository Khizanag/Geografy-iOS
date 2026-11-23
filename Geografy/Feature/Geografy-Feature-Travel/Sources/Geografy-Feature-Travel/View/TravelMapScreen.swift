import Geografy_Core_Common
import Geografy_Core_DesignSystem
import Geografy_Core_Map
import Geografy_Core_Navigation
import Geografy_Core_Service
import Geografy_Feature_Map
import SwiftUI

public struct TravelMapScreen: View {
    // MARK: - Properties
    @Environment(CountryDataService.self) private var countryDataService
    @Environment(GeoJSONCache.self) private var geoJSONCache
    @Environment(TravelService.self) private var travelService
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    public let filter: TravelMapFilter

    @State private var highlightedStatuses: [String: TravelStatus] = [:]
    @State private var isInitialized = false
    @State private var isLoaded = false
    @State private var mapState = MapState()
    @State private var screenSize: CGSize = .zero
    @State private var selectedFilter: TravelMapFilter
    @State private var showLabels = false
    @State private var styledShapes: [CountryShape] = []

    // MARK: - Init
    public init(filter: TravelMapFilter) {
        self.filter = filter
        self._selectedFilter = State(initialValue: filter)
    }

    // MARK: - Body
    public var body: some View {
        extractedContent
            .background(DesignSystem.Color.ocean)
            .ignoresSafeArea()
            .navigationTitle(selectedFilter.displayName)
            .navigationBarTitleDisplayMode(.inline)
            .closeButtonPlacementLeading()
            .safeAreaInset(edge: .top) {
                if isLoaded {
                    VStack(spacing: DesignSystem.Spacing.xs) {
                        infoBanner
                        if selectedFilter == .all {
                            TravelStatusLegend()
                        }
                    }
                    .transition(reduceMotion ? .opacity : .move(edge: .top).combined(with: .opacity))
                }
            }
            .toolbarBackground(.clear, for: .navigationBar)
            .toolbar { toolbarContent }
            .task { await loadMapData() }
            .onChange(of: selectedFilter) { restyleShapes() }
            .onChange(of: travelService.entries) { restyleShapes() }
            .haptic(.impact(weight: .light), trigger: showLabels)
    }
}

// MARK: - Subviews
private extension TravelMapScreen {
    var extractedContent: some View {
        GeometryReader { geometry in
            mapCanvas(in: geometry.size)
                .onAppear { screenSize = geometry.size }
                .onChange(of: geometry.size) { _, newSize in
                    screenSize = newSize
                }
        }
        .overlay {
            if mapState.countryShapes.isEmpty {
                MapLoadingView()
                    .transition(.opacity)
            }
        }
    }

    func mapCanvas(in size: CGSize) -> some View {
        let wrapsWorld = MapProjection.current == .mercator
        return InteractiveMapViewport(
            mapState: mapState,
            viewSize: size,
            bounds: MapProjection.worldBounds(around: mapState.contentBounds),
            wrapsHorizontally: wrapsWorld
        ) { frame, canvasSize in
            MapCanvasView(
                countryShapes: styledShapes,
                scale: frame.scale,
                offset: frame.offset,
                selectedCountryCode: nil,
                showLabels: showLabels,
                canvasSize: canvasSize,
                capitalPoint: nil,
                travelStatuses: highlightedStatuses,
                wrapsHorizontally: wrapsWorld
            )
        }
        .accessibilityLabel("Travel map showing \(travelCount) countries")
        .accessibilityHint("Pinch to zoom, drag to pan")
    }

    var infoBanner: some View {
        HStack(spacing: DesignSystem.Spacing.sm) {
            Image(systemName: filterIcon)
                .font(DesignSystem.Font.headline)
                .foregroundStyle(filterColor)
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: DesignSystem.Spacing.xxs) {
                Text(selectedFilter.displayName)
                    .font(DesignSystem.Font.headline)
                    .foregroundStyle(DesignSystem.Color.textPrimary)

                Text("\(travelCount) countries")
                    .font(DesignSystem.Font.caption)
                    .foregroundStyle(DesignSystem.Color.textSecondary)
            }

            Spacer()
        }
        .padding(DesignSystem.Spacing.sm)
        .glassEffect(.regular, in: RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.large, style: .continuous))
        .padding(.horizontal, DesignSystem.Spacing.md)
        .animation(reduceMotion ? nil : .easeInOut(duration: 0.3), value: selectedFilter)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(selectedFilter.displayName), \(travelCount) countries")
    }
}

// MARK: - Toolbar
private extension TravelMapScreen {
    @ToolbarContentBuilder
    var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .primaryAction) {
            labelsToggle
        }
        .sharedBackgroundVisibility(.hidden)
        ToolbarItem(placement: .primaryAction) {
            filterMenu
        }
    }

    var labelsToggle: some View {
        ToolbarToggle("Country labels", systemImage: "textformat", isOn: showLabels) {
            showLabels.toggle()
        }
    }

    var filterMenu: some View {
        Menu {
            Picker(selection: $selectedFilter.animation(reduceMotion ? nil : .default)) {
                ForEach(TravelMapFilter.allCases, id: \.self) { mapFilter in
                    Label(mapFilter.displayName, systemImage: mapFilter.icon)
                        .tag(mapFilter)
                }
            } label: {
                Label("Filter", systemImage: "line.3.horizontal.decrease")
            }
            .pickerStyle(.inline)
        } label: {
            Image(systemName: "line.3.horizontal.decrease")
                .foregroundStyle(DesignSystem.Color.iconPrimary)
        }
        .accessibilityLabel("Filter")
        .accessibilityValue(selectedFilter.displayName)
    }
}

// MARK: - Helpers
private extension TravelMapScreen {
    var travelCount: Int {
        switch selectedFilter {
        case .visited: travelService.visitedCodes.count
        case .wantToVisit: travelService.wantToVisitCodes.count
        case .all: travelService.entries.count
        }
    }

    var filterIcon: String {
        switch selectedFilter {
        case .visited: "checkmark.circle.fill"
        case .wantToVisit: "heart.fill"
        case .all: "globe"
        }
    }

    var filterColor: Color {
        switch selectedFilter {
        case .visited: DesignSystem.Color.success
        case .wantToVisit: DesignSystem.Color.warning
        case .all: DesignSystem.Color.accent
        }
    }
}

// MARK: - Actions
private extension TravelMapScreen {
    func loadMapData() async {
        let shapes = await geoJSONCache.loadShapes()

        guard !shapes.isEmpty else { return }

        mapState.contentBounds = MapState.bounds(of: shapes)

        withAnimation(reduceMotion ? nil : .easeOut(duration: 0.3)) {
            mapState.countryShapes = shapes
        }
        restyleShapes()

        if screenSize.width > 0, !isInitialized {
            let fitScale = screenSize.width / MapProjection.mapWidth
            mapState.scale = fitScale
            mapState.lastScale = fitScale
            mapState.minScale = fitScale
            isInitialized = true
        }

        withAnimation(reduceMotion ? nil : .easeInOut(duration: 0.4).delay(0.3)) {
            isLoaded = true
        }
    }

    /// Mutes countries the filter leaves out; runs when the filter, entries or shapes change, not every frame.
    func restyleShapes() {
        let statuses = switch selectedFilter {
        case .visited: travelService.entries.filter { $0.value == .visited }
        case .wantToVisit: travelService.entries.filter { $0.value == .wantToVisit }
        case .all: travelService.entries
        }
        highlightedStatuses = statuses
        styledShapes = mapState.countryShapes.map { shape in
            guard statuses[shape.id] == nil else { return shape }
            var muted = shape.recolored(DesignSystem.Color.mapLandMuted)
            muted.name = ""
            return muted
        }
    }
}
