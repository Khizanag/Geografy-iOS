import Geografy_Core_Common
import Geografy_Core_DesignSystem
import Geografy_Core_Navigation
import Geografy_Core_Service
import SwiftUI

public struct QuizPackDetailScreen: View {
    // MARK: - Properties
    @Environment(Navigator.self) private var coordinator
    @Environment(CountryDataService.self) private var countryDataService
    @Environment(\.locale) private var locale

    public let packID: String

    @Environment(QuizPackService.self) private var packService
    @State private var allPacks: [QuizPack] = []
    /// The quiz started from this screen and the level it plays, so its result is recorded against that level.
    @State private var playing: (quizID: UUID, levelID: String)?

    // MARK: - Init
    public init(packID: String) {
        self.packID = packID
    }

    private var pack: QuizPack? {
        allPacks.first { $0.id == packID }
    }

    // MARK: - Body
    public var body: some View {
        Group {
            if let pack {
                packContent(pack)
            } else {
                LoadingView()
            }
        }
        .screenBackground()
        .navigationTitle(pack?.name ?? "Quiz Pack")
        #if !os(tvOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
        .task(id: countryDataService.countries.count) {
            packService.loadProgress()
            allPacks = QuizPackService.makeAllPacks(
                countries: countryDataService.countries
            )
        }
        .onReceive(NotificationCenter.default.publisher(for: QuizConfiguration.finishedNotification)) { notification in
            recordResult(notification)
        }
    }
}

// MARK: - Content
private extension QuizPackDetailScreen {
    func packContent(_ pack: QuizPack) -> some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.lg) {
                GameIntroHeader(
                    title: pack.name,
                    subtitle: pack.description,
                    systemImage: pack.icon,
                    color: pack.color,
                    facts: facts(for: pack)
                )
                progressOverview(pack)
                levelsSection(pack)
            }
            .padding(.horizontal, DesignSystem.Spacing.md)
            .padding(.vertical, DesignSystem.Spacing.sm)
            .readableContentWidth()
        }
        .bottomActionBar {
            if let level = nextLevel(in: pack) {
                GlassButton(
                    String(localized: "Play Level \(level.levelIndex)", in: locale),
                    systemImage: "play.fill",
                    fullWidth: true
                ) {
                    play(level, in: pack)
                }
            }
        }
    }
}

// MARK: - Facts
private extension QuizPackDetailScreen {
    func facts(for pack: QuizPack) -> [GameIntroHeader.Fact] {
        [
            .init(
                String(localized: "\(pack.totalQuestions) questions", in: locale),
                systemImage: "questionmark.circle"
            ),
            .init(
                String(localized: "\(pack.levelCount) levels", in: locale),
                systemImage: "square.grid.3x3.fill"
            ),
        ]
    }
}

// MARK: - Progress Overview
private extension QuizPackDetailScreen {
    func progressOverview(_ pack: QuizPack) -> some View {
        StatTileRow {
            StatTile(
                value: "\(packService.completedLevelCount(for: pack))/\(pack.levelCount)",
                label: "Levels done",
                icon: "checkmark.circle.fill",
                color: DesignSystem.Color.success
            )
            StatTile(
                value: "\(packService.totalStars(for: pack))/\(packService.maxStars(for: pack))",
                label: "Stars",
                icon: "star.fill",
                color: DesignSystem.Color.warning
            )
        }
    }
}

// MARK: - Levels Section
private extension QuizPackDetailScreen {
    static let levelColumns = [GridItem(.adaptive(minimum: 72), spacing: DesignSystem.Spacing.sm)]

    func levelsSection(_ pack: QuizPack) -> some View {
        let next = nextLevel(in: pack)
        return VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            SectionHeaderView(title: "Levels")

            LazyVGrid(columns: Self.levelColumns, spacing: DesignSystem.Spacing.sm) {
                ForEach(Array(pack.levels.enumerated()), id: \.element.id) { index, level in
                    let locked = isLevelLocked(at: index, in: pack)
                    Button {
                        play(level, in: pack)
                    } label: {
                        QuizPackLevelTile(
                            level: level,
                            stars: packService.stars(for: level.id),
                            isLocked: locked,
                            isNext: level.id == next?.id,
                            color: pack.color
                        )
                    }
                    .buttonStyle(PressButtonStyle())
                    .disabled(locked)
                }
            }
        }
    }

    func isLevelLocked(at index: Int, in pack: QuizPack) -> Bool {
        guard index > 0 else { return false }
        let previousLevel = pack.levels[index - 1]
        return packService.progress(for: previousLevel.id) == nil
    }

    /// The first level not played yet; once all are, the first one short of three stars.
    func nextLevel(in pack: QuizPack) -> QuizPackLevel? {
        pack.levels.first { packService.progress(for: $0.id) == nil }
            ?? pack.levels.first { packService.stars(for: $0.id) < 3 }
            ?? pack.levels.first
    }
}

// MARK: - Actions
private extension QuizPackDetailScreen {
    func play(_ level: QuizPackLevel, in pack: QuizPack) {
        let metric: ComparisonMetric =
            pack.category == .population ? .population : .area

        let config = QuizConfiguration(
            type: pack.category.quizType,
            region: .world,
            difficulty: .easy,
            questionCount: QuestionCount(rawValue: level.questionCount) ?? .ten,
            answerMode: .multipleChoice,
            comparisonMetric: metric,
            gameMode: .standard,
            countryCodes: level.countryCodes
        )

        playing = (config.id, level.id)
        coordinator.cover(PlayRoute.quizSession(config))
    }

    func recordResult(_ notification: Notification) {
        guard let playing,
              notification.object as? UUID == playing.quizID,
              let accuracy = notification.userInfo?[QuizConfiguration.accuracyKey] as? Double else {
            return
        }
        packService.recordCompletion(levelID: playing.levelID, accuracy: accuracy)
        self.playing = nil
    }
}
