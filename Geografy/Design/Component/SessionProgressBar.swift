import SwiftUI
import GeografyDesign

struct SessionProgressBar: View {
    let progress: CGFloat
    var height: CGFloat = 6

    @State private var animatedProgress: CGFloat = 0

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(DesignSystem.Color.cardBackgroundHighlighted)
                Capsule()
                    .fill(
                        LinearGradient(
                            colors: [
                                DesignSystem.Color.accent,
                                DesignSystem.Color.accent.opacity(0.7),
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: max(geometry.size.width * animatedProgress, 0))
                    .shadow(
                        color: DesignSystem.Color.accent.opacity(0.5),
                        radius: 6,
                        x: 4
                    )
            }
        }
        .frame(height: height)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Progress")
        .accessibilityValue("\(Int(progress * 100)) percent")
        .onChange(of: progress) {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.6)) {
                animatedProgress = progress
            }
        }
    }
}
