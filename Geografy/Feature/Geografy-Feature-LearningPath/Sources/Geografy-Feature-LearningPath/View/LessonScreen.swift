import Geografy_Core_Common
import Geografy_Core_DesignSystem
import Geografy_Core_Navigation
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
    @Environment(LearningPathService.self) private var learningPathService
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    public let module: LearningModule
    public let lesson: Lesson

    // MARK: - Body
    public var body: some View {
        scrollContent
            .screenBackground()
            .navigationTitle(lesson.title)
            #if !os(tvOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .safeAreaInset(edge: .bottom) {
                completeButton
                    .padding(.horizontal, DesignSystem.Spacing.md)
                    .padding(.vertical, DesignSystem.Spacing.sm)
                    .background(.ultraThinMaterial)
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
        GlassButton(lesson.isCompleted ? "Already Completed" : "Mark as Complete", fullWidth: true) {
            learningPathService.completeLesson(moduleID: module.id, lessonID: lesson.id)
            dismiss()
        }
        .disabled(lesson.isCompleted)
        .opacity(lesson.isCompleted ? 0.5 : 1)
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
