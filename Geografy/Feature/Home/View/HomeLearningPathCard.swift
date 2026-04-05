import Geografy_Core_DesignSystem
import Geografy_Feature_LearningPath
import SwiftUI

struct HomeLearningPathCard: View {
    // MARK: - Properties
    @Environment(LearningPathService.self) private var learningPathService
    let onTap: () -> Void

    // MARK: - Body
    var body: some View {
        Button { onTap() } label: {
            CardView {
                HStack(spacing: DesignSystem.Spacing.md) {
                    pathIcon
                    pathInfo
                    Spacer()
                    actionButton
                }
                .padding(DesignSystem.Spacing.md)
            }
        }
        .buttonStyle(PressButtonStyle())
    }
}

// MARK: - Subviews
private extension HomeLearningPathCard {
    var pathIcon: some View {
        ZStack {
            Circle()
                .fill(
                    RadialGradient(
                        colors: [DesignSystem.Color.blue.opacity(0.28), .clear],
                        center: .center,
                        startRadius: 0,
                        endRadius: 32
                    )
                )
                .frame(width: 56, height: 56)
            Image(systemName: "graduationcap.fill")
                .font(DesignSystem.Font.iconMedium)
                .foregroundStyle(DesignSystem.Color.blue)
        }
    }

    var pathInfo: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text("Learning Path")
                .font(DesignSystem.Font.headline)
                .fontWeight(.bold)
                .foregroundStyle(DesignSystem.Color.textPrimary)
            Text(subtitleText)
                .font(DesignSystem.Font.caption)
                .foregroundStyle(DesignSystem.Color.textSecondary)
                .lineLimit(2)
        }
    }

    var actionButton: some View {
        Text("Explore")
            .font(DesignSystem.Font.subheadline)
            .fontWeight(.bold)
            .foregroundStyle(DesignSystem.Color.onAccent)
            .padding(.horizontal, DesignSystem.Spacing.md)
            .padding(.vertical, DesignSystem.Spacing.xs)
            .background(DesignSystem.Color.blue, in: Capsule())
    }

    var subtitleText: String {
        let completed = learningPathService.modules.flatMap { $0.lessons }.filter { $0.isCompleted }.count
        let total = learningPathService.modules.flatMap { $0.lessons }.count
        if completed == 0 {
            return "Start your geography journey"
        }
        return "\(completed) of \(total) lessons done"
    }
}
