import Foundation

enum HomeSection: String, CaseIterable, Identifiable, Codable {
    case guestBanner
    case carousel
    case spotlight
    case streak
    case dailyChallenge
    case capitalQuiz
    case srsReview
    case worldRecords
    case organizations
    case progress
    case flagGame
    case geoTrivia
    case spellingBee
    case learningPath
    case mapPuzzle
    case landmarkQuiz
    case geoFeed
    case continentStats
    case countryCompare
    case travelBucketList
    case oceanExplorer
    case languageExplorer
    case challengeRoom
    case independenceTimeline
    case economyExplorer
    case geographyFeatures
    case cultureExplorer
    case landmarkGallery
    case geoQuotes
    case nationalSymbolsQuiz
    case mapColoring
    case countryNicknames
    case wordSearch
    case borderChallenge
    case comingSoon

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .guestBanner: "Guest Mode Banner"
        case .carousel: "Explore Maps"
        case .spotlight: "Country Spotlight"
        case .streak: "Daily Streak"
        case .dailyChallenge: "Daily Challenge"
        case .capitalQuiz: "Capital City Quiz"
        case .srsReview: "Due for Review"
        case .worldRecords: "World Records"
        case .organizations: "Organizations"
        case .progress: "Statistics"
        case .flagGame: "Flag Matching"
        case .geoTrivia: "Geo Trivia"
        case .spellingBee: "Spelling Bee"
        case .learningPath: "Learning Path"
        case .mapPuzzle: "Map Puzzle"
        case .landmarkQuiz: "Landmark Quiz"
        case .geoFeed: "Geo Feed"
        case .continentStats: "Continent Statistics"
        case .countryCompare: "Country Comparison"
        case .travelBucketList: "Travel Bucket List"
        case .oceanExplorer: "Ocean Explorer"
        case .languageExplorer: "Language Explorer"
        case .challengeRoom: "Challenge Room"
        case .independenceTimeline: "Independence Timeline"
        case .economyExplorer: "Economy Explorer"
        case .geographyFeatures: "Geography Features"
        case .cultureExplorer: "Culture Explorer"
        case .landmarkGallery: "Landmark Gallery"
        case .geoQuotes: "Geo Quotes"
        case .nationalSymbolsQuiz: "National Symbols Quiz"
        case .mapColoring: "Map Coloring Book"
        case .countryNicknames: "Country Nicknames"
        case .wordSearch: "Geography Word Search"
        case .borderChallenge: "Border Challenge"
        case .comingSoon: "Coming Soon"
        }
    }

    var icon: String {
        switch self {
        case .guestBanner: "person.badge.key.fill"
        case .carousel: "map.fill"
        case .spotlight: "star.fill"
        case .streak: "flame.fill"
        case .dailyChallenge: "calendar.badge.clock"
        case .capitalQuiz: "building.columns.fill"
        case .srsReview: "clock.arrow.circlepath"
        case .worldRecords: "trophy.fill"
        case .organizations: "building.2.fill"
        case .progress: "chart.bar.fill"
        case .flagGame: "flag.fill"
        case .geoTrivia: "checkmark.circle.fill"
        case .spellingBee: "pencil.and.list.clipboard"
        case .learningPath: "graduationcap.fill"
        case .mapPuzzle: "puzzlepiece.fill"
        case .landmarkQuiz: "building.columns.fill"
        case .geoFeed: "newspaper.fill"
        case .continentStats: "chart.bar.xaxis.ascending"
        case .countryCompare: "arrow.left.arrow.right"
        case .travelBucketList: "list.star"
        case .oceanExplorer: "water.waves"
        case .languageExplorer: "character.book.closed.fill"
        case .challengeRoom: "person.2.fill"
        case .independenceTimeline: "calendar.badge.clock"
        case .economyExplorer: "chart.line.uptrend.xyaxis"
        case .geographyFeatures: "mountain.2.fill"
        case .cultureExplorer: "music.note.house.fill"
        case .landmarkGallery: "photo.on.rectangle.angled"
        case .geoQuotes: "quote.bubble.fill"
        case .nationalSymbolsQuiz: "pawprint.fill"
        case .mapColoring: "paintpalette.fill"
        case .countryNicknames: "tag.fill"
        case .wordSearch: "textformat.abc"
        case .borderChallenge: "map.fill"
        case .comingSoon: "sparkles"
        }
    }
}
