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
    @Environment(SoundService.self) private var soundService
    #endif

    public let theme: WordSearchTheme
    /// Set when racing another phone; the first player to find every word wins.
    let match: (any LocalMatch)?
    /// The host's puzzle, played on both phones so they search the same grid.
    private let matchPuzzle: WordSearchPuzzle?

    // MARK: - Init
    init(theme: WordSearchTheme, match: (any LocalMatch)? = nil, matchPuzzle: WordSearchPuzzle? = nil) {
        self.theme = theme
        self.match = match
        self.matchPuzzle = matchPuzzle
    }

    @State private var puzzle: WordSearchPuzzle?
    @State private var checkedAnswer: CheckedAnswer?
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
            // A match brings its own Give Up; on its own, Give Up replaces the cover's close button once it's playing.
            .hideNavigationCloseButton(match == nil && puzzle != nil)
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
            .answerHaptic(checkedAnswer)
            .haptic(trigger: foundWordIDs.count) { oldCount, newCount in
                guard newCount > oldCount else { return nil }
                return newCount == puzzle?.words.count ? .success : .impact(weight: .medium)
            }
            .haptic(.impact(weight: .light), trigger: hintRevealedIDs.count)
            .haptic(.impact(weight: .light), trigger: isRevealed)
    }
}

// MARK: - Toolbar
private extension WordSearchGameScreen {
    @ToolbarContentBuilder
    var toolbarContent: some ToolbarContent {
        if match == nil, puzzle != nil, !gameFinished {
            ToolbarItem(placement: .topBarLeading) {
                LeaveGameButton { showQuitAlert = true }
            }
        }
        ToolbarItem(placement: .topBarTrailing) {
            // At its natural width; alone in the item, the bar would otherwise squeeze it into a circle.
            WordSearchClockLabel(stopwatch: stopwatch)
                .fixedSize()
        }
        if timerActive, match == nil {
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

                if let match {
                    opponentChip(match, wordCount: puzzle.words.count)
                }

                if gameFinished {
                    resultCard(puzzle)
                }

                gridSection(puzzle)

                wordList(puzzle)

                if match == nil, !gameFinished {
                    WordSearchHelpButtons(nextHintWord: nextUnrevealedWord(puzzle)) {
                        revealHint($0)
                    } onRevealAll: {
                        showRevealAllAlert = true
                    }
                }
            }
            .padding(.horizontal, DesignSystem.Spacing.md)
            .padding(.vertical, DesignSystem.Spacing.sm)
            .readableContentWidth()
        }
        .bottomActionBar {
            if gameFinished, match == nil {
                resultFooter
            }
        }
    }

    func wordList(_ puzzle: WordSearchPuzzle) -> some View {
        WordSearchWordList(
            words: puzzle.words,
            foundIDs: foundWordIDs,
            hintRevealedIDs: hintRevealedIDs,
            showsAll: isRevealed,
            canReveal: match == nil && !gameFinished
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

    /// The other player's words found so far; they're always searching, since a race ends when either finds all.
    func opponentChip(_ match: any LocalMatch, wordCount: Int) -> some View {
        MatchOpponentChip(
            name: match.opponentName,
            score: "\(match.opponentScore)/\(wordCount)",
            status: String(localized: "Searching", bundle: .module),
            systemImage: "magnifyingglass"
        )
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
                        WordSearchPauseOverlay { isPaused = false }
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
        let newPuzzle = matchPuzzle ?? service.makePuzzle(theme: theme)
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
        for (round, wordItem) in puzzle.words.enumerated() where !foundWordIDs.contains(wordItem.id) {
            let wordCells = wordCoversCells(wordItem)
            guard wordCells.count == cells.count else { continue }
            // Either way along the word counts: a drag from its last letter to its first finds it too.
            guard wordCells == cells || Array(wordCells.reversed()) == cells else { continue }
            foundWordIDs.insert(wordItem.id)
            match?.didScore(round: round, points: 1)
            if allFound(puzzle) {
                finish()
                soundService.play(.complete)
                let announcement = "Found \(wordItem.word). All words found in \(formattedTime)."
                AccessibilityNotification.Announcement(announcement).post()
            } else {
                soundService.play(.correct)
                let announcement = "Found \(wordItem.word). \(foundWordIDs.count) of \(puzzle.words.count)."
                AccessibilityNotification.Announcement(announcement).post()
            }
            return
        }
        // A tap on one letter isn't a guess; a drag across letters that spell no word is a wrong answer.
        guard cells.count > 1 else { return }
        #if !os(tvOS)
        checkedAnswer = AnswerFeedback(soundService: soundService).play(
            isCorrect: false,
            announcement: String(localized: "Not one of the words.", bundle: .module)
        )
        #endif
    }

    func finish() {
        timerActive = false
        if let match {
            match.didFinishRounds()
        } else {
            xpService.award(
                XPRules.wordSearch(wordsFound: foundWordIDs.count, foundAll: true),
                source: .wordSearchCompleted
            )
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
    }

    func revealAllWords() {
        timerActive = false
        isRevealed = true
        xpService.award(
            XPRules.wordSearch(wordsFound: foundWordIDs.count, foundAll: false),
            source: .wordSearchCompleted
        )
        AccessibilityNotification.Announcement("All words revealed.").post()
    }
}
