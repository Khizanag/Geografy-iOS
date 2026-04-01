import Foundation

@Observable
public final class LandmarkQuizService {
    private(set) var questions: [LandmarkQuestion] = []

    public func loadQuestions() {
        questions = Self.allQuestions.shuffled()
    }

    public func randomWrongAnswers(
        excluding correctCode: String,
        from countryCodes: [String],
        count: Int
    ) -> [String] {
        countryCodes
            .filter { $0 != correctCode }
            .shuffled()
            .prefix(count)
            .map { $0 }
    }
}

// MARK: - Questions Data
private extension LandmarkQuizService {
    // swiftlint:disable closure_body_length
    nonisolated(unsafe) public static let allQuestions: [LandmarkQuestion] = [
        // MARK: Monument
        .init(
            id: "m01",
            hint: "Home of the Eiffel Tower, built in 1889",
            answerCountryCode: "FR",
            category: .monument
        ),
        .init(
            id: "m02",
            hint: "The Great Wall stretches across this country for over 21,000 km",
            answerCountryCode: "CN",
            category: .monument
        ),
        .init(
            id: "m03",
            hint: "The Colosseum, symbol of ancient gladiatorial combat, stands here",
            answerCountryCode: "IT",
            category: .monument
        ),
        .init(
            id: "m04",
            hint: "The Taj Mahal, a white marble mausoleum, is located here",
            answerCountryCode: "IN",
            category: .monument
        ),
        .init(
            id: "m05",
            hint: "Machu Picchu, the ancient Inca citadel, is in this country",
            answerCountryCode: "PE",
            category: .monument
        ),
        .init(
            id: "m06",
            hint: "The Statue of Liberty was a gift to this country from France",
            answerCountryCode: "US",
            category: .monument
        ),
        .init(
            id: "m07",
            hint: "The Parthenon, atop the Acropolis, is the jewel of this nation",
            answerCountryCode: "GR",
            category: .monument
        ),
        .init(
            id: "m08",
            hint: "Angkor Wat, the largest religious monument on Earth, is here",
            answerCountryCode: "KH",
            category: .monument
        ),
        .init(
            id: "m09",
            hint: "The Pyramids of Giza and the Sphinx are found in this country",
            answerCountryCode: "EG",
            category: .monument
        ),
        .init(
            id: "m10",
            hint: "Chichen Itza, the ancient Mayan pyramid complex, is located here",
            answerCountryCode: "MX",
            category: .monument
        ),
        .init(
            id: "m11",
            hint: "Big Ben and the Palace of Westminster are in this country",
            answerCountryCode: "GB",
            category: .monument
        ),
        .init(
            id: "m12",
            hint: "The Sydney Opera House, shaped like sails, is in this country",
            answerCountryCode: "AU",
            category: .monument
        ),
        .init(
            id: "m13",
            hint: "The Sagrada Família, Gaudí's unfinished masterpiece, is here",
            answerCountryCode: "ES",
            category: .monument
        ),
        .init(
            id: "m14",
            hint: "Petra, the rose-red city carved into rock, is in this country",
            answerCountryCode: "JO",
            category: .monument
        ),
        .init(
            id: "m15",
            hint: "The Burj Khalifa, world's tallest building at 828m, stands here",
            answerCountryCode: "AE",
            category: .monument
        ),

        // MARK: Nature
        .init(
            id: "n01",
            hint: "This country has more pyramids than Egypt — most are hidden by desert sand",
            answerCountryCode: "SD",
            category: .nature
        ),
        .init(
            id: "n02",
            hint: "The Amazon Rainforest covers most of this country, the largest in South America",
            answerCountryCode: "BR",
            category: .nature
        ),
        .init(
            id: "n03",
            hint: "Victoria Falls, one of the world's largest waterfalls, borders this country and Zimbabwe",
            answerCountryCode: "ZM",
            category: .nature
        ),
        .init(
            id: "n04",
            hint: "The Sahara Desert covers most of this North African country",
            answerCountryCode: "DZ",
            category: .nature
        ),
        .init(
            id: "n05",
            hint: "Mount Everest, the world's highest peak, sits on the border of this country and China",
            answerCountryCode: "NP",
            category: .nature
        ),
        .init(
            id: "n06",
            hint: "Lake Baikal, the world's deepest lake containing 20% of Earth's fresh water, is here",
            answerCountryCode: "RU",
            category: .nature
        ),
        .init(
            id: "n07",
            hint: "The Galápagos Islands, which inspired Darwin's theory of evolution, belong to this country",
            answerCountryCode: "EC",
            category: .nature
        ),
        .init(
            id: "n08",
            hint: "The Great Barrier Reef, the world's largest coral reef system, is off the coast here",
            answerCountryCode: "AU",
            category: .nature
        ),
        .init(
            id: "n09",
            hint: "Fiordland National Park and Milford Sound are stunning highlights of this island country",
            answerCountryCode: "NZ",
            category: .nature
        ),
        .init(
            id: "n10",
            hint: "Angel Falls, the world's highest uninterrupted waterfall at 979m, is found here",
            answerCountryCode: "VE",
            category: .nature
        ),
        .init(
            id: "n11",
            hint: "The Dead Sea, the lowest point on Earth's surface, borders this country and Jordan",
            answerCountryCode: "IL",
            category: .nature
        ),
        .init(
            id: "n12",
            hint: "The Serengeti, home to the world's greatest wildlife migration, is in this country",
            answerCountryCode: "TZ",
            category: .nature
        ),
        .init(
            id: "n13",
            hint: "Iceland has more geothermal hot springs per capita than anywhere " +
                "— this island nation uses them for 90% of its heating",
            answerCountryCode: "IS",
            category: .nature
        ),
        .init(
            id: "n14",
            hint: "The Congo Rainforest, second largest on Earth, covers most of this country",
            answerCountryCode: "CD",
            category: .nature
        ),

        // MARK: Culture
        .init(
            id: "c01",
            hint: "This country invented pizza and pasta and has more UNESCO sites than any other",
            answerCountryCode: "IT",
            category: .culture
        ),
        .init(
            id: "c02",
            hint: "Samba, bossa nova, and Carnival are defining cultural exports of this country",
            answerCountryCode: "BR",
            category: .culture
        ),
        .init(
            id: "c03",
            hint: "The Nobel Peace Prize ceremony is held in this Scandinavian capital every December",
            answerCountryCode: "NO",
            category: .culture
        ),
        .init(
            id: "c04",
            hint: "LEGO was invented in this country in 1932",
            answerCountryCode: "DK",
            category: .culture
        ),
        .init(
            id: "c05",
            hint: "Origami, sushi, and the tea ceremony all originate from this island nation",
            answerCountryCode: "JP",
            category: .culture
        ),
        .init(
            id: "c06",
            hint: "Beethoven, Bach, and Brahms — the 'Three Bs' of classical music — were all born in this country",
            answerCountryCode: "DE",
            category: .culture
        ),
        .init(
            id: "c07",
            hint: "Hollywood, Silicon Valley, and jazz music all originated in this country",
            answerCountryCode: "US",
            category: .culture
        ),
        .init(
            id: "c08",
            hint: "Bollywood produces more films per year than Hollywood — it is based in this country",
            answerCountryCode: "IN",
            category: .culture
        ),
        .init(
            id: "c09",
            hint: "Flamenco dance, bullfighting, and tapas culture originated here on the Iberian Peninsula",
            answerCountryCode: "ES",
            category: .culture
        ),
        .init(
            id: "c10",
            hint: "The world's oldest university, founded in 859 AD, is located in this country",
            answerCountryCode: "MA",
            category: .culture
        ),
        .init(
            id: "c11",
            hint: "Buddhism, one of the world's major religions, was founded in this country",
            answerCountryCode: "NP",
            category: .culture
        ),
        .init(
            id: "c12",
            hint: "Chess was invented in this country over 1,500 years ago",
            answerCountryCode: "IN",
            category: .culture
        ),
        .init(
            id: "c13",
            hint: "The world's largest film industry by output, Nollywood, is based in this country",
            answerCountryCode: "NG",
            category: .culture
        ),
        .init(
            id: "c14",
            hint: "K-pop and K-drama have made this country a global cultural powerhouse",
            answerCountryCode: "KR",
            category: .culture
        ),
        .init(
            id: "c15",
            hint: "The printing press was invented in this country in the 15th century, changing the world",
            answerCountryCode: "DE",
            category: .culture
        ),

        // MARK: Sport
        .init(
            id: "s01",
            hint: "The first modern Olympic Games were held in this country in 1896",
            answerCountryCode: "GR",
            category: .sport
        ),
        .init(
            id: "s02",
            hint: "Football (soccer) was codified and given its modern rules in this country in 1863",
            answerCountryCode: "GB",
            category: .sport
        ),
        .init(
            id: "s03",
            hint: "Sumo wrestling is the national sport of this island nation",
            answerCountryCode: "JP",
            category: .sport
        ),
        .init(
            id: "s04",
            hint: "Taekwondo, now an Olympic sport, originated in this country",
            answerCountryCode: "KR",
            category: .sport
        ),
        .init(
            id: "s05",
            hint: "Cricket is the most-watched sport in this South Asian country with 1.4 billion people",
            answerCountryCode: "IN",
            category: .sport
        ),
        .init(
            id: "s06",
            hint: "Basketball was invented by a Canadian but became the national passion of this country",
            answerCountryCode: "US",
            category: .sport
        ),
        .init(
            id: "s07",
            hint: "This country invented rugby and has won the Rugby World Cup more times than any other nation",
            answerCountryCode: "NZ",
            category: .sport
        ),
        .init(
            id: "s08",
            hint: "Tour de France, the world's most famous cycling race, is hosted by this country",
            answerCountryCode: "FR",
            category: .sport
        ),
        .init(
            id: "s09",
            hint: "The FIFA World Cup trophy is currently held by this South American country after 2022",
            answerCountryCode: "AR",
            category: .sport
        ),
        .init(
            id: "s10",
            hint: "The Boston Marathon and Super Bowl both take place in this country",
            answerCountryCode: "US",
            category: .sport
        ),
        .init(
            id: "s11",
            hint: "This country has won more Olympic gold medals than any other nation in history",
            answerCountryCode: "US",
            category: .sport
        ),
        .init(
            id: "s12",
            hint: "Judo, an Olympic martial art, was created in this country in 1882",
            answerCountryCode: "JP",
            category: .sport
        ),
        .init(
            id: "s13",
            hint: "The Winter Olympics were invented to showcase sports popular in this Nordic region",
            answerCountryCode: "NO",
            category: .sport
        ),
        .init(
            id: "s14",
            hint: "Capoeira, a martial art disguised as dance, originated among enslaved people in this country",
            answerCountryCode: "BR",
            category: .sport
        ),
        .init(
            id: "s15",
            hint: "Polo, now an elite sport worldwide, was invented on the steppes of this Central Asian country",
            answerCountryCode: "IR",
            category: .sport
        ),
    ]
    // swiftlint:enable closure_body_length
}
