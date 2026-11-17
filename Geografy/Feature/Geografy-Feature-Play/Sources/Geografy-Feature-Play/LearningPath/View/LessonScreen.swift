import Geografy_Core_Common
import Geografy_Core_DesignSystem
import Geografy_Core_Navigation
import Geografy_Core_Service
import SwiftUI

public struct LessonScreen: View {
    // MARK: - Init
    public init(
        module: LearningModule,
        lesson: Lesson
    ) {
        self.module = module
        self.lesson = lesson
    }
    // MARK: - Properties
    @Environment(\.dismiss) private var dismiss
    @Environment(XPService.self) private var xpService
    @Environment(LearningPathService.self) private var learningPathService
    @Environment(CountryDataService.self) private var countryDataService
    @Environment(Navigator.self) private var coordinator
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    public let module: LearningModule
    public let lesson: Lesson

    @State private var playingQuizID: UUID?
    @State private var lastAccuracy: Double?

    // MARK: - Body
    public var body: some View {
        scrollContent
            .screenBackground()
            .navigationTitle(lesson.title)
            #if !os(tvOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .safeAreaBar(edge: .bottom) {
                Group {
                    if let quiz = lesson.quiz, !isCompleted {
                        startQuizButton(quiz)
                    } else {
                        completeButton
                    }
                }
                .padding(.horizontal, DesignSystem.Spacing.md)
                .padding(.vertical, DesignSystem.Spacing.sm)
            }
            .onReceive(NotificationCenter.default.publisher(for: QuizConfiguration.finishedNotification)) {
                recordQuiz($0)
            }
    }
}

// MARK: - Subviews
private extension LessonScreen {
    var scrollContent: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.xl) {
                lessonTypeTag
                lessonContent
                if lesson.quiz != nil {
                    quizRequirement
                }
            }
            .padding(DesignSystem.Spacing.md)
            .readableContentWidth()
        }
    }

    var lessonTypeTag: some View {
        InfoPill(typeLabel, systemImage: typeIcon, style: .accent)
    }

    var lessonContent: some View {
        CardView {
            Text(lesson.content)
                .font(DesignSystem.Font.body)
                .foregroundStyle(DesignSystem.Color.textPrimary)
                .lineSpacing(6)
                .padding(DesignSystem.Spacing.md)
        }
    }

    var completeButton: some View {
        GlassButton(isCompleted ? "Already Completed" : "Mark as Complete", fullWidth: true) {
            complete()
            dismiss()
        }
        .disabled(isCompleted)
    }

    func startQuizButton(_ quiz: LessonQuiz) -> some View {
        GlassButton(lastAccuracy == nil ? "Start Quiz" : "Try Again", systemImage: "play.fill", fullWidth: true) {
            let configuration = quiz.configuration(countries: countryDataService.countries)
            playingQuizID = configuration.id
            coordinator.cover(PlayRoute.quizSession(configuration))
        }
        .disabled(countryDataService.countries.isEmpty)
    }

    /// What passing takes, and how the last try went.
    var quizRequirement: some View {
        let passPercent = Int(LessonQuiz.passingAccuracy * 100)
        return HStack(spacing: DesignSystem.Spacing.sm) {
            Image(systemName: isCompleted ? "checkmark.seal.fill" : "target")
                .foregroundStyle(isCompleted ? DesignSystem.Color.success : DesignSystem.Color.blue)
                .accessibilityHidden(true)
            Group {
                if isCompleted {
                    Text("Passed. This lesson is complete.")
                } else if let lastAccuracy {
                    Text("You scored \(Int(lastAccuracy * 100))%. Score \(passPercent)% or more to complete it.")
                } else {
                    Text("Score \(passPercent)% or more on the quiz to complete this lesson.")
                }
            }
            .font(DesignSystem.Font.subheadline)
            .foregroundStyle(DesignSystem.Color.textSecondary)
        }
        .accessibilityElement(children: .combine)
    }
    var typeIcon: String {
        switch lesson.type {
        case .reading: "book.fill"
        case .quiz: "checkmark.circle.fill"
        case .matching: "arrow.left.arrow.right"
        }
    }

    var typeLabel: String {
        switch lesson.type {
        case .reading: "Reading"
        case .quiz: "Quiz"
        case .matching: "Matching"
        }
    }
}

// MARK: - Completion
private extension LessonScreen {
    /// Read live, so the screen shows the lesson as complete the moment its quiz is passed.
    var isCompleted: Bool {
        learningPathService.modules
            .first { $0.id == module.id }?
            .lessons.first { $0.id == lesson.id }?
            .isCompleted ?? lesson.isCompleted
    }

    func complete() {
        if learningPathService.completeLesson(moduleID: module.id, lessonID: lesson.id) {
            xpService.award(XPRules.lessonCompleted, source: .lessonCompleted)
        }
    }

    func recordQuiz(_ notification: Notification) {
        guard let playingQuizID,
              notification.object as? UUID == playingQuizID,
              let accuracy = notification.userInfo?[QuizConfiguration.accuracyKey] as? Double
        else { return }
        self.playingQuizID = nil
        lastAccuracy = accuracy
        if LessonQuiz.passes(accuracy: accuracy) {
            complete()
        }
    }
}
