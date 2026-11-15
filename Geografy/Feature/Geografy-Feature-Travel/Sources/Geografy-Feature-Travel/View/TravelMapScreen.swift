import Geografy_Core_Common
import Geografy_Core_DesignSystem
import Geografy_Core_Navigation
import Geografy_Core_Service
import Geografy_Feature_Map
import SwiftUI

public struct TravelMapScreen: View {
    // MARK: - Properties
    @Environment(CountryDataService.self) private var countryDataService
    @Environment(GeoJSONCache.self) private var geoJSONCache
    @Environment(HapticsService.self) private var hapticsService
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
        TravelMapCanvas(
            mapState: mapState,
            countryShapes: styledShapes,
            travelStatuses: highlightedStatuses,
            showLabels: showLabels,
            canvasSize: size
        )
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
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.large, style: .continuous))
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
        ToolbarItem(placement: .primaryAction) {
            filterMenu
        }
    }

    var labelsToggle: some View {
        ToolbarToggle("Country labels", isOn: showLabels) {
            showLabels.toggle()
            hapticsService.impact(.light)
        } label: {
            Text(verbatim: "Aa")
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

        mapState.contentBounds = computeContentBounds(from: shapes)

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

    func computeContentBounds(from shapes: [CountryShape]) -> CGRect {
        guard let first = shapes.first else { return .zero }
        var minX = first.boundingBox.minX
        var minY = first.boundingBox.minY
        var maxX = first.boundingBox.maxX
        var maxY = first.boundingBox.maxY

        for shape in shapes.dropFirst() {
            minX = min(minX, shape.boundingBox.minX)
            minY = min(minY, shape.boundingBox.minY)
            maxX = max(maxX, shape.boundingBox.maxX)
            maxY = max(maxY, shape.boundingBox.maxY)
        }

        return CGRect(x: minX, y: minY, width: maxX - minX, height: maxY - minY)
    }
}

// MARK: - TravelMapCanvas
/// Reads pan and zoom on its own, so a gesture redraws the map without re-running the screen around it.
private struct TravelMapCanvas: View {
    // MARK: - Properties
    let mapState: MapState
    let countryShapes: [CountryShape]
    let travelStatuses: [String: TravelStatus]
    let showLabels: Bool
    let canvasSize: CGSize

    // MARK: - Body
    var body: some View {
        MapCanvasView(
            countryShapes: countryShapes,
            scale: mapState.scale,
            offset: mapState.offset,
            selectedCountryCode: nil,
            showLabels: showLabels,
            canvasSize: canvasSize,
            capitalPoint: nil,
            travelStatuses: travelStatuses
        )
        .overlay { MapGraticuleView(scale: mapState.scale, offset: mapState.offset) }
        #if !os(tvOS)
        .gesture(dragGesture)
        .gesture(magnifyGesture)
        #endif
    }
}

// MARK: - Gestures
#if !os(tvOS)
private extension TravelMapCanvas {
    var magnifyGesture: some Gesture {
        MagnifyGesture()
            .onChanged { value in
                let newScale = min(max(mapState.lastScale * value.magnification, mapState.minScale), 20.0)
                let scaleRatio = newScale / mapState.scale
                mapState.offset = CGSize(
                    width: mapState.offset.width * scaleRatio,
                    height: mapState.offset.height * scaleRatio
                )
                mapState.scale = newScale
            }
            .onEnded { _ in
                mapState.lastScale = mapState.scale
                mapState.lastOffset = mapState.offset
            }
    }

    var dragGesture: some Gesture {
        DragGesture()
            .onChanged { value in
                mapState.offset = CGSize(
                    width: mapState.lastOffset.width + value.translation.width,
                    height: mapState.lastOffset.height + value.translation.height
                )
            }
            .onEnded { _ in
                mapState.lastOffset = mapState.offset
            }
    }
}
#endif
