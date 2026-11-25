import Geografy_Core_Common
import Geografy_Core_DesignSystem
import Geografy_Core_Map
import Geografy_Core_Navigation
import Geografy_Core_Service
import SwiftUI

public struct MapScreen: View {
    // MARK: - Properties
    @Environment(\.verticalSizeClass) private var verticalSizeClass
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(Navigator.self) private var coordinator
    @Environment(TravelService.self) private var travelService
    @Environment(CountryDataService.self) private var countryDataService
    @Environment(GeoJSONCache.self) private var geoJSONCache

    @AppStorage("map_showsVisitedCountries") private var showsVisitedCountries = false
    @AppStorage(MapPreferences.showsGraticuleKey) private var showsGraticule = false
    @AppStorage(MapPreferences.projectionKey) private var projection = MapProjectionKind.mercator.rawValue
    @AppStorage(MapPreferences.paletteKey) private var palette = MapPalette.default.rawValue

    public var continentFilter: String?
    public var focusCountryCode: String?

    // MARK: - Init
    /// - Parameter focusCountryCode: A country to zoom to and select once the map is laid out.
    public init(continentFilter: String? = nil, focusCountryCode: String? = nil) {
        self.continentFilter = continentFilter
        self.focusCountryCode = focusCountryCode
    }

    @Namespace private var flagNamespace

    @State private var mapState = MapState()
    @State private var showFlagPreview = false
    @State private var showsFinder = false
    /// Counts the countries the person picks or unpicks, since a requested focus selects one on appear too.
    @State private var countryPickCount = 0
    @State private var screenSize: CGSize = .zero
    @State private var isInitialized = false
    @State private var hasFocusedRequestedCountry = false
    /// What the shown shapes were loaded for, so returning to the Map tab keeps its zoom instead of reloading.
    @State private var loadedMapDataKey: String?
    /// The projection the shown shapes were laid out in. Until it matches the chosen one, the map hides behind
    /// the loading view, so a switch never shows old shapes inside the new projection's outline and grid.
    @State private var loadedProjection: String?

    // MARK: - Body
    public var body: some View {
        mainContent
            .background(DesignSystem.Color.ocean)
            .ignoresSafeArea()
            .navigationTitle(continentFilter ?? "World Map")
            #if !os(tvOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .closeButtonPlacementLeading()
            .safeAreaInset(edge: .bottom) {
                if !isLandscape {
                    bannerOverlay
                        .padding(.bottom, DesignSystem.Spacing.xs)
                        .animation(reduceMotion ? nil : .easeInOut(duration: 0.3), value: mapState.selectedCountryCode)
                }
            }
            .toolbarBackground(.clear, for: .navigationBar)
            .toolbar { toolbarContent }
            .haptic(.selection, trigger: countryPickCount)
            .haptic(.impact(weight: .light), trigger: mapState.showLabels)
            .onChange(of: isInitialized) { focusRequestedCountry() }
            .onChange(of: focusCountryCode) { focusRequestedCountry() }
            // Again when the projection or colors change in Settings: the Map tab stays alive behind it.
            .task(id: mapDataKey) {
                guard mapDataKey != loadedMapDataKey else { return }
                isInitialized = false
                await loadMapData()
                if !Task.isCancelled { loadedMapDataKey = mapDataKey }
            }
            .sheet(isPresented: $showsFinder) {
                CoordinatedNavigationStack(showCloseButton: true) {
                    MapCountryFinder(shapes: mapState.countryShapes) { shape in
                        countryPickCount += 1
                        focus(on: shape)
                    }
                }
            }
            .zoomableViewer(isPresented: $showFlagPreview, title: selectedCountryTitle) {
                if let code = mapState.selectedCountryCode {
                    ZoomableFlagView(countryCode: code) { showFlagPreview = false }
                }
            }
    }
}

// MARK: - Content
private extension MapScreen {
    var mainContent: some View {
        ZStack {
            GeometryReader { geometry in
                mapContent(in: geometry.size)
                    .opacity(isLoading ? 0 : 1)
                    .allowsHitTesting(!isLoading)
                    .onAppear {
                        screenSize = geometry.size
                        if !isInitialized, !mapState.countryShapes.isEmpty {
                            setInitialScale(for: geometry.size)
                            isInitialized = true
                        }
                    }
                    .onChange(of: geometry.size) { _, newSize in
                        screenSize = newSize
                        updateMinScale(for: newSize)
                    }
                    .onChange(of: mapState.countryShapes.isEmpty) { _, isEmpty in
                        if !isEmpty, screenSize.width > 0, !isInitialized {
                            setInitialScale(for: screenSize)
                            isInitialized = true
                        }
                    }
            }

            if isLoading {
                MapLoadingView()
                    .transition(.opacity)
            }
        }
    }

    var isLandscape: Bool { verticalSizeClass == .compact }

    var isLoading: Bool { mapState.countryShapes.isEmpty || loadedProjection != projection }

    var selectedCapitalPoint: CGPoint? {
        guard let code = mapState.selectedCountryCode,
              let coordinate = countryDataService.country(for: code)?.capitalCoordinate
                ?? MapTerritory.info(for: code)?.capitalCoordinate else { return nil }
        return MapProjection.project(coordinate)
    }

    func mapContent(in size: CGSize) -> some View {
        mapCanvas(in: size)
    }

    var isWorldMap: Bool { continentFilter == nil }

    /// The continent shown, when it's one Map Puzzle can be played on.
    var filteredContinent: Country.Continent? {
        Country.Continent.allCases.first { $0.displayName == continentFilter && $0 != .antarctica }
    }

    /// Whether the world repeats sideways. Only a rectangular world can: Equal Earth's curved edges can't meet.
    var wrapsWorld: Bool { isWorldMap && projection == MapProjectionKind.mercator.rawValue }

    var selectedCountryTitle: String? {
        mapState.selectedShape.map { countryDataService.country(for: $0.id)?.name ?? $0.name }
    }

    var selectedCountryName: String? {
        guard let shape = mapState.selectedShape else { return nil }
        let name = countryDataService.country(for: shape.id)?.name ?? shape.name
        guard let status = travelService.entries[shape.id] else { return name }
        return "\(name), \(status.label)"
    }

    func mapCanvas(in size: CGSize) -> some View {
        InteractiveMapViewport(
            mapState: mapState,
            viewSize: size,
            bounds: effectiveViewportBounds,
            wrapsHorizontally: wrapsWorld,
            onTap: { handleTap(at: $0, in: size) },
            canvas: { frame, canvasSize in
                MapCanvasView(
                    countryShapes: mapState.countryShapes,
                    scale: frame.scale,
                    offset: frame.offset,
                    selectedCountryCode: mapState.selectedCountryCode,
                    showLabels: mapState.showLabels,
                    canvasSize: canvasSize,
                    capitalPoint: selectedCapitalPoint,
                    highlightedCodes: showsVisitedCountries ? travelService.visitedCodes : [],
                    wrapsHorizontally: wrapsWorld
                )
            }
        )
        .accessibilityLabel(continentFilter.map { "Interactive map of \($0)" } ?? "Interactive world map")
        .accessibilityValue(selectedCountryName.map { "Selected: \($0)" } ?? "No country selected")
        .accessibilityHint("Double tap to select a country")
    }
}

// MARK: - Toolbar
private extension MapScreen {
    @ToolbarContentBuilder
    var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .principal) {
            if isLandscape {
                bannerOverlay
                    .frame(width: CountryBannerView.landscapeWidth)
                    .animation(reduceMotion ? nil : .easeInOut(duration: 0.3), value: mapState.selectedCountryCode)
            }
        }
        ToolbarItem(placement: .topBarLeading) {
            Button { showsFinder = true } label: {
                Label("Find a Country", systemImage: "magnifyingglass")
            }
            .disabled(isLoading)
        }
        ToolbarItem(placement: .primaryAction) {
            ToolbarToggle("Country labels", systemImage: "textformat", isOn: mapState.showLabels) {
                mapState.showLabels.toggle()
            }
        }
        .sharedBackgroundVisibility(.hidden)
        ToolbarItem(placement: .secondaryAction) {
            Picker(selection: $projection) {
                ForEach(MapProjectionKind.allCases) { kind in
                    Text(kind.title).tag(kind.rawValue)
                }
            } label: {
                Label("Projection", systemImage: "map")
            }
            .pickerStyle(.menu)
        }
        ToolbarItem(placement: .secondaryAction) {
            Picker(selection: $palette) {
                ForEach(MapPalette.allCases) { option in
                    Text(option.title).tag(option.rawValue)
                }
            } label: {
                Label("Colors", systemImage: "paintpalette")
            }
            .pickerStyle(.menu)
        }
        if let continent = filteredContinent {
            ToolbarItem(placement: .secondaryAction) {
                Button("Play Map Puzzle", systemImage: "puzzlepiece") {
                    coordinator.push(PlayRoute.mapPuzzle(continent: continent))
                }
            }
        }
        ToolbarItem(placement: .secondaryAction) {
            Toggle(isOn: $showsVisitedCountries) {
                Label("Show Visited Countries", systemImage: "airplane")
            }
        }
        ToolbarItem(placement: .secondaryAction) {
            Toggle(isOn: $showsGraticule.animation()) {
                Label("Show Latitude & Longitude", systemImage: "globe")
            }
        }
    }
}

// MARK: - Banner
private extension MapScreen {
    @ViewBuilder
    var bannerOverlay: some View {
        if let shape = mapState.selectedShape {
            let country = countryDataService.country(for: shape.id)
            let territory = MapTerritory.info(for: shape.id)

            CountryBannerView(
                countryCode: shape.id,
                name: country?.name ?? shape.name,
                flag: country?.flagEmoji ?? territory?.flag ?? "🏳️",
                capital: country?.capital ?? territory?.capital ?? "",
                namespace: flagNamespace,
                isFlagHidden: showFlagPreview,
                onFlagTap: {
                    withAnimation(reduceMotion ? nil : .spring(response: 0.35, dampingFraction: 0.85)) {
                        showFlagPreview = true
                    }
                },
                onMoreInfo: country.map { selected in { coordinator.push(CountryRoute.countryDetail(selected)) } },
                isCompact: isLandscape,
                onDismiss: {
                    withAnimation(reduceMotion ? nil : .easeInOut(duration: 0.3)) {
                        mapState.selectedCountryCode = nil
                    }
                }
            )
            .transition(reduceMotion ? .opacity : .move(edge: .bottom).combined(with: .opacity))
        }
    }
}

// MARK: - Map Geometry
private extension MapScreen {
    func clampOffset() {
        mapState.clampOffset(to: effectiveViewportBounds, in: screenSize, horizontally: !wrapsWorld)
    }

    func updateMinScale(for size: CGSize) {
        guard size.width > 0, size.height > 0 else { return }
        let newMin = computeMinScale(for: size)
        mapState.minScale = newMin

        if mapState.scale < newMin {
            mapState.scale = newMin
            mapState.lastScale = newMin
        }

        mapState.center(on: effectiveViewportBounds)
        clampOffset()
        mapState.lastOffset = mapState.offset
    }

    func setInitialScale(for size: CGSize) {
        guard size.width > 0, size.height > 0 else { return }
        let fitScale = computeMinScale(for: size)
        mapState.scale = fitScale
        mapState.lastScale = fitScale
        mapState.minScale = fitScale
        mapState.center(on: effectiveViewportBounds)
    }

    func computeMinScale(for size: CGSize) -> CGFloat {
        if continentFilter != nil {
            let bounds = effectiveViewportBounds
            guard bounds.width > 0, bounds.height > 0 else {
                return size.width / MapProjection.mapWidth
            }
            let fitContentWidth = size.width / bounds.width
            let fitContentHeight = size.height / bounds.height
            return min(fitContentWidth, fitContentHeight) * 0.9
        }

        let fitWidth = size.width / MapProjection.mapWidth
        let isLandscape = size.width > size.height
        if isLandscape {
            let bounds = mapState.contentBounds
            guard bounds.height > 0 else { return fitWidth }
            let fitContentHeight = size.height / bounds.height
            return max(fitWidth, fitContentHeight)
        }

        return fitWidth
    }

    // Returns a viewport rect for continents that span the antimeridian or
    // have outlier territories that would skew the computed bounding box.
    var effectiveViewportBounds: CGRect {
        if let filter = continentFilter, let vp = ContinentViewport.rect(for: filter) {
            return vp
        }
        return MapProjection.worldBounds(around: mapState.contentBounds)
    }
}

// MARK: - Actions
private extension MapScreen {
    /// A task re-runs whenever its view reappears, such as on returning to the Map tab; this changes only when
    /// the map itself must be redrawn.
    var mapDataKey: String {
        "\(projection)-\(palette)-\(geoJSONCache.revision)"
    }

    /// Flies the map to a country and selects it. The drawn map moves during the flight and is drawn sharp
    /// again when it lands, the same way a pinch works.
    func focusRequestedCountry() {
        guard isInitialized, !hasFocusedRequestedCountry, let code = focusCountryCode,
              let shape = mapState.countryShapes.first(where: { $0.id == code }) else { return }
        hasFocusedRequestedCountry = true
        focus(on: shape)
    }

    /// Selects the country, then flies the map to it frame by frame, as a pinch moves it, so the map stays sharp
    /// and covered the whole way instead of stretching one picture and snapping sharp at the end.
    func focus(on shape: CountryShape) {
        let start = mapState.currentFrame
        mapState.focus(on: shape.boundingBox, in: screenSize)
        clampOffset()
        let target = mapState.currentFrame
        mapState.scale = start.scale
        mapState.offset = start.offset

        withAnimation(reduceMotion ? nil : .easeInOut(duration: 0.3)) {
            mapState.selectedCountryCode = shape.id
        }
        mapState.fly(to: target, in: screenSize, duration: reduceMotion ? 0 : Self.flightDuration)
    }

    static let flightDuration: TimeInterval = 1.1

    func handleTap(at point: CGPoint, in size: CGSize) {
        let mapPoint = mapState.mapPoint(for: point, in: size, wrapping: wrapsWorld)
        if let shape = mapState.shape(at: mapPoint) {
            withAnimation(reduceMotion ? nil : .spring(response: 0.35, dampingFraction: 0.78)) {
                if mapState.selectedCountryCode == shape.id {
                    mapState.selectedCountryCode = nil
                } else {
                    mapState.selectedCountryCode = shape.id
                }
                countryPickCount += 1
            }
            return
        }

        withAnimation(reduceMotion ? nil : .easeInOut(duration: 0.3)) {
            mapState.selectedCountryCode = nil
        }
    }
}

// MARK: - Data Loading
private extension MapScreen {
    func loadMapData() async {
        let wasPreloaded = geoJSONCache.isLoaded
        var shapes = await geoJSONCache.loadShapes()
        // A newer switch replaced this load; its shapes may be in the projection just left.
        guard !Task.isCancelled else { return }
        if let continentFilter {
            shapes = shapes.filter { $0.continent == continentFilter }
        }

        guard !shapes.isEmpty else { return }

        mapState.contentBounds = MapState.bounds(of: shapes)

        withAnimation(wasPreloaded || reduceMotion ? nil : .easeOut(duration: 0.3)) {
            mapState.countryShapes = shapes
        }

        if screenSize.width > 0, !isInitialized {
            setInitialScale(for: screenSize)
            isInitialized = true
        }

        withAnimation(reduceMotion ? nil : .easeInOut(duration: 0.3)) {
            loadedProjection = projection
        }
    }
}
