import GeografyCore
import GeografyDesign
import SwiftUI

struct MapScreen: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(TravelService.self) private var travelService

    let countryDataService: CountryDataService

    @State private var mapState = MapState()
    @State private var isLoading = true
    @State private var selectedCountry: Country?
    @State private var showCountryDetail = false
    @State private var panVelocity: CGSize = .zero
    @FocusState private var isMapFocused: Bool

    private let panSpeed: CGFloat = 30
    private let zoomStep: CGFloat = 0.3

    var body: some View {
        ZStack {
            if isLoading {
                loadingView
            } else {
                mapContent
            }
        }
        .navigationTitle("World Map")
        .task { await loadMap() }
        .sheet(isPresented: $showCountryDetail) {
            if let selectedCountry {
                NavigationStack {
                    CountryDetailScreen(country: selectedCountry)
                        .toolbar {
                            ToolbarItem(placement: .cancellationAction) {
                                Button("Done") { showCountryDetail = false }
                            }
                        }
                }
            }
        }
    }
}

// MARK: - Map Content
private extension MapScreen {
    var mapContent: some View {
        GeometryReader { geometry in
            ZStack {
                Color.black.ignoresSafeArea()

                MapCanvasView(
                    countryShapes: mapState.countryShapes,
                    scale: mapState.scale,
                    offset: mapState.offset,
                    selectedCountryCode: mapState.selectedCountryCode,
                    showLabels: mapState.showLabels,
                    canvasSize: geometry.size,
                    travelStatuses: travelService.entries,
                )

                controlsOverlay

                if let selectedCountry {
                    countryBanner(selectedCountry)
                }
            }
        }
        .focusable(true)
        .focused($isMapFocused)
        .onAppear { isMapFocused = true }
        .onMoveCommand { direction in
            handlePan(direction)
        }
        .onPlayPauseCommand {
            handleSelect()
        }
        .onExitCommand {
            if mapState.selectedCountryCode != nil {
                mapState.selectedCountryCode = nil
                selectedCountry = nil
            }
        }
    }
}

// MARK: - Controls Overlay
private extension MapScreen {
    var controlsOverlay: some View {
        VStack {
            Spacer()

            HStack {
                Spacer()

                VStack(spacing: 12) {
                    Button {
                        withAnimation(.easeOut(duration: 0.2)) {
                            mapState.scale = min(mapState.scale * (1 + zoomStep), 20.0)
                        }
                    } label: {
                        Image(systemName: "plus")
                            .font(.system(size: 24, weight: .bold))
                            .frame(width: 52, height: 52)
                    }
                    .buttonStyle(.bordered)

                    Button {
                        withAnimation(.easeOut(duration: 0.2)) {
                            mapState.scale = max(mapState.scale * (1 - zoomStep), mapState.minScale)
                        }
                    } label: {
                        Image(systemName: "minus")
                            .font(.system(size: 24, weight: .bold))
                            .frame(width: 52, height: 52)
                    }
                    .buttonStyle(.bordered)

                    Button {
                        mapState.showLabels.toggle()
                    } label: {
                        Image(systemName: mapState.showLabels ? "textformat" : "textformat.slash")
                            .font(.system(size: 20))
                            .frame(width: 52, height: 52)
                    }
                    .buttonStyle(.bordered)

                    Button {
                        withAnimation(.easeOut(duration: 0.3)) {
                            mapState.scale = mapState.minScale
                            mapState.offset = .zero
                        }
                    } label: {
                        Image(systemName: "arrow.counterclockwise")
                            .font(.system(size: 20))
                            .frame(width: 52, height: 52)
                    }
                    .buttonStyle(.bordered)
                }
                .padding(24)
            }
        }
    }
}

// MARK: - Country Banner
private extension MapScreen {
    func countryBanner(_ country: Country) -> some View {
        VStack {
            HStack(spacing: 24) {
                FlagView(countryCode: country.code, height: 60)

                VStack(alignment: .leading, spacing: 4) {
                    Text(country.name)
                        .font(.system(size: 28, weight: .bold))
                        .foregroundStyle(.white)

                    Text(country.capital)
                        .font(.system(size: 22))
                        .foregroundStyle(.white.opacity(0.7))
                }

                Spacer()

                Button {
                    showCountryDetail = true
                } label: {
                    Label("Details", systemImage: "info.circle")
                        .font(.system(size: 20, weight: .semibold))
                }
                .buttonStyle(.bordered)
            }
            .padding(24)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20))
            .padding(.horizontal, 80)
            .padding(.top, 40)

            Spacer()
        }
    }
}

// MARK: - Loading
private extension MapScreen {
    var loadingView: some View {
        VStack(spacing: 24) {
            ProgressView()
                .scaleEffect(2)

            Text("Loading World Map…")
                .font(.system(size: 28))
                .foregroundStyle(DesignSystem.Color.textSecondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(DesignSystem.Color.background)
    }
}

// MARK: - Input Handling
private extension MapScreen {
    func handlePan(_ direction: MoveCommandDirection) {
        withAnimation(.easeOut(duration: 0.15)) {
            switch direction {
            case .left:
                mapState.offset.width += panSpeed
            case .right:
                mapState.offset.width -= panSpeed
            case .up:
                mapState.offset.height += panSpeed
            case .down:
                mapState.offset.height -= panSpeed
            @unknown default:
                break
            }
        }
    }

    func handleSelect() {
        guard !mapState.countryShapes.isEmpty else { return }

        if mapState.selectedCountryCode != nil {
            showCountryDetail = true
            return
        }

        selectCountryAtCenter()
    }

    func selectCountryAtCenter() {
        let centerX = CGFloat(1024)
        let centerY = CGFloat(1024)
        let mapPoint = CGPoint(
            x: (centerX - mapState.offset.width) / mapState.scale,
            y: (centerY - mapState.offset.height) / mapState.scale
        )

        let sortedShapes = mapState.countryShapes.sorted {
            $0.boundingBox.width * $0.boundingBox.height < $1.boundingBox.width * $1.boundingBox.height
        }

        for shape in sortedShapes {
            for polygon in shape.polygons {
                if polygon.contains(mapPoint) {
                    mapState.selectedCountryCode = shape.id
                    selectedCountry = countryDataService.countries.first { $0.code == shape.id }
                    return
                }
            }
        }
    }
}

// MARK: - Data Loading
private extension MapScreen {
    func loadMap() async {
        let shapes = await Task.detached(priority: .userInitiated) {
            guard let url = Bundle.main.url(forResource: "countries", withExtension: "geojson"),
                  let data = try? Data(contentsOf: url) else {
                return [CountryShape]()
            }
            return GeoJSONParser.parse(data: data)
        }.value

        await MainActor.run {
            withAnimation(.easeOut(duration: 0.3)) {
                mapState.countryShapes = shapes
                computeInitialScale()
                isLoading = false
            }
        }
    }

    func computeInitialScale() {
        guard !mapState.countryShapes.isEmpty else { return }

        var minX = CGFloat.infinity
        var minY = CGFloat.infinity
        var maxX = -CGFloat.infinity
        var maxY = -CGFloat.infinity

        for shape in mapState.countryShapes {
            let box = shape.boundingBox
            minX = min(minX, box.minX)
            minY = min(minY, box.minY)
            maxX = max(maxX, box.maxX)
            maxY = max(maxY, box.maxY)
        }

        mapState.contentBounds = CGRect(x: minX, y: minY, width: maxX - minX, height: maxY - minY)

        let screenWidth: CGFloat = 1920
        let screenHeight: CGFloat = 1080
        let scaleX = screenWidth / (maxX - minX)
        let scaleY = screenHeight / (maxY - minY)
        let fitScale = min(scaleX, scaleY) * 0.9

        mapState.minScale = fitScale
        mapState.scale = fitScale

        let centerX = (minX + maxX) / 2
        let centerY = (minY + maxY) / 2
        mapState.offset = CGSize(
            width: screenWidth / 2 - centerX * fitScale,
            height: screenHeight / 2 - centerY * fitScale
        )
    }
}
