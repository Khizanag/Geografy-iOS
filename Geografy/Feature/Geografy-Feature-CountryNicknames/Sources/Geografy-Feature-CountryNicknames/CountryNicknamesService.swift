import Foundation

@Observable
public final class CountryNicknamesService {
    public init() {}
    private(set) var nicknames: [CountryNickname] = CountryNicknamesService.allNicknames

    public func nicknames(for category: NicknameCategory?) -> [CountryNickname] {
        guard let category else { return nicknames }
        return nicknames.filter { $0.category == category }
    }

    public func filteredNicknames(query: String, category: NicknameCategory?) -> [CountryNickname] {
        var result = nicknames
        if let category {
            result = result.filter { $0.category == category }
        }
        if !query.isEmpty {
            let lowercased = query.lowercased()
            result = result.filter {
                $0.nickname.lowercased().contains(lowercased)
                    || $0.reason.lowercased().contains(lowercased)
            }
        }
        return result
    }
}

// MARK: - Data
extension CountryNicknamesService {
    nonisolated(unsafe) public static let allNicknames: [CountryNickname] = [
        CountryNickname(
            id: "AZ", countryCode: "AZ",
            nickname: "Land of Fire",
            reason: "Azerbaijan has natural gas fires that burn eternally from the ground."
                + " The ancient Zoroastrians considered these flames sacred, building fire temples around them.",
            category: .nature
        ),
        CountryNickname(
            id: "NO", countryCode: "NO",
            nickname: "Land of the Midnight Sun",
            reason: "In summer, the sun never fully sets above the Arctic Circle in Norway,"
                + " creating days of continuous daylight that last for weeks.",
            category: .nature
        ),
        CountryNickname(
            id: "FI", countryCode: "FI",
            nickname: "Land of a Thousand Lakes",
            reason: "Finland is home to over 187,000 lakes, the most per capita of any country."
                + " About 10% of Finland's total area is covered by water.",
            category: .geography
        ),
        CountryNickname(
            id: "JP", countryCode: "JP",
            nickname: "Land of the Rising Sun",
            reason: "Japan's name in Japanese (Nihon) means 'origin of the sun.'"
                + " From China's perspective to the west, the sun rose from the direction of Japan.",
            category: .geography
        ),
        CountryNickname(
            id: "CH", countryCode: "CH",
            nickname: "Playground of Europe",
            reason: "Switzerland's majestic Alps, pristine lakes, and world-class ski resorts"
                + " made it the premier destination for wealthy European tourists in the 19th century.",
            category: .geography
        ),
        CountryNickname(
            id: "PT", countryCode: "PT",
            nickname: "Land of Explorers",
            reason: "During the Age of Discovery, Portuguese sailors mapped the coasts of Africa,"
                + " discovered sea routes to India, and reached Brazil.",
            category: .history
        ),
        CountryNickname(
            id: "GR", countryCode: "GR",
            nickname: "Cradle of Western Civilization",
            reason: "Ancient Greece gave the world democracy, philosophy, mathematics, theatre,"
                + " and the Olympic Games, forming the intellectual foundations of Western culture.",
            category: .history
        ),
        CountryNickname(
            id: "EG", countryCode: "EG",
            nickname: "Gift of the Nile",
            reason: "The historian Herodotus coined this phrase. The annual flooding of the Nile"
                + " deposited rich silt that made Egypt's soil among the most fertile on earth.",
            category: .geography
        ),
        CountryNickname(
            id: "KE", countryCode: "KE",
            nickname: "Cradle of Mankind",
            reason: "The East African Rift Valley in Kenya has yielded some of the oldest human fossils,"
                + " suggesting early humans evolved in this region.",
            category: .history
        ),
        CountryNickname(
            id: "BR", countryCode: "BR",
            nickname: "Land of Football",
            reason: "Brazil has won the FIFA World Cup five times — more than any other nation"
                + " — and produced legends like Pelé, Ronaldo, and Ronaldinho.",
            category: .culture
        ),
        CountryNickname(
            id: "AR", countryCode: "AR",
            nickname: "Land of Silver",
            reason: "The name Argentina comes from the Latin 'argentum' meaning silver."
                + " Spanish explorers named it after the silver objects they saw indigenous peoples wearing.",
            category: .history
        ),
        CountryNickname(
            id: "PE", countryCode: "PE",
            nickname: "Land of the Incas",
            reason: "Peru was the heart of the Inca Empire, the largest empire in pre-Columbian America."
                + " Machu Picchu and Cusco stand as enduring monuments to this civilisation.",
            category: .history
        ),
        CountryNickname(
            id: "CN", countryCode: "CN",
            nickname: "Middle Kingdom",
            reason: "The Chinese name for China (Zhongguo) literally means 'Middle Kingdom'"
                + " — ancient Chinese believed their empire was at the centre of the world.",
            category: .culture
        ),
        CountryNickname(
            id: "IN", countryCode: "IN",
            nickname: "Land of Spices",
            reason: "India was the world's primary source of spices like pepper and cardamom for millennia."
                + " The spice trade drove European exploration of sea routes to Asia.",
            category: .culture
        ),
        CountryNickname(
            id: "TH", countryCode: "TH",
            nickname: "Land of Smiles",
            reason: "Thailand's tourism board adopted this nickname in the 1980s to reflect its welcoming culture."
                + " Thais use over 13 distinct types of smiles in daily life.",
            category: .culture
        ),
        CountryNickname(
            id: "NZ", countryCode: "NZ",
            nickname: "Land of the Long White Cloud",
            reason: "In Māori, New Zealand is called Aotearoa — 'long white cloud.'"
                + " The navigator Kupe reportedly first spotted the islands by the clouds above them.",
            category: .geography
        ),
        CountryNickname(
            id: "AU", countryCode: "AU",
            nickname: "Land Down Under",
            reason: "Australia lies entirely in the Southern Hemisphere, below the equator"
                + " — quite literally 'down under' relative to Europe and North America.",
            category: .geography
        ),
        CountryNickname(
            id: "IE", countryCode: "IE",
            nickname: "Emerald Isle",
            reason: "Ireland's temperate climate and abundant rainfall create lush, intensely green landscapes"
                + " that earned it this poetic nickname used since the 18th century.",
            category: .nature
        ),
        CountryNickname(
            id: "IS", countryCode: "IS",
            nickname: "Land of Fire and Ice",
            reason: "Iceland's unique geology features both active volcanoes and vast glaciers"
                + " existing side by side — a dramatic contrast found nowhere else on earth.",
            category: .nature
        ),
        CountryNickname(
            id: "CA", countryCode: "CA",
            nickname: "Great White North",
            reason: "Canada's vast northern territories are blanketed in snow and ice for much of the year."
                + " The phrase also reflects Canada's reputation as cold in both climate and character.",
            category: .geography
        ),
        CountryNickname(
            id: "US", countryCode: "US",
            nickname: "Land of the Free",
            reason: "From the Star-Spangled Banner anthem, this phrase encapsulates America's founding ideals"
                + " of liberty and freedom enshrined in the Bill of Rights.",
            category: .history
        ),
        CountryNickname(
            id: "MX", countryCode: "MX",
            nickname: "Land of the Aztecs",
            reason: "The Aztec Empire, centred in modern-day Mexico City, was one of the greatest"
                + " pre-Columbian civilisations, known for its art, architecture, and calendar systems.",
            category: .history
        ),
        CountryNickname(
            id: "FR", countryCode: "FR",
            nickname: "Hexagon",
            reason: "France's mainland territory has six sides roughly approximating a hexagon shape,"
                + " making 'l'Hexagone' a common self-referential nickname used by French people.",
            category: .geography
        ),
        CountryNickname(
            id: "IT", countryCode: "IT",
            nickname: "Boot of Europe",
            reason: "Italy's distinctive peninsula protrudes into the Mediterranean Sea"
                + " in the unmistakable shape of a high-heeled boot — visible on any map of Europe.",
            category: .geography
        ),
        CountryNickname(
            id: "GB", countryCode: "GB",
            nickname: "Sceptred Isle",
            reason: "From Shakespeare's Richard II, England is described as 'this sceptred isle.'"
                + " The phrase became a common way to describe Britain's proud island identity.",
            category: .culture
        ),
        CountryNickname(
            id: "DE", countryCode: "DE",
            nickname: "Land of Poets and Thinkers",
            reason: "Germany produced Goethe, Schiller, Kant, Hegel, Marx, and Nietzsche."
                + " This nickname celebrates its extraordinary intellectual and literary heritage.",
            category: .culture
        ),
        CountryNickname(
            id: "ES", countryCode: "ES",
            nickname: "Land of the Sun",
            reason: "Spain's Mediterranean climate provides over 3,000 hours of sunshine per year"
                + " in some regions, earning it one of Europe's sunniest reputations.",
            category: .nature
        ),
        CountryNickname(
            id: "NL", countryCode: "NL",
            nickname: "Land of Windmills and Tulips",
            reason: "Historic windmills once powered Dutch industry and pumped water from polders."
                + " Combined with vivid tulip fields, they became iconic symbols of Dutch identity.",
            category: .culture
        ),
        CountryNickname(
            id: "BE", countryCode: "BE",
            nickname: "Cockpit of Europe",
            reason: "Belgium's central location made it the site of major European battles from Waterloo (1815)"
                + " to WWI. Conflicts repeatedly played out on its soil.",
            category: .history
        ),
        CountryNickname(
            id: "SE", countryCode: "SE",
            nickname: "Land of the Vikings",
            reason: "Swedish Norsemen raided and traded across Europe, Asia, and even reached North America"
                + " during the Viking Age (793–1066 AD), leaving a lasting cultural imprint.",
            category: .history
        ),
        CountryNickname(
            id: "RU", countryCode: "RU",
            nickname: "Land of the Bear",
            reason: "The bear has symbolised Russia for centuries — representing strength and resilience."
                + " Russia contains the world's largest wild brown bear population.",
            category: .nature
        ),
        CountryNickname(
            id: "TR", countryCode: "TR",
            nickname: "Bridge Between Two Worlds",
            reason: "Turkey straddles Europe and Asia, with Istanbul divided by the Bosphorus strait."
                + " The country has historically been a crossroads of Eastern and Western civilisations.",
            category: .geography
        ),
        CountryNickname(
            id: "MA", countryCode: "MA",
            nickname: "Gateway to Africa",
            reason: "Morocco sits at the northernmost tip of Africa,"
                + " separated from Europe by only 14 km of the Strait of Gibraltar.",
            category: .geography
        ),
        CountryNickname(
            id: "ZA", countryCode: "ZA",
            nickname: "Rainbow Nation",
            reason: "Archbishop Desmond Tutu coined this term after apartheid ended in 1994"
                + " to celebrate South Africa's extraordinary ethnic and cultural diversity.",
            category: .culture
        ),
        CountryNickname(
            id: "NG", countryCode: "NG",
            nickname: "Giant of Africa",
            reason: "Nigeria is Africa's most populous nation with over 220 million people,"
                + " its largest economy, and most influential cultural powerhouse through Nollywood.",
            category: .culture
        ),
        CountryNickname(
            id: "ET", countryCode: "ET",
            nickname: "Land of Origins",
            reason: "Ethiopia is home to the oldest known human fossils and produced the world's first coffee."
                + " Rastafarianism views it as the Promised Land.",
            category: .history
        ),
        CountryNickname(
            id: "ID", countryCode: "ID",
            nickname: "Emerald of the Equator",
            reason: "Indonesia's thousands of lush tropical islands, draped in dense rainforest"
                + " and surrounded by turquoise seas, create a green jewel stretching across the equator.",
            category: .nature
        ),
        CountryNickname(
            id: "PH", countryCode: "PH",
            nickname: "Pearl of the Orient Seas",
            reason: "José Rizal used this phrase in his poem 'Mi último adiós' to describe the Philippines' beauty."
                + " It remains one of the country's most beloved nicknames.",
            category: .culture
        ),
        CountryNickname(
            id: "MY", countryCode: "MY",
            nickname: "Truly Asia",
            reason: "Malaysia's tourism tagline reflects its extraordinary diversity"
                + " — Malay, Chinese, Indian, and indigenous cultures coexist, a microcosm of Asian civilisations.",
            category: .culture
        ),
        CountryNickname(
            id: "CU", countryCode: "CU",
            nickname: "Pearl of the Antilles",
            reason: "Columbus called Cuba 'the most beautiful land human eyes have ever seen.'"
                + " Its lush landscapes, crystalline waters, and colonial architecture earned this jewel nickname.",
            category: .nature
        ),
        CountryNickname(
            id: "CL", countryCode: "CL",
            nickname: "Land of Poets",
            reason: "Chile has produced two Nobel Prize winners in Literature"
                + " — Pablo Neruda and Gabriela Mistral — an extraordinary achievement for any small nation.",
            category: .culture
        ),
        CountryNickname(
            id: "CO", countryCode: "CO",
            nickname: "Land of El Dorado",
            reason: "The legend of El Dorado — a city of gold — originated from the Muisca people of Colombia,"
                + " who coated their chief in gold dust during sacred ceremonies.",
            category: .history
        ),
        CountryNickname(
            id: "PK", countryCode: "PK",
            nickname: "Land of the Pure",
            reason: "The name Pakistan comes from Urdu/Persian initials of its regions."
                + " 'Pakistan' also directly means 'Land of the Pure' in Urdu.",
            category: .history
        ),
        CountryNickname(
            id: "LK", countryCode: "LK",
            nickname: "Pearl of the Indian Ocean",
            reason: "Sri Lanka's teardrop shape and extraordinary biodiversity"
                + " — including elephants, leopards, and over 400 bird species — make it a precious gem.",
            category: .nature
        ),
        CountryNickname(
            id: "DK", countryCode: "DK",
            nickname: "Land of the Danes",
            reason: "Denmark's name itself means 'Land of the Danes'"
                + " — reflecting one of Europe's oldest national identities stretching back over 1,000 years.",
            category: .history
        ),
        CountryNickname(
            id: "IL", countryCode: "IL",
            nickname: "Startup Nation",
            reason: "Israel has the highest density of tech startups per capita in the world"
                + " and more companies listed on NASDAQ than any other foreign country outside China.",
            category: .culture
        ),
        CountryNickname(
            id: "SG", countryCode: "SG",
            nickname: "Lion City",
            reason: "Singapore's name comes from the Sanskrit 'Singapura' meaning 'Lion City.'"
                + " According to legend, a Sumatran prince saw a lion on the island — likely a tiger.",
            category: .history
        ),
        CountryNickname(
            id: "KZ", countryCode: "KZ",
            nickname: "Land of the Great Steppe",
            reason: "Kazakhstan contains the world's largest dry steppe"
                + " — a vast, windswept grassland stretching for thousands of kilometres across Central Asia.",
            category: .geography
        ),
    ]
}
