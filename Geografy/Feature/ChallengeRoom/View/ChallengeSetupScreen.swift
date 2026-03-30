import SwiftUI

struct ChallengeSetupScreen: View {

    @State private var player1Name = ""
    @State private var player2Name = ""
    @State private var selectedMode: ChallengeMode = .passAndPlay
    @State private var selectedRounds = 10
    @State private var selectedQuizType: QuizType = .capitalQuiz
    @State private var selectedMetric: ComparisonMetric = .population
    @State private var showingGame = false
    @State private var challengeRoom: ChallengeRoom?

    @State private var countryDataService = CountryDataService()

    private let challengeRoomService = ChallengeRoomService()
    private let roundOptions = [5, 10, 15]

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: DesignSystem.Spacing.xl) {
                headerSection

                playersSection

                modeSection

                settingsSection
            }
            .padding(.horizontal, DesignSystem.Spacing.md)
            .padding(.vertical, DesignSystem.Spacing.md)
            .readableContentWidth()
        }
        .safeAreaInset(edge: .bottom) { startButton }
        .background { AmbientBlobsView(.standard) }
        .background(DesignSystem.Color.background.ignoresSafeArea())
        .navigationTitle("Challenge Room")
        .navigationBarTitleDisplayMode(.inline)
        .task { countryDataService.loadCountries() }
        .fullScreenCover(item: $challengeRoom) { room in
            NavigatorView {
                if selectedMode == .splitScreen {
                    ChallengeSplitScreen(
                        room: room,
                        challengeRoomService: challengeRoomService
                    )
                } else {
                    ChallengeGameScreen(
                        room: room,
                        challengeRoomService: challengeRoomService
                    )
                }
            }
        }
    }
}

// MARK: - Subviews
private extension ChallengeSetupScreen {
    var headerSection: some View {
        VStack(spacing: DesignSystem.Spacing.sm) {
            ZStack {
                Circle()
                    .fill(DesignSystem.Color.orange.opacity(0.15))
                    .frame(width: DesignSystem.Size.xxxl, height: DesignSystem.Size.xxxl)
                Image(systemName: "person.2.fill")
                    .font(DesignSystem.Font.iconLarge)
                    .foregroundStyle(DesignSystem.Color.orange)
            }

            VStack(spacing: DesignSystem.Spacing.xxs) {
                Text("Challenge a Friend")
                    .font(DesignSystem.Font.title2)
                    .fontWeight(.bold)
                    .foregroundStyle(DesignSystem.Color.textPrimary)

                Text("Compete head-to-head on geography")
                    .font(DesignSystem.Font.subheadline)
                    .foregroundStyle(DesignSystem.Color.textSecondary)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, DesignSystem.Spacing.md)
    }

    var playersSection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            sectionTitle("Players")

            CardView {
                VStack(spacing: DesignSystem.Spacing.md) {
                    playerField(
                        placeholder: "Player 1",
                        text: $player1Name,
                        icon: "1.circle.fill",
                        color: DesignSystem.Color.blue
                    )

                    Divider()

                    playerField(
                        placeholder: "Player 2",
                        text: $player2Name,
                        icon: "2.circle.fill",
                        color: DesignSystem.Color.orange
                    )
                }
                .padding(DesignSystem.Spacing.md)
            }
        }
    }

    func playerField(placeholder: String, text: Binding<String>, icon: String, color: Color) -> some View {
        HStack(spacing: DesignSystem.Spacing.sm) {
            Image(systemName: icon)
                .font(DesignSystem.Font.title3)
                .foregroundStyle(color)

            TextField(placeholder, text: text)
                .font(DesignSystem.Font.body)
                .foregroundStyle(DesignSystem.Color.textPrimary)
        }
    }

    var modeSection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            sectionTitle("Mode")

            VStack(spacing: DesignSystem.Spacing.xs) {
                ForEach(ChallengeMode.allCases, id: \.self) { mode in
                    modeRow(mode)
                }
            }
        }
    }

    func modeRow(_ mode: ChallengeMode) -> some View {
        let isSelected = selectedMode == mode
        return Button { selectedMode = mode } label: {
            CardView {
                HStack(spacing: DesignSystem.Spacing.md) {
                    ZStack {
                        Circle()
                            .fill(DesignSystem.Color.orange.opacity(isSelected ? 0.2 : 0.08))
                            .frame(width: 40, height: 40)
                        Image(systemName: mode.icon)
                            .font(DesignSystem.Font.subheadline)
                            .foregroundStyle(
                                isSelected ? DesignSystem.Color.orange : DesignSystem.Color.textSecondary
                            )
                    }

                    VStack(alignment: .leading, spacing: DesignSystem.Spacing.xxs) {
                        Text(mode.rawValue)
                            .font(DesignSystem.Font.subheadline)
                            .fontWeight(.semibold)
                            .foregroundStyle(DesignSystem.Color.textPrimary)

                        Text(mode.description)
                            .font(DesignSystem.Font.caption)
                            .foregroundStyle(DesignSystem.Color.textSecondary)
                    }

                    Spacer()

                    if isSelected {
                        Image(systemName: "checkmark.circle.fill")
                            .font(DesignSystem.Font.subheadline)
                            .foregroundStyle(DesignSystem.Color.orange)
                    }
                }
                .padding(DesignSystem.Spacing.sm)
            }
        }
        .buttonStyle(PressButtonStyle())
    }

    var settingsSection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            sectionTitle("Settings")

            CardView {
                VStack(spacing: DesignSystem.Spacing.md) {
                    roundsPicker

                    Divider()

                    quizTypePicker
                }
                .padding(DesignSystem.Spacing.md)
            }
        }
    }

    var roundsPicker: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            Label("Rounds", systemImage: "repeat")
                .font(DesignSystem.Font.subheadline)
                .fontWeight(.semibold)
                .foregroundStyle(DesignSystem.Color.textPrimary)

            HStack(spacing: DesignSystem.Spacing.sm) {
                ForEach(roundOptions, id: \.self) { option in
                    roundButton(option)
                }
            }
        }
    }

    func roundButton(_ rounds: Int) -> some View {
        let isSelected = selectedRounds == rounds
        return Button { selectedRounds = rounds } label: {
            Text("\(rounds)")
                .font(DesignSystem.Font.subheadline)
                .fontWeight(.semibold)
                .foregroundStyle(isSelected ? DesignSystem.Color.onAccent : DesignSystem.Color.textPrimary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, DesignSystem.Spacing.sm)
                .background(
                    isSelected ? DesignSystem.Color.orange : DesignSystem.Color.cardBackground,
                    in: RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.small)
                )
        }
        .buttonStyle(PressButtonStyle())
    }

    var quizTypePicker: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            Label("Quiz Type", systemImage: "questionmark.circle.fill")
                .font(DesignSystem.Font.subheadline)
                .fontWeight(.semibold)
                .foregroundStyle(DesignSystem.Color.textPrimary)

            ForEach(QuizType.allCases) { quizType in
                quizTypeRow(quizType)
            }

            if selectedQuizType.hasComparisonMetric {
                metricPicker
            }
        }
    }

    func quizTypeRow(_ quizType: QuizType) -> some View {
        let isSelected = selectedQuizType == quizType
        return Button { selectedQuizType = quizType } label: {
            HStack(spacing: DesignSystem.Spacing.sm) {
                Image(systemName: quizType.icon)
                    .font(DesignSystem.Font.caption)
                    .foregroundStyle(DesignSystem.Color.accent)
                    .frame(width: 20)

                Text(quizType.displayName)
                    .font(DesignSystem.Font.body)
                    .foregroundStyle(DesignSystem.Color.textPrimary)

                Spacer()

                if isSelected {
                    Image(systemName: "checkmark")
                        .font(DesignSystem.Font.subheadline)
                        .foregroundStyle(DesignSystem.Color.orange)
                }
            }
            .padding(.vertical, DesignSystem.Spacing.xs)
        }
        .buttonStyle(.plain)
    }

    var metricPicker: some View {
        HStack(spacing: DesignSystem.Spacing.xs) {
            ForEach(ComparisonMetric.allCases) { metric in
                let isSelected = selectedMetric == metric
                Button { selectedMetric = metric } label: {
                    VStack(spacing: DesignSystem.Spacing.xxs) {
                        Image(systemName: metric.icon)
                            .font(DesignSystem.Font.caption)

                        Text(metric.rawValue)
                            .font(DesignSystem.Font.caption2)
                            .fontWeight(.semibold)
                            .lineLimit(1)
                            .minimumScaleFactor(0.7)
                    }
                    .foregroundStyle(isSelected ? DesignSystem.Color.onAccent : DesignSystem.Color.textPrimary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, DesignSystem.Spacing.xs)
                    .background(
                        isSelected ? DesignSystem.Color.accent : DesignSystem.Color.cardBackground,
                        in: RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.small)
                    )
                }
                .buttonStyle(PressButtonStyle())
            }
        }
        .padding(.top, DesignSystem.Spacing.xs)
    }

    var startButton: some View {
        GlassButton("Start Challenge", systemImage: "play.fill", fullWidth: true) {
            startChallenge()
        }
        .disabled(!isFormValid)
        .opacity(isFormValid ? 1 : 0.5)
        .padding(.horizontal, DesignSystem.Spacing.md)
        .padding(.bottom, DesignSystem.Spacing.md)
    }
}

// MARK: - Helpers
private extension ChallengeSetupScreen {
    func sectionTitle(_ text: String) -> some View {
        Text(text)
            .font(DesignSystem.Font.headline)
            .fontWeight(.semibold)
            .foregroundStyle(DesignSystem.Color.textPrimary)
    }

    var isFormValid: Bool {
        !player1Name.trimmingCharacters(in: .whitespaces).isEmpty &&
        !player2Name.trimmingCharacters(in: .whitespaces).isEmpty
    }

    func startChallenge() {
        let name1 = player1Name.trimmingCharacters(in: .whitespaces)
        let name2 = player2Name.trimmingCharacters(in: .whitespaces)
        let configuration = ChallengeRoomService.RoomConfiguration(
            player1Name: name1.isEmpty ? "Player 1" : name1,
            player2Name: name2.isEmpty ? "Player 2" : name2,
            totalRounds: selectedRounds,
            quizType: selectedQuizType,
            comparisonMetric: selectedMetric,
            countries: countryDataService.countries
        )
        let room = challengeRoomService.generateRoom(configuration: configuration)
        challengeRoom = room
    }
}

extension ChallengeRoom: Identifiable {
    var id: String { "\(player1Name)-\(player2Name)-\(totalRounds)" }
}
