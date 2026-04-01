import Geografy_Core_DesignSystem
import SwiftUI

struct LaunchScreen: View {
    @State private var globeScale = 0.8
    @State private var globeOpacity = 0.0
    @State private var titleOpacity = 0.0

    var body: some View {
        mainContent
            .background(DesignSystem.Color.background.ignoresSafeArea())
            .onAppear { animateIn() }
    }
}

// MARK: - Subviews
private extension LaunchScreen {
    var mainContent: some View {
        VStack(spacing: DesignSystem.Spacing.lg) {
            Spacer()

            globeIcon

            appTitle

            Spacer()

            loadingIndicator
                .padding(.bottom, DesignSystem.Spacing.xxl)
        }
    }

    var globeIcon: some View {
        Image(systemName: "globe.europe.africa.fill")
            .font(DesignSystem.Font.system(size: 80, weight: .thin))
            .foregroundStyle(
                LinearGradient(
                    colors: [DesignSystem.Color.accent, DesignSystem.Color.blue],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .scaleEffect(globeScale)
            .opacity(globeOpacity)
    }

    var appTitle: some View {
        Text("Geografy")
            .font(DesignSystem.Font.displaySmall)
            .fontWeight(.bold)
            .foregroundStyle(DesignSystem.Color.textPrimary)
            .opacity(titleOpacity)
    }

    var loadingIndicator: some View {
        ProgressView()
            .tint(DesignSystem.Color.accent)
            .opacity(titleOpacity)
    }
}

// MARK: - Actions
private extension LaunchScreen {
    func animateIn() {
        withAnimation(.easeOut(duration: 0.6)) {
            globeScale = 1.0
            globeOpacity = 1.0
        }
        withAnimation(.easeOut(duration: 0.5).delay(0.2)) {
            titleOpacity = 1.0
        }
    }
}
