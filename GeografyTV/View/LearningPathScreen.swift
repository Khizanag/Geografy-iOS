import SwiftUI
import GeografyDesign

struct LearningPathScreen: View {
    @State private var service = LearningPathService()

    var body: some View {
        List(service.modules) { module in
            NavigationLink {
                TVModuleLessonsScreen(module: module, service: service)
            } label: {
                HStack(spacing: 20) {
                    Image(systemName: module.icon)
                        .font(.system(size: 28))
                        .foregroundStyle(
                            module.isUnlocked
                                ? DesignSystem.Color.accent
                                : DesignSystem.Color.textTertiary
                        )
                        .frame(width: 44)

                    VStack(alignment: .leading, spacing: 6) {
                        Text(module.title)
                            .font(.system(size: 22, weight: .semibold))

                        Text(module.description)
                            .font(.system(size: 22))
                            .foregroundStyle(.secondary)
                            .lineLimit(1)

                        if module.isUnlocked {
                            ProgressView(value: module.progressFraction)
                                .tint(DesignSystem.Color.accent)
                        }
                    }

                    Spacer()

                    if module.isCompleted {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 24))
                            .foregroundStyle(DesignSystem.Color.success)
                    } else if !module.isUnlocked {
                        Image(systemName: "lock.fill")
                            .font(.system(size: 20))
                            .foregroundStyle(DesignSystem.Color.textTertiary)
                    }
                }
            }
            .disabled(!module.isUnlocked)
        }
        .navigationTitle("Learning Path")
    }
}

// MARK: - Module Lessons
struct TVModuleLessonsScreen: View {
    let module: LearningModule
    let service: LearningPathService

    var body: some View {
        List(module.lessons) { lesson in
            HStack(spacing: 20) {
                Image(systemName: lesson.isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 24))
                    .foregroundStyle(
                        lesson.isCompleted
                            ? DesignSystem.Color.success
                            : DesignSystem.Color.textTertiary
                    )

                VStack(alignment: .leading, spacing: 4) {
                    Text(lesson.title)
                        .font(.system(size: 22, weight: .semibold))

                    Text(lesson.type.rawValue.capitalized)
                        .font(.system(size: 22))
                        .foregroundStyle(.secondary)
                }

                Spacer()

                if !lesson.isCompleted {
                    Button("Complete") {
                        service.completeLesson(moduleID: module.id, lessonID: lesson.id)
                    }
                    .buttonStyle(.bordered)
                }
            }
        }
        .navigationTitle(module.title)
    }
}
