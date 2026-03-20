import SwiftUI

struct MapScreen: View {
    @Environment(\.dismiss) private var dismiss

    @State private var mapState = MapState()
    @State private var countryDataService = CountryDataService()
    @State private var navigateToCountry: Country?
    @State private var screenSize: CGSize = .zero
    @State private var isLoading = true

    var body: some View {
        ZStack {
            GeometryReader { geometry in
                mapContent(in: geometry.size)
                    .onAppear {
                        screenSize = geometry.size
                        setInitialScale(for: geometry.size)
                    }
                    .onChange(of: geometry.size) { _, newSize in
                        screenSize = newSize
                        updateMinScale(for: newSize)
                    }
            }

            if isLoading {
                MapLoadingView()
                    .transition(.opacity)
            }
        }
        .background(DesignSystem.Color.ocean)
        .ignoresSafeArea()
        .safeAreaInset(edge: .top) {
            bannerOverlay
                .animation(.easeInOut(duration: 0.3), value: mapState.selectedCountryCode)
        }
        .toolbarBackground(.clear, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                closeButton
            }
            ToolbarItem(placement: .topBarTrailing) {
                labelsToggleButton
            }
        }
        .navigationDestination(item: $navigateToCountry) { country in
            CountryDetailScreen(country: country)
        }
        .task {
            await loadMapData()
            try? await Task.sleep(for: .milliseconds(1500))
            withAnimation(.easeOut(duration: 0.3)) {
                isLoading = false
            }
        }
    }
}

// MARK: - Content

private extension MapScreen {
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
            canvasSize: size
        )
        .gesture(dragGesture)
        .gesture(magnifyGesture)
        .onTapGesture(count: 1) { location in
            handleTap(at: location, in: size)
        }
    }
}

// MARK: - Controls

private extension MapScreen {
    var closeButton: some View {
        GeoCircleCloseButton()
    }

    var labelsToggleButton: some View {
        Button {
            mapState.showLabels.toggle()
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
        } label: {
            Text("Aa")
                .font(DesignSystem.Font.headline)
                .foregroundStyle(mapState.showLabels ? DesignSystem.Color.textPrimary : DesignSystem.Color.iconSecondary)
                .padding(DesignSystem.Spacing.xs)
                .background {
                    if mapState.showLabels {
                        Circle().fill(DesignSystem.Color.accent)
                    }
                }
        }
        .buttonStyle(.plain)
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
                name: shape.name,
                flag: country?.flagEmoji ?? basicInfo?.flag ?? "🏳️",
                capital: country?.capital ?? basicInfo?.capital ?? "",
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

        // Center offset accounts for content not being centered in the map
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
        let bounds = mapState.contentBounds
        let fitWidth = size.width / MapProjection.mapWidth

        guard bounds.height > 0 else { return fitWidth }

        let isLandscape = size.width > size.height
        if isLandscape {
            let fitContentHeight = size.height / bounds.height
            return max(fitWidth, fitContentHeight)
        }

        return fitWidth
    }

    func centerOnContent() {
        let bounds = mapState.contentBounds
        guard bounds.height > 0 else { return }

        let contentCenterY = (bounds.minY + bounds.maxY) / 2
        let mapCenterY = MapProjection.mapHeight / 2
        let offsetY = (mapCenterY - contentCenterY) * mapState.scale

        mapState.offset.height = offsetY
        mapState.lastOffset.height = offsetY
    }

    func handleTap(at point: CGPoint, in size: CGSize) {
        let originX = size.width / 2 - (MapProjection.mapWidth * mapState.scale) / 2 + mapState.offset.width
        let originY = size.height / 2 - (MapProjection.mapHeight * mapState.scale) / 2 + mapState.offset.height

        let mapPoint = CGPoint(
            x: (point.x - originX) / mapState.scale,
            y: (point.y - originY) / mapState.scale
        )

        // Check smaller countries first so enclaves are tappable
        let sortedByArea = mapState.countryShapes.sorted {
            $0.boundingBox.width * $0.boundingBox.height < $1.boundingBox.width * $1.boundingBox.height
        }

        for shape in sortedByArea {
            if shape.polygons.contains(where: { $0.contains(mapPoint) }) {
                if mapState.selectedCountryCode == shape.id {
                    mapState.selectedCountryCode = nil
                } else {
                    mapState.selectedCountryCode = shape.id
                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                }
                return
            }
        }

        mapState.selectedCountryCode = nil
    }

    func loadMapData() async {
        guard let url = Bundle.main.url(forResource: "countries", withExtension: "geojson"),
              let data = try? Data(contentsOf: url) else { return }

        let shapes = GeoJSONParser.parse(data: data)
        mapState.countryShapes = shapes
        mapState.contentBounds = computeContentBounds(from: shapes)

        if screenSize.width > 0 {
            setInitialScale(for: screenSize)
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
