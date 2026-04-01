import Geografy_Core_DesignSystem
import SwiftUI

struct HomeTriviaCard: View {
    let onTap: () -> Void

    var body: some View {
        Button { onTap() } label: {
            CardView {
                HStack(spacing: DesignSystem.Spacing.md) {
                    gameIcon
                    gameInfo
                    Spacer()
                    playButton
                }
                .padding(DesignSystem.Spacing.md)
            }
        }
        .buttonStyle(PressButtonStyle())
    }
}

// MARK: - Subviews
private extension HomeTriviaCard {
    var gameIcon: some View {
        ZStack {
            Circle()
                .fill(
                    RadialGradient(
                        colors: [DesignSystem.Color.blue.opacity(0.25), .clear],
                        center: .center,
                        startRadius: 0,
                        endRadius: 32
                    )
                )
                .frame(width: 56, height: 56)
            Image(systemName: "questionmark.bubble.fill")
                .font(DesignSystem.Font.iconMedium)
                .foregroundStyle(DesignSystem.Color.blue)
        }
    }

    var gameInfo: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text("Trivia")
                .font(DesignSystem.Font.headline)
                .fontWeight(.bold)
                .foregroundStyle(DesignSystem.Color.textPrimary)
            Text("Swipe true or false on geography facts")
                .font(DesignSystem.Font.caption)
                .foregroundStyle(DesignSystem.Color.textSecondary)
                .lineLimit(2)
        }
    }

    var playButton: some View {
        Text("Play")
            .font(DesignSystem.Font.subheadline)
            .fontWeight(.bold)
            .foregroundStyle(DesignSystem.Color.onAccent)
            .padding(.horizontal, DesignSystem.Spacing.md)
            .padding(.vertical, DesignSystem.Spacing.xs)
            .background(DesignSystem.Color.blue, in: Capsule())
    }
}
