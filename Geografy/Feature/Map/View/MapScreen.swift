import SwiftUI

struct MapScreen: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.verticalSizeClass) private var verticalSizeClass
    @Environment(TravelService.self) private var travelService
    @Environment(HapticsService.self) private var hapticsService

    var continentFilter: String?

    @Namespace private var flagNamespace

    @State private var mapState = MapState()
    @State private var countryDataService = CountryDataService()
    @State private var navigateToCountry: Country?
    @State private var showFlagPreview = false
    @State private var screenSize: CGSize = .zero
    @State private var isInitialized = false

    var body: some View {
        ZStack {
            GeometryReader { geometry in
                mapContent(in: geometry.size)
                    .onAppear {
                        screenSize = geometry.size
                    }
                    .onChange(of: geometry.size) { _, newSize in
                        screenSize = newSize
                        updateMinScale(for: newSize)
                    }
            }

            if mapState.countryShapes.isEmpty {
                MapLoadingView()
                    .transition(.opacity)
            }
        }
        .background(DesignSystem.Color.ocean)
        .ignoresSafeArea()
        .navigationTitle(continentFilter ?? "World Map")
        .navigationBarTitleDisplayMode(.inline)
        .safeAreaInset(edge: .top) {
            if !isLandscape {
                bannerOverlay
                    .animation(.easeInOut(duration: 0.3), value: mapState.selectedCountryCode)
            }
        }
        .toolbarBackground(.clear, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                closeButton
            }
            ToolbarItem(placement: .principal) {
                if isLandscape {
                    bannerOverlay
                        .frame(maxWidth: 500)
                        .animation(.easeInOut(duration: 0.3), value: mapState.selectedCountryCode)
                }
            }
            ToolbarItem(placement: .topBarTrailing) {
                HStack(spacing: DesignSystem.Spacing.xs) {
                    densityToggleButton
                    labelsToggleButton
                }
            }
        }
        .safeAreaInset(edge: .bottom) {
            if mapState.showDensityOverlay {
                densityLegend
                    .padding(.horizontal, DesignSystem.Spacing.md)
                    .padding(.bottom, DesignSystem.Spacing.sm)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .navigationDestination(item: $navigateToCountry) { country in
            CountryDetailScreen(country: country)
        }
        .overlay {
            if showFlagPreview, let code = mapState.selectedCountryCode {
                flagPreview(for: code)
            }
        }
        .task {
            await loadMapData()
        }
    }
}

// MARK: - Content

private extension MapScreen {
    var isLandscape: Bool { verticalSizeClass == .compact }

    func flagPreview(for code: String) -> some View {
        ZoomableFlagView(countryCode: code, namespace: flagNamespace) {
            withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
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
            travelStatuses: travelService.entries,
            densityData: densityData,
            showDensityOverlay: mapState.showDensityOverlay
        )
        .gesture(dragGesture)
        .gesture(magnifyGesture)
        .onTapGesture(count: 1) { location in
            handleTap(at: location, in: size)
        }
    }

    var densityData: [String: Double] {
        Dictionary(uniqueKeysWithValues: countryDataService.countries.map { ($0.code, $0.populationDensity) })
    }
}

// MARK: - Controls

private extension MapScreen {
    var closeButton: some View {
        CircleCloseButton()
    }

    var labelsToggleButton: some View {
        Button {
            mapState.showLabels.toggle()
            hapticsService.impact(.light)
        } label: {
            Text("Aa")
                .font(DesignSystem.Font.headline)
                .foregroundStyle(mapState.showLabels ? DesignSystem.Color.onAccent : DesignSystem.Color.iconPrimary)
                .padding(DesignSystem.Spacing.xs)
                .background {
                    if mapState.showLabels {
                        Circle().fill(DesignSystem.Color.accent)
                    }
                }
        }
        .buttonStyle(.plain)
    }

    var densityToggleButton: some View {
        Button {
            withAnimation(.easeInOut(duration: 0.25)) {
                mapState.showDensityOverlay.toggle()
            }
            hapticsService.impact(.light)
        } label: {
            Image(systemName: "flame.fill")
                .font(DesignSystem.Font.headline)
                .foregroundStyle(mapState.showDensityOverlay ? DesignSystem.Color.onAccent : DesignSystem.Color.iconPrimary)
                .padding(DesignSystem.Spacing.xs)
                .background {
                    if mapState.showDensityOverlay {
                        Circle().fill(DesignSystem.Color.orange)
                    }
                }
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Density Legend

private extension MapScreen {
    var densityLegend: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.xxs) {
            Text("Population Density (people/km²)")
                .font(DesignSystem.Font.caption2)
                .fontWeight(.semibold)
                .foregroundStyle(DesignSystem.Color.textPrimary)
            LinearGradient(
                colors: [
                    Color(red: 1, green: 1, blue: 0.7),
                    Color(red: 1, green: 0.65, blue: 0.2),
                    Color(red: 1, green: 0.3, blue: 0),
                    Color(red: 0.7, green: 0, blue: 0),
                    Color(red: 0.45, green: 0, blue: 0),
                ],
                startPoint: .leading,
                endPoint: .trailing
            )
            .frame(height: 10)
            .clipShape(Capsule())
            HStack {
                Text("< 1")
                Spacer()
                Text("10")
                Spacer()
                Text("100")
                Spacer()
                Text("1k")
                Spacer()
                Text("> 10k")
            }
            .font(DesignSystem.Font.caption2)
            .foregroundStyle(DesignSystem.Color.textSecondary)
        }
        .padding(DesignSystem.Spacing.sm)
        .background(DesignSystem.Color.background.opacity(0.92))
        .clipShape(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium))
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
                onMoreInfo: country != nil ? { navigateToCountry = country } : nil,
                onDismiss: { mapState.selectedCountryCode = nil }
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
                let newScale = min(max(mapState.lastScale * value.magnification, mapState.minScale), 20.0)
                let scaleRatio = newScale / mapState.scale

                mapState.offset = CGSize(
                    width: mapState.offset.width * scaleRatio,
                    height: mapState.offset.height * scaleRatio
                )
                mapState.scale = newScale
                clampVerticalOffset()
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
                clampVerticalOffset()
            }
            .onEnded { _ in
                wrapHorizontalOffset()
                mapState.lastOffset = mapState.offset
            }
    }
}

// MARK: - Actions

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
            "Europe": (-25, 45, 34, 72),
            "North America": (-170, -50, 7, 84),
            "Oceania": (110, 180, -50, 15),
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
                if mapState.selectedCountryCode == shape.id {
                    mapState.selectedCountryCode = nil
                    hapticsService.impact(.light)
                } else {
                    mapState.selectedCountryCode = shape.id
                    hapticsService.impact(.medium)
                }
                return
            }
        }

        mapState.selectedCountryCode = nil
    }

    func loadMapData() async {
        countryDataService.loadCountries()

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
