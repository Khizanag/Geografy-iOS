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
                    }
            }

            if isLoading {
                MapLoadingView()
                    .transition(.opacity)
            }
        }
        .background(DesignSystem.Color.ocean)
        .ignoresSafeArea()
        .navigationBarHidden(true)
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

            GeometryReader { geo in
                VStack {
                    controlsBar
                        .padding(.top, geo.safeAreaInsets.top + DesignSystem.Spacing.xs)
                    Spacer()
                }
            }

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
    var controlsBar: some View {
        HStack {
            closeButton
            Spacer()
            labelsToggleButton
        }
        .padding(.horizontal, DesignSystem.Spacing.md)
    }

    var closeButton: some View {
        Button { dismiss() } label: {
            Image(systemName: "xmark")
                .font(DesignSystem.Font.headline)
                .foregroundStyle(DesignSystem.Color.textPrimary)
                .frame(width: DesignSystem.Size.xl, height: DesignSystem.Size.xl)
                .contentShape(Circle())
        }
        .glassEffect(.regular.interactive(), in: .circle)
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
                let newScale = min(max(mapState.lastScale * value.magnification, 0.15), 20.0)
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

// MARK: - Actions

private extension MapScreen {
    func setInitialScale(for size: CGSize) {
        guard size.width > 0 else { return }
        let fitScale = size.width / MapProjection.mapWidth
        mapState.scale = fitScale
        mapState.lastScale = fitScale
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
