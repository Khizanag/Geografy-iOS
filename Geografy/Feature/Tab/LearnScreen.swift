import Geografy_Core_Common
import Geografy_Core_DesignSystem
import Geografy_Core_Navigation
import Geografy_Core_Service
import SwiftUI

/// The Learn tab: the country of the day on top, then study, reference, and tools.
struct LearnScreen: View {
    // MARK: - Properties
    @Environment(Navigator.self) private var coordinator
    @Environment(CountryDataService.self) private var countryDataService

    // MARK: - Body
    var body: some View {
        HubScreen(title: "Learn", sections: Self.sections) {
            countryOfTheDay
        }
    }
}

// MARK: - Sections
private extension LearnScreen {
    static let sections = [
        HubSection(title: "Study", items: [.learningPath, .srsStudy]),
        HubSection(title: "Discover", items: [.worldFacts, .timeline, .orgs, .compare, .feed, .quotes]),
        HubSection(title: "Tools", items: [.timeZones, .currencyConverter, .distanceCalculator]),
    ]
}

// MARK: - Country of the Day
private extension LearnScreen {
    @ViewBuilder
    var countryOfTheDay: some View {
        if let country = countryDataService.countryOfTheDay() {
            Button { coordinator.push(.countryDetail(country)) } label: {
                CountrySpotlightCard(
                    country: country,
                    funFact: CountryFunFacts.data[country.code]?.first
                )
            }
            .buttonStyle(PressButtonStyle())
        }
    }
}
