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

    init(filter: TravelMapFilter) {
        self.filter = filter
        self._selectedFilter = State(initialValue: filter)
    }

    var body: some View {
        ZStack {
            GeometryReader { geometry in
                mapCanvas(in: geometry.size)
                    .onAppear {
                        screenSize = geometry.size
                    }
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
        .toolbarBackground(.ultraThinMaterial, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                GeoCircleCloseButton()
            }
            ToolbarItem(placement: .topBarTrailing) {
                filterMenu
            }
        }
        .safeAreaInset(edge: .bottom) {
            legendBar
        }
        .task { await loadMapData() }
    }
}

// MARK: - Map

private extension TravelMapScreen {
    func mapCanvas(in size: CGSize) -> some View {
        MapCanvasView(
            countryShapes: mapState.countryShapes,
            scale: mapState.scale,
            offset: mapState.offset,
            selectedCountryCode: nil,
            showLabels: true,
            canvasSize: size,
            capitalPoint: nil,
            travelStatuses: highlightedStatuses
        )
    }

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
}

// MARK: - Toolbar

private extension TravelMapScreen {
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

// MARK: - Legend

private extension TravelMapScreen {
    var legendBar: some View {
        HStack(spacing: DesignSystem.Spacing.lg) {
            legendItem(color: TravelStatus.visited.color, label: "Visited", count: travelService.visitedCodes.count)
            legendItem(color: TravelStatus.wantToVisit.color, label: "Want to Visit", count: travelService.wantToVisitCodes.count)
        }
        .padding(.vertical, DesignSystem.Spacing.sm)
        .padding(.horizontal, DesignSystem.Spacing.lg)
        .background(.ultraThinMaterial)
    }

    func legendItem(color: Color, label: String, count: Int) -> some View {
        HStack(spacing: DesignSystem.Spacing.xs) {
            Circle()
                .fill(color)
                .frame(width: DesignSystem.Spacing.sm, height: DesignSystem.Spacing.sm)

            Text(label)
                .font(DesignSystem.Font.caption)
                .foregroundStyle(DesignSystem.Color.textSecondary)

            Text("\(count)")
                .font(DesignSystem.Font.caption)
                .fontWeight(.bold)
                .foregroundStyle(DesignSystem.Color.textPrimary)
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
