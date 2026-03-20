import SwiftUI

struct MapScreen: View {
    @Environment(\.dismiss) private var dismiss

    @State private var mapState = MapState()
    @State private var countryDataService = CountryDataService()
    @State private var navigateToCountry: Country?

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                mapCanvas(in: geometry.size)
                controlsOverlay
                bannerOverlay
            }
            .onAppear {
                setInitialScale(for: geometry.size)
            }
        }
        .background(GeoColors.ocean)
        .ignoresSafeArea()
        .navigationBarHidden(true)
        .navigationDestination(item: $navigateToCountry) { country in
            CountryDetailScreen(country: country)
        }
        .task {
            await loadMapData()
        }
    }
}

// MARK: - Subviews

private extension MapScreen {
    func mapCanvas(in size: CGSize) -> some View {
        MapCanvasView(
            countryShapes: mapState.countryShapes,
            scale: mapState.scale,
            offset: mapState.offset,
            selectedCountryCode: mapState.selectedCountryCode,
            showLabels: mapState.showLabels,
            canvasSize: size
        )
        .simultaneousGesture(magnifyGesture)
        .simultaneousGesture(dragGesture(in: size))
        .gesture(tapGesture(in: size))
    }

    var controlsOverlay: some View {
        VStack {
            HStack {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "chevron.left")
                        .font(GeoFont.headline)
                        .foregroundStyle(GeoColors.textPrimary)
                        .frame(width: 44, height: 44)
                }
                .buttonStyle(.plain)
                .glassEffect(.regular.interactive(), in: .circle)

                Spacer()

                Button {
                    mapState.showLabels.toggle()
                } label: {
                    Text("Aa")
                        .font(GeoFont.headline)
                        .foregroundStyle(mapState.showLabels ? .white : GeoColors.textPrimary)
                        .frame(width: 44, height: 44)
                }
                .buttonStyle(.plain)
                .glassEffect(.regular.interactive(), in: .circle)
            }
            .padding(.horizontal, GeoSpacing.md)
            .padding(.top, GeoSpacing.xxl)

            Spacer()
        }
    }

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
                .padding(.top, GeoSpacing.xxl + 56)
            }

            Spacer()
        }
        .animation(.easeInOut(duration: 0.3), value: mapState.selectedCountryCode)
    }
}

// MARK: - Gestures

private extension MapScreen {
    var magnifyGesture: some Gesture {
        MagnifyGesture()
            .onChanged { value in
                let newScale = mapState.lastScale * value.magnification
                mapState.scale = min(max(newScale, 0.15), 20.0)
            }
            .onEnded { _ in
                mapState.lastScale = mapState.scale
            }
    }

    func dragGesture(in size: CGSize) -> some Gesture {
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

    func tapGesture(in size: CGSize) -> some Gesture {
        SpatialTapGesture()
            .onEnded { value in
                handleTap(at: value.location, in: size)
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
        let centerX = size.width / 2 - MapProjection.mapWidth / 2
        let centerY = size.height / 2 - MapProjection.mapHeight / 2

        let mapX = (point.x - centerX - mapState.offset.width) / mapState.scale
        let mapY = (point.y - centerY - mapState.offset.height) / mapState.scale

        let mapPoint = CGPoint(x: mapX, y: mapY)

        for shape in mapState.countryShapes.reversed() {
            if shape.polygons.contains(where: { $0.contains(mapPoint) }) {
                mapState.selectedCountryCode = shape.id
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
