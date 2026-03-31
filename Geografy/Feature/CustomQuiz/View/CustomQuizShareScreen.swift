import SwiftUI
import GeografyDesign

struct CustomQuizShareScreen: View {
    let quiz: CustomQuiz

    var body: some View {
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
        .background(DesignSystem.Color.background)
        .navigationTitle("Share Quiz")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    UIPasteboard.general.string = quiz.shareableJSON
                } label: {
                    Label("Copy", systemImage: "doc.on.doc")
                }
            }
        }
    }
}
