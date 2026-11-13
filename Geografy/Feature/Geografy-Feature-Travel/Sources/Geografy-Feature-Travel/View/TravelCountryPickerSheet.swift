import Geografy_Core_Common
import Geografy_Core_DesignSystem
import Geografy_Core_Service
import SwiftUI

/// Adds countries to the travel lists, built on the shared `CountryPicker`.
public struct TravelCountryPickerSheet: View {
    // MARK: - Properties
    @Environment(AchievementService.self) private var achievementService
    @Environment(TravelService.self) private var travelService
    @Environment(XPService.self) private var xpService

    public let countries: [Country]
    public let preferredStatus: TravelStatus?

    @State private var statusCountry: Country?

    // MARK: - Init
    public init(countries: [Country], preferredStatus: TravelStatus?) {
        self.countries = countries
        self.preferredStatus = preferredStatus
    }

    // MARK: - Body
    public var body: some View {
        CountryPicker(
            LocalizedStringKey(navigationTitle),
            countries: countries,
            checkedCodes: checkedCodes,
            onSelect: select
        ) { country in
            trailingView(travelService.status(for: country.code))
        }
        .sheet(item: $statusCountry) { country in
            TravelStatusPickerSheet(country: country)
        }
    }
}

// MARK: - Subviews
private extension TravelCountryPickerSheet {
    @ViewBuilder
    func trailingView(_ status: TravelStatus?) -> some View {
        if let status {
            statusBadge(status)
        } else {
            Image(systemName: "plus.circle")
                .font(DesignSystem.Font.headline)
                .foregroundStyle(DesignSystem.Color.textTertiary)
                .accessibilityHidden(true)
        }
    }

    func statusBadge(_ status: TravelStatus) -> some View {
        InfoPill(status.shortLabel, systemImage: status.icon, style: .tinted(status.color))
    }
}

// MARK: - Helpers
private extension TravelCountryPickerSheet {
    var navigationTitle: String {
        if let status = preferredStatus {
            return "Add to \(status.label)"
        }
        return "Add Country"
    }

    var checkedCodes: Set<String> {
        guard let preferredStatus else { return [] }
        return Set(countries.map(\.code).filter { travelService.status(for: $0) == preferredStatus })
    }

    func select(_ country: Country) {
        guard let status = preferredStatus else {
            statusCountry = country
            return
        }
        guard travelService.status(for: country.code) != status else { return }
        recorder.record(status, for: country.code)
    }

    var recorder: TravelStatusRecorder {
        TravelStatusRecorder(travelService: travelService, xpService: xpService, achievementService: achievementService)
    }
}
