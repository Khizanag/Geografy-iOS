import Geografy_Core_Common
import Geografy_Core_DesignSystem
import Geografy_Core_Service
import SwiftUI

public struct WordSearchGameScreen: View {
    // MARK: - Properties
    @Environment(\.dismiss) private var dismiss
    #if !os(tvOS)
    @Environment(HapticsService.self) private var hapticsService
    #endif

    public let theme: WordSearchTheme

    // MARK: - Init
    public init(theme: WordSearchTheme) {
        self.theme = theme
    }

    @State private var puzzle: WordSearchPuzzle?
    @State private var selectionStart: GridCoord?
    @State private var selectionEnd: GridCoord?
    @State private var foundWordIDs: Set<UUID> = []
    @State private var elapsedSeconds = 0
    @State private var timerActive = false
    @State private var isPaused = false
    @State private var isRevealed = false
    @State private var hintRevealedIDs: Set<UUID> = []

    private let service = WordSearchService()
    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    // MARK: - Body
    public var body: some View {
        contentSwitcher
            .background(DesignSystem.Color.background)
            .navigationTitle("Word Search")
            .toolbarBackground(DesignSystem.Color.background, for: .navigationBar)
            .toolbar { toolbarContent }
            .task { startPuzzle() }
            .onReceive(timer) { _ in
                guard timerActive, !isPaused else { return }
                elapsedSeconds += 1
            }
    }
}

// MARK: - Toolbar
private extension WordSearchGameScreen {
    @ToolbarContentBuilder
    var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .topBarLeading) {
            HStack(spacing: DesignSystem.Spacing.xs) {
                Image(systemName: "timer")
                    .font(DesignSystem.Font.caption)
                    .foregroundStyle(.white)
                Text(formattedTime)
                    .font(DesignSystem.Font.caption)
                    .fontWeight(.bold)
                    .monospacedDigit()
                    .foregroundStyle(.white)
                    .contentTransition(.numericText())
                    .animation(.snappy, value: elapsedSeconds)

                if timerActive {
                    Button {
                        isPaused.toggle()
                    } label: {
                        Image(systemName: isPaused ? "play.fill" : "pause.fill")
                            .foregroundStyle(.white)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    var formattedTime: String {
        let minutes = elapsedSeconds / 60
        let seconds = elapsedSeconds % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

// MARK: - Subviews
private extension WordSearchGameScreen {
    @ViewBuilder
    var contentSwitcher: some View {
        if let puzzle {
            gameContent(puzzle)
        } else {
            ProgressView().tint(DesignSystem.Color.accent)
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
        .safeAreaInset(edge: .bottom) {
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
                Text(allFound(puzzle) ? "All Words Found!" : "Puzzle Complete")
                    .font(DesignSystem.Font.title2)
                    .fontWeight(.bold)
                    .foregroundStyle(DesignSystem.Color.textPrimary)
                HStack(spacing: DesignSystem.Spacing.md) {
                    ResultStatItem(
                        icon: "checkmark.circle.fill",
                        value: "\(foundWordIDs.count)",
                        label: "Found",
                        color: DesignSystem.Color.success
                    )
                    ResultStatItem(
                        icon: "eye.fill",
                        value: "\(revealedCount)",
                        label: "Revealed",
                        color: DesignSystem.Color.warning
                    )
                    ResultStatItem(
                        icon: "timer",
                        value: formattedTime,
                        label: "Time"
                    )
                }
            }
            .padding(DesignSystem.Spacing.lg)
            .frame(maxWidth: .infinity)
        }
    }

    var resultFooter: some View {
        HStack(spacing: DesignSystem.Spacing.sm) {
            GlassButton("Close", systemImage: "xmark", fullWidth: true) {
                dismiss()
            }
            GlassButton("Try Again", systemImage: "arrow.clockwise", fullWidth: true) {
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

            ZStack {
                VStack(spacing: 0) {
                    ForEach(0..<service.gridSize, id: \.self) { row in
                        HStack(spacing: 0) {
                            ForEach(0..<service.gridSize, id: \.self) { col in
                                gridCell(
                                    row: row,
                                    col: col,
                                    letter: puzzle.grid[row][col],
                                    cellSize: computedCellSize,
                                    puzzle: puzzle
                                )
                            }
                        }
                    }
                }
                .clipShape(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium))
                #if !os(tvOS)
                .gesture(isPaused || gameFinished ? nil : dragGesture(cellSize: computedCellSize, puzzle: puzzle))
                #endif
                .blur(radius: isPaused ? 8 : 0)
                .animation(.easeInOut(duration: 0.2), value: isPaused)

                if isPaused {
                    pauseOverlay
                        .transition(.opacity)
                        .animation(.easeInOut(duration: 0.2), value: isPaused)
                }
            }
        }
        .aspectRatio(1, contentMode: .fit)
        .animation(.easeInOut(duration: 0.4), value: isRevealed)
    }

    var pauseOverlay: some View {
        RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium)
            .fill(DesignSystem.Color.background.opacity(0.6))
            .overlay {
                VStack(spacing: DesignSystem.Spacing.sm) {
                    Image(systemName: "pause.circle.fill")
                        .font(DesignSystem.Font.displaySmall)
                        .foregroundStyle(DesignSystem.Color.textSecondary)
                    Text("Paused")
                        .font(DesignSystem.Font.title2)
                        .fontWeight(.bold)
                        .foregroundStyle(DesignSystem.Color.textPrimary)
                    GlassButton("Continue", systemImage: "play.fill") {
                        isPaused = false
                    }
                }
            }
    }

    func gridCell(
        row: Int,
        col: Int,
        letter: Character,
        cellSize: CGFloat,
        puzzle: WordSearchPuzzle
    ) -> some View {
        let isHighlighted = isCellHighlighted(row: row, col: col)
        let isFound = isCellFound(row: row, col: col, puzzle: puzzle)
        let isActive = isHighlighted || isFound

        return Text(String(letter))
            .font(DesignSystem.Font.system(size: max(cellSize * 0.48, 12), weight: .semibold, design: .monospaced))
            .foregroundStyle(isActive ? DesignSystem.Color.onAccent : DesignSystem.Color.textPrimary)
            .frame(width: cellSize, height: cellSize)
            .background {
                if isActive {
                    Circle()
                        .fill(cellColor(isHighlighted: isHighlighted, isFound: isFound))
                        .padding(1)
                }
            }
            .background(DesignSystem.Color.cardBackground.opacity(0.3))
    }

    func cellColor(isHighlighted: Bool, isFound: Bool) -> Color {
        if isFound { return DesignSystem.Color.success.opacity(0.7) }
        return DesignSystem.Color.accent
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
            } else if isRevealedOnly {
                Image(systemName: "eye.fill")
                    .font(DesignSystem.Font.caption2)
                    .foregroundStyle(DesignSystem.Color.warning)
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
                ? DesignSystem.Color.success.opacity(0.12)
                : (isRevealedOnly ? DesignSystem.Color.warning.opacity(0.12) : DesignSystem.Color.cardBackground),
            in: RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.small)
        )
    }
}

#if !os(tvOS)
// MARK: - Gesture
private extension WordSearchGameScreen {
    func dragGesture(cellSize: CGFloat, puzzle: WordSearchPuzzle) -> some Gesture {
        DragGesture(minimumDistance: 0)
            .onChanged { value in
                let col = Int(value.location.x / cellSize)
                let row = Int(value.location.y / cellSize)
                let clampedRow = max(0, min(service.gridSize - 1, row))
                let clampedCol = max(0, min(service.gridSize - 1, col))

                if selectionStart == nil {
                    selectionStart = GridCoord(row: clampedRow, col: clampedCol)
                }
                selectionEnd = GridCoord(row: clampedRow, col: clampedCol)
            }
            .onEnded { _ in
                if let start = selectionStart, let end = selectionEnd {
                    checkSelection(from: start, to: end, puzzle: puzzle)
                }
                selectionStart = nil
                selectionEnd = nil
            }
    }
}
#endif

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

    func startPuzzle() {
        foundWordIDs = []
        hintRevealedIDs = []
        elapsedSeconds = 0
        isPaused = false
        isRevealed = false
        puzzle = service.makePuzzle(theme: theme)
        timerActive = true
    }

    func isCellHighlighted(row: Int, col: Int) -> Bool {
        guard let start = selectionStart, let end = selectionEnd else { return false }
        return selectedCells(from: start, to: end).contains(GridCoord(row: row, col: col))
    }

    func isCellFound(row: Int, col: Int, puzzle: WordSearchPuzzle) -> Bool {
        let coord = GridCoord(row: row, col: col)
        return puzzle.words.contains { wordItem in
            guard foundWordIDs.contains(wordItem.id) || isRevealed || hintRevealedIDs.contains(wordItem.id) else {
                return false
            }
            return wordCoversCells(wordItem).contains(coord)
        }
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
            #if !os(tvOS)
            hapticsService.impact(.medium)
            #endif
            if allFound(puzzle) {
                timerActive = false
                #if !os(tvOS)
                hapticsService.notification(.success)
                #endif
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
        _ = withAnimation(.easeInOut(duration: 0.3)) {
            hintRevealedIDs.insert(wordItem.id)
        }
        #if !os(tvOS)
        hapticsService.impact(.light)
        #endif
    }

    func revealAllWords() {
        timerActive = false
        isRevealed = true
        #if !os(tvOS)
        hapticsService.impact(.light)
        #endif
    }
}

// MARK: - Supporting Types
private struct GridCoord: Hashable {
    let row: Int
    let col: Int
}
