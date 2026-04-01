import Foundation
import Observation

@Observable
@MainActor
public final class QuotesService {
    private let favoritesKey = "geo_quotes_favorites"

    public private(set) var quotes: [Quote] = []

    public init() {
        quotes = makeQuotes()
        loadFavorites()
    }

    public func toggleFavorite(id: String) {
        guard let index = quotes.firstIndex(where: { $0.id == id }) else { return }
        quotes[index].isFavorited.toggle()
        saveFavorites()
    }

    public func quotes(for category: QuoteCategory?) -> [Quote] {
        guard let category else { return quotes }
        return quotes.filter { $0.category == category }
    }

    public func quotesOfTheDay() -> [Quote] {
        let dayOfYear = Calendar.current.ordinality(of: .day, in: .year, for: Date()) ?? 1
        let shuffled = quotes.sorted { a, _ in a.id.hashValue ^ dayOfYear.hashValue > 0 }
        return Array(shuffled.prefix(3))
    }

    public func favoriteQuotes() -> [Quote] {
        quotes.filter { $0.isFavorited }
    }
}

// MARK: - Persistence
private extension QuotesService {
    func loadFavorites() {
        let favoriteIds = Set(UserDefaults.standard.stringArray(forKey: favoritesKey) ?? [])
        for index in quotes.indices {
            quotes[index].isFavorited = favoriteIds.contains(quotes[index].id)
        }
    }

    func saveFavorites() {
        let favoriteIds = quotes.filter { $0.isFavorited }.map { $0.id }
        UserDefaults.standard.set(favoriteIds, forKey: favoritesKey)
    }
}

// MARK: - Data
private extension QuotesService {
    // swiftlint:disable:next function_body_length
    func makeQuotes() -> [Quote] {
        [
            Quote(
                id: "q001",
                text: "The world is a book, and those who do not travel read only one page.",
                author: "Saint Augustine",
                countryCode: "DZ",
                category: .travel,
                isFavorited: false
            ),
            Quote(
                id: "q002",
                text: "Not all those who wander are lost.",
                author: "J.R.R. Tolkien",
                countryCode: "GB",
                category: .travel,
                isFavorited: false
            ),
            Quote(
                id: "q003",
                text: "Travel makes one modest. You see what a tiny place you occupy in the world.",
                author: "Gustave Flaubert",
                countryCode: "FR",
                category: .travel,
                isFavorited: false
            ),
            Quote(
                id: "q004",
                text: "To travel is to live.",
                author: "Hans Christian Andersen",
                countryCode: "DK",
                category: .travel,
                isFavorited: false
            ),
            Quote(
                id: "q005",
                text: "A good traveler has no fixed plans and is not intent on arriving.",
                author: "Lao Tzu",
                countryCode: "CN",
                category: .wisdom,
                isFavorited: false
            ),
            Quote(
                id: "q006",
                text: "The Earth does not belong to us. We belong to the Earth.",
                author: "Chief Seattle",
                countryCode: "US",
                category: .geography,
                isFavorited: false
            ),
            Quote(
                id: "q007",
                text: "Once a year, go somewhere you have never been before.",
                author: "Dalai Lama",
                countryCode: "IN",
                category: .travel,
                isFavorited: false
            ),
            Quote(
                id: "q008",
                text: "The real voyage of discovery consists not in seeking new landscapes, but in having new eyes.",
                author: "Marcel Proust",
                countryCode: "FR",
                category: .exploration,
                isFavorited: false
            ),
            Quote(
                id: "q009",
                text: "Earth is the cradle of humanity, but one cannot live in a cradle forever.",
                author: "Konstantin Tsiolkovsky",
                countryCode: "RU",
                category: .exploration,
                isFavorited: false
            ),
            Quote(
                id: "q010",
                text: "Travel is fatal to prejudice, bigotry, and narrow-mindedness.",
                author: "Mark Twain",
                countryCode: "US",
                category: .travel,
                isFavorited: false
            ),
            Quote(
                id: "q011",
                text: "That's one small step for man, one giant leap for mankind.",
                author: "Neil Armstrong",
                countryCode: "US",
                category: .exploration,
                isFavorited: false
            ),
            Quote(
                id: "q012",
                text: "In every walk with nature, one receives far more than he seeks.",
                author: "John Muir",
                countryCode: "US",
                category: .geography,
                isFavorited: false
            ),
            Quote(
                id: "q013",
                text: "Paris is always a good idea.",
                author: "Audrey Hepburn",
                countryCode: "GB",
                category: .country,
                isFavorited: false
            ),
            Quote(
                id: "q014",
                text: "Italy is not a country. It is an emotion.",
                author: "Unknown",
                countryCode: nil,
                category: .country,
                isFavorited: false
            ),
            Quote(
                id: "q015",
                text: "Japan is the most introverted country in the world, and that is precisely what makes it so beautiful.",
                author: "Unknown",
                countryCode: nil,
                category: .country,
                isFavorited: false
            ),
            Quote(
                id: "q016",
                text: "To travel is to take a journey into yourself.",
                author: "Danny Kaye",
                countryCode: "US",
                category: .wisdom,
                isFavorited: false
            ),
            Quote(
                id: "q017",
                text: "The ocean is everything I want to be — beautiful, mysterious, wild, and free.",
                author: "Unknown",
                countryCode: nil,
                category: .geography,
                isFavorited: false
            ),
            Quote(
                id: "q018",
                text: "The mountains are calling and I must go.",
                author: "John Muir",
                countryCode: "US",
                category: .geography,
                isFavorited: false
            ),
            Quote(
                id: "q019",
                text: "Wherever you go, go with all your heart.",
                author: "Confucius",
                countryCode: "CN",
                category: .wisdom,
                isFavorited: false
            ),
            Quote(
                id: "q020",
                text: "There is no moment of delight in any pilgrimage like the beginning of it.",
                author: "Charles Dudley Warner",
                countryCode: "US",
                category: .travel,
                isFavorited: false
            ),
            Quote(
                id: "q021",
                text: "We shall not cease from exploration, and the end of all our exploring will be to arrive where we started and know the place for the first time.",
                author: "T.S. Eliot",
                countryCode: "US",
                category: .exploration,
                isFavorited: false
            ),
            Quote(
                id: "q022",
                text: "The world is too big to stay in one place and life is too short to do just one thing.",
                author: "Unknown",
                countryCode: nil,
                category: .travel,
                isFavorited: false
            ),
            Quote(
                id: "q023",
                text: "Life is either a daring adventure or nothing at all.",
                author: "Helen Keller",
                countryCode: "US",
                category: .wisdom,
                isFavorited: false
            ),
            Quote(
                id: "q024",
                text: "Geography is destiny.",
                author: "Napoleon Bonaparte",
                countryCode: "FR",
                category: .geography,
                isFavorited: false
            ),
            Quote(
                id: "q025",
                text: "The sea, once it casts its spell, holds one in its net of wonder forever.",
                author: "Jacques Cousteau",
                countryCode: "FR",
                category: .geography,
                isFavorited: false
            ),
            Quote(
                id: "q026",
                text: "Every dreamer knows that it is entirely possible to be homesick for a place you have never been to.",
                author: "Judith Thurman",
                countryCode: "US",
                category: .travel,
                isFavorited: false
            ),
            Quote(
                id: "q027",
                text: "I am not the same having seen the moon shine on the other side of the world.",
                author: "Mary Anne Radmacher",
                countryCode: "US",
                category: .travel,
                isFavorited: false
            ),
            Quote(
                id: "q028",
                text: "Brazil is not for beginners.",
                author: "Tom Jobim",
                countryCode: "BR",
                category: .country,
                isFavorited: false
            ),
            Quote(
                id: "q029",
                text: "India is not a country but a feeling.",
                author: "Unknown",
                countryCode: nil,
                category: .country,
                isFavorited: false
            ),
            Quote(
                id: "q030",
                text: "Africa is not a country. It is a continent of 54 unique nations.",
                author: "Unknown",
                countryCode: nil,
                category: .country,
                isFavorited: false
            ),
            Quote(
                id: "q031",
                text: "The sky is not the limit. There are footprints on the moon.",
                author: "Paul Brandt",
                countryCode: "CA",
                category: .exploration,
                isFavorited: false
            ),
            Quote(
                id: "q032",
                text: "The journey of a thousand miles begins with one step.",
                author: "Lao Tzu",
                countryCode: "CN",
                category: .wisdom,
                isFavorited: false
            ),
            Quote(
                id: "q033",
                text: "Exploration is the engine that drives innovation.",
                author: "Edith Widder",
                countryCode: "US",
                category: .exploration,
                isFavorited: false
            ),
            Quote(
                id: "q034",
                text: "The best education I have ever received was through travel.",
                author: "Lisa Ling",
                countryCode: "US",
                category: .travel,
                isFavorited: false
            ),
            Quote(
                id: "q035",
                text: "We travel not to escape life, but for life not to escape us.",
                author: "Unknown",
                countryCode: nil,
                category: .travel,
                isFavorited: false
            ),
            Quote(
                id: "q036",
                text: "The world belongs to those who can see it.",
                author: "Ralph Waldo Emerson",
                countryCode: "US",
                category: .wisdom,
                isFavorited: false
            ),
            Quote(
                id: "q037",
                text: "Australia is not just a country — it's a state of mind.",
                author: "Unknown",
                countryCode: nil,
                category: .country,
                isFavorited: false
            ),
            Quote(
                id: "q038",
                text: "Maps are the language of geography.",
                author: "Unknown",
                countryCode: nil,
                category: .geography,
                isFavorited: false
            ),
            Quote(
                id: "q039",
                text: "I have seen much of the world, and what I have learned is that we are all more alike than we are different.",
                author: "Maya Angelou",
                countryCode: "US",
                category: .wisdom,
                isFavorited: false
            ),
            Quote(
                id: "q040",
                text: "To know the world, one must construct it.",
                author: "Cesare Pavese",
                countryCode: "IT",
                category: .geography,
                isFavorited: false
            ),
            Quote(
                id: "q041",
                text: "Land is the only thing in the world that amounts to anything.",
                author: "Margaret Mitchell",
                countryCode: "US",
                category: .geography,
                isFavorited: false
            ),
            Quote(
                id: "q042",
                text: "Greece is a good place to look at the moon.",
                author: "Lunar quote",
                countryCode: "GR",
                category: .country,
                isFavorited: false
            ),
            Quote(
                id: "q043",
                text: "The world is round and the place which may seem like the end may also be only the beginning.",
                author: "Ivy Baker Priest",
                countryCode: "US",
                category: .wisdom,
                isFavorited: false
            ),
            Quote(
                id: "q044",
                text: "Man cannot discover new oceans unless he has the courage to lose sight of the shore.",
                author: "André Gide",
                countryCode: "FR",
                category: .exploration,
                isFavorited: false
            ),
            Quote(
                id: "q045",
                text: "Mexico, the country of inequality. Nowhere else in the world is there such a fearful difference in the distribution of wealth.",
                author: "Alexander von Humboldt",
                countryCode: "DE",
                category: .country,
                isFavorited: false
            ),
            Quote(
                id: "q046",
                text: "It is not down in any map; true places never are.",
                author: "Herman Melville",
                countryCode: "US",
                category: .geography,
                isFavorited: false
            ),
            Quote(
                id: "q047",
                text: "New Zealand — so beautiful it almost doesn't seem real.",
                author: "Unknown",
                countryCode: nil,
                category: .country,
                isFavorited: false
            ),
            Quote(
                id: "q048",
                text: "Every day is a journey, and the journey itself is home.",
                author: "Matsuo Bashō",
                countryCode: "JP",
                category: .travel,
                isFavorited: false
            ),
            Quote(
                id: "q049",
                text: "A ship in harbor is safe, but that's not what ships are for.",
                author: "John A. Shedd",
                countryCode: "US",
                category: .exploration,
                isFavorited: false
            ),
            Quote(
                id: "q050",
                text: "Morocco is a country where your senses are constantly surprised.",
                author: "Unknown",
                countryCode: nil,
                category: .country,
                isFavorited: false
            ),
            Quote(
                id: "q051",
                text: "We do not inherit the earth from our ancestors; we borrow it from our children.",
                author: "Antoine de Saint-Exupéry",
                countryCode: "FR",
                category: .geography,
                isFavorited: false
            ),
            Quote(
                id: "q052",
                text: "Canada is like a really nice apartment over a great party.",
                author: "Robin Williams",
                countryCode: "US",
                category: .country,
                isFavorited: false
            ),
            Quote(
                id: "q053",
                text: "The fishermen know that the sea is dangerous and the storm terrible, but they have never found these dangers sufficient reason for remaining ashore.",
                author: "Vincent van Gogh",
                countryCode: "NL",
                category: .exploration,
                isFavorited: false
            ),
            Quote(
                id: "q054",
                text: "Take nothing but memories, leave nothing but footprints.",
                author: "Chief Seattle",
                countryCode: "US",
                category: .wisdom,
                isFavorited: false
            ),
            Quote(
                id: "q055",
                text: "The globe is a unit and we must know it as such.",
                author: "Unknown",
                countryCode: nil,
                category: .geography,
                isFavorited: false
            ),
            Quote(
                id: "q056",
                text: "A traveler without observation is a bird without wings.",
                author: "Moslih Eddin Saadi",
                countryCode: "IR",
                category: .wisdom,
                isFavorited: false
            ),
            Quote(
                id: "q057",
                text: "Russia is a riddle wrapped in a mystery inside an enigma.",
                author: "Winston Churchill",
                countryCode: "GB",
                category: .country,
                isFavorited: false
            ),
            Quote(
                id: "q058",
                text: "Look deep into nature, and then you will understand everything better.",
                author: "Albert Einstein",
                countryCode: "DE",
                category: .geography,
                isFavorited: false
            ),
            Quote(
                id: "q059",
                text: "Wherever I am I always find myself looking out the window wishing I was somewhere else.",
                author: "Angelina Jolie",
                countryCode: "US",
                category: .travel,
                isFavorited: false
            ),
            Quote(
                id: "q060",
                text: "I have not yet begun to travel.",
                author: "Unknown",
                countryCode: nil,
                category: .travel,
                isFavorited: false
            ),
            Quote(
                id: "q061",
                text: "Columbus did not invent America; he merely discovered what had been there all along.",
                author: "Attributed",
                countryCode: nil,
                category: .exploration,
                isFavorited: false
            ),
            Quote(
                id: "q062",
                text: "The explorer who will not come back, or send back, his ships to tell his tale is not an explorer — only an adventurer.",
                author: "Ursula K. Le Guin",
                countryCode: "US",
                category: .exploration,
                isFavorited: false
            ),
            Quote(
                id: "q063",
                text: "Africa is the future. Africa has always been the future.",
                author: "Lupita Nyong'o",
                countryCode: "KE",
                category: .country,
                isFavorited: false
            ),
            Quote(
                id: "q064",
                text: "Living at the top of the world, looking down on creation.",
                author: "Unknown",
                countryCode: nil,
                category: .geography,
                isFavorited: false
            ),
            Quote(
                id: "q065",
                text: "The world is not a problem to be solved; it is a living being to which we belong.",
                author: "Llewelyn Vaughan-Lee",
                countryCode: "GB",
                category: .wisdom,
                isFavorited: false
            ),
        ]
    }
}
