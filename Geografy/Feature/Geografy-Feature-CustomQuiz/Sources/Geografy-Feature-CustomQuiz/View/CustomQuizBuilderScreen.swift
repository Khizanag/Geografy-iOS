#if !os(tvOS)
import Geografy_Core_Common
import Geografy_Core_DesignSystem
import Geografy_Core_Service
import SwiftUI

public struct CustomQuizBuilderScreen: View {
    // MARK: - Properties
    @Environment(\.dismiss) private var dismiss
    public let existingQuiz: CustomQuiz?
    public let countryDataService: CountryDataService
    public let quizService: CustomQuizService

    @State private var currentStep: BuilderStep = .name
    @State private var quizName = ""
    @State private var selectedIcon = CustomQuiz.availableIcons[0]
    @State private var selectedCountryCodes: Set<String> = []
    @State private var selectedQuestionTypes: Set<QuizType> = [.flagQuiz]
    @State private var showCountryPicker = false
    @State private var showPreview = false

    // MARK: - Init
    public init(
        existingQuiz: CustomQuiz? = nil,
        countryDataService: CountryDataService,
        quizService: CustomQuizService
    ) {
        self.existingQuiz = existingQuiz
        self.countryDataService = countryDataService
        self.quizService = quizService
    }

    // MARK: - Body
    public var body: some View {
        formContent
            .background(DesignSystem.Color.background)
            .navigationTitle(existingQuiz == nil ? "New Quiz" : "Edit Quiz")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear { loadExistingQuiz() }
            .sheet(isPresented: $showCountryPicker) { countryPickerSheet }
            .sheet(isPresented: $showPreview) { previewSheet }
    }
}

// MARK: - Main Content
private extension CustomQuizBuilderScreen {
    var formContent: some View {
        VStack(spacing: 0) {
            stepIndicator
            stepContent
            Spacer(minLength: 0)
            navigationButtons
        }
    }
}

// MARK: - Builder Step
private extension CustomQuizBuilderScreen {
    enum BuilderStep: Int, CaseIterable {
        case name
        case countries
        case questionTypes

        var title: String {
            switch self {
            case .name: "Name"
            case .countries: "Countries"
            case .questionTypes: "Questions"
            }
        }

        var icon: String {
            switch self {
            case .name: "pencil"
            case .countries: "globe"
            case .questionTypes: "list.bullet"
            }
        }
    }
}

// MARK: - Step Indicator
private extension CustomQuizBuilderScreen {
    var stepIndicator: some View {
        StepProgressBar(
            steps: BuilderStep.allCases.map(\.title),
            currentStep: currentStep.rawValue
        )
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
                }
            }
            .padding(DesignSystem.Spacing.md)
            .readableContentWidth()
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
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            Text("Icon")
                .font(DesignSystem.Font.headline)
                .foregroundStyle(DesignSystem.Color.textPrimary)

            LazyVGrid(
                columns: [GridItem(.adaptive(minimum: 56), spacing: DesignSystem.Spacing.sm)],
                spacing: DesignSystem.Spacing.sm
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
            ZStack {
                Circle()
                    .fill(
                        isSelected
                            ? DesignSystem.Color.accent.opacity(0.2)
                            : DesignSystem.Color.cardBackground
                    )
                Circle()
                    .strokeBorder(
                        isSelected
                            ? DesignSystem.Color.accent
                            : DesignSystem.Color.cardBackgroundHighlighted,
                        lineWidth: isSelected ? 2 : 1
                    )
                Image(systemName: icon)
                    .font(DesignSystem.Font.title3)
                    .foregroundStyle(
                        isSelected
                            ? DesignSystem.Color.accent
                            : DesignSystem.Color.textSecondary
                    )
            }
            .frame(width: 56, height: 56)
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

            GlassButton("Pick Countries", systemImage: "globe", fullWidth: true) {
                showCountryPicker = true
            }

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

// MARK: - Navigation Buttons
private extension CustomQuizBuilderScreen {
    var navigationButtons: some View {
        HStack(spacing: DesignSystem.Spacing.sm) {
            if currentStep != .name {
                GlassButton("Back", systemImage: "chevron.left", role: .secondary) {
                    goToPreviousStep()
                }
            }

            Spacer()

            if currentStep == .questionTypes {
                GlassButton("Preview", systemImage: "eye.fill") {
                    showPreview = true
                }
                .opacity(canProceed ? 1 : 0.5)
                .disabled(!canProceed)
            } else {
                GlassButton("Next", systemImage: "chevron.right") {
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
        case .countries: !selectedCountryCodes.isEmpty
        case .questionTypes: !selectedQuestionTypes.isEmpty
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
            return updated
        }
        return .makeNew(
            name: quizName,
            icon: selectedIcon,
            countryCodes: Array(selectedCountryCodes),
            questionTypes: Array(selectedQuestionTypes),
            difficulty: .medium,
        )
    }

    func loadExistingQuiz() {
        guard let quiz = existingQuiz else { return }
        quizName = quiz.name
        selectedIcon = quiz.icon
        selectedCountryCodes = Set(quiz.countryCodes)
        selectedQuestionTypes = Set(quiz.questionTypes)
    }
}
#endif
