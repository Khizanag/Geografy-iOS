import Geografy_Core_Common
#if !os(tvOS)
import Geografy_Core_DesignSystem
import SwiftUI

public struct CustomQuizShareScreen: View {
    public let quiz: CustomQuiz

    public init(quiz: CustomQuiz) {
        self.quiz = quiz
    }

    public var body: some View {
        scrollContent
            .background(DesignSystem.Color.background)
            .navigationTitle("Share Quiz")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        UIPasteboard.general.string = quiz.shareableJSON
                    } label: {
                        Label("Copy", systemImage: "doc.on.doc")
                    }
                }
            }
    }
}

// MARK: - Subviews
private extension CustomQuizShareScreen {
    var scrollContent: some View {
        ScrollView {
            Text(quiz.shareableJSON)
                .font(.system(.caption, design: .monospaced))
                .foregroundStyle(DesignSystem.Color.textPrimary)
                .padding(DesignSystem.Spacing.md)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(DesignSystem.Color.cardBackground)
                .clipShape(
                    RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium)
                )
                .padding(DesignSystem.Spacing.md)
        }
    }
}
#endif
