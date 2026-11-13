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
                withAnimation(reduceMotion ? nil : .easeInOut(duration: 0.25)) {
                    showFlagFullScreen = true
                }
            } label: {
                FlagView(countryCode: country.code, height: 120)
                    .opacity(flagScrolledUp ? 0 : 1)
                    .geoShadow(.elevated)
                    .onGeometryChange(for: Bool.self) { proxy in
                        proxy.frame(in: .scrollView).maxY < 0
                    } action: { isHidden in
                        withAnimation(reduceMotion ? nil : .spring(response: 0.35, dampingFraction: 0.8)) {
                            flagScrolledUp = isHidden
                        }
                    }
            }
            .buttonStyle(.plain)

            heroNameRow
                .frame(maxWidth: .infinity)
        }
        .frame(maxWidth: .infinity)
        .padding(DesignSystem.Spacing.xl)
    }

    // At accessibility sizes the name gets the full width and the speaker sits below it.
    @ViewBuilder
    var heroNameRow: some View {
        if dynamicTypeSize.isAccessibilitySize {
            VStack(spacing: DesignSystem.Spacing.sm) {
                heroName
                SpeakerButton(text: country.name, countryCode: country.code)
            }
        } else {
            // A hidden twin of the button on the left keeps the name centered under the flag.
            HStack(spacing: DesignSystem.Spacing.xs) {
                SpeakerButton(text: country.name, countryCode: country.code)
                    .hidden()
                    .accessibilityHidden(true)
                heroName
                SpeakerButton(text: country.name, countryCode: country.code)
            }
        }
    }

    var heroName: some View {
        Text(country.name)
            .font(DesignSystem.Font.title)
            .foregroundStyle(DesignSystem.Color.textPrimary)
            .multilineTextAlignment(.center)
    }
}
