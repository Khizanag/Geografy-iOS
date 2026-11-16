#if !os(tvOS)
import Geografy_Core_Common
import Geografy_Core_DesignSystem
import Geografy_Core_Map
import Geografy_Core_Navigation
import Geografy_Core_Service
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
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
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
    @State private var dimmedCodes: Set<String> = []
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
            .onChange(of: mapState.selectedCountryCode) { _, code in
                announceSelection(of: code)
            }
            .sheet(item: $selectedEvent) { event in
                CoordinatedNavigationStack(showCloseButton: true) {
                    eventSheet(for: event)
                }
            }
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
        HistoricalMapCanvas(mapState: mapState, canvasSize: size)
            .accessibilityLabel("Historical map, \(String(selectedYear))")
            .accessibilityValue(selectedCountryDescription.map { "Selected: \($0)" } ?? "No country selected")
            .accessibilityHint("Double tap to select a country")
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
                .transition(reduceMotion ? .opacity : .move(edge: .bottom).combined(with: .opacity))
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
                .accessibilityHidden(true)
                VStack(alignment: .leading, spacing: DesignSystem.Spacing.xxs) {
                    Text(country?.name ?? shape.name)
                        .font(DesignSystem.Font.headline)
                        .foregroundStyle(DesignSystem.Color.textPrimary)
                        .lineLimit(1)
                    independenceLabel(year: independenceYear)
                }
                .accessibilityElement(children: .combine)
                Spacer(minLength: 0)
                if let year = independenceYear {
                    eventInfoButton(code: code, year: year)
                }
            }
            .padding(DesignSystem.Spacing.md)
        }
        .padding(.horizontal, DesignSystem.Spacing.sm)
        .padding(.bottom, DesignSystem.Spacing.xxs)
        .animation(reduceMotion ? nil : .easeInOut(duration: 0.3), value: code)
    }

    func independenceLabel(year: Int?) -> some View {
        Group {
            if let year {
                Text("Independent since \(String(year))")
                    .foregroundStyle(DesignSystem.Color.accent)
            } else {
                Text("Historical state unknown")
                    .foregroundStyle(DesignSystem.Color.textSecondary)
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

    var selectedCountryDescription: String? {
        guard let shape = mapState.selectedShape else { return nil }
        let name = countryDataService.country(for: shape.id)?.name ?? shape.name
        guard let year = independenceMap[shape.id] else { return name }
        return "\(name), independent since \(String(year))"
    }

    func announceSelection(of code: String?) {
        guard code != nil, let description = selectedCountryDescription else { return }
        AccessibilityNotification.Announcement("Selected \(description)").post()
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
    }

    func eventSheetContent(for event: HistoricalEvent) -> some View {
        VStack(
            alignment: .leading,
            spacing: DesignSystem.Spacing.lg
        ) {
            eventHeader(for: event)
            eventDescription(for: event)
        }
        .padding(DesignSystem.Spacing.md)
        .readableContentWidth()
        .fittedSheet()
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
                clampOffset()
                mapState.lastScale = mapState.scale
                mapState.lastOffset = mapState.offset
            }
    }

    /// Keeps the map's land on screen; the historical map doesn't repeat sideways.
    func clampOffset() {
        mapState.clampOffset(
            to: MapProjection.worldBounds(around: mapState.contentBounds),
            in: screenSize,
            horizontally: true
        )
    }

    var dragGesture: some Gesture {
        DragGesture()
            .onChanged { value in
                mapState.offset = CGSize(
                    width: mapState.lastOffset.width + value.translation.width,
                    height: mapState.lastOffset.height + value.translation.height
                )
                clampOffset()
            }
            .onEnded { _ in
                mapState.lastOffset = mapState.offset
            }
    }
}

// MARK: - Actions
private extension HistoricalMapScreen {
    func handleTap(at point: CGPoint, in size: CGSize) {
        let mapPoint = mapState.mapPoint(for: point, in: size, wrapping: false)
        if let shape = mapState.shape(at: mapPoint) {
            if mapState.selectedCountryCode == shape.id {
                mapState.selectedCountryCode = nil
            } else {
                mapState.selectedCountryCode = shape.id
            }
            #if !os(tvOS)
            hapticsService.selection()
            #endif
            return
        }

        mapState.selectedCountryCode = nil
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

        mapState.center(on: mapState.contentBounds)
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
        mapState.contentBounds = MapState.bounds(of: shapes)
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

    /// Most year steps change no country's status, so the map is recolored only when the dimmed set changes.
    func applyColorsForYear(shapes: [CountryShape]) {
        let dimmed = Set(shapes.lazy.filter { !isIndependent($0.id) }.map(\.id))
        guard dimmed != dimmedCodes || mapState.countryShapes.isEmpty else { return }
        dimmedCodes = dimmed

        let dimmedColor = DesignSystem.Color.mapLandMuted
        mapState.countryShapes = shapes.map { shape in
            dimmed.contains(shape.id) ? shape.recolored(dimmedColor) : shape
        }
    }
}

// MARK: - Helpers
private extension HistoricalMapScreen {
    var independentCountryCount: Int {
        allShapes.count { isIndependent($0.id) }
    }

    func isIndependent(_ code: String) -> Bool {
        guard let year = independenceMap[code] else { return true }
        return year <= selectedYear
    }
}

#endif
