import SwiftUI

struct WordSearchGameScreen: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(HapticsService.self) private var hapticsService

    let theme: WordSearchTheme

    @State private var puzzle: WordSearchPuzzle?
    @State private var selectionStart: GridCoord?
    @State private var selectionEnd: GridCoord?
    @State private var foundWordIDs: Set<UUID> = []
    @State private var elapsedSeconds = 0
    @State private var timerActive = false
    @State private var isRevealed = false

    private let service = WordSearchService()
    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                if let puzzle {
                    gameContent(puzzle)
                } else {
                    Spacer()
                    ProgressView().tint(DesignSystem.Color.accent)
                    Spacer()
                }
            }
            .background(DesignSystem.Color.background)
            .navigationTitle("Word Search")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { toolbarContent }
            .onReceive(timer) { _ in
                guard timerActive else { return }
                elapsedSeconds += 1
            }
            .task { startPuzzle() }
        }
    }
}

// MARK: - Toolbar

private extension WordSearchGameScreen {
    @ToolbarContentBuilder
    var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .topBarLeading) {
            Text(formattedTime)
                .font(.system(size: 13, weight: .bold, design: .monospaced))
                .foregroundStyle(DesignSystem.Color.textSecondary)
        }
        ToolbarItem(placement: .topBarTrailing) {
            CircleCloseButton { dismiss() }
        }
    }

    var formattedTime: String {
        let minutes = elapsedSeconds / 60
        let seconds = elapsedSeconds % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

// MARK: - Game Content

private extension WordSearchGameScreen {
    func gameContent(_ puzzle: WordSearchPuzzle) -> some View {
        VStack(spacing: DesignSystem.Spacing.md) {
            progressSection(puzzle)
                .padding(.horizontal, DesignSystem.Spacing.md)
                .padding(.top, DesignSystem.Spacing.sm)
            gridSection(puzzle)
            wordListSection(puzzle)
                .padding(.horizontal, DesignSystem.Spacing.md)
        }
        .safeAreaInset(edge: .bottom) {
            if !isRevealed, !allFound(puzzle) {
                GlassButton("Give Up — Reveal", role: .secondary, fullWidth: true) {
                    revealAllWords()
                }
                .padding(.horizontal, DesignSystem.Spacing.md)
                .padding(.bottom, DesignSystem.Spacing.md)
            }
        }
    }

    func progressSection(_ puzzle: WordSearchPuzzle) -> some View {
        HStack(spacing: DesignSystem.Spacing.sm) {
            SessionProgressBar(progress: progressFraction(puzzle))
            QuestionCounterPill(current: foundWordIDs.count, total: puzzle.words.count)
        }
    }

    func gridSection(_ puzzle: WordSearchPuzzle) -> some View {
        GeometryReader { geometry in
            let availableWidth = geometry.size.width - DesignSystem.Spacing.md * 2
            let computedCellSize = availableWidth / CGFloat(service.gridSize)

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
            .padding(.horizontal, DesignSystem.Spacing.md)
            .gesture(dragGesture(cellSize: computedCellSize, puzzle: puzzle))
        }
        .frame(height: CGFloat(service.gridSize) * 32)
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

        return ZStack {
            Rectangle()
                .fill(cellBackground(isHighlighted: isHighlighted, isFound: isFound))
            Text(String(letter))
                .font(.system(size: max(cellSize * 0.48, 12), weight: .semibold, design: .monospaced))
                .foregroundStyle(
                    isHighlighted || isFound
                        ? DesignSystem.Color.onAccent
                        : DesignSystem.Color.textPrimary
                )
        }
        .frame(width: cellSize, height: cellSize)
    }

    func cellBackground(isHighlighted: Bool, isFound: Bool) -> Color {
        if isFound { return DesignSystem.Color.success.opacity(0.7) }
        if isHighlighted { return DesignSystem.Color.accent }
        return DesignSystem.Color.cardBackground.opacity(0.3)
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
        let isRevealedOnly = isRevealed && !isUserFound

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

// MARK: - Helpers

private extension WordSearchGameScreen {
    func progressFraction(_ puzzle: WordSearchPuzzle) -> CGFloat {
        guard !puzzle.words.isEmpty else { return 0 }
        return CGFloat(foundWordIDs.count) / CGFloat(puzzle.words.count)
    }

    func allFound(_ puzzle: WordSearchPuzzle) -> Bool {
        foundWordIDs.count == puzzle.words.count
    }

    func startPuzzle() {
        foundWordIDs = []
        elapsedSeconds = 0
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
            guard foundWordIDs.contains(wordItem.id) || isRevealed else { return false }
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
            hapticsService.impact(.medium)
            if allFound(puzzle) {
                timerActive = false
                hapticsService.notification(.success)
            }
            return
        }
    }

    func revealAllWords() {
        timerActive = false
        withAnimation(.easeInOut(duration: 0.4)) { isRevealed = true }
        hapticsService.impact(.light)
    }
}

// MARK: - Supporting Types

private struct GridCoord: Hashable {
    let row: Int
    let col: Int
}
