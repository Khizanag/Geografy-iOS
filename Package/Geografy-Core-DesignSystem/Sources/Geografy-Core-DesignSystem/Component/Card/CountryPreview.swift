import Geografy_Core_Common
import SwiftUI

/// The long-press preview of a country, as its page opens: the flag, the name, and the facts its header leads with.
public struct CountryPreview: View {
    // MARK: - Properties
    private let country: Country

    // MARK: - Init
    public init(country: Country) {
        self.country = country
    }

    // MARK: - Body
    public var body: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
            FlagView(countryCode: country.code, height: DesignSystem.Size.Flag.detail, fixedWidth: true)
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.xxs) {
                Text(country.name)
                    .font(DesignSystem.Font.title2)
                    .fontWeight(.bold)
                    .foregroundStyle(DesignSystem.Color.textPrimary)
                Text(country.continent.displayName)
                    .font(DesignSystem.Font.subheadline)
                    .foregroundStyle(DesignSystem.Color.textSecondary)
            }
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
                if !country.capital.isEmpty {
                    fact("star.fill", Text("Capital: \(country.capital)", bundle: .module))
                }
                fact("person.2.fill", Text("Population: \(country.population.formatPopulation())", bundle: .module))
                fact("ruler.fill", Text("Area: \(country.area.formatArea())", bundle: .module))
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(DesignSystem.Spacing.lg)
    }
}

// MARK: - Subviews
private extension CountryPreview {
    func fact(_ systemImage: String, _ text: Text) -> some View {
        Label {
            text.monospacedDigit()
        } icon: {
            Image(systemName: systemImage)
        }
        .font(DesignSystem.Font.subheadline)
        .foregroundStyle(DesignSystem.Color.textPrimary)
    }
}

// MARK: - Menu
public extension RowListMenu where Item == Country {
    /// A country's long press, wherever a list shows one: its preview, then Open, Copy, and Share, and Remove when
    /// the list can remove it.
    static func countries(open: @escaping (Country) -> Void, remove: ((Country) -> Void)? = nil) -> Self {
        RowListMenu(open: open, text: \.name, remove: remove) { country in
            CountryPreview(country: country)
        }
    }
}
