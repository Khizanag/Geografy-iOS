import SwiftUI

enum ScreenFactory {
    @ViewBuilder
    static func view(for screen: Screen) -> some View {
        switch screen {
        case .map(let continentFilter):
            MapScreen(continentFilter: continentFilter?.rawValue)
        case .countryDetail(let country):
            CountryDetailScreen(country: country)
        case .organizationDetail(let organization):
            OrganizationDetailScreen(organization: organization)
        case .allMaps:
            AllMapsScreen()
        case .achievements:
            AchievementsScreen()
        case .themes:
            ThemesScreen()
        case .settings:
            SettingsScreen()
        case .quizSetup:
            QuizSetupScreen()
        }
    }
}
