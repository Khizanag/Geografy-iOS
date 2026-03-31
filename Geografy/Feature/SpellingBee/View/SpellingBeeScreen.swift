import SwiftUI
import Accessibility
import GeografyCore
import GeografyDesign

struct SpellingBeeScreen: View {
    @State private var countryDataService = CountryDataService()
    @State private var currentCountry: Country?
    @State private var typedText = ""
    @State private var usedHints: Set<HintType> = []
    @State private var feedback: SpellingFeedback = .none
    @State private var score = 0
    @State private var roundNumber = 0
    @State private var showCorrectAnswer = false
    @State private var showGuide = false
    @AppStorage("spellingBee_autoContinue") private var autoContinue = true
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

                            if showCorrectAnswer, !autoContinue {
                                nextButton
                            } else {
                                inputSection

                                hintButtons
                            }
                        }
                    }
                    .padding(.horizontal, DesignSystem.Spacing.md)
                    .padding(.top, DesignSystem.Spacing.lg)
                    .padding(.bottom, DesignSystem.Spacing.xxl)
                    .readableContentWidth()
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
                    .accessibilityLabel("Show guide")
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button { autoContinue.toggle() } label: {
                        Image(systemName: autoContinue ? "forward.fill" : "forward")
                            .foregroundStyle(
                                autoContinue
                                    ? DesignSystem.Color.accent
                                    : DesignSystem.Color.textTertiary
                            )
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("Auto continue: \(autoContinue ? "on" : "off")")
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
                    .accessibilityHidden(true)
                Text("\(score)")
                    .fontWeight(.bold)
                    .contentTransition(.numericText())
            }
            .font(DesignSystem.Font.subheadline)
            .foregroundStyle(DesignSystem.Color.textPrimary)
            .accessibilityElement(children: .combine)
            .accessibilityLabel("Score: \(score)")
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
                .accessibilityHidden(true)
            Text(text)
                .font(DesignSystem.Font.caption)
                .foregroundStyle(DesignSystem.Color.textSecondary)
        }
        .padding(.horizontal, DesignSystem.Spacing.sm)
        .padding(.vertical, DesignSystem.Spacing.xxs)
        .background(DesignSystem.Color.cardBackground, in: Capsule())
        .accessibilityElement(children: .combine)
    }

    var letterGrid: some View {
        CardView {
            LetterGridView(
                targetText: currentCountry?.name ?? "",
                typedText: typedText,
                isRevealed: showCorrectAnswer
            )
            .frame(maxWidth: .infinity)
            .padding(DesignSystem.Spacing.md)
        }
    }

    var nextButton: some View {
        GlassButton("Next", systemImage: "arrow.right", fullWidth: true) {
            loadNextCountry()
        }
    }

    var inputSection: some View {
        TextField("", text: $typedText)
            .autocorrectionDisabled()
            .textInputAutocapitalization(.characters)
            .focused($isInputFocused)
            .onChange(of: typedText) { _, newValue in
                validateInput(newValue)
            }
            .frame(width: 1, height: 1)
            .opacity(0)
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
        if LetterGridHelper.lettersMatch(typed: text, target: country.name) {
            submitAnswer()
        }
    }

    func submitAnswer() {
        guard let country = currentCountry else { return }
        let isCorrect = LetterGridHelper.lettersMatch(typed: typedText, target: country.name)

        if isCorrect {
            let pointsEarned = max(10, 30 - (usedHints.count * 10))
            withAnimation {
                score += pointsEarned
            }
            feedback = .correct
            showCorrectAnswer = true
            isInputFocused = false
            AccessibilityNotification.Announcement("Correct! Plus \(pointsEarned) points").post()
            if autoContinue {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                    loadNextCountry()
                }
            }
        } else {
            feedback = .wrong
            showCorrectAnswer = true
            isInputFocused = false
            AccessibilityNotification.Announcement("Incorrect. The answer was \(country.name)").post()
            if autoContinue {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.8) {
                    loadNextCountry()
                }
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
