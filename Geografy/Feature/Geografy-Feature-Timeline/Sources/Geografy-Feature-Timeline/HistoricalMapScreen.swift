#if !os(tvOS)
import Geografy_Core_Common
import Geografy_Core_DesignSystem
import Geografy_Core_Service
import Geografy_Feature_Map
import SwiftUI

public struct HistoricalMapScreen: View {
    // MARK: - Init
    public init(
        initialYear: Int
    ) {
        self.initialYear = initialYear
    }
    // MARK: - Properties
    @Environment(\.verticalSizeClass) private var verticalSizeClass
    #if !os(tvOS)
    @Environment(HapticsService.self) private var hapticsService
    #endif
    @Environment(CountryDataService.self) private var countryDataService
    @Environment(GeoJSONCache.self) private var geoJSONCache

    public let initialYear: Int

    @State private var mapState = MapState()
    @State private var timelineService = TimelineService()
    @State private var selectedYear = 1_960
    @State private var allShapes: [CountryShape] = []
    @State private var independenceMap: [String: Int] = [:]
    @State private var selectedEvent: HistoricalEvent?
    @State private var screenSize: CGSize = .zero
    @State private var isInitialized = false

    // MARK: - Body
    public var body: some View {
        mapLayer
            .background(DesignSystem.Color.ocean)
            .ignoresSafeArea()
            .navigationTitle("Historical Map")
            #if !os(tvOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .overlay(alignment: .bottom) { footerOverlay }
            .toolbarBackground(.clear, for: .navigationBar)
            .task { await loadData() }
            .onAppear { selectedYear = initialYear }
            .onChange(of: selectedYear) { updateCountryColors() }
            .sheet(item: $selectedEvent) { eventSheet(for: $0) }
    }
}

// MARK: - Subviews
private extension HistoricalMapScreen {
    var mapLayer: some View {
        ZStack {
            GeometryReader { geometry in
                mapContent(in: geometry.size)
                    .onAppear { screenSize = geometry.size }
                    .onChange(of: geometry.size) { _, newSize in
                        screenSize = newSize
                        updateMinScale(for: newSize)
                    }
            }

            if allShapes.isEmpty {
                MapLoadingView()
                    .transition(.opacity)
            }
        }
    }

    func mapContent(in size: CGSize) -> some View {
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
        .onTapGesture { location in
            handleTap(at: location, in: size)
        }
    }

    var footerOverlay: some View {
        VStack(spacing: 0) {
            selectedCountryBanner

            TimelineSlider(
                selectedYear: $selectedYear,
                range: 1_800...2_025,
                decades: [],
                eventCountForDecade: { _ in 0 },
                accessoryLabel: "\(independentCountryCount) independent"
            )
        }
    }

    @ViewBuilder
    var selectedCountryBanner: some View {
        if let code = mapState.selectedCountryCode,
           let shape = mapState.selectedShape {
            historicalBanner(for: code, shape: shape)
                .transition(.move(edge: .bottom).combined(with: .opacity))
        }
    }

    func historicalBanner(
        for code: String,
        shape: CountryShape
    ) -> some View {
        let country = countryDataService.country(for: code)
        let independenceYear = independenceMap[code]

        return CardView {
            HStack(spacing: DesignSystem.Spacing.sm) {
                FlagView(
                    countryCode: code,
                    height: DesignSystem.Size.xl
                )
                VStack(alignment: .leading, spacing: DesignSystem.Spacing.xxs) {
                    Text(country?.name ?? shape.name)
                        .font(DesignSystem.Font.headline)
                        .foregroundStyle(DesignSystem.Color.textPrimary)
                        .lineLimit(1)
                    independenceLabel(year: independenceYear)
                }
                Spacer(minLength: 0)
                if let year = independenceYear {
                    eventInfoButton(code: code, year: year)
                }
            }
            .padding(DesignSystem.Spacing.md)
        }
        .padding(.horizontal, DesignSystem.Spacing.sm)
        .padding(.bottom, DesignSystem.Spacing.xxs)
        .animation(.easeInOut(duration: 0.3), value: code)
    }

    func independenceLabel(year: Int?) -> some View {
        Group {
            if let year {
                Text("Independent since \(String(year))")
                    .foregroundStyle(DesignSystem.Color.accent)
            } else {
                Text("Historical state unknown")
                    .foregroundStyle(DesignSystem.Color.textTertiary)
            }
        }
        .font(DesignSystem.Font.caption)
    }

    func eventInfoButton(code: String, year: Int) -> some View {
        Button {
            selectedEvent = timelineService.events
                .first { $0.countryCode == code && $0.year == year }
        } label: {
            Image(systemName: "info.circle")
                .font(DesignSystem.Font.title2)
                .foregroundStyle(DesignSystem.Color.accent)
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Event details")
    }
}

// MARK: - Event Sheet
private extension HistoricalMapScreen {
    func eventSheet(for event: HistoricalEvent) -> some View {
        eventSheetContent(for: event)
            .navigationTitle("Event Details")
            #if !os(tvOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .presentationDetents([.medium])
    }

    func eventSheetContent(for event: HistoricalEvent) -> some View {
        ScrollView {
            VStack(
                alignment: .leading,
                spacing: DesignSystem.Spacing.lg
            ) {
                eventHeader(for: event)
                eventDescription(for: event)
            }
            .padding(DesignSystem.Spacing.md)
            .readableContentWidth()
        }
        .background(DesignSystem.Color.background)
    }

    func eventHeader(for event: HistoricalEvent) -> some View {
        HStack(spacing: DesignSystem.Spacing.sm) {
            FlagView(
                countryCode: event.countryCode,
                height: DesignSystem.Size.xxl
            )
            VStack(
                alignment: .leading,
                spacing: DesignSystem.Spacing.xxs
            ) {
                Text(event.title)
                    .font(DesignSystem.Font.title2)
                    .foregroundStyle(DesignSystem.Color.textPrimary)
                Text(event.formattedDate)
                    .font(DesignSystem.Font.subheadline)
                    .foregroundStyle(DesignSystem.Color.textSecondary)
            }
        }
    }

    func eventDescription(for event: HistoricalEvent) -> some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
            SectionHeaderView(title: "About")
            Text(event.description)
                .font(DesignSystem.Font.body)
                .foregroundStyle(DesignSystem.Color.textPrimary)
        }
    }
}

// MARK: - Gestures
private extension HistoricalMapScreen {
    var magnifyGesture: some Gesture {
        MagnifyGesture()
            .onChanged { value in
                let newScale = min(
                    max(mapState.lastScale * value.magnification, mapState.minScale),
                    20.0
                )
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
private extension HistoricalMapScreen {
    func handleTap(at point: CGPoint, in size: CGSize) {
        let originX = size.width / 2
            - (MapProjection.mapWidth * mapState.scale) / 2
            + mapState.offset.width
        let originY = size.height / 2
            - (MapProjection.mapHeight * mapState.scale) / 2
            + mapState.offset.height

        let mapPoint = CGPoint(
            x: (point.x - originX) / mapState.scale,
            y: (point.y - originY) / mapState.scale
        )

        let sortedByArea = mapState.countryShapes.sorted {
            $0.boundingBox.width * $0.boundingBox.height
                < $1.boundingBox.width * $1.boundingBox.height
        }

        for shape in sortedByArea where shape.polygons.contains(where: { $0.contains(mapPoint) }) {
            if mapState.selectedCountryCode == shape.id {
                mapState.selectedCountryCode = nil
            } else {
                mapState.selectedCountryCode = shape.id
            }
            #if !os(tvOS)
            hapticsService.impact(.medium)
            #endif
            return
        }

        mapState.selectedCountryCode = nil
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
        let fitWidth = size.width / MapProjection.mapWidth
        mapState.minScale = fitWidth

        if mapState.scale < fitWidth {
            mapState.scale = fitWidth
            mapState.lastScale = fitWidth
        }
    }

    func setInitialScale(for size: CGSize) {
        guard size.width > 0, size.height > 0 else { return }
        let fitScale = size.width / MapProjection.mapWidth
        mapState.scale = fitScale
        mapState.lastScale = fitScale
        mapState.minScale = fitScale

        let bounds = mapState.contentBounds
        guard bounds.width > 0, bounds.height > 0 else { return }
        let centerX = (bounds.minX + bounds.maxX) / 2
        let centerY = (bounds.minY + bounds.maxY) / 2
        let mapCenterX = MapProjection.mapWidth / 2
        let mapCenterY = MapProjection.mapHeight / 2
        mapState.offset = CGSize(
            width: (mapCenterX - centerX) * fitScale,
            height: (mapCenterY - centerY) * fitScale
        )
        mapState.lastOffset = mapState.offset
    }
}

// MARK: - Data Loading
private extension HistoricalMapScreen {
    func loadData() async {
        timelineService.loadEvents()
        buildIndependenceMap()

        let shapes = await geoJSONCache.loadShapes()

        guard !shapes.isEmpty else { return }

        allShapes = shapes
        mapState.contentBounds = computeContentBounds(from: shapes)
        applyColorsForYear(shapes: shapes)

        if screenSize.width > 0, !isInitialized {
            setInitialScale(for: screenSize)
            isInitialized = true
        }
    }

    func buildIndependenceMap() {
        for event in timelineService.events {
            guard event.type == .independence || event.type == .formation
            else { continue }

            if let existing = independenceMap[event.countryCode] {
                independenceMap[event.countryCode] = min(existing, event.year)
            } else {
                independenceMap[event.countryCode] = event.year
            }
        }
    }

    func updateCountryColors() {
        guard !allShapes.isEmpty else { return }
        applyColorsForYear(shapes: allShapes)
    }

    func applyColorsForYear(shapes: [CountryShape]) {
        let dimmedColor = SwiftUI.Color(hex: "3A3A3A")

        let colored = shapes
            .map { shape -> CountryShape in
                let isIndependent: Bool
                if let year = independenceMap[shape.id] {
                    isIndependent = year <= selectedYear
                } else {
                    isIndependent = true
                }

                return CountryShape(
                    id: shape.id,
                    name: shape.name,
                    continent: shape.continent,
                    polygons: shape.polygons,
                    centroid: shape.centroid,
                    boundingBox: shape.boundingBox,
                    color: isIndependent ? shape.color : dimmedColor
                )
            }

        withAnimation(.easeInOut(duration: 0.2)) {
            mapState.countryShapes = colored
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

// MARK: - Helpers
private extension HistoricalMapScreen {
    var independentCountryCount: Int {
        allShapes.count { shape in
            if let year = independenceMap[shape.id] {
                year <= selectedYear
            } else {
                true
            }
        }
    }
}

#endif
