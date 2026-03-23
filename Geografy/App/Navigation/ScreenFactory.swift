import SwiftUI

@MainActor
enum ScreenFactory {
    @ViewBuilder
    static func view(for screen: Screen) -> some View {
        Group {
            coreView(for: screen)
            exploreView(for: screen)
        }
    }
}

// MARK: - Core

@MainActor
private extension ScreenFactory {
    @ViewBuilder
    static func coreView(for screen: Screen) -> some View {
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
        default:
            EmptyView()
        }
    }
}

// MARK: - Explore

@MainActor
private extension ScreenFactory {
    @ViewBuilder
    static func exploreView(for screen: Screen) -> some View {
        switch screen {
        case .worldRecords:
            WorldRecordsScreen()
        case .learningPath:
            LearningPathScreen()
        case .mapPuzzle:
            MapPuzzleSetupScreen()
        case .continentPicker:
            ContinentPickerScreen()
        case .continentStats(let continentName):
            ContinentStatsScreen(continentName: continentName)
        case .oceanExplorer:
            OceanExplorerScreen()
        case .languageExplorer:
            LanguageExplorerScreen()
        case .independenceTimeline:
            IndependenceTimelineScreen()
        case .economyExplorer:
            EconomyExplorerScreen()
        case .geographyFeatures:
            GeographyFeaturesScreen()
        default:
            EmptyView()
        }
    }
}
