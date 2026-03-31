import SwiftUI
import GeografyDesign
import GeografyCore

struct OrganizationMapScreen: View {
    @Environment(\.verticalSizeClass) private var verticalSizeClass
    @Environment(HapticsService.self) private var hapticsService

    let organization: Organization

    @State private var mapState = MapState()
    @State private var countryDataService = CountryDataService()
    @State private var navigateToCountry: Country?
    @Namespace private var flagNamespace

    @State private var showFlagPreview = false
    @State private var screenSize: CGSize = .zero
    @State private var isInitialized = false
    @State private var memberCount = 0

    private let nonMemberColor = DesignSystem.Color.cardBackground

    var body: some View {
        NavigationStack {
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
            .background(DesignSystem.Color.ocean)
            .ignoresSafeArea()
            .safeAreaInset(edge: .top) {
                if !isLandscape {
                    topContent
                        .animation(.easeInOut(duration: 0.3), value: mapState.selectedCountryCode)
                }
            }
            .toolbarBackground(.clear, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    if isLandscape {
                        topContent
                            .frame(maxWidth: 500)
                            .animation(.easeInOut(duration: 0.3), value: mapState.selectedCountryCode)
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    labelsToggleButton
                }
            }
            .navigationDestination(item: $navigateToCountry) { country in
                CountryDetailScreen(country: country)
            }
            .overlay {
                if showFlagPreview, let code = mapState.selectedCountryCode {
                    ZoomableFlagView(countryCode: code) {
                        withAnimation(.easeInOut(duration: 0.25)) {
                            showFlagPreview = false
                        }
                    }
                }
            }
            .task { await loadMapData() }
        }
    }
}

// MARK: - Content
private extension OrganizationMapScreen {
    var isLandscape: Bool { verticalSizeClass == .compact }

    var topContent: some View {
        VStack(spacing: DesignSystem.Spacing.sm) {
            orgHeader
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
            canvasSize: size,
            capitalPoint: selectedCapitalPoint
        )
        .gesture(dragGesture)
        .gesture(magnifyGesture)
        .onTapGesture(count: 1) { location in
            handleTap(at: location, in: size)
        }
    }

    var selectedCapitalPoint: CGPoint? {
        guard let code = mapState.selectedCountryCode,
              let info = CountryBasicInfo.info(for: code) else { return nil }
        return MapProjection.project(longitude: info.capitalLongitude, latitude: info.capitalLatitude)
    }
}

// MARK: - Org Header
private extension OrganizationMapScreen {
    var orgHeader: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            HStack(alignment: .top, spacing: DesignSystem.Spacing.sm) {
                ZStack {
                    Circle()
                        .fill(organization.highlightColor.opacity(0.15))
                        .frame(width: 40, height: 40)
                    Image(systemName: organization.icon)
                        .font(DesignSystem.Font.iconSmall.weight(.medium))
                        .foregroundStyle(organization.highlightColor)
                }

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

            legend
        }
        .padding(.horizontal, DesignSystem.Spacing.md)
        .padding(.vertical, DesignSystem.Spacing.sm)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.large))
        .padding(.horizontal, DesignSystem.Spacing.md)
        .padding(.top, DesignSystem.Spacing.xxs)
    }

    var memberCountBadge: some View {
        Text("\(memberCount) members")
            .font(DesignSystem.Font.caption2)
            .fontWeight(.semibold)
            .foregroundStyle(organization.highlightColor)
            .lineLimit(1)
            .fixedSize(horizontal: true, vertical: false)
            .padding(.horizontal, DesignSystem.Spacing.xs)
            .padding(.vertical, DesignSystem.Spacing.xxs)
            .background(organization.highlightColor.opacity(0.15))
            .clipShape(Capsule())
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
            let basicInfo = CountryBasicInfo.info(for: shape.id)

            CountryBannerView(
                countryCode: shape.id,
                name: country?.name ?? shape.name,
                flag: country?.flagEmoji ?? basicInfo?.flag ?? "🏳️",
                capital: country?.capital ?? basicInfo?.capital ?? "",
                namespace: flagNamespace,
                isFlagHidden: showFlagPreview,
                onFlagTap: {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
                        showFlagPreview = true
                    }
                },
                onMoreInfo: country != nil ? { navigateToCountry = country } : nil,
                onDismiss: { mapState.selectedCountryCode = nil }
            )
            .transition(.move(edge: .top).combined(with: .opacity))
        }
    }
}

// MARK: - Controls
private extension OrganizationMapScreen {
    var labelsToggleButton: some View {
        Button {
            mapState.showLabels.toggle()
            hapticsService.impact(.light)
        } label: {
            Text("Aa")
                .font(DesignSystem.Font.headline)
                .foregroundStyle(mapState.showLabels ? DesignSystem.Color.onAccent : DesignSystem.Color.iconPrimary)
                .padding(DesignSystem.Spacing.xs)
                .background {
                    if mapState.showLabels {
                        Circle().fill(DesignSystem.Color.accent)
                    }
                }
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Gestures
private extension OrganizationMapScreen {
    var magnifyGesture: some Gesture {
        MagnifyGesture()
            .onChanged { value in
                let newScale = min(
                    max(mapState.lastScale * value.magnification, mapState.minScale),
                    MapState.maxScale
                )
                let scaleRatio = newScale / mapState.scale

                let anchor = value.startLocation
                let screenCenter = CGPoint(x: screenSize.width / 2, y: screenSize.height / 2)
                let anchorOffset = CGSize(
                    width: anchor.x - screenCenter.x,
                    height: anchor.y - screenCenter.y
                )

                mapState.offset = CGSize(
                    width: mapState.offset.width * scaleRatio - anchorOffset.width * (scaleRatio - 1),
                    height: mapState.offset.height * scaleRatio - anchorOffset.height * (scaleRatio - 1)
                )
                mapState.scale = newScale
                clampVerticalOffset()
            }
            .onEnded { _ in
                wrapHorizontalOffset()
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
                clampVerticalOffset()
            }
            .onEnded { _ in
                wrapHorizontalOffset()
                mapState.lastOffset = mapState.offset
            }
    }
}

// MARK: - Actions
private extension OrganizationMapScreen {
    func handleTap(at point: CGPoint, in size: CGSize) {
        let originX = size.width / 2 - (MapProjection.mapWidth * mapState.scale) / 2 + mapState.offset.width
        let originY = size.height / 2 - (MapProjection.mapHeight * mapState.scale) / 2 + mapState.offset.height
        let mapPoint = CGPoint(
            x: (point.x - originX) / mapState.scale,
            y: (point.y - originY) / mapState.scale
        )
        let sortedByArea = mapState.countryShapes.sorted {
            $0.boundingBox.width * $0.boundingBox.height < $1.boundingBox.width * $1.boundingBox.height
        }
        for shape in sortedByArea {
            if shape.polygons.contains(where: { $0.contains(mapPoint) }) {
                if mapState.selectedCountryCode == shape.id {
                    mapState.selectedCountryCode = nil
                    hapticsService.impact(.light)
                } else {
                    mapState.selectedCountryCode = shape.id
                    hapticsService.impact(.medium)
                }
                return
            }
        }
        mapState.selectedCountryCode = nil
    }

    func clampVerticalOffset() {
        let bounds = mapState.contentBounds
        guard bounds.height > 0 else { return }
        let scaledContentHeight = bounds.height * mapState.scale
        let maxOffsetY = max(0, (scaledContentHeight - screenSize.height) / 2)
        let contentCenterInMap = (bounds.minY + bounds.maxY) / 2
        let mapCenter = MapProjection.mapHeight / 2
        let centerCorrection = (mapCenter - contentCenterInMap) * mapState.scale
        let correctedOffset = mapState.offset.height - centerCorrection
        let clamped = min(max(correctedOffset, -maxOffsetY), maxOffsetY)
        mapState.offset.height = clamped + centerCorrection
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
        let newMin = computeMinScale(for: size)
        mapState.minScale = newMin
        if mapState.scale < newMin {
            mapState.scale = newMin
            mapState.lastScale = newMin
        }
        centerOnContent()
        clampVerticalOffset()
        mapState.lastOffset = mapState.offset
    }

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

    func centerOnContent() {
        let bounds = mapState.contentBounds
        guard bounds.width > 0, bounds.height > 0 else { return }
        let contentCenterX = (bounds.minX + bounds.maxX) / 2
        let contentCenterY = (bounds.minY + bounds.maxY) / 2
        let offsetX = (MapProjection.mapWidth / 2 - contentCenterX) * mapState.scale
        let offsetY = (MapProjection.mapHeight / 2 - contentCenterY) * mapState.scale
        mapState.offset = CGSize(width: offsetX, height: offsetY)
        mapState.lastOffset = mapState.offset
    }

    func loadMapData() async {
        countryDataService.loadCountries()

        let memberCodes = Set(
            countryDataService.countries
                .filter { $0.organizations.contains(organization.id) }
                .map { $0.code }
        )
        memberCount = memberCodes.count

        // Capture value types before entering background task
        let highlightColor = organization.highlightColor
        let dimColor = nonMemberColor

        // Move heavy I/O and parsing off the main thread
        let shapes = await Task.detached(priority: .userInitiated) { () -> [CountryShape] in
            guard let url = Bundle.main.url(forResource: "countries", withExtension: "geojson"),
                  let data = try? Data(contentsOf: url) else { return [] }
            var parsed = GeoJSONParser.parse(data: data)
            for i in parsed.indices {
                parsed[i].color = memberCodes.contains(parsed[i].id) ? highlightColor : dimColor
            }
            return parsed
        }.value

        guard !shapes.isEmpty else { return }

        mapState.contentBounds = computeContentBounds(from: shapes)

        withAnimation(.easeOut(duration: 0.3)) {
            mapState.countryShapes = shapes
        }

        if screenSize.width > 0, !isInitialized {
            let fitScale = computeMinScale(for: screenSize)
            mapState.scale = fitScale
            mapState.lastScale = fitScale
            mapState.minScale = fitScale
            centerOnContent()
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
