import Geografy_Core_Common
import Geografy_Core_DesignSystem
import SwiftUI

// MARK: - Navigation Title
struct CountryDetailNavigationTitle: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    let country: Country
    let scrollState: CountryDetailScrollState

    var body: some View {
        let isFlagScrolledUp = scrollState.isFlagScrolledUp
        HStack(spacing: isFlagScrolledUp ? DesignSystem.Spacing.xs : 0) {
            FlagView(countryCode: country.code, height: 20, fixedWidth: true)
                .opacity(isFlagScrolledUp ? 1 : 0)
                .scaleEffect(isFlagScrolledUp || reduceMotion ? 1 : 0.5)
                .frame(width: isFlagScrolledUp ? nil : 0, height: 20)
                .clipped()
            Text(country.name)
                .font(DesignSystem.Font.headline)
        }
        .animation(reduceMotion ? nil : .easeInOut(duration: 0.2), value: isFlagScrolledUp)
    }
}

// MARK: - Hero Flag
struct CountryDetailHeroFlag: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    let countryCode: String
    let scrollState: CountryDetailScrollState

    var body: some View {
        FlagView(countryCode: countryCode, height: 120)
            .opacity(scrollState.isFlagScrolledUp ? 0 : 1)
            .geoShadow(.elevated)
            .onGeometryChange(for: Bool.self) { proxy in
                proxy.frame(in: .scrollView).maxY < 0
            } action: { isHidden in
                withAnimation(reduceMotion ? nil : .spring(response: 0.35, dampingFraction: 0.8)) {
                    scrollState.isFlagScrolledUp = isHidden
                }
            }
    }
}
