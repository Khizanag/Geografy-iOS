import Geografy_Core_Common
import Geografy_Core_DesignSystem
import Geografy_Core_Map
import Geografy_Core_Navigation
import Geografy_Core_Service
import SwiftUI

public struct OrganizationMapScreen: View {
    // MARK: - Properties
    @Environment(\.verticalSizeClass) private var verticalSizeClass
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(Navigator.self) private var coordinator
    @Environment(CountryDataService.self) private var countryDataService
    @Environment(GeoJSONCache.self) private var geoJSONCache

    public let organization: Organization

    // MARK: - Init
    public init(organization: Organization) {
        self.organization = organization
    }

    @State private var mapState = MapState()
    @State private var navigateToCountry: Country?
    @Namespace private var flagNamespace
    @State private var showFlagPreview = false
    @State private var screenSize: CGSize = .zero
    @State private var isInitialized = false
    @State private var memberCount = 0

    private let nonMemberColor = DesignSystem.Color.mapLandMuted

    // MARK: - Body
    public var body: some View {
        extractedContent
            .background(DesignSystem.Color.ocean)
            .ignoresSafeArea()
            .safeAreaInset(edge: .top) {
                if !isLandscape {
                    orgHeader
                }
            }
            .safeAreaInset(edge: .bottom) {
                if !isLandscape {
                    bannerOverlay
                        .padding(.bottom, DesignSystem.Spacing.xs)
                        .animation(reduceMotion ? nil : .easeInOut(duration: 0.3), value: mapState.selectedCountryCode)
                }
            }
            .closeButtonPlacementLeading()
            .toolbarBackground(.clear, for: .navigationBar)
            .toolbar { toolbarContent }
            .haptic(.selection, trigger: mapState.selectedCountryCode)
            .haptic(.impact(weight: .light), trigger: mapState.showLabels)
            .task { await loadMapData() }
            .onChange(of: navigateToCountry) { _, country in
                if let country {
                    coordinator.push(CountryRoute.countryDetail(country))
                    navigateToCountry = nil
                }
            }
            .zoomableViewer(isPresented: $showFlagPreview, title: mapState.selectedShape?.name) {
                if let code = mapState.selectedCountryCode {
                    ZoomableFlagView(countryCode: code) { showFlagPreview = false }
                }
            }
    }
}

// MARK: - Subviews
private extension OrganizationMapScreen {
    var extractedContent: some View {
        ZStack {
            GeometryReader { geometry in
                mapCanvas(in: geometry.size)
                    .onAppear { screenSize = geometry.size }
                    .onChange(of: geometry.size) { _, newSize in
                        screenSize = newSize
                        updateMinScale(for: newSize)
                    }
            }
            if mapState.countryShapes.isEmpty {
                MapLoadingView()
                    .transition(.opacity)
            }
        }
    }

    var isLandscape: Bool { verticalSizeClass == .compact }

    var landscapeHeader: some View {
        VStack(spacing: DesignSystem.Spacing.sm) {
            orgHeader
            bannerOverlay
        }
    }

    func mapCanvas(in size: CGSize) -> some View {
        InteractiveMapViewport(
            mapState: mapState,
            viewSize: size,
            bounds: MapProjection.worldBounds(around: mapState.contentBounds),
            wrapsHorizontally: wrapsWorld,
            onTap: { handleTap(at: $0, in: size) },
            canvas: { frame, canvasSize in
                MapCanvasView(
                    countryShapes: mapState.countryShapes,
                    scale: frame.scale,
                    offset: frame.offset,
                    selectedCountryCode: mapState.selectedCountryCode,
                    showLabels: mapState.showLabels,
                    canvasSize: canvasSize,
                    capitalPoint: selectedCapitalPoint,
                    wrapsHorizontally: wrapsWorld
                )
            }
        )
        .accessibilityLabel("Map of \(organization.displayName) members")
        .accessibilityValue(selectedCountryName.map { "Selected: \($0)" } ?? "No country selected")
        .accessibilityHint("Double tap to select a country")
    }

    var selectedCountryName: String? {
        guard let shape = mapState.selectedShape else { return nil }
        return countryDataService.country(for: shape.id)?.name ?? shape.name
    }

    var selectedCapitalPoint: CGPoint? {
        guard let code = mapState.selectedCountryCode,
              let coordinate = countryDataService.country(for: code)?.capitalCoordinate
                ?? MapTerritory.info(for: code)?.capitalCoordinate else { return nil }
        return MapProjection.project(coordinate)
    }
}

// MARK: - Toolbar
private extension OrganizationMapScreen {
    @ToolbarContentBuilder
    var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .principal) {
            if isLandscape {
                landscapeHeader
                    .frame(width: CountryBannerView.landscapeWidth)
                    .animation(reduceMotion ? nil : .easeInOut(duration: 0.3), value: mapState.selectedCountryCode)
            }
        }
        ToolbarItem(placement: .primaryAction) {
            ToolbarToggle("Country labels", systemImage: "textformat", isOn: mapState.showLabels) {
                mapState.showLabels.toggle()
            }
        }
        .sharedBackgroundVisibility(.hidden)
    }
}

// MARK: - Org Header
private extension OrganizationMapScreen {
    var orgHeader: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            orgHeaderContent
            legend
        }
        .padding(.horizontal, DesignSystem.Spacing.md)
        .padding(.vertical, DesignSystem.Spacing.sm)
        .glassEffect(.regular, in: RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.large, style: .continuous))
        .padding(.horizontal, DesignSystem.Spacing.md)
        .padding(.top, DesignSystem.Spacing.xxs)
    }

    var orgHeaderContent: some View {
        HStack(alignment: .top, spacing: DesignSystem.Spacing.sm) {
            IconBadge(organization.icon, color: organization.highlightColor, size: .small)

            VStack(alignment: .leading, spacing: DesignSystem.Spacing.xxs) {
                Text(organization.displayName)
                    .font(DesignSystem.Font.headline)
                    .foregroundStyle(DesignSystem.Color.textPrimary)

                if organization.fullName != organization.displayName {
                    Text(organization.fullName)
                        .font(DesignSystem.Font.caption)
                        .foregroundStyle(DesignSystem.Color.textSecondary)
                        .multilineTextAlignment(.leading)
                        .lineLimit(nil)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            memberCountBadge
        }
    }

    var memberCountBadge: some View {
        InfoPill("\(memberCount) members", style: .tinted(organization.highlightColor))
            .lineLimit(1)
            .fixedSize(horizontal: true, vertical: false)
    }

    var legend: some View {
        HStack(spacing: DesignSystem.Spacing.sm) {
            legendDot(color: organization.highlightColor, label: "Member")
            legendDot(color: DesignSystem.Color.textTertiary, label: "Other")
        }
    }

    func legendDot(color: Color, label: String) -> some View {
        HStack(spacing: DesignSystem.Spacing.xxs) {
            Circle()
                .fill(color)
                .frame(width: 8, height: 8)
            Text(label)
                .font(DesignSystem.Font.caption2)
                .foregroundStyle(DesignSystem.Color.textSecondary)
        }
    }
}

// MARK: - Banner
private extension OrganizationMapScreen {
    @ViewBuilder
    var bannerOverlay: some View {
        if let shape = mapState.selectedShape {
            let country = countryDataService.country(for: shape.id)
            let territory = MapTerritory.info(for: shape.id)

            CountryBannerView(
                countryCode: shape.id,
                name: country?.name ?? shape.name,
                flag: country?.flagEmoji ?? territory?.flag ?? "🏳️",
                capital: country?.capital ?? territory?.capital ?? "",
                namespace: flagNamespace,
                isFlagHidden: showFlagPreview,
                onFlagTap: {
                    withAnimation(reduceMotion ? nil : .spring(response: 0.35, dampingFraction: 0.85)) {
                        showFlagPreview = true
                    }
                },
                onMoreInfo: country != nil ? { navigateToCountry = country } : nil,
                isCompact: isLandscape,
                onDismiss: { mapState.selectedCountryCode = nil }
            )
            .transition(reduceMotion ? .opacity : .move(edge: .bottom).combined(with: .opacity))
        }
    }
}

// MARK: - Actions
private extension OrganizationMapScreen {
    func handleTap(at point: CGPoint, in size: CGSize) {
        let mapPoint = mapState.mapPoint(for: point, in: size, wrapping: wrapsWorld)
        if let shape = mapState.shape(at: mapPoint) {
            if mapState.selectedCountryCode == shape.id {
                mapState.selectedCountryCode = nil
            } else {
                mapState.selectedCountryCode = shape.id
            }
            return
        }
        mapState.selectedCountryCode = nil
    }

    /// Only Mercator's rectangular world repeats sideways; Equal Earth's curved edges can't meet.
    var wrapsWorld: Bool { MapProjection.current == .mercator }

    func clampOffset() {
        mapState.clampOffset(
            to: MapProjection.worldBounds(around: mapState.contentBounds),
            in: screenSize,
            horizontally: !wrapsWorld
        )
    }

    func updateMinScale(for size: CGSize) {
        guard size.width > 0, size.height > 0 else { return }
        let newMin = computeMinScale(for: size)
        mapState.minScale = newMin
        if mapState.scale < newMin {
            mapState.scale = newMin
            mapState.lastScale = newMin
        }
        mapState.center(on: mapState.contentBounds)
        clampOffset()
        mapState.lastOffset = mapState.offset
    }

    func loadMapData() async {
        let memberCodes = Set(
            countryDataService.countries
                .filter { $0.organizations.contains(organization.id) }
                .map { $0.code }
        )
        memberCount = memberCodes.count

        let highlightColor = organization.highlightColor
        let dimColor = nonMemberColor

        var shapes = await geoJSONCache.loadShapes()
        for i in shapes.indices {
            shapes[i].color = memberCodes.contains(shapes[i].id) ? highlightColor : dimColor
        }

        guard !shapes.isEmpty else { return }

        mapState.contentBounds = MapState.bounds(of: shapes)

        withAnimation(reduceMotion ? nil : .easeOut(duration: 0.3)) {
            mapState.countryShapes = shapes
        }

        if screenSize.width > 0, !isInitialized {
            let fitScale = computeMinScale(for: screenSize)
            mapState.scale = fitScale
            mapState.lastScale = fitScale
            mapState.minScale = fitScale
            mapState.center(on: mapState.contentBounds)
            isInitialized = true
        }
    }
}

// MARK: - Helpers
private extension OrganizationMapScreen {
    func computeMinScale(for size: CGSize) -> CGFloat {
        let fitWidth = size.width / MapProjection.mapWidth
        let isLandscape = size.width > size.height
        if isLandscape {
            let bounds = mapState.contentBounds
            guard bounds.height > 0 else { return fitWidth }
            let fitContentHeight = size.height / bounds.height
            return max(fitWidth, fitContentHeight)
        }
        return fitWidth
    }
}
