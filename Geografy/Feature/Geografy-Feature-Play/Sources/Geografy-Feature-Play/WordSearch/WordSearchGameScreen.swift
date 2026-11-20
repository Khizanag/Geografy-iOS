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
    #if !os(tvOS)
    @Environment(HapticsService.self) private var hapticsService
    @Environment(SoundService.self) private var soundService
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
    @State private var showQuitAlert = false
    @State private var showRevealAllAlert = false

    private let service = WordSearchService()

    // MARK: - Body
    public var body: some View {
        contentSwitcher
            .screenBackground()
            .navigationTitle("Word Search")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { toolbarContent }
            .hideNavigationCloseButton(puzzle != nil)
            .alert("Give Up?", isPresented: $showQuitAlert) {
                Button("Give Up", role: .destructive) { dismiss() }
                Button("Continue", role: .cancel) {}
            } message: {
                Text("Your answers so far won't be saved.")
            }
            .alert("Reveal All Words?", isPresented: $showRevealAllAlert) {
                Button("Reveal All") { revealAllWords() }
                Button("Keep Searching", role: .cancel) {}
            } message: {
                Text("This ends the puzzle.")
            }
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
        if puzzle != nil, !gameFinished {
            ToolbarItem(placement: .topBarLeading) {
                GiveUpButton { showQuitAlert = true }
            }
        }
        ToolbarItem(placement: .topBarTrailing) {
            // At its natural width; alone in the item, the bar would otherwise squeeze it into a circle.
            WordSearchClockLabel(stopwatch: stopwatch)
                .fixedSize()
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
                    resultCard(puzzle)
                }

                gridSection(puzzle)

                wordList(puzzle)

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
                            showRevealAllAlert = true
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

    func wordList(_ puzzle: WordSearchPuzzle) -> some View {
        WordSearchWordList(
            words: puzzle.words,
            foundIDs: foundWordIDs,
            hintRevealedIDs: hintRevealedIDs,
            showsAll: isRevealed,
            canReveal: !gameFinished
        ) { revealHint($0) }
    }

    func resultCard(_ puzzle: WordSearchPuzzle) -> some View {
        WordSearchResultCard(
            foundAll: allFound(puzzle),
            foundCount: foundWordIDs.count,
            revealedCount: revealedCount,
            time: formattedTime
        )
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
}

// MARK: - Helpers
private extension WordSearchGameScreen {
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

    func wordCoversCells(_ wordItem: WordSearchWord) -> [GridCoord] {
        let (rowDelta, colDelta) = service.delta(for: wordItem.direction)
        return (0..<wordItem.word.count).map { index in
            GridCoord(row: wordItem.startRow + rowDelta * index, col: wordItem.startCol + colDelta * index)
        }
    }

    func checkSelection(from start: GridCoord, to end: GridCoord, puzzle: WordSearchPuzzle) {
        let cells = GridCoord.line(from: start, to: end)
        for wordItem in puzzle.words where !foundWordIDs.contains(wordItem.id) {
            let wordCells = wordCoversCells(wordItem)
            guard wordCells.count == cells.count else { continue }
            // Either way along the word counts: a drag from its last letter to its first finds it too.
            guard wordCells == cells || Array(wordCells.reversed()) == cells else { continue }
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
                soundService.play(.complete)
                let announcement = "Found \(wordItem.word). All words found in \(formattedTime)."
                AccessibilityNotification.Announcement(announcement).post()
            } else {
                #if !os(tvOS)
                hapticsService.impact(.medium)
                #endif
                soundService.play(.correct)
                let announcement = "Found \(wordItem.word). \(foundWordIDs.count) of \(puzzle.words.count)."
                AccessibilityNotification.Announcement(announcement).post()
            }
            return
        }
        // A tap on one letter isn't a guess; a drag across letters that spell no word is a wrong answer.
        guard cells.count > 1 else { return }
        #if !os(tvOS)
        AnswerFeedback(soundService: soundService, hapticsService: hapticsService).play(
            isCorrect: false,
            announcement: String(localized: "Not one of the words.", bundle: .module)
        )
        #endif
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
