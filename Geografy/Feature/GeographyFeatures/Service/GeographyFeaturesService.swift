import Foundation

struct GeographyFeaturesService {
    let features: [GeographyFeature] = mountains + rivers + deserts + lakes

    func features(for type: GeographyFeatureType) -> [GeographyFeature] {
        features.filter { $0.type == type }
    }
}

// MARK: - Mountains

private let mountains: [GeographyFeature] = [
    GeographyFeature(
        id: "everest",
        name: "Mount Everest",
        type: .mountain,
        countryCode: "NP",
        countryCodes: ["NP", "CN"],
        measurement: 8_849,
        measurementLabel: "Height",
        measurementUnit: "m",
        continent: "Asia",
        description: "The highest peak on Earth, located in the Himalayas on the Nepal-China border.",
        funFact: "Everest grows about 4mm taller each year due to tectonic plate movement."
    ),
    GeographyFeature(
        id: "k2",
        name: "K2",
        type: .mountain,
        countryCode: "PK",
        countryCodes: ["PK", "CN"],
        measurement: 8_611,
        measurementLabel: "Height",
        measurementUnit: "m",
        continent: "Asia",
        description: "The second highest mountain on Earth, known as the 'Savage Mountain' for its extreme difficulty.",
        funFact: "K2 has never been climbed in winter — a feat that remained unachieved until January 2021."
    ),
    GeographyFeature(
        id: "kangchenjunga",
        name: "Kangchenjunga",
        type: .mountain,
        countryCode: "NP",
        countryCodes: ["NP", "IN"],
        measurement: 8_586,
        measurementLabel: "Height",
        measurementUnit: "m",
        continent: "Asia",
        description: "The third highest mountain, straddling Nepal and India's Sikkim state.",
        funFact: "Local tradition holds the summit as sacred, so most climbers stop just below the peak."
    ),
    GeographyFeature(
        id: "lhotse",
        name: "Lhotse",
        type: .mountain,
        countryCode: "NP",
        countryCodes: ["NP", "CN"],
        measurement: 8_516,
        measurementLabel: "Height",
        measurementUnit: "m",
        continent: "Asia",
        description: "The fourth highest mountain, directly south of Everest and connected by the South Col.",
        funFact: "Lhotse shares its base camp with Everest and is often climbed in conjunction with it."
    ),
    GeographyFeature(
        id: "makalu",
        name: "Makalu",
        type: .mountain,
        countryCode: "NP",
        countryCodes: ["NP", "CN"],
        measurement: 8_485,
        measurementLabel: "Height",
        measurementUnit: "m",
        continent: "Asia",
        description: "The fifth highest peak, shaped like a four-sided pyramid, southeast of Everest.",
        funFact: "Makalu is one of the most difficult eight-thousanders to climb due to sharp ridges."
    ),
    GeographyFeature(
        id: "cho-oyu",
        name: "Cho Oyu",
        type: .mountain,
        countryCode: "NP",
        countryCodes: ["NP", "CN"],
        measurement: 8_188,
        measurementLabel: "Height",
        measurementUnit: "m",
        continent: "Asia",
        description: "The sixth highest peak, considered one of the easier eight-thousanders to climb.",
        funFact: "Cho Oyu means 'Turquoise Goddess' in Tibetan."
    ),
    GeographyFeature(
        id: "dhaulagiri",
        name: "Dhaulagiri",
        type: .mountain,
        countryCode: "NP",
        countryCodes: ["NP"],
        measurement: 8_167,
        measurementLabel: "Height",
        measurementUnit: "m",
        continent: "Asia",
        description: "The seventh highest peak, entirely within Nepal, meaning 'White Mountain' in Sanskrit.",
        funFact: "For 30 years, Dhaulagiri was believed to be the world's highest mountain before Everest was measured."
    ),
    GeographyFeature(
        id: "manaslu",
        name: "Manaslu",
        type: .mountain,
        countryCode: "NP",
        countryCodes: ["NP"],
        measurement: 8_163,
        measurementLabel: "Height",
        measurementUnit: "m",
        continent: "Asia",
        description: "The eighth highest peak in Nepal, meaning 'Mountain of the Spirit' in Sanskrit.",
        funFact: "Manaslu was first climbed in 1956 by a Japanese expedition."
    ),
    GeographyFeature(
        id: "nanga-parbat",
        name: "Nanga Parbat",
        type: .mountain,
        countryCode: "PK",
        countryCodes: ["PK"],
        measurement: 8_126,
        measurementLabel: "Height",
        measurementUnit: "m",
        continent: "Asia",
        description: "The ninth highest mountain, known as 'Killer Mountain' for its high fatality rate.",
        funFact: "Nanga Parbat has one of the largest mountain faces on Earth — the Rupal Face rises 4,600m."
    ),
    GeographyFeature(
        id: "annapurna",
        name: "Annapurna I",
        type: .mountain,
        countryCode: "NP",
        countryCodes: ["NP"],
        measurement: 8_091,
        measurementLabel: "Height",
        measurementUnit: "m",
        continent: "Asia",
        description: "The tenth highest mountain and historically the most dangerous to climb.",
        funFact: "Annapurna was the first eight-thousander ever climbed, in 1950 by a French expedition."
    ),
    GeographyFeature(
        id: "kilimanjaro",
        name: "Kilimanjaro",
        type: .mountain,
        countryCode: "TZ",
        countryCodes: ["TZ"],
        measurement: 5_895,
        measurementLabel: "Height",
        measurementUnit: "m",
        continent: "Africa",
        description: "The highest peak in Africa and the world's tallest free-standing mountain.",
        funFact: "Kilimanjaro has lost over 80% of its ice cap since 1912 due to climate change."
    ),
    GeographyFeature(
        id: "mont-blanc",
        name: "Mont Blanc",
        type: .mountain,
        countryCode: "FR",
        countryCodes: ["FR", "IT"],
        measurement: 4_808,
        measurementLabel: "Height",
        measurementUnit: "m",
        continent: "Europe",
        description: "The highest peak in the Alps and Western Europe, on the France-Italy border.",
        funFact: "Mont Blanc's summit shifts slightly due to varying snow and ice accumulation each year."
    ),
    GeographyFeature(
        id: "denali",
        name: "Denali",
        type: .mountain,
        countryCode: "US",
        countryCodes: ["US"],
        measurement: 6_190,
        measurementLabel: "Height",
        measurementUnit: "m",
        continent: "North America",
        description: "The highest peak in North America, located in Alaska, formerly known as Mount McKinley.",
        funFact: "Denali has the greatest vertical relief of any mountain on land above sea level."
    ),
    GeographyFeature(
        id: "aconcagua",
        name: "Aconcagua",
        type: .mountain,
        countryCode: "AR",
        countryCodes: ["AR"],
        measurement: 6_961,
        measurementLabel: "Height",
        measurementUnit: "m",
        continent: "South America",
        description: "The highest peak in the Americas and the highest outside of Asia.",
        funFact: "Aconcagua is a non-technical climb but its extreme altitude makes it deadly."
    ),
    GeographyFeature(
        id: "elbrus",
        name: "Mount Elbrus",
        type: .mountain,
        countryCode: "RU",
        countryCodes: ["RU"],
        measurement: 5_642,
        measurementLabel: "Height",
        measurementUnit: "m",
        continent: "Europe",
        description: "The highest peak in Europe (by most definitions), a dormant volcano in the Caucasus.",
        funFact: "Elbrus has two summits — the west summit is slightly higher than the east."
    ),
]

// MARK: - Rivers

private let rivers: [GeographyFeature] = [
    GeographyFeature(
        id: "nile",
        name: "Nile",
        type: .river,
        countryCode: "EG",
        countryCodes: ["EG", "SD", "UG", "ET", "KE", "TZ", "RW", "BI"],
        measurement: 6_650,
        measurementLabel: "Length",
        measurementUnit: "km",
        continent: "Africa",
        description: "The world's longest river, flowing northward through northeastern Africa to the Mediterranean.",
        funFact: "Ancient Egyptian civilization was built entirely around the Nile's annual flood cycle."
    ),
    GeographyFeature(
        id: "amazon",
        name: "Amazon",
        type: .river,
        countryCode: "BR",
        countryCodes: ["BR", "PE", "CO"],
        measurement: 6_400,
        measurementLabel: "Length",
        measurementUnit: "km",
        continent: "South America",
        description: "The world's largest river by discharge, carrying 20% of all fresh water entering the oceans.",
        funFact: "The Amazon has no bridges crossing it — it flows entirely through dense rainforest."
    ),
    GeographyFeature(
        id: "yangtze",
        name: "Yangtze",
        type: .river,
        countryCode: "CN",
        countryCodes: ["CN"],
        measurement: 6_300,
        measurementLabel: "Length",
        measurementUnit: "km",
        continent: "Asia",
        description: "Asia's longest river and China's great waterway, draining into the East China Sea.",
        funFact: "The Three Gorges Dam on the Yangtze is the world's largest power station by capacity."
    ),
    GeographyFeature(
        id: "mississippi",
        name: "Mississippi",
        type: .river,
        countryCode: "US",
        countryCodes: ["US"],
        measurement: 6_275,
        measurementLabel: "Length",
        measurementUnit: "km",
        continent: "North America",
        description: "The chief river of the United States, flowing from Minnesota to the Gulf of Mexico.",
        funFact: "The Mississippi-Missouri river system is the world's fourth longest river system."
    ),
    GeographyFeature(
        id: "yenisei",
        name: "Yenisei",
        type: .river,
        countryCode: "RU",
        countryCodes: ["RU", "MN"],
        measurement: 5_539,
        measurementLabel: "Length",
        measurementUnit: "km",
        continent: "Asia",
        description: "The largest river system flowing into the Arctic Ocean, running through Siberia.",
        funFact: "The Yenisei drains a watershed almost twice the size of Western Europe."
    ),
    GeographyFeature(
        id: "yellow-river",
        name: "Yellow River",
        type: .river,
        countryCode: "CN",
        countryCodes: ["CN"],
        measurement: 5_464,
        measurementLabel: "Length",
        measurementUnit: "km",
        continent: "Asia",
        description: "The second longest river in China, cradle of Chinese civilization, named for its muddy water.",
        funFact: "The Yellow River has flooded over 1,500 times in the last 3,000 years."
    ),
    GeographyFeature(
        id: "ob",
        name: "Ob",
        type: .river,
        countryCode: "RU",
        countryCodes: ["RU", "KZ"],
        measurement: 5_410,
        measurementLabel: "Length",
        measurementUnit: "km",
        continent: "Asia",
        description: "One of the three great Siberian rivers, flowing north to the Gulf of Ob.",
        funFact: "The Ob-Irtysh system is the world's seventh longest river system."
    ),
    GeographyFeature(
        id: "congo",
        name: "Congo",
        type: .river,
        countryCode: "CD",
        countryCodes: ["CD", "CG"],
        measurement: 4_700,
        measurementLabel: "Length",
        measurementUnit: "km",
        continent: "Africa",
        description: "The world's deepest river and second largest by discharge, flowing through Central Africa.",
        funFact: "The Congo is the world's deepest river, reaching depths of 220 metres."
    ),
    GeographyFeature(
        id: "amur",
        name: "Amur",
        type: .river,
        countryCode: "RU",
        countryCodes: ["RU", "CN"],
        measurement: 4_444,
        measurementLabel: "Length",
        measurementUnit: "km",
        continent: "Asia",
        description: "The tenth longest river, forming part of the Russia-China border before reaching the Pacific.",
        funFact: "The Amur is home to one of the world's largest sturgeon populations."
    ),
    GeographyFeature(
        id: "lena",
        name: "Lena",
        type: .river,
        countryCode: "RU",
        countryCodes: ["RU"],
        measurement: 4_400,
        measurementLabel: "Length",
        measurementUnit: "km",
        continent: "Asia",
        description: "One of the longest rivers in the world, flowing through eastern Siberia to the Arctic Ocean.",
        funFact: "The Lena delta is one of the largest river deltas in the world, covering 32,000 km²."
    ),
]

// MARK: - Deserts

private let deserts: [GeographyFeature] = [
    GeographyFeature(
        id: "sahara",
        name: "Sahara",
        type: .desert,
        countryCode: "DZ",
        countryCodes: ["DZ", "EG", "LY", "MR", "ML", "NE", "SD", "TN", "MA", "EH"],
        measurement: 9_200_000,
        measurementLabel: "Area",
        measurementUnit: "km²",
        continent: "Africa",
        description: "The world's largest hot desert, covering most of northern Africa.",
        funFact: "The Sahara was green savannah 6,000 years ago before climate shifts turned it to desert."
    ),
    GeographyFeature(
        id: "arabian",
        name: "Arabian Desert",
        type: .desert,
        countryCode: "SA",
        countryCodes: ["SA", "AE", "OM", "YE", "JO", "IQ", "KW"],
        measurement: 2_330_000,
        measurementLabel: "Area",
        measurementUnit: "km²",
        continent: "Asia",
        description: "The largest desert in Asia, covering most of the Arabian Peninsula.",
        funFact: "The Empty Quarter (Rub' al Khali) within the Arabian Desert is the world's largest sand sea."
    ),
    GeographyFeature(
        id: "gobi",
        name: "Gobi Desert",
        type: .desert,
        countryCode: "CN",
        countryCodes: ["CN", "MN"],
        measurement: 1_295_000,
        measurementLabel: "Area",
        measurementUnit: "km²",
        continent: "Asia",
        description: "A large cold desert spanning northern China and southern Mongolia.",
        funFact: "The Gobi is the fastest growing desert on Earth, expanding by thousands of square km each year."
    ),
    GeographyFeature(
        id: "patagonian",
        name: "Patagonian Desert",
        type: .desert,
        countryCode: "AR",
        countryCodes: ["AR", "CL"],
        measurement: 673_000,
        measurementLabel: "Area",
        measurementUnit: "km²",
        continent: "South America",
        description: "The largest desert in South America, a cold desert in Argentina and Chile.",
        funFact: "Despite being a desert, Patagonia receives regular snowfall during winter months."
    ),
    GeographyFeature(
        id: "great-victoria",
        name: "Great Victoria Desert",
        type: .desert,
        countryCode: "AU",
        countryCodes: ["AU"],
        measurement: 647_000,
        measurementLabel: "Area",
        measurementUnit: "km²",
        continent: "Oceania",
        description: "The largest desert in Australia, spanning Western Australia and South Australia.",
        funFact: "The Great Victoria Desert has over 100 dry lake beds called playas."
    ),
    GeographyFeature(
        id: "kalahari",
        name: "Kalahari Desert",
        type: .desert,
        countryCode: "BW",
        countryCodes: ["BW", "NA", "ZA"],
        measurement: 360_000,
        measurementLabel: "Area",
        measurementUnit: "km²",
        continent: "Africa",
        description: "A semi-arid sandy savannah in southern Africa, home to the San people.",
        funFact: "The Kalahari is sometimes called a fossil desert because it was once much drier."
    ),
]

// MARK: - Lakes

private let lakes: [GeographyFeature] = [
    GeographyFeature(
        id: "caspian-sea",
        name: "Caspian Sea",
        type: .lake,
        countryCode: "AZ",
        countryCodes: ["AZ", "IR", "KZ", "RU", "TM"],
        measurement: 371_000,
        measurementLabel: "Area",
        measurementUnit: "km²",
        continent: "Asia/Europe",
        description: "The world's largest lake by area, a landlocked sea bordered by five countries.",
        funFact: "The Caspian Sea contains about 40% of all lake water on Earth."
    ),
    GeographyFeature(
        id: "lake-superior",
        name: "Lake Superior",
        type: .lake,
        countryCode: "US",
        countryCodes: ["US", "CA"],
        measurement: 82_100,
        measurementLabel: "Area",
        measurementUnit: "km²",
        continent: "North America",
        description: "The world's largest freshwater lake by surface area, one of the Great Lakes.",
        funFact: "Lake Superior contains 10% of the world's surface fresh water."
    ),
    GeographyFeature(
        id: "lake-victoria",
        name: "Lake Victoria",
        type: .lake,
        countryCode: "KE",
        countryCodes: ["KE", "UG", "TZ"],
        measurement: 69_485,
        measurementLabel: "Area",
        measurementUnit: "km²",
        continent: "Africa",
        description: "Africa's largest lake and the second largest freshwater lake in the world.",
        funFact: "Lake Victoria is the source of the White Nile, the main tributary of the Nile River."
    ),
    GeographyFeature(
        id: "lake-huron",
        name: "Lake Huron",
        type: .lake,
        countryCode: "US",
        countryCodes: ["US", "CA"],
        measurement: 59_600,
        measurementLabel: "Area",
        measurementUnit: "km²",
        continent: "North America",
        description: "The second largest of the Great Lakes, containing many islands including Manitoulin.",
        funFact: "Manitoulin Island in Lake Huron is the world's largest freshwater island."
    ),
    GeographyFeature(
        id: "lake-michigan",
        name: "Lake Michigan",
        type: .lake,
        countryCode: "US",
        countryCodes: ["US"],
        measurement: 58_000,
        measurementLabel: "Area",
        measurementUnit: "km²",
        continent: "North America",
        description: "The only Great Lake located entirely within the United States.",
        funFact: "Lake Michigan and Huron are hydrologically one lake connected at the Straits of Mackinac."
    ),
    GeographyFeature(
        id: "lake-tanganyika",
        name: "Lake Tanganyika",
        type: .lake,
        countryCode: "TZ",
        countryCodes: ["TZ", "CD", "BI", "ZM"],
        measurement: 32_600,
        measurementLabel: "Area",
        measurementUnit: "km²",
        continent: "Africa",
        description: "The world's longest freshwater lake and second deepest, in the East African Rift.",
        funFact: "Lake Tanganyika is about 20 million years old, one of the oldest lakes on Earth."
    ),
    GeographyFeature(
        id: "lake-baikal",
        name: "Lake Baikal",
        type: .lake,
        countryCode: "RU",
        countryCodes: ["RU"],
        measurement: 31_722,
        measurementLabel: "Area",
        measurementUnit: "km²",
        continent: "Asia",
        description: "The world's deepest lake, containing about 20% of the world's unfrozen fresh water.",
        funFact: "Lake Baikal is so clear you can see objects up to 40 metres below the surface."
    ),
]
