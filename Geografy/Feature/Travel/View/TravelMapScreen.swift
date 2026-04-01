import Geografy_Core_Navigation
import Geografy_Feature_Map
import Geografy_Core_Service
import Geografy_Core_Common
import Geografy_Core_DesignSystem
import SwiftUI

struct TravelMapScreen: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(CountryDataService.self) private var countryDataService
    @Environment(HapticsService.self) private var hapticsService
    @Environment(TravelService.self) private var travelService

    let filter: TravelMapFilter

    @State private var isInitialized = false
    @State private var isLoaded = false
    @State private var mapState = MapState()
    @State private var screenSize: CGSize = .zero
    @State private var selectedFilter: TravelMapFilter
    @State private var showLabels = false

    init(filter: TravelMapFilter) {
        self.filter = filter
        self._selectedFilter = State(initialValue: filter)
    }

    var body: some View {
        extractedContent
            .background(DesignSystem.Color.ocean)
            .ignoresSafeArea()
            .navigationTitle(selectedFilter.displayName)
            .navigationBarTitleDisplayMode(.inline)
            .closeButtonPlacementLeading()
            .safeAreaInset(edge: .top) {
                if isLoaded {
                    infoBanner
                        .transition(.move(edge: .top).combined(with: .opacity))
                }
            }
            .toolbarBackground(.clear, for: .navigationBar)
            .toolbar { toolbarContent }
            .task { await loadMapData() }
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
        .accessibilityLabel("Travel map showing \(travelCodes.count) countries")
        .accessibilityHint("Pinch to zoom, drag to pan")
        .gesture(dragGesture)
        .gesture(magnifyGesture)
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
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(selectedFilter.displayName), \(travelCodes.count) countries")
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
        Button {
            showLabels.toggle()
            hapticsService.impact(.light)
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
            Picker(selection: $selectedFilter.animation()) {
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
    }
}

// MARK: - Gestures
private extension TravelMapScreen {
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

// MARK: - Helpers
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
                    modified.name = ""
                }
                return modified
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
