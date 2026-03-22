import SwiftUI

struct TravelMapScreen: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(TravelService.self) private var travelService

    let filter: TravelMapFilter

    @State private var mapState = MapState()
    @State private var countryDataService = CountryDataService()
    @State private var screenSize: CGSize = .zero
    @State private var isInitialized = false
    @State private var selectedFilter: TravelMapFilter
    @State private var showLabels = false
    @State private var isLoaded = false

    init(filter: TravelMapFilter) {
        self.filter = filter
        self._selectedFilter = State(initialValue: filter)
    }

    var body: some View {
        ZStack {
            GeometryReader { geometry in
                mapCanvas(in: geometry.size)
                    .onAppear { screenSize = geometry.size }
                    .onChange(of: geometry.size) { _, newSize in
                        screenSize = newSize
                    }
            }

            if mapState.countryShapes.isEmpty {
                MapLoadingView()
                    .transition(.opacity)
            }
        }
        .background(DesignSystem.Color.ocean)
        .ignoresSafeArea()
        .navigationTitle(selectedFilter.displayName)
        .navigationBarTitleDisplayMode(.inline)
        .safeAreaInset(edge: .top) {
            if isLoaded {
                infoBanner
                    .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
        .toolbarBackground(.clear, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                CircleCloseButton()
            }
            ToolbarItem(placement: .topBarTrailing) {
                labelsToggle
            }
            ToolbarItem(placement: .topBarTrailing) {
                filterMenu
            }
        }
        .task { await loadMapData() }
    }
}

// MARK: - Map

private extension TravelMapScreen {
    func mapCanvas(in size: CGSize) -> some View {
        MapCanvasView(
            countryShapes: styledShapes,
            scale: mapState.scale,
            offset: mapState.offset,
            selectedCountryCode: nil,
            showLabels: showLabels,
            canvasSize: size,
            capitalPoint: nil,
            travelStatuses: highlightedStatuses
        )
        .gesture(dragGesture)
        .gesture(magnifyGesture)
    }

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

// MARK: - Data

private extension TravelMapScreen {
    var highlightedStatuses: [String: TravelStatus] {
        switch selectedFilter {
        case .visited:
            travelService.entries.filter { $0.value == .visited }
        case .wantToVisit:
            travelService.entries.filter { $0.value == .wantToVisit }
        case .all:
            travelService.entries
        }
    }

    var travelCodes: Set<String> {
        Set(highlightedStatuses.keys)
    }

    var styledShapes: [CountryShape] {
        mapState.countryShapes
            .map { shape in
                var modified = shape
                if !travelCodes.contains(shape.id) {
                    modified.color = Color(hex: "1A1A2E").opacity(0.5)
                    // Hide labels for non-travel countries
                    modified.name = ""
                }
                return modified
            }
    }
}

// MARK: - Toolbar

private extension TravelMapScreen {
    var labelsToggle: some View {
        Button {
            showLabels.toggle()
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
        } label: {
            Text("Aa")
                .font(DesignSystem.Font.headline)
                .foregroundStyle(showLabels ? DesignSystem.Color.onAccent : DesignSystem.Color.iconPrimary)
                .padding(DesignSystem.Spacing.xs)
                .background {
                    if showLabels {
                        Circle().fill(DesignSystem.Color.accent)
                    }
                }
        }
        .buttonStyle(.plain)
    }

    var filterMenu: some View {
        Menu {
            ForEach(TravelMapFilter.allCases, id: \.self) { mapFilter in
                Button {
                    withAnimation { selectedFilter = mapFilter }
                } label: {
                    if selectedFilter == mapFilter {
                        Label(mapFilter.displayName, systemImage: "checkmark")
                    } else {
                        Text(mapFilter.displayName)
                    }
                }
            }
        } label: {
            Image(systemName: "line.3.horizontal.decrease")
                .foregroundStyle(DesignSystem.Color.iconPrimary)
        }
    }
}

// MARK: - Info Banner

private extension TravelMapScreen {
    var infoBanner: some View {
        HStack(spacing: DesignSystem.Spacing.sm) {
            Image(systemName: filterIcon)
                .font(DesignSystem.Font.headline)
                .foregroundStyle(filterColor)

            VStack(alignment: .leading, spacing: DesignSystem.Spacing.xxs) {
                Text(selectedFilter.displayName)
                    .font(DesignSystem.Font.headline)
                    .foregroundStyle(DesignSystem.Color.textPrimary)

                Text("\(travelCodes.count) countries")
                    .font(DesignSystem.Font.caption)
                    .foregroundStyle(DesignSystem.Color.textSecondary)
            }

            Spacer()
        }
        .padding(DesignSystem.Spacing.sm)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.large))
        .padding(.horizontal, DesignSystem.Spacing.md)
        .animation(.easeInOut(duration: 0.3), value: selectedFilter)
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

// MARK: - Data Loading

private extension TravelMapScreen {
    func loadMapData() async {
        countryDataService.loadCountries()

        let shapes = await Task.detached(priority: .userInitiated) { () -> [CountryShape] in
            guard let url = Bundle.main.url(forResource: "countries", withExtension: "geojson"),
                  let data = try? Data(contentsOf: url) else { return [] }
            return GeoJSONParser.parse(data: data)
        }.value

        guard !shapes.isEmpty else { return }

        mapState.contentBounds = computeContentBounds(from: shapes)

        withAnimation(.easeOut(duration: 0.3)) {
            mapState.countryShapes = shapes
        }

        if screenSize.width > 0, !isInitialized {
            let fitScale = screenSize.width / MapProjection.mapWidth
            mapState.scale = fitScale
            mapState.lastScale = fitScale
            mapState.minScale = fitScale
            isInitialized = true
        }

        withAnimation(.easeInOut(duration: 0.4).delay(0.3)) {
            isLoaded = true
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
