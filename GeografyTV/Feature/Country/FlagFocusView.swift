import Geografy_Core_Common
import Geografy_Core_DesignSystem
import SwiftUI

struct FlagFocusView: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.dismiss) private var dismiss

    let countryCode: String
    let countryName: String

    @State private var appeared = false

    var body: some View {
        ZStack {
            DesignSystem.Color.background.ignoresSafeArea()
            AmbientBlobsView(.tv)

            VStack(spacing: 40) {
                Spacer()

                flagContent

                countryLabel

                Spacer()

                dismissHint
            }
            .padding(60)
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.5)) {
                appeared = true
            }
        }
        .onExitCommand { dismiss() }
    }
}

// MARK: - Subviews
private extension FlagFocusView {
    var flagContent: some View {
        GeometryReader { geometryReader in
            let aspectRatio = FlagAspectRatio.ratio(for: countryCode) ?? 1.5
            let maxHeight = geometryReader.size.height * 0.7
            let maxWidth = geometryReader.size.width * 0.8
            let heightFromWidth = maxWidth / aspectRatio
            let targetHeight = min(heightFromWidth, maxHeight)

            FlagView(countryCode: countryCode, height: targetHeight)
                .shadow(
                    color: .black.opacity(0.4),
                    radius: 40,
                    y: 20
                )
                .scaleEffect(appeared ? 1.0 : 0.8)
                .opacity(appeared ? 1.0 : 0)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .frame(height: 500)
    }

    var countryLabel: some View {
        Text(countryName)
            .font(DesignSystem.Font.system(size: 44, weight: .bold))
            .foregroundStyle(DesignSystem.Color.textPrimary)
            .opacity(appeared ? 1.0 : 0)
    }

    var dismissHint: some View {
        Text("Press Menu to close")
            .font(DesignSystem.Font.system(size: 20))
            .foregroundStyle(DesignSystem.Color.textTertiary)
            .opacity(appeared ? 0.6 : 0)
    }
}
