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
        ZStack {
            mapCanvas(in: size)
            bannerOverlay
        }
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
                .fontWeight(mapState.showLabels ? .bold : .regular)
                .foregroundStyle(mapState.showLabels ? DesignSystem.Color.accent : DesignSystem.Color.textSecondary)
                .frame(width: DesignSystem.Size.xl, height: DesignSystem.Size.xl)
                .contentShape(Circle())
        }
        .glassEffect(
            mapState.showLabels ? .regular.interactive().tint(DesignSystem.Color.accent) : .regular.interactive(),
            in: .circle
        )
    }
}

// MARK: - Banner

private extension MapScreen {
    @ViewBuilder
    var bannerOverlay: some View {
        VStack {
            if let shape = mapState.selectedShape,
               let country = countryDataService.country(for: shape.id) {
                CountryBannerView(
                    country: country,
                    onMoreInfo: { navigateToCountry = country },
                    onDismiss: { mapState.selectedCountryCode = nil }
                )
                .padding(.top, DesignSystem.Spacing.xxl + 56)
            }

            Spacer()
        }
        .allowsHitTesting(mapState.selectedShape != nil)
        .animation(.easeInOut(duration: 0.3), value: mapState.selectedCountryCode)
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
                wrapHorizontalOffset()
                mapState.lastOffset = mapState.offset
            }
    }
}

// MARK: - Actions

private extension MapScreen {
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
        let fitWidth = size.width / MapProjection.mapWidth
        let fitHeight = size.height / MapProjection.mapHeight
        let newMin = max(fitWidth, fitHeight)
        mapState.minScale = newMin

        if mapState.scale < newMin {
            mapState.scale = newMin
            mapState.lastScale = newMin
        }
    }

    func setInitialScale(for size: CGSize) {
        guard size.width > 0, size.height > 0 else { return }
        let fitWidth = size.width / MapProjection.mapWidth
        let fitHeight = size.height / MapProjection.mapHeight
        let fitScale = max(fitWidth, fitHeight)
        mapState.scale = fitScale
        mapState.lastScale = fitScale
        mapState.minScale = fitScale
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

        mapState.countryShapes = GeoJSONParser.parse(data: data)
    }
}
