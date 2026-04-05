import Geografy_Core_Common
import Geografy_Core_DesignSystem
import Geografy_Core_Navigation
import Geografy_Core_Service
import SwiftUI

public struct ModuleLessonsScreen: View {
    // MARK: - Init
    public init(
        module: LearningModule
    ) {
        self.module = module
    }
    // MARK: - Properties
    @Environment(Navigator.self) private var coordinator
    @Environment(LearningPathService.self) private var learningPathService

    public let module: LearningModule

    // MARK: - Body
    public var body: some View {
        scrollContent
            .background(DesignSystem.Color.background.ignoresSafeArea())
            .navigationTitle(module.title)
            #if !os(tvOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
    }
}

// MARK: - Subviews
private extension ModuleLessonsScreen {
    var scrollContent: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.lg) {
                moduleHeaderCard
                lessonsList
            }
            .padding(.vertical, DesignSystem.Spacing.md)
            .readableContentWidth()
        }
    }

    var currentModule: LearningModule {
        learningPathService.modules.first { $0.id == module.id } ?? module
    }

    var moduleHeaderCard: some View {
        CardView {
            HStack(spacing: DesignSystem.Spacing.md) {
                ZStack {
                    Circle()
                        .fill(DesignSystem.Color.accent.opacity(0.15))
                        .frame(width: 52, height: 52)
                    Image(systemName: module.icon)
                        .font(DesignSystem.Font.iconMedium)
                        .foregroundStyle(DesignSystem.Color.accent)
                }
                VStack(alignment: .leading, spacing: 4) {
                    Text(module.description)
                        .font(DesignSystem.Font.subheadline)
                        .foregroundStyle(DesignSystem.Color.textSecondary)
                        .lineLimit(3)
                    Text("\(currentModule.completedCount) of \(currentModule.totalCount) lessons")
                        .font(DesignSystem.Font.caption)
                        .fontWeight(.semibold)
                        .foregroundStyle(DesignSystem.Color.accent)
                }
            }
            .padding(DesignSystem.Spacing.md)
        }
        .padding(.horizontal, DesignSystem.Spacing.md)
    }

    var lessonsList: some View {
        VStack(spacing: DesignSystem.Spacing.sm) {
            ForEach(Array(currentModule.lessons.enumerated()), id: \.element.id) { index, lesson in
                Button { coordinator.push(.lesson(currentModule, lesson)) } label: {
                    lessonRow(lesson: lesson, index: index)
                }
                .buttonStyle(PressButtonStyle())
                .padding(.horizontal, DesignSystem.Spacing.md)
            }
        }
    }

    func lessonRow(lesson: Lesson, index: Int) -> some View {
        CardView {
            HStack(spacing: DesignSystem.Spacing.md) {
                lessonNumberBadge(index: index, isCompleted: lesson.isCompleted)
                lessonInfo(lesson: lesson)
                Spacer()
                Image(systemName: "chevron.right")
                    .font(DesignSystem.Font.caption)
                    .foregroundStyle(DesignSystem.Color.textTertiary)
            }
            .padding(DesignSystem.Spacing.md)
        }
    }

    func lessonNumberBadge(index: Int, isCompleted: Bool) -> some View {
        ZStack {
            Circle()
                .fill(
                    isCompleted
                        ? DesignSystem.Color.success.opacity(0.15)
                        : DesignSystem.Color.accent.opacity(0.12)
                )
                .frame(width: 36, height: 36)
            if isCompleted {
                Image(systemName: "checkmark")
                    .font(DesignSystem.Font.iconXS.bold())
                    .foregroundStyle(DesignSystem.Color.success)
            } else {
                Text("\(index + 1)")
                    .font(DesignSystem.Font.headline)
                    .fontWeight(.bold)
                    .foregroundStyle(DesignSystem.Color.accent)
            }
        }
    }

    func lessonInfo(lesson: Lesson) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(lesson.title)
                .font(DesignSystem.Font.subheadline)
                .fontWeight(.semibold)
                .foregroundStyle(DesignSystem.Color.textPrimary)
                .lineLimit(1)
            HStack(spacing: DesignSystem.Spacing.xxs) {
                Image(systemName: lessonTypeIcon(lesson.type))
                    .font(DesignSystem.Font.caption2)
                    .foregroundStyle(DesignSystem.Color.textSecondary)
                Text(lessonTypeLabel(lesson.type))
                    .font(DesignSystem.Font.caption)
                    .foregroundStyle(DesignSystem.Color.textSecondary)
            }
        }
    }

    func lessonTypeIcon(_ type: Lesson.LessonType) -> String {
        switch type {
        case .reading: "book.fill"
        case .quiz: "checkmark.circle.fill"
        case .matching: "arrow.left.arrow.right"
        }
    }

    func lessonTypeLabel(_ type: Lesson.LessonType) -> String {
        switch type {
        case .reading: "Reading"
        case .quiz: "Quiz"
        case .matching: "Matching"
        }
    }
}
