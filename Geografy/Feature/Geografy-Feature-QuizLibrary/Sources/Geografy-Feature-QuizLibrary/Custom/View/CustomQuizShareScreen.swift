import Geografy_Core_Common
#if !os(tvOS)
import Geografy_Core_DesignSystem
import Geografy_Core_Navigation
import SwiftUI

public struct CustomQuizShareScreen: View {
    // MARK: - Properties
    public let quiz: CustomQuiz

    // MARK: - Init
    public init(quiz: CustomQuiz) {
        self.quiz = quiz
    }

    // MARK: - Body
    public var body: some View {
        scrollContent
            .screenBackground()
            .navigationTitle("Share Quiz")
            .navigationBarTitleDisplayMode(.inline)
            .closeButtonPlacementLeading()
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
            CardView(cornerRadius: DesignSystem.CornerRadius.medium) {
                Text(quiz.shareableJSON)
                    .font(DesignSystem.Font.textStyle(.caption, design: .monospaced))
                    .foregroundStyle(DesignSystem.Color.textPrimary)
                    .padding(DesignSystem.Spacing.md)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(DesignSystem.Spacing.md)
        }
    }
}
#endif
