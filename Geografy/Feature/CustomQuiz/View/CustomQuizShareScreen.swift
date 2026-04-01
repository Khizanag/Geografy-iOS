import Geografy_Core_Common
#if !os(tvOS)
import Geografy_Core_DesignSystem
import SwiftUI

struct CustomQuizShareScreen: View {
    let quiz: CustomQuiz

    var body: some View {
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
