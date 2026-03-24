import Foundation

enum Screen: Hashable {
    case map(continentFilter: Country.Continent? = nil)
    case countryDetail(Country)
    case organizationDetail(Organization)
    case allMaps
    case continentOverview(Country.Continent)
    case achievements
    case themes
    case settings
    case quizSetup
    case neighborExplorer(Country)
    case capitalQuizSetup
    case worldRecords
    case learningPath
    case mapPuzzle
    case continentPicker
    case continentStats(String)
    case oceanExplorer
    case languageExplorer
    case independenceTimeline
    case economyExplorer
    case geographyFeatures
    case cultureExplorer
    case landmarkGallery
    case mapColoring
    case territorialDisputes
    case lesson(LearningModule, Lesson)
}
