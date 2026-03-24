import Foundation

enum HomeSection: String, CaseIterable, Identifiable, Codable {
    case guestBanner
    case carousel
    case spotlight
    case streak
    case dailyChallenge
    case srsReview
    case worldRecords
    case organizations
    case progress
    case flagGame
    case trivia
    case spellingBee
    case learningPath
    case mapPuzzle
    case landmarkQuiz
    case feed
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
        case .srsReview: "Due for Review"
        case .worldRecords: "World Records"
        case .organizations: "Organizations"
        case .progress: "Statistics"
        case .flagGame: "Flag Matching"
        case .trivia: "Trivia"
        case .spellingBee: "Spelling Bee"
        case .learningPath: "Learning Path"
        case .mapPuzzle: "Map Puzzle"
        case .landmarkQuiz: "Landmark Quiz"
        case .feed: "Feed"
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
        case .srsReview: "clock.arrow.circlepath"
        case .worldRecords: "trophy.fill"
        case .organizations: "building.2.fill"
        case .progress: "chart.bar.fill"
        case .flagGame: "flag.fill"
        case .trivia: "questionmark.bubble.fill"
        case .spellingBee: "textformat.abc"
        case .learningPath: "graduationcap.fill"
        case .mapPuzzle: "puzzlepiece.fill"
        case .landmarkQuiz: "photo.fill"
        case .feed: "newspaper.fill"
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
        case .mapColoring: "paintpalette.fill"
        case .countryNicknames: "tag.fill"
        case .wordSearch: "character.magnify"
        case .borderChallenge: "square.dashed"
        case .comingSoon: "sparkles"
        }
    }

    var isNew: Bool {
        switch self {
        case .borderChallenge,
             .countryNicknames,
             .economyExplorer,
             .trivia,
             .geographyFeatures,
             .mapColoring,
             .oceanExplorer,
             .wordSearch:
            true
        default:
            false
        }
    }
}
