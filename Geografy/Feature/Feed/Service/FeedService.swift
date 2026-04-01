import GeografyCore
import SwiftUI

@Observable
final class FeedService {
    private(set) var items: [FeedItem] = []
    private(set) var savedItemIDs: Set<String> = []

    func loadFeed() {
        items = Self.allItems.shuffled()
    }

    func refresh() {
        items = Self.allItems.shuffled()
    }

    func toggleSaved(itemID: String) {
        if savedItemIDs.contains(itemID) {
            savedItemIDs.remove(itemID)
        } else {
            savedItemIDs.insert(itemID)
        }
    }

    func isSaved(_ itemID: String) -> Bool {
        savedItemIDs.contains(itemID)
    }
}

// MARK: - Feed Data
// swiftlint:disable closure_body_length
private extension FeedService {
    static let allItems: [FeedItem] = [
        // MARK: Did You Know
        .init(
            id: "dyk01",
            type: .didYouKnow,
            title: "Smallest Country",
            body: "Vatican City is the smallest country in the world at just 0.44 km². " +
                "It is smaller than many city parks and has a population of about 800 people.",
            countryCode: "VA",
            icon: "building.columns.fill",
            color: .purple
        ),
        .init(
            id: "dyk02",
            type: .didYouKnow,
            title: "Canada's Lakes",
            body: "Canada contains more lakes than all other countries combined — over 2 million! " +
                "That is about 9% of Canada's total area covered by fresh water.",
            countryCode: "CA",
            icon: "drop.fill",
            color: .blue
        ),
        .init(
            id: "dyk03",
            type: .didYouKnow,
            title: "Australia vs. the Moon",
            body: "Australia is wider than the moon. The continent stretches 4,000 km from east to west, " +
                "while the moon's diameter is only 3,476 km.",
            countryCode: "AU",
            icon: "moon.fill",
            color: .indigo
        ),
        .init(
            id: "dyk04",
            type: .didYouKnow,
            title: "Russia's Time Zones",
            body: "Russia spans 11 time zones — more than any other country. " +
                "When it is noon in Moscow, it is already 10 PM in the far east near the Bering Strait.",
            countryCode: "RU",
            icon: "clock.fill",
            color: .orange
        ),
        .init(
            id: "dyk05",
            type: .didYouKnow,
            title: "Norway's Midnight Sun",
            body: "In northern Norway, the sun does not set for 76 consecutive days in summer. " +
                "The locals call this the 'midnight sun' phenomenon.",
            countryCode: "NO",
            icon: "sun.max.fill",
            color: .yellow
        ),
        .init(
            id: "dyk06",
            type: .didYouKnow,
            title: "Monaco's Tiny Size",
            body: "Monaco is the most densely populated country on Earth, with over 19,000 people per km². " +
                "The entire country is smaller than Central Park in New York.",
            countryCode: "MC",
            icon: "person.3.fill",
            color: .red
        ),
        .init(
            id: "dyk07",
            type: .didYouKnow,
            title: "Bolivia's Two Capitals",
            body: "Bolivia has two capital cities: Sucre (constitutional) and La Paz (administrative). " +
                "La Paz, at 3,650m, is the world's highest administrative capital.",
            countryCode: "BO",
            icon: "building.2.fill",
            color: .green
        ),
        .init(
            id: "dyk08",
            type: .didYouKnow,
            title: "Iceland's No Mosquitoes",
            body: "Iceland is one of the few places on Earth with no mosquitoes. " +
                "The country's unique climate and geology make it inhospitable for mosquito populations.",
            countryCode: "IS",
            icon: "wind",
            color: .teal
        ),
        .init(
            id: "dyk09",
            type: .didYouKnow,
            title: "Japan's Islands",
            body: "Japan consists of 6,852 islands, though most of its population lives on the four main islands: " +
                "Honshu, Hokkaido, Kyushu, and Shikoku.",
            countryCode: "JP",
            icon: "map.fill",
            color: .red
        ),
        .init(
            id: "dyk10",
            type: .didYouKnow,
            title: "Brazil's Amazon",
            body: "Brazil's Amazon rainforest produces 20% of the world's oxygen " +
                "and is home to 10% of all species on Earth. It is often called the 'lungs of the planet'.",
            countryCode: "BR",
            icon: "leaf.fill",
            color: .green
        ),

        // MARK: Records
        .init(
            id: "rec01",
            type: .record,
            title: "Longest Coastline",
            body: "Canada has the longest coastline of any country in the world at 202,080 km. " +
                "If you walked it non-stop at 25 km/day, it would take over 22 years.",
            countryCode: "CA",
            icon: "water.waves",
            color: .blue
        ),
        .init(
            id: "rec02",
            type: .record,
            title: "Most Languages",
            body: "Papua New Guinea has the most languages of any country — about 840 distinct languages " +
                "for its 9 million people, roughly one language per 11,000 residents.",
            countryCode: "PG",
            icon: "text.bubble.fill",
            color: .purple
        ),
        .init(
            id: "rec03",
            type: .record,
            title: "Highest Capital",
            body: "La Paz, Bolivia stands at 3,650 metres above sea level, " +
                "making it the world's highest administrative capital city. Newcomers often need days to adjust.",
            countryCode: "BO",
            icon: "mountain.2.fill",
            color: .orange
        ),
        .init(
            id: "rec04",
            type: .record,
            title: "Largest Country",
            body: "Russia is the largest country on Earth at 17.1 million km², " +
                "covering 11% of all land on the planet. It is nearly twice the size of Canada.",
            countryCode: "RU",
            icon: "globe.europe.africa.fill",
            color: .red
        ),
        .init(
            id: "rec05",
            type: .record,
            title: "Most Populous Country",
            body: "India surpassed China in 2023 to become the most populous nation with over 1.4 billion people, " +
                "projected to keep growing until at least 2064.",
            countryCode: "IN",
            icon: "person.3.fill",
            color: .orange
        ),
        .init(
            id: "rec06",
            type: .record,
            title: "Youngest Country",
            body: "South Sudan, which gained independence from Sudan in 2011, " +
                "is the world's youngest internationally recognised country.",
            countryCode: "SS",
            icon: "flag.fill",
            color: .green
        ),
        .init(
            id: "rec07",
            type: .record,
            title: "Oldest Country",
            body: "San Marino, founded in 301 AD, claims to be the world's oldest republic. " +
                "It is completely surrounded by Italy and has a population of only 34,000.",
            countryCode: "SM",
            icon: "scroll.fill",
            color: .indigo
        ),
        .init(
            id: "rec08",
            type: .record,
            title: "Most Borders",
            body: "China and Russia are tied for the most land borders at 14 neighbouring countries each. " +
                "China's borders stretch over 22,000 km in total.",
            countryCode: "CN",
            icon: "line.diagonal",
            color: .red
        ),
        .init(
            id: "rec09",
            type: .record,
            title: "Flattest Country",
            body: "The Maldives is the world's flattest country, with an average elevation of just 1.8 metres " +
                "above sea level. It is extremely vulnerable to rising sea levels.",
            countryCode: "MV",
            icon: "arrow.up.and.down",
            color: .teal
        ),
        .init(
            id: "rec10",
            type: .record,
            title: "Most Visited Country",
            body: "France consistently ranks as the world's most visited country, " +
                "welcoming over 90 million international tourists each year — more than its entire population.",
            countryCode: "FR",
            icon: "airplane.arrival",
            color: .blue
        ),

        // MARK: Fun Facts
        .init(
            id: "ff01",
            type: .funFact,
            title: "Finland's Saunas",
            body: "Finland has 3.3 million saunas for a population of 5.5 million people " +
                "— roughly one sauna per two people. It is a fundamental part of Finnish culture.",
            countryCode: "FI",
            icon: "flame.fill",
            color: .orange
        ),
        .init(
            id: "ff02",
            type: .funFact,
            title: "Sweden's Right-Hand Turn",
            body: "On September 3, 1967, Sweden switched from driving on the left to the right overnight. " +
                "The entire country changed simultaneously at 5:00 AM.",
            countryCode: "SE",
            icon: "car.fill",
            color: .yellow
        ),
        .init(
            id: "ff03",
            type: .funFact,
            title: "Switzerland's Army Knives",
            body: "Switzerland exports 34,000 army knives every day, yet has not fought a war since 1815. " +
                "The Swiss Armed Forces have been officially neutral for over 200 years.",
            countryCode: "CH",
            icon: "scissors",
            color: .red
        ),
        .init(
            id: "ff04",
            type: .funFact,
            title: "Bhutan's Gross Happiness",
            body: "Bhutan measures its success not by GDP but by 'Gross National Happiness', " +
                "a concept that considers wellbeing, culture, environment, and governance equally.",
            countryCode: "BT",
            icon: "face.smiling.fill",
            color: .orange
        ),
        .init(
            id: "ff05",
            type: .funFact,
            title: "Colombia's Flowers",
            body: "Colombia is the world's second-largest exporter of flowers after the Netherlands, " +
                "responsible for about 75% of all flowers sold in the United States.",
            countryCode: "CO",
            icon: "leaf.fill",
            color: .pink
        ),
        .init(
            id: "ff06",
            type: .funFact,
            title: "Kyrgyzstan's Eagle Hunters",
            body: "Kyrgyzstan is home to the ancient tradition of hunting with trained golden eagles. " +
                "Some of these birds are passed down through generations of nomadic families.",
            countryCode: "KG",
            icon: "bird.fill",
            color: .brown
        ),
        .init(
            id: "ff07",
            type: .funFact,
            title: "Peru's Potato Origin",
            body: "The potato was first domesticated in Peru around 7,000 years ago. " +
                "Today there are over 4,000 varieties of potato still grown in the Andes mountains.",
            countryCode: "PE",
            icon: "fork.knife",
            color: .orange
        ),
        .init(
            id: "ff08",
            type: .funFact,
            title: "Denmark's Bike Culture",
            body: "In Copenhagen, Denmark, more people commute by bicycle than by car. " +
                "The city has 390 km of dedicated bike lanes, and 62% of residents cycle year-round.",
            countryCode: "DK",
            icon: "bicycle",
            color: .green
        ),
        .init(
            id: "ff09",
            type: .funFact,
            title: "Singapore's Chewing Gum Ban",
            body: "Singapore banned chewing gum in 1992 to keep public spaces clean. " +
                "It is only sold with a prescription for therapeutic purposes such as nicotine gum.",
            countryCode: "SG",
            icon: "exclamationmark.circle.fill",
            color: .red
        ),
        .init(
            id: "ff10",
            type: .funFact,
            title: "Ethiopia's Calendar",
            body: "Ethiopia follows its own calendar system and is 7 to 8 years behind the Gregorian calendar. " +
                "They also have 13 months and celebrate New Year in September.",
            countryCode: "ET",
            icon: "calendar",
            color: .green
        ),

        // MARK: Facts
        .init(
            id: "fct01",
            type: .fact,
            title: "Africa's Size",
            body: "Africa is the second-largest continent but is larger than China, the USA, India, Mexico, " +
                "and much of Europe combined. Maps often underrepresent its true size.",
            countryCode: nil,
            icon: "globe.europe.africa.fill",
            color: .orange
        ),
        .init(
            id: "fct02",
            type: .fact,
            title: "Arctic vs. Antarctic",
            body: "The Arctic is an ocean covered by ice surrounded by land. " +
                "Antarctica is a continent covered by ice surrounded by ocean. " +
                "Polar bears live only in the Arctic.",
            countryCode: nil,
            icon: "snowflake",
            color: .blue
        ),
        .init(
            id: "fct03",
            type: .fact,
            title: "Landlocked Countries",
            body: "There are 44 landlocked countries in the world, with no access to the sea. " +
                "Kazakhstan is the world's largest landlocked country, bigger than Western Europe.",
            countryCode: "KZ",
            icon: "land.below.water",
            color: .brown
        ),
        .init(
            id: "fct04",
            type: .fact,
            title: "Country Name Origins",
            body: "Many country names have surprising origins. Brazil is named after the brazilwood tree, " +
                "while Argentina comes from the Latin 'argentum' meaning silver.",
            countryCode: nil,
            icon: "book.fill",
            color: .purple
        ),
        .init(
            id: "fct05",
            type: .fact,
            title: "Island Nations",
            body: "There are 47 island nations in the world. Indonesia alone consists of over 17,000 islands, " +
                "and the Philippines has more than 7,000, spread across the Pacific Ocean.",
            countryCode: "ID",
            icon: "water.waves",
            color: .blue
        ),
        .init(
            id: "fct06",
            type: .fact,
            title: "Equatorial Countries",
            body: "The equator passes through 11 countries: Ecuador, Colombia, Brazil, " +
                "São Tomé and Príncipe, Gabon, Congo, DRC, Uganda, Kenya, Somalia, and Indonesia.",
            countryCode: "EC",
            icon: "globe",
            color: .green
        ),
        .init(
            id: "fct07",
            type: .fact,
            title: "Longest Country Name",
            body: "The UK's full name is 'United Kingdom of Great Britain and Northern Ireland'. " +
                "Libya was once 'Great Socialist People's Libyan Arab Jamahiriya'.",
            countryCode: "GB",
            icon: "textformat",
            color: .red
        ),
        .init(
            id: "fct08",
            type: .fact,
            title: "Countries Without Rivers",
            body: "Several countries have no rivers at all, including Saudi Arabia, Yemen, Malta, and Qatar. " +
                "They rely on desalination plants and underground aquifers.",
            countryCode: "SA",
            icon: "drop.triangle.fill",
            color: .yellow
        ),
        .init(
            id: "fct09",
            type: .fact,
            title: "Five Oceans",
            body: "Earth has five oceans: the Pacific (largest), Atlantic, Indian, " +
                "Southern (recognised in 2000), and Arctic (smallest). " +
                "The Pacific alone is larger than all land combined.",
            countryCode: nil,
            icon: "water.waves.and.arrow.trianglehead.up.fill",
            color: .blue
        ),
        .init(
            id: "fct10",
            type: .fact,
            title: "Unique Shaped Flags",
            body: "Nepal is the only country with a non-rectangular national flag — " +
                "it consists of two stacked triangular pennants. All other countries use rectangles or squares.",
            countryCode: "NP",
            icon: "flag.fill",
            color: .red
        ),
        .init(
            id: "fct11",
            type: .funFact,
            title: "Greenland's Ownership",
            body: "Greenland is geographically part of North America but politically an autonomous territory " +
                "of Denmark in Europe. It is the world's largest island at 2.17 million km².",
            countryCode: "GL",
            icon: "snowflake",
            color: .teal
        ),
        .init(
            id: "fct12",
            type: .record,
            title: "Deepest Lake",
            body: "Lake Baikal in Siberia, Russia, is the world's deepest lake at 1,642 metres. " +
                "It contains about 20% of all the world's unfrozen surface fresh water.",
            countryCode: "RU",
            icon: "water.waves",
            color: .blue
        ),
        .init(
            id: "fct13",
            type: .didYouKnow,
            title: "Isolated Markets",
            body: "Cuba and North Korea were the only countries where Coca-Cola was not officially sold " +
                "until 2015 when Cuba opened. North Korea remains the last holdout.",
            countryCode: "KP",
            icon: "cup.and.saucer.fill",
            color: .red
        ),
        .init(
            id: "fct14",
            type: .funFact,
            title: "Czech Beer Culture",
            body: "Czechia has the highest beer consumption per capita in the world, " +
                "with each person drinking an average of 184 litres of beer per year.",
            countryCode: "CZ",
            icon: "mug.fill",
            color: .yellow
        ),
        .init(
            id: "fct15",
            type: .fact,
            title: "Micro-Nations",
            body: "There are several disputed micro-nations in the world, including Sealand " +
                "(an abandoned sea fort off England), Liberland on the Danube, and Lovely (a garden in the UK).",
            countryCode: nil,
            icon: "flag.2.crossed.fill",
            color: .purple
        ),
    ]
}
// swiftlint:enable closure_body_length
