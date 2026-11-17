import Geografy_Core_Common
import Geografy_Core_DesignSystem
import Geografy_Core_Navigation
import Geografy_Core_Service
import SwiftUI

public struct WordSearchGameScreen: View {
    // MARK: - Properties
    @Environment(\.dismiss) private var dismiss
    @Environment(XPService.self) private var xpService
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency
    @Environment(\.colorSchemeContrast) private var contrast
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    #if !os(tvOS)
    @Environment(HapticsService.self) private var hapticsService
    #endif

    public let theme: WordSearchTheme

    // MARK: - Init
    public init(theme: WordSearchTheme) {
        self.theme = theme
    }

    @State private var puzzle: WordSearchPuzzle?
    @State private var spokenRows: [String] = []
    @State private var foundWordIDs: Set<UUID> = []
    @State private var stopwatch = WordSearchStopwatch()
    @State private var timerActive = false
    @State private var isPaused = false
    @State private var isRevealed = false
    @State private var hintRevealedIDs: Set<UUID> = []

    private let service = WordSearchService()

    // MARK: - Body
    public var body: some View {
        contentSwitcher
            .screenBackground()
            .navigationTitle("Word Search")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { toolbarContent }
            .task { startPuzzle() }
            .onChange(of: isClockRunning) { _, isRunning in
                if isRunning {
                    stopwatch.resume(at: .now)
                } else {
                    stopwatch.pause(at: .now)
                }
            }
    }
}

// MARK: - Toolbar
private extension WordSearchGameScreen {
    @ToolbarContentBuilder
    var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .topBarLeading) {
            WordSearchClockLabel(stopwatch: stopwatch)
        }
        if timerActive {
            ToolbarItem(placement: .topBarTrailing) {
                Button(
                    isPaused ? "Resume" : "Pause",
                    systemImage: isPaused ? "play.fill" : "pause.fill"
                ) {
                    isPaused.toggle()
                }
            }
        }
    }

    var formattedTime: String {
        WordSearchStopwatch.formatted(seconds: stopwatch.wholeSeconds(at: .now))
    }
}

// MARK: - Subviews
private extension WordSearchGameScreen {
    @ViewBuilder
    var contentSwitcher: some View {
        if let puzzle {
            gameContent(puzzle)
        } else {
            LoadingView()
        }
    }
}

// MARK: - Game Content
private extension WordSearchGameScreen {
    func gameContent(_ puzzle: WordSearchPuzzle) -> some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: DesignSystem.Spacing.md) {
                progressSection(puzzle)

                if gameFinished {
                    resultBanner(puzzle)
                }

                gridSection(puzzle)

                wordListSection(puzzle)

                if !gameFinished {
                    VStack(spacing: DesignSystem.Spacing.sm) {
                        if let nextHintWord = nextUnrevealedWord(puzzle) {
                            GlassButton(
                                "Reveal \"\(nextHintWord.word)\"",
                                systemImage: "eye",
                                fullWidth: true
                            ) {
                                revealHint(nextHintWord)
                            }
                        }
                        GlassButton("Reveal All", systemImage: "eye.slash", fullWidth: true) {
                            revealAllWords()
                        }
                    }
                }
            }
            .padding(.horizontal, DesignSystem.Spacing.md)
            .padding(.vertical, DesignSystem.Spacing.sm)
            .readableContentWidth()
        }
        .safeAreaBar(edge: .bottom) {
            if gameFinished {
                resultFooter
                    .padding(.horizontal, DesignSystem.Spacing.md)
                    .padding(.bottom, DesignSystem.Spacing.md)
            }
        }
    }

    func resultBanner(_ puzzle: WordSearchPuzzle) -> some View {
        CardView {
            VStack(spacing: DesignSystem.Spacing.sm) {
                Image(systemName: allFound(puzzle) ? "trophy.fill" : "flag.checkered")
                    .font(DesignSystem.Font.iconXL)
                    .foregroundStyle(allFound(puzzle) ? DesignSystem.Color.warning : DesignSystem.Color.textSecondary)
                    .accessibilityHidden(true)
                Text(allFound(puzzle) ? "All Words Found!" : "Puzzle Complete")
                    .font(DesignSystem.Font.title2)
                    .fontWeight(.bold)
                    .foregroundStyle(DesignSystem.Color.textPrimary)
                    .accessibilityAddTraits(.isHeader)
                resultStats
            }
            .padding(DesignSystem.Spacing.lg)
            .frame(maxWidth: .infinity)
        }
    }

    var resultStats: some View {
        statsLayout {
            StatTile(
                value: "\(foundWordIDs.count)",
                label: "Found",
                icon: "checkmark.circle.fill",
                color: DesignSystem.Color.success,
                style: .plain            )
            StatTile(
                value: "\(revealedCount)",
                label: "Revealed",
                icon: "eye.fill",
                color: DesignSystem.Color.warning,
                style: .plain            )
            StatTile(
                value: formattedTime,
                label: "Time",
                icon: "timer",
                color: DesignSystem.Color.indigo,
                style: .plain            )
        }
    }

    var resultFooter: some View {
        ButtonRow {
            GlassButton("Done", systemImage: "checkmark", role: .secondary, fullWidth: true) {
                dismiss()
            }
            GlassButton("Play Again", systemImage: "arrow.counterclockwise", fullWidth: true) {
                startPuzzle()
            }
        }
    }

    func progressSection(_ puzzle: WordSearchPuzzle) -> some View {
        SessionProgressView(
            progress: progressFraction(puzzle),
            current: foundWordIDs.count,
            total: puzzle.words.count
        )
    }

    func gridSection(_ puzzle: WordSearchPuzzle) -> some View {
        GeometryReader { geometry in
            let computedCellSize = geometry.size.width / CGFloat(service.gridSize)

            gridLayers(puzzle, cellSize: computedCellSize)
                .clipShape(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium, style: .continuous))
                .blur(radius: isPaused && !reduceTransparency ? 8 : 0)
                .animation(reduceMotion ? nil : .easeInOut(duration: 0.2), value: isPaused)
                .accessibilityElement(children: .contain)
                .accessibilityLabel("Letter grid")
                .accessibilityHidden(isPaused)
                .overlay {
                    if isPaused {
                        pauseOverlay
                            .transition(.opacity)
                            .animation(reduceMotion ? nil : .easeInOut(duration: 0.2), value: isPaused)
                    }
                }
        }
        .aspectRatio(1, contentMode: .fit)
        .animation(reduceMotion ? nil : .easeInOut(duration: 0.4), value: isRevealed)
    }

    func gridLayers(_ puzzle: WordSearchPuzzle, cellSize: CGFloat) -> some View {
        ZStack {
            WordSearchLetterGrid(
                puzzleID: puzzle.id,
                grid: puzzle.grid,
                spokenRows: spokenRows,
                cellSize: cellSize
            )
            .equatable()

            wordCapsules(puzzle: puzzle, cellSize: cellSize)
                .accessibilityHidden(true)
            WordSearchSelectionLayer(
                gridSize: service.gridSize,
                cellSize: cellSize,
                isEnabled: !isPaused && !gameFinished
            ) { start, end in
                checkSelection(from: start, to: end, puzzle: puzzle)
            }
        }
    }

    var pauseOverlay: some View {
        RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium, style: .continuous)
            .fill(DesignSystem.Color.background.opacity(reduceTransparency ? 1 : 0.6))
            .overlay {
                VStack(spacing: DesignSystem.Spacing.sm) {
                    Image(systemName: "pause.circle.fill")
                        .font(DesignSystem.Font.displaySmall)
                        .foregroundStyle(DesignSystem.Color.textSecondary)
                        .accessibilityHidden(true)
                    Text("Paused")
                        .font(DesignSystem.Font.title2)
                        .fontWeight(.bold)
                        .foregroundStyle(DesignSystem.Color.textPrimary)
                        .accessibilityAddTraits(.isHeader)
                    GlassButton("Continue", systemImage: "play.fill") {
                        isPaused = false
                    }
                }
            }
    }

    func wordCapsules(puzzle: WordSearchPuzzle, cellSize: CGFloat) -> some View {
        ForEach(puzzle.words) { wordItem in
            let isUserFound = foundWordIDs.contains(wordItem.id)
            let isHintRevealed = hintRevealedIDs.contains(wordItem.id)
            if isUserFound || isRevealed || isHintRevealed {
                let cells = wordCoversCells(wordItem)
                if let first = cells.first, let last = cells.last {
                    // Revealed words get a dashed outline so they differ from found words by shape, not just color.
                    WordSearchCapsule(
                        start: first,
                        end: last,
                        cellSize: cellSize,
                        color: isUserFound
                            ? DesignSystem.Color.success.opacity(DesignSystem.Opacity.half)
                            : DesignSystem.Color.warning.opacity(DesignSystem.Opacity.half),
                        dashedOutline: isUserFound ? nil : DesignSystem.Color.warning
                    )
                }
            }
        }
    }

    func wordListSection(_ puzzle: WordSearchPuzzle) -> some View {
        CardView {
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
                SectionHeaderView(title: "Find These Words")
                    .padding(.horizontal, DesignSystem.Spacing.sm)
                    .padding(.top, DesignSystem.Spacing.sm)
                LazyVGrid(
                    columns: [GridItem(.flexible()), GridItem(.flexible())],
                    spacing: DesignSystem.Spacing.xs
                ) {
                    ForEach(puzzle.words) { wordItem in
                        wordChip(wordItem)
                    }
                }
                .padding(.horizontal, DesignSystem.Spacing.sm)
                .padding(.bottom, DesignSystem.Spacing.sm)
            }
        }
    }

    func wordChip(_ wordItem: WordSearchWord) -> some View {
        let isUserFound = foundWordIDs.contains(wordItem.id)
        let isHintRevealed = hintRevealedIDs.contains(wordItem.id)
        let isRevealedOnly = (isRevealed || isHintRevealed) && !isUserFound

        return HStack(spacing: DesignSystem.Spacing.xxs) {
            if isUserFound {
                Image(systemName: "checkmark.circle.fill")
                    .font(DesignSystem.Font.caption2)
                    .foregroundStyle(DesignSystem.Color.success)
                    .accessibilityHidden(true)
            } else if isRevealedOnly {
                Image(systemName: "eye.fill")
                    .font(DesignSystem.Font.caption2)
                    .foregroundStyle(DesignSystem.Color.warning)
                    .accessibilityHidden(true)
            }
            Text(wordItem.word)
                .font(DesignSystem.Font.caption)
                .fontWeight(.semibold)
                .foregroundStyle(
                    isUserFound
                        ? DesignSystem.Color.success
                        : (isRevealedOnly ? DesignSystem.Color.warning : DesignSystem.Color.textPrimary)
                )
                .strikethrough(isUserFound || isRevealedOnly)
        }
        .padding(.horizontal, DesignSystem.Spacing.sm)
        .padding(.vertical, DesignSystem.Spacing.xxs)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            isUserFound
                ? DesignSystem.Color.success.opacity(DesignSystem.Opacity.tint)
                : (isRevealedOnly
                    ? DesignSystem.Color.warning.opacity(DesignSystem.Opacity.tint)
                    : DesignSystem.Color.cardBackground),
            in: RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.small, style: .continuous)
        )
        .overlay {
            if contrast == .increased {
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.small, style: .continuous)
                    .strokeBorder(DesignSystem.Color.dividerSubtle, lineWidth: 1)
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(wordItem.word)
        .accessibilityValue(
            isUserFound
                ? "Found, \(wordItem.spokenLocation)"
                : (isRevealedOnly ? "Revealed, \(wordItem.spokenLocation)" : "Not found")
        )
        .accessibilityAction(named: "Reveal location") {
            guard !isUserFound, !gameFinished else { return }
            revealHint(wordItem)
        }
    }
}

// MARK: - Helpers
private extension WordSearchGameScreen {
    func statsLayout<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        let layout = dynamicTypeSize.isAccessibilitySize
            ? AnyLayout(VStackLayout(spacing: DesignSystem.Spacing.md))
            : AnyLayout(HStackLayout(spacing: DesignSystem.Spacing.md))
        return layout(content)
    }

    var revealedCount: Int {
        guard let puzzle else { return 0 }
        let autoRevealed = isRevealed ? puzzle.words.count - foundWordIDs.count - hintRevealedIDs.count : 0
        return hintRevealedIDs.count + autoRevealed
    }

    var gameFinished: Bool {
        guard let puzzle else { return false }
        return allFound(puzzle) || isRevealed
    }

    func progressFraction(_ puzzle: WordSearchPuzzle) -> CGFloat {
        guard !puzzle.words.isEmpty else { return 0 }
        return CGFloat(foundWordIDs.count) / CGFloat(puzzle.words.count)
    }

    func allFound(_ puzzle: WordSearchPuzzle) -> Bool {
        foundWordIDs.count == puzzle.words.count
    }

    var isClockRunning: Bool {
        timerActive && !isPaused
    }

    func startPuzzle() {
        let newPuzzle = service.makePuzzle(theme: theme)
        foundWordIDs = []
        hintRevealedIDs = []
        stopwatch = WordSearchStopwatch()
        stopwatch.resume(at: .now)
        isPaused = false
        isRevealed = false
        spokenRows = WordSearchLetterGrid.spokenRows(of: newPuzzle.grid)
        puzzle = newPuzzle
        timerActive = true
    }

    func selectedCells(from start: GridCoord, to end: GridCoord) -> [GridCoord] {
        let rowDelta = end.row - start.row
        let colDelta = end.col - start.col
        let steps = max(abs(rowDelta), abs(colDelta))
        guard steps > 0 else { return [start] }

        let rowStep = rowDelta == 0 ? 0 : rowDelta / abs(rowDelta)
        let colStep = colDelta == 0 ? 0 : colDelta / abs(colDelta)

        guard abs(rowDelta) == 0 || abs(colDelta) == 0 || abs(rowDelta) == abs(colDelta) else {
            return [start]
        }

        return (0...steps).map { index in
            GridCoord(row: start.row + rowStep * index, col: start.col + colStep * index)
        }
    }

    func wordCoversCells(_ wordItem: WordSearchWord) -> [GridCoord] {
        let (rowDelta, colDelta) = service.delta(for: wordItem.direction)
        return (0..<wordItem.word.count).map { index in
            GridCoord(row: wordItem.startRow + rowDelta * index, col: wordItem.startCol + colDelta * index)
        }
    }

    func checkSelection(from start: GridCoord, to end: GridCoord, puzzle: WordSearchPuzzle) {
        let cells = selectedCells(from: start, to: end)
        for wordItem in puzzle.words where !foundWordIDs.contains(wordItem.id) {
            let wordCells = wordCoversCells(wordItem)
            guard wordCells.count == cells.count else { continue }
            guard zip(wordCells, cells).allSatisfy({ $0 == $1 }) else { continue }
            foundWordIDs.insert(wordItem.id)
            if allFound(puzzle) {
                timerActive = false
                xpService.award(
                    XPRules.wordSearch(wordsFound: foundWordIDs.count, foundAll: true),
                    source: .wordSearchCompleted
                )
                #if !os(tvOS)
                hapticsService.notification(.success)
                #endif
                let announcement = "Found \(wordItem.word). All words found in \(formattedTime)."
                AccessibilityNotification.Announcement(announcement).post()
            } else {
                #if !os(tvOS)
                hapticsService.impact(.medium)
                #endif
                let announcement = "Found \(wordItem.word). \(foundWordIDs.count) of \(puzzle.words.count)."
                AccessibilityNotification.Announcement(announcement).post()
            }
            return
        }
    }

    func nextUnrevealedWord(_ puzzle: WordSearchPuzzle) -> WordSearchWord? {
        puzzle.words.first { wordItem in
            !foundWordIDs.contains(wordItem.id) && !hintRevealedIDs.contains(wordItem.id)
        }
    }

    func revealHint(_ wordItem: WordSearchWord) {
        _ = withAnimation(reduceMotion ? nil : .easeInOut(duration: 0.3)) {
            hintRevealedIDs.insert(wordItem.id)
        }
        AccessibilityNotification.Announcement("\(wordItem.word) \(wordItem.spokenLocation).").post()
        #if !os(tvOS)
        hapticsService.impact(.light)
        #endif
    }

    func revealAllWords() {
        timerActive = false
        isRevealed = true
        xpService.award(
            XPRules.wordSearch(wordsFound: foundWordIDs.count, foundAll: false),
            source: .wordSearchCompleted
        )
        AccessibilityNotification.Announcement("All words revealed.").post()
        #if !os(tvOS)
        hapticsService.impact(.light)
        #endif
    }
}
