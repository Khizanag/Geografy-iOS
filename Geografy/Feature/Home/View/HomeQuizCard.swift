import SwiftUI

struct HomeQuizCard: View {
    let onTap: () -> Void

    @State private var pulseScale: CGFloat = 1.0

    var body: some View {
        Button { onTap() } label: {
            ZStack(alignment: .bottomLeading) {
                cardBackground
                watermarkIcon
                cardContent
            }
            .clipShape(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.extraLarge))
            .shadow(color: Color(hex: "0F3460").opacity(0.5), radius: 24, y: 12)
        }
        .buttonStyle(GeoPressButtonStyle())
        .onAppear {
            withAnimation(.easeInOut(duration: 2.2).repeatForever(autoreverses: true)) {
                pulseScale = 1.05
            }
        }
    }
}

// MARK: - Subviews

private extension HomeQuizCard {
    var cardBackground: some View {
        LinearGradient(
            colors: [Color(hex: "0F3460"), Color(hex: "16213E"), Color(hex: "1A1A2E")],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    var watermarkIcon: some View {
        Image(systemName: "gamecontroller.fill")
            .font(DesignSystem.IconSize.flag)
            .foregroundStyle(.white.opacity(0.06))
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
            .offset(x: 24, y: -16)
            .clipped()
    }

    var cardContent: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            labelRow
            titleText
            quizTypePills
            startButton
        }
        .padding(DesignSystem.Spacing.lg)
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    var labelRow: some View {
        HStack(spacing: DesignSystem.Spacing.xs) {
            Image(systemName: "sparkles")
                .font(DesignSystem.Font.caption2)
                .foregroundStyle(DesignSystem.Color.accent)
            Text("QUIZ CHALLENGE")
                .font(DesignSystem.Font.caption2)
                .fontWeight(.bold)
                .foregroundStyle(DesignSystem.Color.accent)
                .kerning(1.2)
        }
    }

    var titleText: some View {
        Text("Test Your\nKnowledge")
            .font(DesignSystem.Font.largeTitle)
            .fontWeight(.bold)
            .foregroundStyle(DesignSystem.Color.onAccent)
            .lineSpacing(2)
    }

    var quizTypePills: some View {
        HStack(spacing: DesignSystem.Spacing.xs) {
            ForEach(["🚩 Flags", "🏛️ Capitals", "🗺️ Area"], id: \.self) { tag in
                Text(tag)
                    .font(DesignSystem.Font.caption2)
                    .foregroundStyle(.white.opacity(0.75))
                    .padding(.horizontal, DesignSystem.Spacing.xs)
                    .padding(.vertical, 4)
                    .background(.white.opacity(0.12), in: Capsule())
            }
        }
    }

    var startButton: some View {
        HStack(spacing: DesignSystem.Spacing.xs) {
            Text("Start Playing")
                .font(DesignSystem.Font.headline)
                .fontWeight(.semibold)
            Image(systemName: "arrow.right")
                .font(DesignSystem.Font.subheadline)
        }
        .foregroundStyle(DesignSystem.Color.onAccent)
        .padding(.horizontal, DesignSystem.Spacing.md)
        .padding(.vertical, DesignSystem.Spacing.sm)
        .background(DesignSystem.Color.accent.opacity(0.85))
        .clipShape(Capsule())
        .scaleEffect(pulseScale)
    }
}
