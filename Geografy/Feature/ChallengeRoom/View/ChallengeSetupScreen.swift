import SwiftUI

struct ChallengeSetupScreen: View {
    @Environment(\.dismiss) private var dismiss

    @State private var player1Name = ""
    @State private var player2Name = ""
    @State private var selectedRounds = 10
    @State private var selectedCategory = ChallengeCategory.mixed
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
                settingsSection
                startButton
            }
            .padding(.horizontal, DesignSystem.Spacing.md)
            .padding(.vertical, DesignSystem.Spacing.md)
        }
        .background(DesignSystem.Color.background.ignoresSafeArea())
        .navigationTitle("Challenge Room")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                CircleCloseButton { dismiss() }
            }
        }
        .task { countryDataService.loadCountries() }
        .fullScreenCover(item: $challengeRoom) { room in
            ChallengeGameScreen(
                room: room,
                challengeRoomService: challengeRoomService
            )
        }
    }
}

// MARK: - Subviews

private extension ChallengeSetupScreen {
    var headerSection: some View {
        VStack(spacing: DesignSystem.Spacing.sm) {
            ZStack {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [DesignSystem.Color.orange.opacity(0.25), .clear],
                            center: .center,
                            startRadius: 0,
                            endRadius: 50
                        )
                    )
                    .frame(width: 88, height: 88)
                Image(systemName: "person.2.fill")
                    .font(.system(size: 36))
                    .foregroundStyle(DesignSystem.Color.orange)
            }
            Text("Challenge a Friend")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundStyle(DesignSystem.Color.textPrimary)
            Text("Pass the device between turns")
                .font(DesignSystem.Font.subheadline)
                .foregroundStyle(DesignSystem.Color.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, DesignSystem.Spacing.lg)
    }

    var playersSection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            SectionHeaderView(title: "Players", icon: "person.fill")
            CardView {
                VStack(spacing: DesignSystem.Spacing.md) {
                    playerField(
                        placeholder: "Player 1 name",
                        text: $player1Name,
                        icon: "1.circle.fill",
                        color: DesignSystem.Color.blue
                    )
                    Divider()
                    playerField(
                        placeholder: "Player 2 name",
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
                .font(.system(size: 20))
                .foregroundStyle(color)
            TextField(placeholder, text: text)
                .font(DesignSystem.Font.body)
                .foregroundStyle(DesignSystem.Color.textPrimary)
        }
    }

    var settingsSection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            SectionHeaderView(title: "Settings", icon: "gearshape.fill")
            CardView {
                VStack(spacing: DesignSystem.Spacing.md) {
                    roundsPicker
                    Divider()
                    categoryPicker
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
        return Button {
            selectedRounds = rounds
        } label: {
            Text("\(rounds)")
                .font(DesignSystem.Font.subheadline)
                .fontWeight(.semibold)
                .foregroundStyle(isSelected ? DesignSystem.Color.onAccent : DesignSystem.Color.textPrimary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, DesignSystem.Spacing.sm)
                .background(
                    isSelected ? DesignSystem.Color.accent : DesignSystem.Color.cardBackground,
                    in: RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.small)
                )
        }
        .buttonStyle(PressButtonStyle())
    }

    var categoryPicker: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            Label("Category", systemImage: "tag.fill")
                .font(DesignSystem.Font.subheadline)
                .fontWeight(.semibold)
                .foregroundStyle(DesignSystem.Color.textPrimary)
            ForEach(ChallengeCategory.allCases, id: \.rawValue) { category in
                categoryRow(category)
            }
        }
    }

    func categoryRow(_ category: ChallengeCategory) -> some View {
        let isSelected = selectedCategory == category
        return Button {
            selectedCategory = category
        } label: {
            HStack {
                Text(category.rawValue)
                    .font(DesignSystem.Font.body)
                    .foregroundStyle(DesignSystem.Color.textPrimary)
                Spacer()
                if isSelected {
                    Image(systemName: "checkmark")
                        .font(DesignSystem.Font.subheadline)
                        .foregroundStyle(DesignSystem.Color.accent)
                }
            }
            .padding(.vertical, DesignSystem.Spacing.xs)
        }
        .buttonStyle(.plain)
    }

    var startButton: some View {
        Button {
            startChallenge()
        } label: {
            Text("Start Challenge")
                .font(DesignSystem.Font.headline)
                .fontWeight(.bold)
                .foregroundStyle(DesignSystem.Color.onAccent)
                .frame(maxWidth: .infinity)
                .padding(.vertical, DesignSystem.Spacing.md)
                .background(
                    isFormValid ? DesignSystem.Color.accent : DesignSystem.Color.textSecondary.opacity(0.3),
                    in: RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium)
                )
        }
        .disabled(!isFormValid)
        .buttonStyle(PressButtonStyle())
        .padding(.bottom, DesignSystem.Spacing.lg)
    }
}

// MARK: - Actions

private extension ChallengeSetupScreen {
    var isFormValid: Bool {
        !player1Name.trimmingCharacters(in: .whitespaces).isEmpty &&
        !player2Name.trimmingCharacters(in: .whitespaces).isEmpty
    }

    func startChallenge() {
        let room = challengeRoomService.generateRoom(
            player1Name: player1Name.trimmingCharacters(in: .whitespaces),
            player2Name: player2Name.trimmingCharacters(in: .whitespaces),
            totalRounds: selectedRounds,
            category: selectedCategory,
            countries: countryDataService.countries
        )
        challengeRoom = room
    }
}

extension ChallengeRoom: Identifiable {
    var id: String { "\(player1Name)-\(player2Name)-\(totalRounds)" }
}
