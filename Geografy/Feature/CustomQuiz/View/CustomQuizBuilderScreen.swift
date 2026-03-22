import SwiftUI

struct CustomQuizBuilderScreen: View {
    @Environment(\.dismiss) private var dismiss
    let existingQuiz: CustomQuiz?
    let countryDataService: CountryDataService
    let quizService: CustomQuizService

    @State private var currentStep: BuilderStep = .name
    @State private var quizName = ""
    @State private var selectedIcon = CustomQuiz.availableIcons[0]
    @State private var selectedCountryCodes: Set<String> = []
    @State private var selectedQuestionTypes: Set<QuizType> = [.flagQuiz]
    @State private var selectedDifficulty: QuizDifficulty = .easy
    @State private var showCountryPicker = false
    @State private var showPreview = false

    init(
        existingQuiz: CustomQuiz? = nil,
        countryDataService: CountryDataService,
        quizService: CustomQuizService
    ) {
        self.existingQuiz = existingQuiz
        self.countryDataService = countryDataService
        self.quizService = quizService
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                stepIndicator
                stepContent
                Spacer(minLength: 0)
                navigationButtons
            }
            .background(DesignSystem.Color.background)
            .navigationTitle(existingQuiz == nil ? "New Quiz" : "Edit Quiz")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { toolbarContent }
            .sheet(isPresented: $showCountryPicker) { countryPickerSheet }
            .sheet(isPresented: $showPreview) { previewSheet }
            .onAppear { loadExistingQuiz() }
        }
    }
}

// MARK: - Builder Step

private extension CustomQuizBuilderScreen {
    enum BuilderStep: Int, CaseIterable {
        case name
        case countries
        case questionTypes
        case difficulty

        var title: String {
            switch self {
            case .name: "Name"
            case .countries: "Countries"
            case .questionTypes: "Questions"
            case .difficulty: "Difficulty"
            }
        }

        var icon: String {
            switch self {
            case .name: "pencil"
            case .countries: "globe"
            case .questionTypes: "list.bullet"
            case .difficulty: "speedometer"
            }
        }
    }
}

// MARK: - Step Indicator

private extension CustomQuizBuilderScreen {
    var stepIndicator: some View {
        HStack(spacing: DesignSystem.Spacing.xs) {
            ForEach(BuilderStep.allCases, id: \.rawValue) { step in
                stepDot(step)
            }
        }
        .padding(.vertical, DesignSystem.Spacing.sm)
    }

    func stepDot(_ step: BuilderStep) -> some View {
        let isActive = step == currentStep
        let isCompleted = step.rawValue < currentStep.rawValue

        return VStack(spacing: DesignSystem.Spacing.xxs) {
            Circle()
                .fill(isActive ? DesignSystem.Color.accent : isCompleted ? DesignSystem.Color.success : DesignSystem.Color.cardBackgroundHighlighted)
                .frame(width: 10, height: 10)

            Text(step.title)
                .font(DesignSystem.Font.caption2)
                .foregroundStyle(isActive ? DesignSystem.Color.accent : DesignSystem.Color.textTertiary)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Step Content

private extension CustomQuizBuilderScreen {
    @ViewBuilder
    var stepContent: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.lg) {
                switch currentStep {
                case .name: nameStep
                case .countries: countriesStep
                case .questionTypes: questionTypesStep
                case .difficulty: difficultyStep
                }
            }
            .padding(DesignSystem.Spacing.md)
        }
    }
}

// MARK: - Name Step

private extension CustomQuizBuilderScreen {
    var nameStep: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.lg) {
            stepHeader(title: "Name Your Quiz", subtitle: "Give your quiz a memorable name")
            nameField
            iconPicker
        }
    }

    var nameField: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
            Text("Quiz Name")
                .font(DesignSystem.Font.headline)
                .foregroundStyle(DesignSystem.Color.textPrimary)

            TextField("e.g. European Capitals", text: $quizName)
                .font(DesignSystem.Font.body)
                .padding(DesignSystem.Spacing.sm)
                .background(DesignSystem.Color.cardBackground)
                .clipShape(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium))
                .overlay(
                    RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium)
                        .strokeBorder(
                            nameValidationColor,
                            lineWidth: 1,
                        )
                )

            if isDuplicateName {
                Text("A quiz with this name already exists")
                    .font(DesignSystem.Font.caption)
                    .foregroundStyle(DesignSystem.Color.error)
            }
        }
    }

    var iconPicker: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
            Text("Icon")
                .font(DesignSystem.Font.headline)
                .foregroundStyle(DesignSystem.Color.textPrimary)

            LazyVGrid(
                columns: [GridItem(.adaptive(minimum: 48), spacing: DesignSystem.Spacing.xs)],
                spacing: DesignSystem.Spacing.xs
            ) {
                ForEach(CustomQuiz.availableIcons, id: \.self) { icon in
                    iconButton(icon)
                }
            }
        }
    }

    func iconButton(_ icon: String) -> some View {
        let isSelected = selectedIcon == icon
        return Button {
            selectedIcon = icon
        } label: {
            Image(systemName: icon)
                .font(DesignSystem.Font.title2)
                .foregroundStyle(
                    isSelected ? DesignSystem.Color.accent : DesignSystem.Color.textSecondary
                )
                .frame(width: 48, height: 48)
                .background(
                    isSelected ? DesignSystem.Color.accent.opacity(0.15) : DesignSystem.Color.cardBackground
                )
                .clipShape(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.small))
                .overlay(
                    RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.small)
                        .strokeBorder(
                            isSelected ? DesignSystem.Color.accent : DesignSystem.Color.cardBackgroundHighlighted,
                            lineWidth: isSelected ? 2 : 1,
                        )
                )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Countries Step

private extension CustomQuizBuilderScreen {
    var countriesStep: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.lg) {
            stepHeader(
                title: "Select Countries",
                subtitle: "Choose which countries to include (\(selectedCountryCodes.count) selected)",
            )

            Button {
                showCountryPicker = true
            } label: {
                Label("Pick Countries", systemImage: "globe")
                    .font(DesignSystem.Font.headline)
                    .foregroundStyle(DesignSystem.Color.textPrimary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, DesignSystem.Spacing.xxs)
            }
            .buttonStyle(.glass)

            selectedCountrySummary
        }
    }

    @ViewBuilder
    var selectedCountrySummary: some View {
        if !selectedCountryCodes.isEmpty {
            let countries = countryDataService.countries.filter {
                selectedCountryCodes.contains($0.code)
            }
            let grouped = Dictionary(grouping: countries, by: \.continent)

            VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
                ForEach(
                    grouped.keys.sorted(by: { $0.displayName < $1.displayName }),
                    id: \.self
                ) { continent in
                    continentSummaryRow(continent, count: grouped[continent]?.count ?? 0)
                }
            }
        }
    }

    func continentSummaryRow(_ continent: Country.Continent, count: Int) -> some View {
        HStack {
            Text(continent.displayName)
                .font(DesignSystem.Font.subheadline)
                .foregroundStyle(DesignSystem.Color.textPrimary)

            Spacer()

            Text("\(count)")
                .font(DesignSystem.Font.subheadline)
                .foregroundStyle(DesignSystem.Color.textSecondary)
        }
        .padding(.horizontal, DesignSystem.Spacing.sm)
        .padding(.vertical, DesignSystem.Spacing.xs)
        .background(DesignSystem.Color.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.small))
    }
}

// MARK: - Question Types Step

private extension CustomQuizBuilderScreen {
    var questionTypesStep: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.lg) {
            stepHeader(
                title: "Question Types",
                subtitle: "Select one or more question formats",
            )

            TypeSelectionGrid(
                items: QuizType.allCases.map { $0 },
                selectedIDs: Set(selectedQuestionTypes.map(\.id)),
                onSelect: { toggleQuestionType($0) }
            )
        }
    }
}

// MARK: - Difficulty Step

private extension CustomQuizBuilderScreen {
    var difficultyStep: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.lg) {
            stepHeader(title: "Set Difficulty", subtitle: "Choose how challenging the quiz should be")

            Picker("Difficulty", selection: $selectedDifficulty) {
                ForEach(QuizDifficulty.allCases) { difficulty in
                    Text(difficulty.displayName).tag(difficulty)
                }
            }
            .pickerStyle(.segmented)

            difficultyDetail
        }
    }

    var difficultyDetail: some View {
        HStack(spacing: DesignSystem.Spacing.xs) {
            Image(systemName: selectedDifficulty.icon)
                .font(DesignSystem.Font.caption2)
                .foregroundStyle(DesignSystem.Color.accent)
            Text(selectedDifficulty.subtitle)
                .font(DesignSystem.Font.caption)
                .foregroundStyle(DesignSystem.Color.textSecondary)
        }
        .animation(.easeInOut(duration: 0.2), value: selectedDifficulty)
    }
}

// MARK: - Navigation Buttons

private extension CustomQuizBuilderScreen {
    var navigationButtons: some View {
        HStack(spacing: DesignSystem.Spacing.sm) {
            if currentStep != .name {
                GeoButton("Back", systemImage: "chevron.left", style: .secondary) {
                    goToPreviousStep()
                }
            }

            Spacer()

            if currentStep == .difficulty {
                GeoButton("Preview", systemImage: "eye.fill") {
                    showPreview = true
                }
                .opacity(canProceed ? 1 : 0.5)
                .disabled(!canProceed)
            } else {
                GeoButton("Next", systemImage: "chevron.right") {
                    goToNextStep()
                }
                .opacity(canProceed ? 1 : 0.5)
                .disabled(!canProceed)
            }
        }
        .padding(.horizontal, DesignSystem.Spacing.md)
        .padding(.bottom, DesignSystem.Spacing.md)
    }
}

// MARK: - Toolbar

private extension CustomQuizBuilderScreen {
    @ToolbarContentBuilder
    var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .topBarLeading) {
            CircleCloseButton()
        }
    }
}

// MARK: - Sheets

private extension CustomQuizBuilderScreen {
    var countryPickerSheet: some View {
        CustomQuizCountryPicker(
            countries: countryDataService.countries,
            selectedCodes: $selectedCountryCodes,
        )
    }

    var previewSheet: some View {
        CustomQuizPreviewScreen(quiz: buildQuiz()) { quiz in
            if existingQuiz != nil {
                quizService.update(quiz)
            } else {
                quizService.save(quiz)
            }
            dismiss()
        }
    }
}

// MARK: - Helpers

private extension CustomQuizBuilderScreen {
    func stepHeader(title: String, subtitle: String) -> some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.xxs) {
            Text(title)
                .font(DesignSystem.Font.title2)
                .foregroundStyle(DesignSystem.Color.textPrimary)
            Text(subtitle)
                .font(DesignSystem.Font.subheadline)
                .foregroundStyle(DesignSystem.Color.textSecondary)
        }
    }

    var nameValidationColor: Color {
        if quizName.isEmpty {
            DesignSystem.Color.cardBackgroundHighlighted
        } else if isDuplicateName {
            DesignSystem.Color.error
        } else {
            DesignSystem.Color.accent.opacity(0.5)
        }
    }

    var isDuplicateName: Bool {
        quizService.nameExists(quizName, excluding: existingQuiz?.id)
    }

    var canProceed: Bool {
        switch currentStep {
        case .name: !quizName.trimmingCharacters(in: .whitespaces).isEmpty && !isDuplicateName
        case .countries: selectedCountryCodes.count >= 4
        case .questionTypes: !selectedQuestionTypes.isEmpty
        case .difficulty: true
        }
    }

    func goToNextStep() {
        guard canProceed,
              let nextIndex = BuilderStep.allCases.firstIndex(of: currentStep)
                .map({ $0 + 1 }),
              nextIndex < BuilderStep.allCases.count else {
            return
        }
        withAnimation { currentStep = BuilderStep.allCases[nextIndex] }
    }

    func goToPreviousStep() {
        guard let previousIndex = BuilderStep.allCases.firstIndex(of: currentStep)
                .map({ $0 - 1 }),
              previousIndex >= 0 else {
            return
        }
        withAnimation { currentStep = BuilderStep.allCases[previousIndex] }
    }

    func toggleQuestionType(_ type: QuizType) {
        if selectedQuestionTypes.contains(type) {
            if selectedQuestionTypes.count > 1 {
                selectedQuestionTypes.remove(type)
            }
        } else {
            selectedQuestionTypes.insert(type)
        }
    }

    func buildQuiz() -> CustomQuiz {
        if let existingQuiz {
            var updated = existingQuiz
            updated.name = quizName
            updated.icon = selectedIcon
            updated.countryCodes = Array(selectedCountryCodes)
            updated.questionTypes = Array(selectedQuestionTypes)
            updated.difficulty = selectedDifficulty
            return updated
        }
        return .makeNew(
            name: quizName,
            icon: selectedIcon,
            countryCodes: Array(selectedCountryCodes),
            questionTypes: Array(selectedQuestionTypes),
            difficulty: selectedDifficulty,
        )
    }

    func loadExistingQuiz() {
        guard let quiz = existingQuiz else { return }
        quizName = quiz.name
        selectedIcon = quiz.icon
        selectedCountryCodes = Set(quiz.countryCodes)
        selectedQuestionTypes = Set(quiz.questionTypes)
        selectedDifficulty = quiz.difficulty
    }
}
