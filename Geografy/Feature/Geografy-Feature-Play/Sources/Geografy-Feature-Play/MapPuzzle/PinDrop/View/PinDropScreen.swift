import Geografy_Core_Common
import Geografy_Core_DesignSystem
import Geografy_Core_Map
import Geografy_Core_Service
import SwiftUI

/// Pin Drop: a country is named, the player drops a pin where they think it is, and the map
/// flies to the answer to show how far off they were.
struct PinDropScreen: View {
    // MARK: - Properties
    @Environment(\.dismiss) private var dismiss
    @Environment(XPService.self) private var xpService
    @Environment(\.locale) private var locale
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(CountryDataService.self) private var countryDataService
    @Environment(GeoJSONCache.self) private var geoJSONCache
    #if !os(tvOS)
    @Environment(HapticsService.self) private var hapticsService
    #endif

    let configuration: PinDropConfiguration

    @State private var game: PinDropGame?
    @State private var allShapes: [CountryShape] = []
    /// The region's countries in their land colors.
    @State private var landShapes: [CountryShape] = []
    /// What's drawn: the land, with a wrong country pick greyed while the answer shows.
    @State private var shapes: [CountryShape] = []
    @State private var shapesBySize: [CountryShape] = []
    @State private var hasLoaded = false

    @State private var camera = MapFrame(scale: 0.2, offset: .zero)
    /// Where the map stays drawn while it's moved by a transform; nil draws it at the camera.
    @State private var heldFrame: MapFrame?
    @State private var dragStart: MapFrame?
    @State private var pinchStart: MapFrame?

    @State private var screenSize: CGSize = .zero
    @State private var safeInsets = EdgeInsets()
    @State private var promptHeight: CGFloat = 120
    @State private var controlsHeight: CGFloat = 80

    @State private var dropCount = 0
    @State private var lineProgress: CGFloat = 0
    @State private var bestScore = 0
    @State private var isNewBest = false

    private let records = PinDropRecords()
    /// Room the reveal card takes at the bottom, for framing the answer above it before it's measured.
    private let revealCardHeight: CGFloat = 230

    // MARK: - Body
    var body: some View {
        GeometryReader { proxy in
            // The cards lay out inside the safe area; the map runs under the bars behind them.
            overlay
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background {
                    mapArea(fullSize: fullSize(of: proxy))
                        .ignoresSafeArea()
                }
                .onAppear { updateLayout(proxy) }
                .onChange(of: proxy.size) { updateLayout(proxy) }
        }
        .background(DesignSystem.Color.ocean)
        .navigationTitle(regionTitle)
        #if !os(tvOS)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(.hidden, for: .tabBar)
        #endif
        .task { await load() }
    }
}

// MARK: - Map
private extension PinDropScreen {
    /// Built from the locale: a bar keeps a plain key's first translation.
    var regionTitle: String {
        configuration.region == .world
            ? String(localized: "Whole World", in: locale)
            : configuration.region.displayName
    }

    @ViewBuilder
    func mapArea(fullSize: CGSize) -> some View {
        if hasLoaded, fullSize.width > 0 {
            PinDropMapLayer(
                camera: camera,
                drawnFrame: heldFrame ?? camera,
                size: fullSize,
                shapes: shapes,
                pin: game?.pin,
                selectedCountryCode: game?.selectedCountryCode,
                dropCount: dropCount,
                result: game?.phase == .aiming ? nil : game?.lastResult,
                lineProgress: lineProgress,
                borderColor: configuration.showsBorders
                    ? DesignSystem.Color.background.opacity(DesignSystem.Opacity.strong)
                    : nil
            )
            .contentShape(Rectangle())
            #if !os(tvOS)
            .gesture(dragGesture)
            .gesture(pinchGesture)
            .onTapGesture { location in guess(atScreenPoint: location) }
            #endif
            .accessibilityElement()
            .accessibilityLabel(Text("Map of \(configuration.region.displayName)"))
            .accessibilityHint(
                configuration.showsBorders
                    ? "Tap the country you think it is"
                    : "Tap where you think the country is to drop a pin"
            )
            .accessibilityAddTraits(.allowsDirectInteraction)
        } else {
            LoadingView("Unfolding the map…")
        }
    }

    func fullSize(of proxy: GeometryProxy) -> CGSize {
        CGSize(
            width: proxy.size.width + proxy.safeAreaInsets.leading + proxy.safeAreaInsets.trailing,
            height: proxy.size.height + proxy.safeAreaInsets.top + proxy.safeAreaInsets.bottom
        )
    }

    func updateLayout(_ proxy: GeometryProxy) {
        let isFirstLayout = screenSize == .zero
        safeInsets = proxy.safeAreaInsets
        screenSize = fullSize(of: proxy)
        if isFirstLayout, hasLoaded { frameRegion(animated: false) }
    }
}

// MARK: - Overlay
private extension PinDropScreen {
    @ViewBuilder
    var overlay: some View {
        if let game {
            if game.phase == .finished {
                PinDropResultsView(
                    results: game.results,
                    roundCount: game.rounds.count,
                    bestScore: bestScore,
                    isNewBest: isNewBest,
                    onDone: { dismiss() },
                    onPlayAgain: playAgain
                )
                .padding(DesignSystem.Spacing.md)
                .transition(.move(edge: .bottom).combined(with: .opacity))
            } else {
                VStack(spacing: 0) {
                    prompt(for: game)
                    Spacer(minLength: 0)
                    controls(for: game)
                }
                .padding(.horizontal, DesignSystem.Spacing.md)
                .padding(.bottom, DesignSystem.Spacing.xs)
            }
        } else if hasLoaded {
            EmptyStateView(
                icon: "map",
                title: "No Countries Here",
                message: "This region has no countries to find at this difficulty.",
                actionTitle: "Back"
            ) { dismiss() }
        }
    }

    @ViewBuilder
    func prompt(for game: PinDropGame) -> some View {
        if let round = game.currentRound {
            PinDropPromptCard(
                country: round.country,
                roundIndex: game.currentIndex,
                roundCount: game.rounds.count,
                totalScore: game.totalScore,
                ratings: game.results.map(\.score.rating)
            )
            .animation(reduceMotion ? nil : .smooth, value: game.currentIndex)
            .onGeometryChange(for: CGFloat.self) { $0.size.height } action: { promptHeight = $0 }
            .padding(.top, DesignSystem.Spacing.xs)
        }
    }

    @ViewBuilder
    func controls(for game: PinDropGame) -> some View {
        Group {
            switch game.phase {
            case .aiming:
                if game.pin == nil {
                    tapHint(picksCountries: configuration.showsBorders)
                } else {
                    GlassButton("Lock In", systemImage: "scope", fullWidth: true, action: lockIn)
                        .transition(.scale(scale: 0.9).combined(with: .opacity))
                }
            case .revealed:
                if let result = game.lastResult {
                    PinDropRevealCard(result: result, isLastRound: game.isLastRound, onNext: advance)
                        .id(result.id)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            case .finished:
                EmptyView()
            }
        }
        .onGeometryChange(for: CGFloat.self) { $0.size.height } action: { controlsHeight = $0 }
        .animation(reduceMotion ? nil : .spring(duration: 0.45, bounce: 0.25), value: game.phase)
        .animation(reduceMotion ? nil : .spring(duration: 0.35, bounce: 0.3), value: game.pin == nil)
    }

    func tapHint(picksCountries: Bool) -> some View {
        Label(
            picksCountries ? "Tap the country you think it is" : "Tap the map to drop your pin",
            systemImage: "hand.tap.fill"
        )
            .font(DesignSystem.Font.subheadline)
            .fontWeight(.semibold)
            .foregroundStyle(DesignSystem.Color.textPrimary)
            .padding(.horizontal, DesignSystem.Spacing.md)
            .padding(.vertical, DesignSystem.Spacing.sm)
            .glassEffect(.regular, in: .capsule)
            .symbolEffect(.wiggle, options: reduceMotion ? .nonRepeating : .repeat(.periodic(delay: 2.5)))
            .transition(.opacity)
    }
}

// MARK: - Gestures
#if !os(tvOS)
private extension PinDropScreen {
    var dragGesture: some Gesture {
        DragGesture(minimumDistance: 6)
            .onChanged { value in
                let start = dragStart ?? camera
                if dragStart == nil {
                    dragStart = start
                    heldFrame = heldFrame ?? camera
                }
                var moved = start
                moved.offset.width += value.translation.width
                moved.offset.height += value.translation.height
                camera = PinDropCamera.clamped(moved, keeping: configuration.region.mapRect, in: screenSize)
                redrawIfNeeded()
            }
            .onEnded { _ in
                dragStart = nil
                finishGesture()
            }
    }

    var pinchGesture: some Gesture {
        MagnifyGesture()
            .onChanged { value in
                let start = pinchStart ?? camera
                if pinchStart == nil {
                    pinchStart = start
                    heldFrame = heldFrame ?? camera
                }
                let limits = scaleLimits
                let scale = min(max(start.scale * value.magnification, limits.lowerBound), limits.upperBound)
                let ratio = scale / start.scale
                let anchor = CGSize(
                    width: value.startLocation.x - screenSize.width / 2,
                    height: value.startLocation.y - screenSize.height / 2
                )
                let zoomed = MapFrame(
                    scale: scale,
                    offset: CGSize(
                        width: start.offset.width * ratio - anchor.width * (ratio - 1),
                        height: start.offset.height * ratio - anchor.height * (ratio - 1)
                    )
                )
                camera = PinDropCamera.clamped(zoomed, keeping: configuration.region.mapRect, in: screenSize)
                redrawIfNeeded()
            }
            .onEnded { _ in
                pinchStart = nil
                finishGesture()
            }
    }

    /// Draws the map again mid-gesture once the moved drawing would show an edge or blur.
    func redrawIfNeeded() {
        guard let heldFrame, !MapFrame.drawnMap(heldFrame, covers: screenSize, at: camera) else { return }
        self.heldFrame = camera
    }

    func finishGesture() {
        guard dragStart == nil, pinchStart == nil else { return }
        heldFrame = nil
    }
}
#endif

// MARK: - Camera
private extension PinDropScreen {
    var regionFrame: MapFrame {
        PinDropCamera.frame(fitting: configuration.region.mapRect, in: screenSize, insets: aimingInsets, fill: 0.96)
    }

    var scaleLimits: ClosedRange<CGFloat> {
        let fit = regionFrame.scale
        return (fit * 0.8)...(fit * 24)
    }

    var aimingInsets: EdgeInsets {
        EdgeInsets(
            top: safeInsets.top + promptHeight + DesignSystem.Spacing.md,
            leading: DesignSystem.Spacing.sm,
            bottom: safeInsets.bottom + controlsHeight + DesignSystem.Spacing.md,
            trailing: DesignSystem.Spacing.sm
        )
    }

    var revealInsets: EdgeInsets {
        var insets = aimingInsets
        insets.bottom = safeInsets.bottom + revealCardHeight + DesignSystem.Spacing.lg
        return insets
    }

    func frameRegion(animated: Bool) {
        fly(to: regionFrame, animated: animated)
    }

    /// Frames the pin and the country together, cropped to the region so far territories don't zoom it out.
    func frameAnswer(_ result: PinDropGame.Result) {
        let regionRect = configuration.region.mapRect
        var rect = result.round.shape.boundingBox.intersection(regionRect.insetBy(dx: -40, dy: -40))
        if rect.isNull { rect = result.round.shape.boundingBox }
        rect = rect.union(CGRect(origin: result.pin, size: .zero))
        let minimumSide = regionRect.width * 0.08
        rect = rect.insetBy(dx: min(0, (rect.width - minimumSide) / 2), dy: min(0, (rect.height - minimumSide) / 2))
        let target = PinDropCamera.frame(fitting: rect, in: screenSize, insets: revealInsets, fill: 0.6)
        fly(to: MapFrame(scale: min(target.scale, scaleLimits.upperBound), offset: target.offset), animated: true)
    }

    /// Moves the camera, drawing the map once at the more zoomed-out end so it covers the whole flight.
    func fly(to target: MapFrame, animated: Bool) {
        guard animated, !reduceMotion else {
            camera = target
            heldFrame = nil
            return
        }
        heldFrame = target.scale < camera.scale ? target : camera
        withAnimation(.smooth(duration: 0.9)) {
            camera = target
        } completion: {
            heldFrame = nil
        }
    }
}

// MARK: - Game Flow
private extension PinDropScreen {
    func load() async {
        guard !hasLoaded else { return }
        let loaded = await geoJSONCache.loadShapes()
        allShapes = loaded
        let region = configuration.region.mapRect
        let visible = region.insetBy(dx: -region.width * 0.2, dy: -region.height * 0.2)
        landShapes = loaded
            .filter { $0.boundingBox.intersects(visible) }
            .map { $0.recolored(landColor(for: $0)) }
        shapes = landShapes
        shapesBySize = shapes.sorted {
            $0.boundingBox.width * $0.boundingBox.height < $1.boundingBox.width * $1.boundingBox.height
        }
        startGame()
        hasLoaded = true
        if screenSize != .zero { frameRegion(animated: false) }
    }

    func startGame() {
        var generator = SystemRandomNumberGenerator()
        let rounds = PinDropGame.makeRounds(
            for: configuration,
            countries: countryDataService.countries,
            shapes: allShapes,
            using: &generator
        )
        game = rounds.isEmpty ? nil : PinDropGame(configuration: configuration, rounds: rounds)
        bestScore = records.best(for: configuration)
        isNewBest = false
        lineProgress = 0
    }

    /// With borders, picks the country under the tap; without, drops the pin there.
    func guess(atScreenPoint point: CGPoint) {
        guard let game, game.phase == .aiming else { return }
        let mapPoint = PinDropCamera.mapPoint(of: point, frame: camera, in: screenSize)
        if configuration.showsBorders {
            // Smallest first, so an enclave like San Marino wins over the country around it.
            guard let shape = shapesBySize.first(where: { $0.contains(mapPoint) }) else { return }
            game.selectCountry(shape)
            #if !os(tvOS)
            hapticsService.selection()
            #endif
        } else {
            game.dropPin(at: mapPoint)
            dropCount += 1
            #if !os(tvOS)
            hapticsService.impact(.medium)
            #endif
        }
        SoundService.shared.play(.tap)
    }

    func lockIn() {
        guard let game, let result = game.lockIn() else { return }
        if let guess = result.guessedCountryCode, !result.isInside {
            // Grey, not a rating color, so only the answer carries how the round went.
            let missTint = DesignSystem.Color.mapLandMuted.mix(with: DesignSystem.Color.textPrimary, by: 0.5)
            shapes = landShapes.map { $0.id == guess ? $0.recolored(missTint) : $0 }
        }
        celebrate(result)
        frameAnswer(result)
        lineProgress = 0
        withAnimation(reduceMotion ? nil : .easeInOut(duration: 0.7).delay(0.75)) {
            lineProgress = 1
        }
        let distance = PinDropStyle.distance(result.distanceKilometers, locale: .current)
        let name = result.round.country.name
        let summary = result.isInside ? "Inside \(name)." : "\(distance) from \(name)."
        AccessibilityNotification.Announcement("\(summary) \(result.score.total) points.").post()
    }

    func celebrate(_ result: PinDropGame.Result) {
        let rating = result.score.rating
        let isGood = rating == .bullseye || rating == .excellent
        #if !os(tvOS)
        hapticsService.notification(isGood ? .success : rating == .far ? .error : .warning)
        #endif
        SoundService.shared.play(isGood ? .correct : rating == .far ? .wrong : .tap)
    }

    func advance() {
        guard let game else { return }
        withAnimation(reduceMotion ? nil : .spring(duration: 0.5, bounce: 0.2)) {
            game.advance()
            lineProgress = 0
        }
        shapes = landShapes
        if game.phase == .finished {
            finish(game)
        } else {
            frameRegion(animated: true)
        }
    }

    func finish(_ game: PinDropGame) {
        xpService.award(PinDropScoring.xp(for: game.results), source: .pinDropCompleted)
        isNewBest = records.record(game.totalScore, for: configuration)
        bestScore = max(bestScore, game.totalScore)
        SoundService.shared.play(isNewBest ? .levelUp : .sessionComplete)
        #if !os(tvOS)
        hapticsService.notification(.success)
        #endif
        frameRegion(animated: true)
    }

    func playAgain() {
        withAnimation(reduceMotion ? nil : .smooth) {
            startGame()
        }
        frameRegion(animated: true)
    }

    /// With borders, a muted tint of the map's own palette, which never gives neighbors the same color,
    /// so they read apart while staying quiet enough not to give countries away. Without, one land color.
    func landColor(for shape: CountryShape) -> Color {
        // Nudged toward the text color, which darkens it in light mode and lightens it in dark, so the
        // coastline stands out from the ocean either way.
        guard configuration.showsBorders else {
            return DesignSystem.Color.mapLandMuted.mix(with: DesignSystem.Color.textPrimary, by: 0.2)
        }
        return DesignSystem.Color.mapLandMuted.mix(with: shape.color, by: 0.45)
    }
}
