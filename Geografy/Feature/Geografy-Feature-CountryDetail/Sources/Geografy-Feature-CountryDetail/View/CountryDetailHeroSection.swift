import Geografy_Core_Common
import Geografy_Core_DesignSystem
import Geografy_Core_Service
import SwiftUI

// MARK: - Hero
extension CountryDetailScreen {
    var heroSection: some View {
        CardView(cornerRadius: DesignSystem.CornerRadius.extraLarge) {
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

            HStack(spacing: DesignSystem.Spacing.xs) {
                Text(country.name)
                    .font(DesignSystem.Font.title)
                    .foregroundStyle(DesignSystem.Color.textPrimary)
                    .multilineTextAlignment(.center)
                #if !os(tvOS)
                SpeakerButton(text: country.name, countryCode: country.code)
                #endif
            }
            .frame(maxWidth: .infinity)
        }
        .frame(maxWidth: .infinity)
        .padding(DesignSystem.Spacing.xl)
    }
}
