import SwiftUI

struct SpellingBeeScreen: View {
    @Environment(\.dismiss) private var dismiss

    @State private var countryDataService = CountryDataService()
    @State private var currentCountry: Country?
    @State private var typedText = ""
    @State private var usedHints: Set<HintType> = []
    @State private var feedback: SpellingFeedback = .none
    @State private var score = 0
    @State private var roundNumber = 0
    @State private var showCorrectAnswer = false
    @State private var showGuide = false
    @FocusState private var isInputFocused: Bool

    var body: some View {
        NavigationStack {
            ZStack {
                DesignSystem.Color.background.ignoresSafeArea()
                ScrollView {
                    VStack(spacing: DesignSystem.Spacing.lg) {
                        scorePill
                        if let country = currentCountry {
                            flagSection(for: country)
                            hintSection(for: country)
                            letterGrid
                            inputSection
                            hintButtons
                        }
                    }
                    .padding(.horizontal, DesignSystem.Spacing.md)
                    .padding(.top, DesignSystem.Spacing.lg)
                    .padding(.bottom, DesignSystem.Spacing.xxl)
                }
            }
            .navigationTitle("Spelling Bee")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button { showGuide = true } label: {
                        Image(systemName: "info.circle")
                    }
                    .buttonStyle(.plain)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    CircleCloseButton { dismiss() }
                }
            }
            .sheet(isPresented: $showGuide) { SpellingBeeGuideSheet() }
        }
        .onAppear {
            countryDataService.loadCountries()
            loadNextCountry()
        }
    }
}

// MARK: - Subviews

private extension SpellingBeeScreen {
    var scorePill: some View {
        HStack(spacing: DesignSystem.Spacing.md) {
            Label("Round \(roundNumber)", systemImage: "flag")
                .font(DesignSystem.Font.caption)
                .foregroundStyle(DesignSystem.Color.textSecondary)
            Spacer()
            HStack(spacing: DesignSystem.Spacing.xxs) {
                Image(systemName: "star.fill")
                    .foregroundStyle(DesignSystem.Color.accent)
                Text("\(score)")
                    .fontWeight(.bold)
                    .contentTransition(.numericText())
            }
            .font(DesignSystem.Font.subheadline)
            .foregroundStyle(DesignSystem.Color.textPrimary)
        }
        .padding(.horizontal, DesignSystem.Spacing.md)
        .padding(.vertical, DesignSystem.Spacing.sm)
        .background(DesignSystem.Color.cardBackground, in: Capsule())
    }

    func flagSection(for country: Country) -> some View {
        VStack(spacing: DesignSystem.Spacing.sm) {
            FlagView(countryCode: country.code, height: 80)
                .geoShadow(.subtle)
            Text(country.continent.displayName)
                .font(DesignSystem.Font.caption)
                .foregroundStyle(DesignSystem.Color.textSecondary)
                .padding(.horizontal, DesignSystem.Spacing.sm)
                .padding(.vertical, DesignSystem.Spacing.xxs)
                .background(DesignSystem.Color.cardBackground, in: Capsule())
        }
    }

    func hintSection(for country: Country) -> some View {
        VStack(spacing: DesignSystem.Spacing.sm) {
            if usedHints.contains(.firstLetter) {
                hintChip(
                    text: "First letter: \(String(country.name.prefix(1)))",
                    icon: "textformat"
                )
            }
            if usedHints.contains(.capital) {
                hintChip(text: "Capital: \(country.capital)", icon: "building.columns")
            }
            if usedHints.contains(.population) {
                hintChip(
                    text: "Population: \(country.population.formatted())",
                    icon: "person.2"
                )
            }
        }
    }

    func hintChip(text: String, icon: String) -> some View {
        HStack(spacing: DesignSystem.Spacing.xs) {
            Image(systemName: icon)
                .font(DesignSystem.Font.caption)
                .foregroundStyle(DesignSystem.Color.accent)
            Text(text)
                .font(DesignSystem.Font.caption)
                .foregroundStyle(DesignSystem.Color.textSecondary)
        }
        .padding(.horizontal, DesignSystem.Spacing.sm)
        .padding(.vertical, DesignSystem.Spacing.xxs)
        .background(DesignSystem.Color.cardBackground, in: Capsule())
    }

    var letterGrid: some View {
        CardView {
            VStack(spacing: DesignSystem.Spacing.sm) {
                if showCorrectAnswer, let country = currentCountry {
                    revealedLetterCells(for: country.name)
                } else {
                    letterCells
                }
            }
            .frame(maxWidth: .infinity)
            .padding(DesignSystem.Spacing.md)
        }
    }

    var letterCells: some View {
        let target = currentCountry?.name ?? ""
        let segments = splitIntoSegments(target)
        let targetLettersOnly = target.lowercased().filter { $0.isLetter }
        let typedLettersOnly = Array(typedText.lowercased().filter { $0.isLetter })

        return VStack(spacing: DesignSystem.Spacing.xs) {
            ForEach(Array(segments.enumerated()), id: \.offset) { _, segment in
                wordRowFromSegment(
                    segment: segment,
                    targetLetters: targetLettersOnly,
                    typedLetters: typedLettersOnly
                )
            }
        }
    }

    func wordRowFromSegment(
        segment: WordSegment,
        targetLetters: [Character],
        typedLetters: [Character]
    ) -> some View {
        HStack(spacing: DesignSystem.Spacing.xs) {
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
                    isCorrect: typedLetter == targetLetter,
                    isSpace: false
                )
            }
        }
    }

    func separatorCell(_ separator: String) -> some View {
        Text(separator)
            .font(DesignSystem.Font.headline)
            .fontWeight(.bold)
            .foregroundStyle(DesignSystem.Color.textTertiary)
            .frame(width: 16, height: 36)
    }

    func revealedLetterCells(for name: String) -> some View {
        let segments = splitIntoSegments(name)
        return VStack(spacing: DesignSystem.Spacing.xs) {
            ForEach(Array(segments.enumerated()), id: \.offset) { _, segment in
                HStack(spacing: DesignSystem.Spacing.xs) {
                    if let separator = segment.leadingSeparator {
                        separatorCell(String(separator))
                    }
                    ForEach(Array(segment.letters.enumerated()), id: \.offset) { _, letter in
                        revealedCell(String(letter))
                    }
                }
            }
        }
    }

    func revealedCell(_ letter: String) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.small)
                .fill(DesignSystem.Color.success.opacity(0.2))
                .frame(width: 32, height: 36)
                .overlay(
                    RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.small)
                        .stroke(DesignSystem.Color.success.opacity(0.5), lineWidth: 1.5)
                )
            Text(letter.uppercased())
                .font(DesignSystem.Font.headline)
                .fontWeight(.bold)
                .foregroundStyle(DesignSystem.Color.success)
        }
    }

    func letterCell(typed: String?, isCorrect: Bool, isSpace: Bool) -> some View {
        Group {
            if isSpace {
                Color.clear.frame(width: DesignSystem.Spacing.sm, height: 36)
            } else {
                ZStack {
                    RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.small)
                        .fill(cellBackground(typed: typed, isCorrect: isCorrect))
                        .frame(width: 32, height: 36)
                        .overlay(
                            RoundedRectangle(
                                cornerRadius: DesignSystem.CornerRadius.small
                            )
                            .stroke(
                                cellBorderColor(typed: typed, isCorrect: isCorrect),
                                lineWidth: 1.5
                            )
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
        }
    }

    var inputSection: some View {
        CardView {
            HStack {
                TextField("Type country name...", text: $typedText)
                    .font(DesignSystem.Font.headline)
                    .foregroundStyle(DesignSystem.Color.textPrimary)
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.never)
                    .focused($isInputFocused)
                    .onChange(of: typedText) { _, newValue in
                        validateInput(newValue)
                    }
                if !typedText.isEmpty {
                    Button { typedText = "" } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(DesignSystem.Color.textTertiary)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(DesignSystem.Spacing.md)
        }
    }

    var hintButtons: some View {
        HStack(spacing: DesignSystem.Spacing.sm) {
            hintButton(type: .firstLetter, icon: "textformat", label: "First Letter")
            hintButton(type: .capital, icon: "building.columns", label: "Capital")
            hintButton(type: .population, icon: "person.2", label: "Population")
        }
    }

    func hintButton(type: HintType, icon: String, label: String) -> some View {
        let isUsed = usedHints.contains(type)
        return Button {
            usedHints.insert(type)
        } label: {
            VStack(spacing: DesignSystem.Spacing.xxs) {
                Image(systemName: isUsed ? "\(icon).fill" : icon)
                    .font(DesignSystem.Font.subheadline)
                    .foregroundStyle(
                        isUsed
                            ? DesignSystem.Color.accent
                            : DesignSystem.Color.textSecondary
                    )
                Text(label)
                    .font(DesignSystem.Font.caption2)
                    .foregroundStyle(
                        isUsed
                            ? DesignSystem.Color.accent
                            : DesignSystem.Color.textTertiary
                    )
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, DesignSystem.Spacing.sm)
            .background(
                isUsed
                    ? DesignSystem.Color.accent.opacity(0.12)
                    : DesignSystem.Color.cardBackground,
                in: RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium)
            )
        }
        .buttonStyle(.plain)
        .disabled(isUsed)
    }

}

// MARK: - Helpers

private extension SpellingBeeScreen {
    func cellBackground(typed: String?, isCorrect: Bool) -> Color {
        guard typed != nil else { return DesignSystem.Color.cardBackgroundHighlighted }
        return isCorrect ? DesignSystem.Color.success : DesignSystem.Color.error
    }

    func cellBorderColor(typed: String?, isCorrect: Bool) -> Color {
        guard typed != nil else {
            return DesignSystem.Color.textTertiary.opacity(0.4)
        }
        return isCorrect ? DesignSystem.Color.success : DesignSystem.Color.error
    }
}

// MARK: - Actions

private extension SpellingBeeScreen {
    func loadNextCountry() {
        let countries = countryDataService.countries.filter { !$0.name.isEmpty }
        currentCountry = countries.randomElement()
        typedText = ""
        usedHints = []
        feedback = .none
        showCorrectAnswer = false
        roundNumber += 1
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            isInputFocused = true
        }
    }

    func validateInput(_ text: String) {
        guard let country = currentCountry else { return }
        if text.lowercased() == country.name.lowercased() {
            submitAnswer()
        }
    }

    func submitAnswer() {
        guard let country = currentCountry else { return }
        let typedLettersOnly = typedText.lowercased().filter { $0.isLetter }
        let targetLettersOnly = country.name.lowercased().filter { $0.isLetter }
        let isCorrect = typedLettersOnly == targetLettersOnly

        if isCorrect {
            let pointsEarned = max(10, 30 - (usedHints.count * 10))
            withAnimation {
                score += pointsEarned
            }
            feedback = .correct
            showCorrectAnswer = true
            isInputFocused = false
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                loadNextCountry()
            }
        } else {
            feedback = .wrong
            showCorrectAnswer = true
            isInputFocused = false
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.8) {
                loadNextCountry()
            }
        }
    }
}

// MARK: - Supporting Types

private extension SpellingBeeScreen {
    enum HintType: Hashable {
        case firstLetter
        case capital
        case population
    }

    enum SpellingFeedback: Equatable {
        case none
        case correct
        case wrong
    }

    struct WordSegment {
        let letters: [Character]
        let letterIndices: [Int]
        let leadingSeparator: Character?
    }

    func splitIntoSegments(_ name: String) -> [WordSegment] {
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
}
