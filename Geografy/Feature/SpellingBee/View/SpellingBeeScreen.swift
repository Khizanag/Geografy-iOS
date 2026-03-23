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
    @FocusState private var isInputFocused: Bool

    var body: some View {
        ZStack {
            backgroundView
            mainContent
        }
        .navigationBarHidden(true)
        .onAppear {
            countryDataService.loadCountries()
            loadNextCountry()
        }
    }
}

// MARK: - Subviews

private extension SpellingBeeScreen {
    var backgroundView: some View {
        DesignSystem.Color.background
            .ignoresSafeArea()
    }

    var mainContent: some View {
        ScrollView {
            VStack(spacing: DesignSystem.Spacing.lg) {
                topBar
                if let country = currentCountry {
                    flagSection(for: country)
                    hintSection(for: country)
                    letterGrid
                    inputSection
                    actionRow
                }
                Spacer(minLength: DesignSystem.Spacing.xxl)
            }
            .padding(.horizontal, DesignSystem.Spacing.md)
            .padding(.top, DesignSystem.Spacing.lg)
        }
    }

    var topBar: some View {
        HStack {
            dismissButton
            Spacer()
            scoreView
            Spacer()
            roundView
        }
    }

    var dismissButton: some View {
        Button { dismiss() } label: {
            Image(systemName: "xmark")
                .font(DesignSystem.Font.subheadline)
                .foregroundStyle(DesignSystem.Color.textSecondary)
                .padding(DesignSystem.Spacing.xs)
                .background(DesignSystem.Color.cardBackground, in: Circle())
        }
        .buttonStyle(.plain)
    }

    var scoreView: some View {
        VStack(spacing: 2) {
            Text("\(score)")
                .font(DesignSystem.Font.title2)
                .fontWeight(.bold)
                .foregroundStyle(DesignSystem.Color.textPrimary)
                .contentTransition(.numericText())
            Text("Score")
                .font(DesignSystem.Font.caption2)
                .foregroundStyle(DesignSystem.Color.textTertiary)
        }
    }

    var roundView: some View {
        Text("Round \(roundNumber)")
            .font(DesignSystem.Font.caption)
            .foregroundStyle(DesignSystem.Color.textTertiary)
            .frame(minWidth: 60, alignment: .trailing)
    }

    func flagSection(for country: Country) -> some View {
        VStack(spacing: DesignSystem.Spacing.sm) {
            FlagView(countryCode: country.code, height: 80)
                .shadow(color: .black.opacity(0.25), radius: 8, x: 0, y: 4)
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
                hintChip(text: "First letter: \(String(country.name.prefix(1)))", icon: "textformat")
            }
            if usedHints.contains(.capital) {
                hintChip(text: "Capital: \(country.capital)", icon: "building.columns")
            }
            if usedHints.contains(.population) {
                hintChip(text: "Population: \(country.population.formatted())", icon: "person.2")
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
                    Text(country.name)
                        .font(DesignSystem.Font.headline)
                        .fontWeight(.bold)
                        .foregroundStyle(DesignSystem.Color.success)
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
        let letters = Array(typedText.lowercased())
        let targetLetters = Array(target.lowercased())

        return FlowLayout(spacing: DesignSystem.Spacing.xs) {
            ForEach(Array(targetLetters.enumerated()), id: \.offset) { index, targetLetter in
                let typedLetter: Character? = index < letters.count ? letters[index] : nil
                letterCell(
                    typed: typedLetter.map { String($0) },
                    isCorrect: typedLetter == targetLetter,
                    isSpace: targetLetter == " "
                )
            }
        }
    }

    func letterCell(typed: String?, isCorrect: Bool, isSpace: Bool) -> some View {
        Group {
            if isSpace {
                Spacer().frame(width: DesignSystem.Spacing.sm)
            } else {
                ZStack {
                    RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.small)
                        .fill(cellBackground(typed: typed, isCorrect: isCorrect))
                        .frame(width: 32, height: 36)
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
        }
    }

    func cellBackground(typed: String?, isCorrect: Bool) -> Color {
        guard typed != nil else { return DesignSystem.Color.cardBackgroundHighlighted }
        return isCorrect ? DesignSystem.Color.success : DesignSystem.Color.error
    }

    func cellBorderColor(typed: String?, isCorrect: Bool) -> Color {
        guard typed != nil else { return DesignSystem.Color.textTertiary.opacity(0.4) }
        return isCorrect ? DesignSystem.Color.success : DesignSystem.Color.error
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

    var actionRow: some View {
        VStack(spacing: DesignSystem.Spacing.md) {
            hintButtons
            submitButton
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
                    .foregroundStyle(isUsed ? DesignSystem.Color.accent : DesignSystem.Color.textSecondary)
                Text(label)
                    .font(DesignSystem.Font.caption2)
                    .foregroundStyle(isUsed ? DesignSystem.Color.accent : DesignSystem.Color.textTertiary)
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

    var submitButton: some View {
        Button { submitAnswer() } label: {
            HStack(spacing: DesignSystem.Spacing.xs) {
                Image(systemName: "checkmark")
                Text("Submit")
                    .fontWeight(.bold)
            }
            .font(DesignSystem.Font.headline)
            .foregroundStyle(DesignSystem.Color.textPrimary)
            .frame(maxWidth: .infinity)
            .padding(.vertical, DesignSystem.Spacing.md)
        }
        .buttonStyle(.glass)
        .disabled(typedText.trimmingCharacters(in: .whitespaces).isEmpty)
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
        let normalized = typedText.trimmingCharacters(in: .whitespaces).lowercased()
        let isCorrect = normalized == country.name.lowercased()

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
}

// MARK: - FlowLayout

private struct FlowLayout<Content: View>: View {
    let spacing: CGFloat
    let content: Content

    init(spacing: CGFloat = 8, @ViewBuilder content: () -> Content) {
        self.spacing = spacing
        self.content = content()
    }

    var body: some View {
        _VariadicView.Tree(FlowLayoutHelper(spacing: spacing)) {
            content
        }
    }
}

private struct FlowLayoutHelper: _VariadicView_UnaryViewRoot {
    let spacing: CGFloat

    func body(children: _VariadicView.Children) -> some View {
        GeometryReader { geometryReader in
            let width = geometryReader.size.width
            buildRows(children: children, width: width)
        }
    }

    func buildRows(children: _VariadicView.Children, width: CGFloat) -> some View {
        VStack(alignment: .leading, spacing: spacing) {
            HStack(spacing: spacing) {
                ForEach(children) { child in
                    child
                }
            }
        }
    }
}
