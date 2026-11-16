struct CountryNickname: Sendable {
    let nickname: String
    let reason: String
}

// MARK: - Data
/// Informal country nicknames, keyed by ISO 3166-1 alpha-2 country code.
// swiftlint:disable:next type_body_length
enum CountryNicknames {
    static let data: [String: [CountryNickname]] = [
        "AR": [
            CountryNickname(
                nickname: "Land of Silver",
                reason: "The name Argentina comes from the Latin 'argentum' meaning silver. Spanish explorers "
                    + "named it after the silver objects they saw indigenous peoples wearing."
            ),
        ],
        "AU": [
            CountryNickname(
                nickname: "Land Down Under",
                reason: "Australia lies entirely in the Southern Hemisphere, below the equator — quite literally "
                    + "'down under' relative to Europe and North America."
            ),
        ],
        "AZ": [
            CountryNickname(
                nickname: "Land of Fire",
                reason: "Azerbaijan has natural gas fires that burn eternally from the ground. The ancient "
                    + "Zoroastrians considered these flames sacred, building fire temples around them."
            ),
        ],
        "BE": [
            CountryNickname(
                nickname: "Cockpit of Europe",
                reason: "Belgium's central location made it the site of major European battles from Waterloo "
                    + "(1815) to WWI. Conflicts repeatedly played out on its soil."
            ),
        ],
        "BR": [
            CountryNickname(
                nickname: "Land of Football",
                reason: "Brazil has won the FIFA World Cup five times — more than any other nation — and produced"
                    + " legends like Pelé, Ronaldo, and Ronaldinho."
            ),
        ],
        "CA": [
            CountryNickname(
                nickname: "Great White North",
                reason: "Canada's vast northern territories are blanketed in snow and ice for much of the year. "
                    + "The phrase also reflects Canada's reputation as cold in both climate and character."
            ),
        ],
        "CH": [
            CountryNickname(
                nickname: "Playground of Europe",
                reason: "Switzerland's majestic Alps, pristine lakes, and world-class ski resorts made it the "
                    + "premier destination for wealthy European tourists in the 19th century."
            ),
        ],
        "CL": [
            CountryNickname(
                nickname: "Land of Poets",
                reason: "Chile has produced two Nobel Prize winners in Literature — Pablo Neruda and Gabriela "
                    + "Mistral — an extraordinary achievement for any small nation."
            ),
        ],
        "CN": [
            CountryNickname(
                nickname: "Middle Kingdom",
                reason: "The Chinese name for China (Zhongguo) literally means 'Middle Kingdom' — ancient Chinese"
                    + " believed their empire was at the centre of the world."
            ),
        ],
        "CO": [
            CountryNickname(
                nickname: "Land of El Dorado",
                reason: "The legend of El Dorado — a city of gold — originated from the Muisca people of "
                    + "Colombia, who coated their chief in gold dust during sacred ceremonies."
            ),
        ],
        "CU": [
            CountryNickname(
                nickname: "Pearl of the Antilles",
                reason: "Columbus called Cuba 'the most beautiful land human eyes have ever seen.' Its lush "
                    + "landscapes, crystalline waters, and colonial architecture earned this jewel nickname."
            ),
        ],
        "DE": [
            CountryNickname(
                nickname: "Land of Poets and Thinkers",
                reason: "Germany produced Goethe, Schiller, Kant, Hegel, Marx, and Nietzsche. This nickname "
                    + "celebrates its extraordinary intellectual and literary heritage."
            ),
        ],
        "DK": [
            CountryNickname(
                nickname: "Land of the Danes",
                reason: "Denmark's name itself means 'Land of the Danes' — reflecting one of Europe's oldest "
                    + "national identities stretching back over 1,000 years."
            ),
        ],
        "EG": [
            CountryNickname(
                nickname: "Gift of the Nile",
                reason: "The historian Herodotus coined this phrase. The annual flooding of the Nile deposited "
                    + "rich silt that made Egypt's soil among the most fertile on earth."
            ),
        ],
        "ES": [
            CountryNickname(
                nickname: "Land of the Sun",
                reason: "Spain's Mediterranean climate provides over 3,000 hours of sunshine per year in some "
                    + "regions, earning it one of Europe's sunniest reputations."
            ),
        ],
        "ET": [
            CountryNickname(
                nickname: "Land of Origins",
                reason: "Ethiopia is home to the oldest known human fossils and produced the world's first "
                    + "coffee. Rastafarianism views it as the Promised Land."
            ),
        ],
        "FI": [
            CountryNickname(
                nickname: "Land of a Thousand Lakes",
                reason: "Finland is home to over 187,000 lakes, the most per capita of any country. About 10% of "
                    + "Finland's total area is covered by water."
            ),
        ],
        "FR": [
            CountryNickname(
                nickname: "Hexagon",
                reason: "France's mainland territory has six sides roughly approximating a hexagon shape, making "
                    + "'l'Hexagone' a common self-referential nickname used by French people."
            ),
        ],
        "GB": [
            CountryNickname(
                nickname: "Sceptred Isle",
                reason: "From Shakespeare's Richard II, England is described as 'this sceptred isle.' The phrase "
                    + "became a common way to describe Britain's proud island identity."
            ),
        ],
        "GR": [
            CountryNickname(
                nickname: "Cradle of Western Civilization",
                reason: "Ancient Greece gave the world democracy, philosophy, mathematics, theatre, and the "
                    + "Olympic Games, forming the intellectual foundations of Western culture."
            ),
        ],
        "ID": [
            CountryNickname(
                nickname: "Emerald of the Equator",
                reason: "Indonesia's thousands of lush tropical islands, draped in dense rainforest and "
                    + "surrounded by turquoise seas, create a green jewel stretching across the equator."
            ),
        ],
        "IE": [
            CountryNickname(
                nickname: "Emerald Isle",
                reason: "Ireland's temperate climate and abundant rainfall create lush, intensely green "
                    + "landscapes that earned it this poetic nickname used since the 18th century."
            ),
        ],
        "IL": [
            CountryNickname(
                nickname: "Startup Nation",
                reason: "Israel has the highest density of tech startups per capita in the world and more "
                    + "companies listed on NASDAQ than any other foreign country outside China."
            ),
        ],
        "IN": [
            CountryNickname(
                nickname: "Land of Spices",
                reason: "India was the world's primary source of spices like pepper and cardamom for millennia. "
                    + "The spice trade drove European exploration of sea routes to Asia."
            ),
        ],
        "IS": [
            CountryNickname(
                nickname: "Land of Fire and Ice",
                reason: "Iceland's unique geology features both active volcanoes and vast glaciers existing side "
                    + "by side — a dramatic contrast found nowhere else on earth."
            ),
        ],
        "IT": [
            CountryNickname(
                nickname: "Boot of Europe",
                reason: "Italy's distinctive peninsula protrudes into the Mediterranean Sea in the unmistakable "
                    + "shape of a high-heeled boot — visible on any map of Europe."
            ),
        ],
        "JP": [
            CountryNickname(
                nickname: "Land of the Rising Sun",
                reason: "Japan's name in Japanese (Nihon) means 'origin of the sun.' From China's perspective to "
                    + "the west, the sun rose from the direction of Japan."
            ),
        ],
        "KE": [
            CountryNickname(
                nickname: "Cradle of Mankind",
                reason: "The East African Rift Valley in Kenya has yielded some of the oldest human fossils, "
                    + "suggesting early humans evolved in this region."
            ),
        ],
        "KZ": [
            CountryNickname(
                nickname: "Land of the Great Steppe",
                reason: "Kazakhstan contains the world's largest dry steppe — a vast, windswept grassland "
                    + "stretching for thousands of kilometres across Central Asia."
            ),
        ],
        "LK": [
            CountryNickname(
                nickname: "Pearl of the Indian Ocean",
                reason: "Sri Lanka's teardrop shape and extraordinary biodiversity — including elephants, "
                    + "leopards, and over 400 bird species — make it a precious gem."
            ),
        ],
        "MA": [
            CountryNickname(
                nickname: "Gateway to Africa",
                reason: "Morocco sits at the northernmost tip of Africa, separated from Europe by only 14 km of "
                    + "the Strait of Gibraltar."
            ),
        ],
        "MX": [
            CountryNickname(
                nickname: "Land of the Aztecs",
                reason: "The Aztec Empire, centred in modern-day Mexico City, was one of the greatest pre-"
                    + "Columbian civilisations, known for its art, architecture, and calendar systems."
            ),
        ],
        "MY": [
            CountryNickname(
                nickname: "Truly Asia",
                reason: "Malaysia's tourism tagline reflects its extraordinary diversity — Malay, Chinese, "
                    + "Indian, and indigenous cultures coexist, a microcosm of Asian civilisations."
            ),
        ],
        "NG": [
            CountryNickname(
                nickname: "Giant of Africa",
                reason: "Nigeria is Africa's most populous nation with over 220 million people, its largest "
                    + "economy, and most influential cultural powerhouse through Nollywood."
            ),
        ],
        "NL": [
            CountryNickname(
                nickname: "Land of Windmills and Tulips",
                reason: "Historic windmills once powered Dutch industry and pumped water from polders. Combined "
                    + "with vivid tulip fields, they became iconic symbols of Dutch identity."
            ),
        ],
        "NO": [
            CountryNickname(
                nickname: "Land of the Midnight Sun",
                reason: "In summer, the sun never fully sets above the Arctic Circle in Norway, creating days of "
                    + "continuous daylight that last for weeks."
            ),
        ],
        "NZ": [
            CountryNickname(
                nickname: "Land of the Long White Cloud",
                reason: "In Māori, New Zealand is called Aotearoa — 'long white cloud.' The navigator Kupe "
                    + "reportedly first spotted the islands by the clouds above them."
            ),
        ],
        "PE": [
            CountryNickname(
                nickname: "Land of the Incas",
                reason: "Peru was the heart of the Inca Empire, the largest empire in pre-Columbian America. "
                    + "Machu Picchu and Cusco stand as enduring monuments to this civilisation."
            ),
        ],
        "PH": [
            CountryNickname(
                nickname: "Pearl of the Orient Seas",
                reason: "José Rizal used this phrase in his poem 'Mi último adiós' to describe the Philippines' "
                    + "beauty. It remains one of the country's most beloved nicknames."
            ),
        ],
        "PK": [
            CountryNickname(
                nickname: "Land of the Pure",
                reason: "The name Pakistan comes from Urdu/Persian initials of its regions. 'Pakistan' also "
                    + "directly means 'Land of the Pure' in Urdu."
            ),
        ],
        "PT": [
            CountryNickname(
                nickname: "Land of Explorers",
                reason: "During the Age of Discovery, Portuguese sailors mapped the coasts of Africa, discovered "
                    + "sea routes to India, and reached Brazil."
            ),
        ],
        "RU": [
            CountryNickname(
                nickname: "Land of the Bear",
                reason: "The bear has symbolised Russia for centuries — representing strength and resilience. "
                    + "Russia contains the world's largest wild brown bear population."
            ),
        ],
        "SE": [
            CountryNickname(
                nickname: "Land of the Vikings",
                reason: "Swedish Norsemen raided and traded across Europe, Asia, and even reached North America "
                    + "during the Viking Age (793–1066 AD), leaving a lasting cultural imprint."
            ),
        ],
        "SG": [
            CountryNickname(
                nickname: "Lion City",
                reason: "Singapore's name comes from the Sanskrit 'Singapura' meaning 'Lion City.' According to "
                    + "legend, a Sumatran prince saw a lion on the island — likely a tiger."
            ),
        ],
        "TH": [
            CountryNickname(
                nickname: "Land of Smiles",
                reason: "Thailand's tourism board adopted this nickname in the 1980s to reflect its welcoming "
                    + "culture. Thais use over 13 distinct types of smiles in daily life."
            ),
        ],
        "TR": [
            CountryNickname(
                nickname: "Bridge Between Two Worlds",
                reason: "Turkey straddles Europe and Asia, with Istanbul divided by the Bosphorus strait. The "
                    + "country has historically been a crossroads of Eastern and Western civilisations."
            ),
        ],
        "US": [
            CountryNickname(
                nickname: "Land of the Free",
                reason: "From the Star-Spangled Banner anthem, this phrase encapsulates America's founding ideals"
                    + " of liberty and freedom enshrined in the Bill of Rights."
            ),
        ],
        "ZA": [
            CountryNickname(
                nickname: "Rainbow Nation",
                reason: "Archbishop Desmond Tutu coined this term after apartheid ended in 1994 to celebrate "
                    + "South Africa's extraordinary ethnic and cultural diversity."
            ),
        ],
    ]
}
