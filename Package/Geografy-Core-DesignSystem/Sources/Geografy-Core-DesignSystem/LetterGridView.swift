import SwiftUI

public struct LetterGridView: View {
    public let targetText: String
    public let typedText: String
    public let isRevealed: Bool
    public let wasSkipped: Bool

    public init(
        targetText: String,
        typedText: String,
        isRevealed: Bool,
        wasSkipped: Bool = false
    ) {
        self.targetText = targetText
        self.typedText = typedText
        self.isRevealed = isRevealed
        self.wasSkipped = wasSkipped
    }

    public var body: some View {
        if isRevealed {
            revealedContent
        } else {
            typingContent
        }
    }
}

// MARK: - Content
private extension LetterGridView {
    var typingContent: some View {
        let segments = LetterGridHelper.splitIntoSegments(targetText)
        let targetLetters = Array(targetText.lowercased().filter { $0.isLetter })
        let typedLetters = Array(typedText.lowercased().filter { $0.isLetter })

        return VStack(spacing: DesignSystem.Spacing.xs) {
            ForEach(Array(segments.enumerated()), id: \.offset) { _, segment in
                HStack(spacing: DesignSystem.Spacing.xxs) {
                    if let separator = segment.leadingSeparator {
                        separatorCell(String(separator))
                    }

                    ForEach(Array(segment.letterIndices.enumerated()), id: \.offset) { _, letterIndex in
                        let targetLetter = targetLetters[letterIndex]
                        let typedLetter: Character? = letterIndex < typedLetters.count
                            ? typedLetters[letterIndex]
                            : nil
                        letterCell(
                            typed: typedLetter.map { String($0) },
                            isCorrect: typedLetter == targetLetter
                        )
                        .frame(maxWidth: 36)
                    }
                }
            }
        }
    }

    var revealedContent: some View {
        let segments = LetterGridHelper.splitIntoSegments(targetText)

        return VStack(spacing: DesignSystem.Spacing.xs) {
            ForEach(Array(segments.enumerated()), id: \.offset) { _, segment in
                HStack(spacing: DesignSystem.Spacing.xxs) {
                    if let separator = segment.leadingSeparator {
                        separatorCell(String(separator))
                    }

                    ForEach(Array(segment.letters.enumerated()), id: \.offset) { _, letter in
                        revealedCell(String(letter))
                            .frame(maxWidth: 36)
                    }
                }
            }
        }
    }
}

// MARK: - Cells
private extension LetterGridView {
    func separatorCell(_ separator: String) -> some View {
        Text(separator)
            .font(DesignSystem.Font.headline)
            .fontWeight(.bold)
            .foregroundStyle(DesignSystem.Color.textTertiary)
            .frame(width: 16, height: 36)
    }

    func letterCell(typed: String?, isCorrect: Bool) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.small)
                .fill(cellBackground(typed: typed, isCorrect: isCorrect))
                .aspectRatio(32.0 / 36.0, contentMode: .fit)
                .overlay(
                    RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.small)
                        .stroke(cellBorderColor(typed: typed, isCorrect: isCorrect), lineWidth: 1.5)
                )

            if let letter = typed {
                Text(letter.uppercased())
                    .font(DesignSystem.Font.headline)
                    .fontWeight(.bold)
                    .foregroundStyle(
                        typed != nil
                            ? DesignSystem.Color.onAccent
                            : DesignSystem.Color.textTertiary
                    )
            }
        }
    }

    func revealedCell(_ letter: String) -> some View {
        let color = wasSkipped
            ? DesignSystem.Color.textSecondary
            : DesignSystem.Color.success

        return ZStack {
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.small)
                .fill(color.opacity(0.2))
                .aspectRatio(32.0 / 36.0, contentMode: .fit)
                .overlay(
                    RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.small)
                        .stroke(color.opacity(0.5), lineWidth: 1.5)
                )

            Text(letter.uppercased())
                .font(DesignSystem.Font.headline)
                .fontWeight(.bold)
                .foregroundStyle(color)
        }
    }

    func cellBackground(typed: String?, isCorrect: Bool) -> Color {
        guard typed != nil else { return DesignSystem.Color.cardBackground }
        return isCorrect ? DesignSystem.Color.success : DesignSystem.Color.error
    }

    func cellBorderColor(typed: String?, isCorrect: Bool) -> Color {
        guard typed != nil else { return DesignSystem.Color.textTertiary.opacity(0.3) }
        return isCorrect ? DesignSystem.Color.success : DesignSystem.Color.error
    }
}

// MARK: - Helper
public enum LetterGridHelper {
    public struct WordSegment {
        public let letters: [Character]
        public let letterIndices: [Int]
        public let leadingSeparator: Character?

        public init(letters: [Character], letterIndices: [Int], leadingSeparator: Character?) {
            self.letters = letters
            self.letterIndices = letterIndices
            self.leadingSeparator = leadingSeparator
        }
    }

    public static func splitIntoSegments(_ name: String) -> [WordSegment] {
        var segments: [WordSegment] = []
        var currentLetters: [Character] = []
        var currentIndices: [Int] = []
        var letterIndex = 0
        var pendingSeparator: Character?

        for character in name {
            if character.isLetter {
                currentLetters.append(character)
                currentIndices.append(letterIndex)
                letterIndex += 1
            } else {
                if !currentLetters.isEmpty {
                    segments.append(
                        WordSegment(
                            letters: currentLetters,
                            letterIndices: currentIndices,
                            leadingSeparator: pendingSeparator
                        )
                    )
                    currentLetters = []
                    currentIndices = []
                    pendingSeparator = nil
                }
                pendingSeparator = character == " " ? nil : character
            }
        }

        if !currentLetters.isEmpty {
            segments.append(
                WordSegment(
                    letters: currentLetters,
                    letterIndices: currentIndices,
                    leadingSeparator: pendingSeparator
                )
            )
        }

        return segments
    }

    public static func lettersMatch(typed: String, target: String) -> Bool {
        let typedLetters = typed.lowercased().filter { $0.isLetter }
        let targetLetters = target.lowercased().filter { $0.isLetter }
        return typedLetters == targetLetters
    }
}
