import SwiftUI

@MainActor
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
        case .continentOverview(let continent):
            ContinentOverviewScreen(continent: continent)
        case .achievements:
            AchievementsScreen()
        case .themes:
            ThemesScreen()
        case .settings:
            SettingsScreen()
        case .quizSetup:
            QuizSetupScreen()
        case .neighborExplorer(let country):
            NeighborExplorerScreen(country: country)
        case .capitalQuizSetup:
            CapitalQuizSetupScreen()
        case .worldRecords:
            WorldRecordsScreen()
        case .learningPath:
            LearningPathScreen()
        case .mapPuzzle:
            MapPuzzleSetupScreen()
        }
    }
}
