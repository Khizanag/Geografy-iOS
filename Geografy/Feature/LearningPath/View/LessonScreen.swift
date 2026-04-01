import Geografy_Core_Common
import Geografy_Core_DesignSystem
import SwiftUI

struct LessonScreen: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(LearningPathService.self) private var learningPathService
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    let module: LearningModule
    let lesson: Lesson

    @State private var blobAnimating = false

    var body: some View {
        scrollContent
            .background { ambientBlobs }
            .background(DesignSystem.Color.background.ignoresSafeArea())
            .navigationTitle(lesson.title)
            .navigationBarTitleDisplayMode(.inline)
            .safeAreaInset(edge: .bottom) {
                completeButton
                    .padding(.horizontal, DesignSystem.Spacing.md)
                    .padding(.vertical, DesignSystem.Spacing.sm)
                    .background(.ultraThinMaterial)
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    CircleCloseButton { dismiss() }
                }
            }
            .onAppear { startBlobAnimation() }
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
        HStack(spacing: DesignSystem.Spacing.xs) {
            Image(systemName: typeIcon)
                .font(DesignSystem.Font.caption)
                .foregroundStyle(DesignSystem.Color.accent)
            Text(typeLabel)
                .font(DesignSystem.Font.caption)
                .fontWeight(.semibold)
                .foregroundStyle(DesignSystem.Color.accent)
        }
        .padding(.horizontal, DesignSystem.Spacing.sm)
        .padding(.vertical, DesignSystem.Spacing.xxs)
        .background(DesignSystem.Color.accent.opacity(0.12), in: Capsule())
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

    var ambientBlobs: some View {
        ZStack {
            blobEllipse(color: DesignSystem.Color.accent, opacity: 0.20, offset: (100, -180), animates: blobAnimating)
            blobEllipse(color: DesignSystem.Color.indigo, opacity: 0.18, offset: (-120, 250), animates: !blobAnimating)
        }
        .allowsHitTesting(false)
        .animation(reduceMotion ? nil : .easeInOut(duration: 6).repeatForever(autoreverses: true), value: blobAnimating)
    }

    func blobEllipse(color: Color, opacity: Double, offset: (CGFloat, CGFloat), animates: Bool) -> some View {
        Ellipse()
            .fill(
                RadialGradient(
                    colors: [color.opacity(opacity), .clear],
                    center: .center,
                    startRadius: 0,
                    endRadius: 180
                )
            )
            .frame(width: 360, height: 280)
            .blur(radius: 36)
            .offset(x: offset.0, y: offset.1)
            .scaleEffect(animates ? 1.08 : 0.92)
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

// MARK: - Actions
private extension LessonScreen {
    func startBlobAnimation() {
        blobAnimating = true
    }
}
