import Geografy_Feature_Map
import GeografyCore
import GeografyDesign
import SwiftUI

struct MapScreen: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.verticalSizeClass) private var verticalSizeClass
    @Environment(Navigator.self) private var coordinator
    @Environment(TravelService.self) private var travelService
    @Environment(HapticsService.self) private var hapticsService
    @Environment(CountryDataService.self) private var countryDataService

    var continentFilter: String?

    @Namespace private var flagNamespace

    @State private var mapState = MapState()
    @State private var showFlagPreview = false
    @State private var screenSize: CGSize = .zero
    @State private var isInitialized = false

    var body: some View {
        mainContent
            .background(DesignSystem.Color.ocean)
            .ignoresSafeArea()
            .navigationTitle(continentFilter ?? "World Map")
            .navigationBarTitleDisplayMode(.inline)
            .closeButtonPlacementLeading()
            .safeAreaInset(edge: .top) {
                if !isLandscape {
                    bannerOverlay
                        .animation(.easeInOut(duration: 0.3), value: mapState.selectedCountryCode)
                }
            }
            .toolbarBackground(.clear, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar { toolbarContent }
            .task { await loadMapData() }
            .overlay {
                if showFlagPreview, let code = mapState.selectedCountryCode {
                    flagPreview(for: code)
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

            if mapState.countryShapes.isEmpty {
                MapLoadingView()
                    .transition(.opacity)
            }
        }
    }

    var isLandscape: Bool { verticalSizeClass == .compact }

    func flagPreview(for code: String) -> some View {
        ZoomableFlagView(countryCode: code) {
            withAnimation(.easeInOut(duration: 0.25)) {
                showFlagPreview = false
            }
        }
    }

    var selectedCapitalPoint: CGPoint? {
        guard let code = mapState.selectedCountryCode,
              let info = CountryBasicInfo.info(for: code) else { return nil }
        return MapProjection.project(longitude: info.capitalLongitude, latitude: info.capitalLatitude)
    }

    func mapContent(in size: CGSize) -> some View {
        mapCanvas(in: size)
    }

    func mapCanvas(in size: CGSize) -> some View {
        MapCanvasView(
            countryShapes: mapState.countryShapes,
            scale: mapState.scale,
            offset: mapState.offset,
            selectedCountryCode: mapState.selectedCountryCode,
            showLabels: mapState.showLabels,
            canvasSize: size,
            capitalPoint: selectedCapitalPoint,
            travelStatuses: travelService.entries
        )
        .accessibilityLabel("Interactive world map")
        .accessibilityHint("Double tap to select a country")
        .gesture(dragGesture)
        .gesture(magnifyGesture)
        .onTapGesture(count: 1) { location in
            handleTap(at: location, in: size)
        }
    }

}

// MARK: - Toolbar
private extension MapScreen {
    @ToolbarContentBuilder
    var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .principal) {
            if isLandscape {
                bannerOverlay
                    .frame(maxWidth: 500)
                    .animation(.easeInOut(duration: 0.3), value: mapState.selectedCountryCode)
            }
        }
        ToolbarItem(placement: .primaryAction) {
            labelsToggleButton
        }
    }

    var labelsToggleButton: some View {
        Button {
            mapState.showLabels.toggle()
            hapticsService.impact(.light)
        } label: {
            Text("Aa")
                .font(DesignSystem.Font.headline)
                .foregroundStyle(
                    mapState.showLabels ? DesignSystem.Color.onAccent : DesignSystem.Color.iconPrimary
                )
                .padding(DesignSystem.Spacing.xs)
                .background {
                    if mapState.showLabels {
                        Circle().fill(DesignSystem.Color.accent)
                    }
                }
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Country labels")
        .accessibilityValue(mapState.showLabels ? "Shown" : "Hidden")
        .accessibilityHint("Double tap to toggle country name labels")
    }
}

// MARK: - Banner
private extension MapScreen {
    @ViewBuilder
    var bannerOverlay: some View {
        if let shape = mapState.selectedShape {
            let country = countryDataService.country(for: shape.id)
            let basicInfo = CountryBasicInfo.info(for: shape.id)

            CountryBannerView(
                countryCode: shape.id,
                name: country?.name ?? shape.name,
                flag: country?.flagEmoji ?? basicInfo?.flag ?? "🏳️",
                capital: country?.capital ?? basicInfo?.capital ?? "",
                namespace: flagNamespace,
                isFlagHidden: showFlagPreview,
                onFlagTap: {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
                        showFlagPreview = true
                    }
                },
                onMoreInfo: country.map { selected in { coordinator.push(.countryDetail(selected)) } },
                onDismiss: { withAnimation(.easeInOut(duration: 0.3)) { mapState.selectedCountryCode = nil } }
            )
            .transition(.move(edge: .top).combined(with: .opacity))
        }
    }
}

// MARK: - Gestures
private extension MapScreen {
    var magnifyGesture: some Gesture {
        MagnifyGesture()
            .onChanged { value in
                let newScale = min(
                    max(mapState.lastScale * value.magnification, mapState.minScale),
                    MapState.maxScale
                )
                let scaleRatio = newScale / mapState.scale

                let anchor = value.startLocation
                let screenCenter = CGPoint(x: screenSize.width / 2, y: screenSize.height / 2)
                let anchorOffset = CGSize(
                    width: anchor.x - screenCenter.x,
                    height: anchor.y - screenCenter.y
                )

                mapState.offset = CGSize(
                    width: mapState.offset.width * scaleRatio - anchorOffset.width * (scaleRatio - 1),
                    height: mapState.offset.height * scaleRatio - anchorOffset.height * (scaleRatio - 1)
                )
                mapState.scale = newScale
                clampVerticalOffset()
            }
            .onEnded { _ in
                wrapHorizontalOffset()
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
                clampVerticalOffset()
            }
            .onEnded { _ in
                wrapHorizontalOffset()
                mapState.lastOffset = mapState.offset
            }
    }
}

// MARK: - Map Geometry
private extension MapScreen {
    func clampVerticalOffset() {
        let bounds = mapState.contentBounds
        guard bounds.height > 0 else { return }

        let scaledContentHeight = bounds.height * mapState.scale
        let maxOffsetY = max(0, (scaledContentHeight - screenSize.height) / 2)

        let contentCenterInMap = (bounds.minY + bounds.maxY) / 2
        let mapCenter = MapProjection.mapHeight / 2
        let centerCorrection = (mapCenter - contentCenterInMap) * mapState.scale

        let correctedOffset = mapState.offset.height - centerCorrection
        let clamped = min(max(correctedOffset, -maxOffsetY), maxOffsetY)
        mapState.offset.height = clamped + centerCorrection
    }

    func wrapHorizontalOffset() {
        let mapWidthScaled = MapProjection.mapWidth * mapState.scale
        let halfWidth = mapWidthScaled / 2

        if mapState.offset.width > halfWidth {
            mapState.offset.width -= mapWidthScaled
        } else if mapState.offset.width < -halfWidth {
            mapState.offset.width += mapWidthScaled
        }
    }

    func updateMinScale(for size: CGSize) {
        guard size.width > 0, size.height > 0 else { return }
        let newMin = computeMinScale(for: size)
        mapState.minScale = newMin

        if mapState.scale < newMin {
            mapState.scale = newMin
            mapState.lastScale = newMin
        }

        centerOnContent()
        clampVerticalOffset()
        mapState.lastOffset = mapState.offset
    }

    func setInitialScale(for size: CGSize) {
        guard size.width > 0, size.height > 0 else { return }
        let fitScale = computeMinScale(for: size)
        mapState.scale = fitScale
        mapState.lastScale = fitScale
        mapState.minScale = fitScale
        centerOnContent()
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

    func centerOnContent() {
        let bounds = effectiveViewportBounds
        guard bounds.width > 0, bounds.height > 0 else { return }

        let contentCenterX = (bounds.minX + bounds.maxX) / 2
        let contentCenterY = (bounds.minY + bounds.maxY) / 2
        let mapCenterX = MapProjection.mapWidth / 2
        let mapCenterY = MapProjection.mapHeight / 2

        let offsetX = (mapCenterX - contentCenterX) * mapState.scale
        let offsetY = (mapCenterY - contentCenterY) * mapState.scale

        mapState.offset = CGSize(width: offsetX, height: offsetY)
        mapState.lastOffset = mapState.offset
    }

    // Returns a viewport rect for continents that span the antimeridian or
    // have outlier territories that would skew the computed bounding box.
    func continentViewportBounds(for filter: String) -> CGRect? {
        typealias Bounds = (minLng: Double, maxLng: Double, minLat: Double, maxLat: Double)
        let lookup: [String: Bounds] = [
            "Europe": (-25, 40, 34, 72),
            "North America": (-140, -52, 7, 72),
            "Oceania": (112, 178, -50, 10),
            "Asia": (26, 145, -11, 78),
            "Africa": (-20, 55, -35, 38),
            "South America": (-82, -34, -56, 13),
        ]
        guard let b = lookup[filter] else { return nil }
        let topLeft = MapProjection.project(longitude: b.minLng, latitude: b.maxLat)
        let bottomRight = MapProjection.project(longitude: b.maxLng, latitude: b.minLat)
        return CGRect(
            x: topLeft.x,
            y: topLeft.y,
            width: bottomRight.x - topLeft.x,
            height: bottomRight.y - topLeft.y
        )
    }

    var effectiveViewportBounds: CGRect {
        if let filter = continentFilter, let vp = continentViewportBounds(for: filter) {
            return vp
        }
        return mapState.contentBounds
    }

}

// MARK: - Actions
private extension MapScreen {
    func handleTap(at point: CGPoint, in size: CGSize) {
        let originX = size.width / 2 - (MapProjection.mapWidth * mapState.scale) / 2 + mapState.offset.width
        let originY = size.height / 2 - (MapProjection.mapHeight * mapState.scale) / 2 + mapState.offset.height

        let mapPoint = CGPoint(
            x: (point.x - originX) / mapState.scale,
            y: (point.y - originY) / mapState.scale
        )

        let sortedByArea = mapState.countryShapes.sorted {
            $0.boundingBox.width * $0.boundingBox.height < $1.boundingBox.width * $1.boundingBox.height
        }

        for shape in sortedByArea {
            if shape.polygons.contains(where: { $0.contains(mapPoint) }) {
                withAnimation(.easeInOut(duration: 0.3)) {
                    if mapState.selectedCountryCode == shape.id {
                        mapState.selectedCountryCode = nil
                        hapticsService.impact(.light)
                    } else {
                        mapState.selectedCountryCode = shape.id
                        hapticsService.impact(.medium)
                    }
                }
                return
            }
        }

        withAnimation(.easeInOut(duration: 0.3)) {
            mapState.selectedCountryCode = nil
        }
    }

}

// MARK: - Data Loading
private extension MapScreen {
    func loadMapData() async {
        // Capture on main thread before switching to background
        let filter = continentFilter

        // Move heavy I/O and parsing off the main thread so the loading
        // indicator renders immediately
        let shapes = await Task.detached(priority: .userInitiated) { () -> [CountryShape] in
            guard let url = Bundle.main.url(forResource: "countries", withExtension: "geojson"),
                  let data = try? Data(contentsOf: url) else { return [] }
            var parsed = GeoJSONParser.parse(data: data)
            if let filter {
                parsed = parsed.filter { $0.continent == filter }
            }
            return parsed
        }.value

        guard !shapes.isEmpty else { return }

        mapState.contentBounds = computeContentBounds(from: shapes)

        withAnimation(.easeOut(duration: 0.3)) {
            mapState.countryShapes = shapes
        }

        if screenSize.width > 0, !isInitialized {
            setInitialScale(for: screenSize)
            isInitialized = true
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
