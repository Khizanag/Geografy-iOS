import SwiftUI

struct TVQuizSetupScreen: View {
    let countryDataService: CountryDataService

    @State private var selectedType: QuizType = .flagQuiz
    @State private var selectedRegion: QuizRegion = .world
    @State private var selectedDifficulty: QuizDifficulty = .easy
    @State private var selectedCount = 10
    @State private var showQuiz = false

    var body: some View {
        Form {
            Section("Choose Your Quiz") {
                ForEach(QuizType.allCases) { type in
                    Button {
                        selectedType = type
                    } label: {
                        HStack(spacing: 20) {
                            Image(systemName: type.icon)
                                .font(.system(size: 28))
                                .foregroundStyle(DesignSystem.Color.accent)
                                .frame(width: 44)

                            VStack(alignment: .leading, spacing: 4) {
                                Text(type.displayName)
                                    .font(.system(size: 22, weight: .semibold))

                                Text(type.description)
                                    .font(.system(size: 18))
                                    .foregroundStyle(.secondary)
                            }

                            Spacer()

                            if selectedType == type {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.system(size: 24))
                                    .foregroundStyle(DesignSystem.Color.accent)
                            }
                        }
                    }
                }
            }

            Section("Difficulty") {
                ForEach(QuizDifficulty.allCases) { difficulty in
                    Button {
                        selectedDifficulty = difficulty
                    } label: {
                        HStack(spacing: 20) {
                            Image(systemName: difficulty.icon)
                                .font(.system(size: 24))
                                .foregroundStyle(DesignSystem.Color.accent)
                                .frame(width: 36)

                            VStack(alignment: .leading, spacing: 4) {
                                Text(difficulty.displayName)
                                    .font(.system(size: 22, weight: .semibold))

                                Text(difficulty.subtitle)
                                    .font(.system(size: 18))
                                    .foregroundStyle(.secondary)
                            }

                            Spacer()

                            if selectedDifficulty == difficulty {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.system(size: 24))
                                    .foregroundStyle(DesignSystem.Color.accent)
                            }
                        }
                    }
                }
            }

            Section("Settings") {
                Picker("Region", selection: $selectedRegion) {
                    ForEach(QuizRegion.allCases) { region in
                        Text(region.displayName)
                            .tag(region)
                    }
                }

                Picker("Questions", selection: $selectedCount) {
                    ForEach([5, 10, 15, 20, 30], id: \.self) { count in
                        Text("\(count)")
                            .tag(count)
                    }
                }
            }

            Section {
                Button {
                    showQuiz = true
                } label: {
                    HStack {
                        Spacer()
                        Label("Start \(selectedType.displayName)", systemImage: "play.fill")
                            .font(.system(size: 24, weight: .bold))
                        Spacer()
                    }
                }
            }
        }
        .navigationTitle("Quiz")
        .fullScreenCover(isPresented: $showQuiz) {
            TVQuizSessionScreen(
                countryDataService: countryDataService,
                quizType: selectedType,
                region: selectedRegion,
                difficulty: selectedDifficulty,
                questionCount: selectedCount,
            )
        }
    }
}
