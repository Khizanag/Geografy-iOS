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
            Section {
                Picker("Quiz Type", selection: $selectedType) {
                    ForEach(QuizType.allCases) { type in
                        Label(type.displayName, systemImage: type.icon)
                            .tag(type)
                    }
                }

                Picker("Region", selection: $selectedRegion) {
                    ForEach(QuizRegion.allCases) { region in
                        Text(region.displayName)
                            .tag(region)
                    }
                }

                Picker("Difficulty", selection: $selectedDifficulty) {
                    ForEach(QuizDifficulty.allCases) { difficulty in
                        Text(difficulty.displayName)
                            .tag(difficulty)
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
                    Label("Start Quiz", systemImage: "play.fill")
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
