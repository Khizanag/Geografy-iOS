import Geografy_Core_Common
import Geografy_Core_DesignSystem
import Geografy_Core_Service
import SwiftUI

// MARK: - Hero
extension CountryDetailScreen {
    var heroSection: some View {
        CardView {
            heroCardContent
        }
    }

    var heroCardContent: some View {
        VStack(spacing: DesignSystem.Spacing.md) {
            Button {
                withAnimation(.easeInOut(duration: 0.25)) {
                    showFlagFullScreen = true
                }
            } label: {
                FlagView(countryCode: country.code, height: 120)
                    .opacity(flagScrolledUp ? 0 : 1)
                    .geoShadow(.elevated)
                    .onGeometryChange(for: Bool.self) { proxy in
                        proxy.frame(in: .scrollView).maxY < 0
                    } action: { isHidden in
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                            flagScrolledUp = isHidden
                        }
                    }
            }
            .buttonStyle(.plain)

            // An empty slot the button's width on the left keeps the name centered under the flag.
            HStack(spacing: DesignSystem.Spacing.xs) {
                Color.clear
                    .frame(width: SpeakerButton.size, height: SpeakerButton.size)
                    .accessibilityHidden(true)
                Text(country.name)
                    .font(DesignSystem.Font.title)
                    .foregroundStyle(DesignSystem.Color.textPrimary)
                    .multilineTextAlignment(.center)
                SpeakerButton(text: country.name, countryCode: country.code)
            }
            .frame(maxWidth: .infinity)
        }
        .frame(maxWidth: .infinity)
        .padding(DesignSystem.Spacing.xl)
    }
}
