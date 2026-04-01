import Geografy_Core_Common
import Foundation

@Observable
public final class LearningPathService {
    private(set) var modules: [LearningModule] = []

    private let storageKey = "learningPath.progress"

    public init() {
        modules = makeModules()
        loadProgress()
    }

    public func completeLesson(moduleID: String, lessonID: String) {
        guard let moduleIndex = modules.firstIndex(where: { $0.id == moduleID }),
              let lessonIndex = modules[moduleIndex].lessons.firstIndex(where: { $0.id == lessonID })
        else { return }

        modules[moduleIndex].lessons[lessonIndex].isCompleted = true
        unlockNextModuleIfNeeded(after: moduleIndex)
        saveProgress()
    }
}

// MARK: - Helpers
private extension LearningPathService {
    func unlockNextModuleIfNeeded(after index: Int) {
        let nextIndex = index + 1
        guard nextIndex < modules.count else { return }
        if modules[index].isCompleted {
            modules[nextIndex].isUnlocked = true
        }
    }

    func saveProgress() {
        let progressData = modules.map { module in
            (module.id, module.lessons.map { ($0.id, $0.isCompleted) })
        }
        let encoded = progressData.map { moduleID, lessons in
            [moduleID: Dictionary(uniqueKeysWithValues: lessons)]
        }
        if let data = try? JSONEncoder().encode(encoded) {
            UserDefaults.standard.set(data, forKey: storageKey)
        }
    }

    func loadProgress() {
        guard let data = UserDefaults.standard.data(forKey: storageKey),
              let encoded = try? JSONDecoder().decode([[String: [String: Bool]]].self, from: data)
        else { return }

        let progressMap = Dictionary(
            uniqueKeysWithValues: encoded.flatMap { $0 }
        )

        for moduleIndex in modules.indices {
            let moduleID = modules[moduleIndex].id
            guard let lessonProgress = progressMap[moduleID] else { continue }
            for lessonIndex in modules[moduleIndex].lessons.indices {
                let lessonID = modules[moduleIndex].lessons[lessonIndex].id
                if lessonProgress[lessonID] == true {
                    modules[moduleIndex].lessons[lessonIndex].isCompleted = true
                }
            }
            if moduleIndex > 0, modules[moduleIndex - 1].isCompleted {
                modules[moduleIndex].isUnlocked = true
            }
        }
    }

    func makeModules() -> [LearningModule] {
        [
            makeContinentsModule(),
            makeEuropeModule(),
            makeAsiaModule(),
            makeAfricaModule(),
            makeAmericasModule(),
            makeIslandsModule(),
            makeCapitalsModule(),
        ]
    }

    func makeContinentsModule() -> LearningModule {
        LearningModule(
            id: "continents",
            title: "World Continents",
            description: "Explore the seven continents, their geography, and key facts.",
            icon: "globe.europe.africa.fill",
            lessons: [
                makeLesson("continents-1", "What is a Continent?", .reading, continentsIntroContent),
                makeLesson("continents-2", "Africa — The Cradle", .reading, africaContent),
                makeLesson("continents-3", "Asia — The Giant", .reading, asiaContent),
                makeLesson("continents-4", "Europe — The Peninsula", .reading, europeContent),
                makeLesson("continents-5", "The Americas", .reading, americasContent),
                makeLesson("continents-6", "Oceania & Antarctica", .reading, oceaniaContent),
                makeLesson("continents-7", "Continent Quiz", .quiz, "Test your continent knowledge."),
            ],
            isUnlocked: true
        )
    }

    func makeEuropeModule() -> LearningModule {
        LearningModule(
            id: "europe",
            title: "European Countries",
            description: "Dive into the diversity of European nations.",
            icon: "globe.europe.africa",
            lessons: [
                makeLesson("europe-1", "Western Europe", .reading, westernEuropeContent),
                makeLesson("europe-2", "Eastern Europe", .reading, easternEuropeContent),
                makeLesson("europe-3", "Scandinavian Nations", .reading, scandinaviaContent),
                makeLesson("europe-4", "Capitals Quiz", .quiz, "Match European capitals."),
                makeLesson("europe-5", "Flags Matching", .matching, "Match the flag to the country."),
            ],
            isUnlocked: false
        )
    }

    func makeAsiaModule() -> LearningModule {
        LearningModule(
            id: "asia",
            title: "Asian Giants",
            description: "Discover the world's largest and most populous continent.",
            icon: "globe.asia.australia.fill",
            lessons: [
                makeLesson("asia-1", "China & India", .reading, chinaIndiaContent),
                makeLesson("asia-2", "Southeast Asia", .reading, southeastAsiaContent),
                makeLesson("asia-3", "Central Asia", .reading, centralAsiaContent),
                makeLesson("asia-4", "Middle East", .reading, middleEastContent),
                makeLesson("asia-5", "Asia Quiz", .quiz, "Test your Asia knowledge."),
            ],
            isUnlocked: false
        )
    }

    func makeAfricaModule() -> LearningModule {
        LearningModule(
            id: "africa",
            title: "African Nations",
            description: "Explore Africa's rich diversity of nations and cultures.",
            icon: "sun.max.fill",
            lessons: [
                makeLesson("africa-1", "North Africa", .reading, northAfricaContent),
                makeLesson("africa-2", "Sub-Saharan Africa", .reading, subSaharanContent),
                makeLesson("africa-3", "East African Nations", .reading, eastAfricaContent),
                makeLesson("africa-4", "Southern Africa", .reading, southernAfricaContent),
                makeLesson("africa-5", "Africa Quiz", .quiz, "Test your Africa knowledge."),
            ],
            isUnlocked: false
        )
    }

    func makeAmericasModule() -> LearningModule {
        LearningModule(
            id: "americas",
            title: "The Americas",
            description: "Journey through North and South America.",
            icon: "globe.americas.fill",
            lessons: [
                makeLesson("americas-1", "North America", .reading, northAmericaContent),
                makeLesson("americas-2", "Central America & Caribbean", .reading, centralAmericaContent),
                makeLesson("americas-3", "South America", .reading, southAmericaContent),
                makeLesson("americas-4", "Americas Quiz", .quiz, "Test your Americas knowledge."),
            ],
            isUnlocked: false
        )
    }

    func makeIslandsModule() -> LearningModule {
        LearningModule(
            id: "islands",
            title: "Island Nations",
            description: "Discover the unique island nations of the Pacific and Caribbean.",
            icon: "water.waves",
            lessons: [
                makeLesson("islands-1", "Pacific Island Nations", .reading, pacificIslandsContent),
                makeLesson("islands-2", "Caribbean Islands", .reading, caribbeanContent),
                makeLesson("islands-3", "Atlantic & Indian Ocean", .reading, atlanticIslandsContent),
                makeLesson("islands-4", "Island Nations Quiz", .quiz, "Test your island knowledge."),
            ],
            isUnlocked: false
        )
    }

    func makeCapitalsModule() -> LearningModule {
        LearningModule(
            id: "capitals",
            title: "World Capitals Mastery",
            description: "Master the capitals of every country in the world.",
            icon: "building.columns.fill",
            lessons: [
                makeLesson("capitals-1", "Europe Capitals", .quiz, "Match European countries to their capitals."),
                makeLesson("capitals-2", "Asia Capitals", .quiz, "Match Asian countries to their capitals."),
                makeLesson("capitals-3", "Africa Capitals", .quiz, "Match African countries to their capitals."),
                makeLesson("capitals-4", "Americas Capitals", .quiz, "Match Americas countries to their capitals."),
                makeLesson("capitals-5", "Grand Final", .quiz, "Master quiz covering all capitals."),
            ],
            isUnlocked: false
        )
    }

    func makeLesson(
        _ id: String,
        _ title: String,
        _ type: Lesson.LessonType,
        _ content: String
    ) -> Lesson {
        Lesson(id: id, title: title, type: type, content: content, isCompleted: false)
    }
}

// MARK: - Lesson Content
private extension LearningPathService {
    var continentsIntroContent: String {
        "A continent is one of Earth's large landmasses. Geographers recognize seven continents: "
        + "Africa, Antarctica, Asia, Australia (Oceania), Europe, North America, and South America.\n\n"
        + "Continents vary enormously in size — Asia is the largest, covering about 44.6 million km², "
        + "while Australia is the smallest at about 7.7 million km².\n\n"
        + "Each continent has unique geography, climate zones, ecosystems, and cultural history. "
        + "Together, the continents make up about 29% of Earth's surface."
    }

    var africaContent: String {
        "Africa is the world's second-largest continent and second-most populous. "
        + "It covers about 30.3 million km² and is home to over 1.4 billion people across 54 countries.\n\n"
        + "Africa is often called the 'Cradle of Humanity' — the oldest human fossils have been found here. "
        + "The Sahara Desert in the north is the world's largest hot desert, while the Congo Basin "
        + "contains the world's second-largest tropical rainforest.\n\n"
        + "Key facts: The Nile River, at 6,650 km, is the world's longest river. "
        + "Mount Kilimanjaro in Tanzania is Africa's highest peak at 5,895 m."
    }

    var asiaContent: String {
        "Asia is Earth's largest continent, covering about 44.6 million km² — roughly 30% of Earth's "
        + "total land area. With over 4.7 billion people, it is also the most populous continent.\n\n"
        + "Asia contains the world's highest mountain (Everest, 8,849 m), the world's deepest lake "
        + "(Baikal, 1,642 m deep), and the world's lowest point on land (Dead Sea, 430 m below sea level).\n\n"
        + "The continent stretches from Turkey in the west to Japan in the east, "
        + "and from Russia in the north to Indonesia in the south."
    }

    var europeContent: String {
        "Europe is the world's second-smallest continent by area, covering about 10.5 million km². "
        + "It has historically had enormous global influence through exploration, colonization, "
        + "and the development of modern science and democracy.\n\n"
        + "Europe is often described as a 'peninsula of peninsulas' — the Iberian, Italian, and "
        + "Scandinavian peninsulas jut out from the main landmass. The continent has 44 countries "
        + "and is home to the European Union, one of the world's largest economic blocs.\n\n"
        + "The Alps, Pyrenees, and Carpathian Mountains are major mountain ranges. "
        + "The Rhine, Danube, and Volga are key rivers."
    }

    var americasContent: String {
        "The Americas consist of two major continents: North America and South America, "
        + "connected by the narrow isthmus of Central America.\n\n"
        + "North America covers about 24.7 million km² and includes Canada, the United States, "
        + "Mexico, Central American countries, and Caribbean nations.\n\n"
        + "South America covers about 17.8 million km² and is dominated by the Amazon Basin — "
        + "the world's largest tropical rainforest. The Andes Mountains run along the entire western coast."
    }

    var oceaniaContent: String {
        "Oceania is a region centered on the islands of the tropical Pacific Ocean. "
        + "It includes Australia, New Zealand, Papua New Guinea, and thousands of smaller islands.\n\n"
        + "Australia is both a continent and a country — the world's sixth-largest country by area. "
        + "The continent is known for its unique wildlife including kangaroos, koalas, and platypuses.\n\n"
        + "Antarctica is Earth's southernmost continent, containing the South Pole. "
        + "It is the coldest, driest, and windiest continent, governed by the Antarctic Treaty System."
    }

    var westernEuropeContent: String {
        "Western Europe includes countries such as France, Germany, Spain, Portugal, Italy, "
        + "and the Benelux nations. This region has been at the heart of Western civilization for millennia.\n\n"
        + "France is the largest country in Western Europe, known for its art, culture, cuisine, "
        + "and global influence. Germany is Europe's largest economy. "
        + "Spain and Portugal were once powerful maritime empires.\n\n"
        + "Many Western European countries use the Euro and are members of the European Union."
    }

    var easternEuropeContent: String {
        "Eastern Europe includes Poland, Ukraine, Romania, Czech Republic, Hungary, and the Baltic states. "
        + "The region has a rich history shaped by empires, world wars, and the Cold War.\n\n"
        + "Poland is the largest country in Eastern Europe. Ukraine is Europe's second-largest country "
        + "by area. The Baltic states — Estonia, Latvia, and Lithuania — gained independence in 1991.\n\n"
        + "The Carpathian Mountains stretch across several Eastern European countries, "
        + "and the Danube River flows through many of them."
    }

    var scandinaviaContent: String {
        "Scandinavia traditionally refers to Norway, Sweden, and Denmark. "
        + "The broader Nordic region also includes Finland and Iceland.\n\n"
        + "The Scandinavian Peninsula is one of Europe's largest, characterized by fjords, mountains, "
        + "and forests. Norway's fjords are among the world's most dramatic landscapes. "
        + "Sweden is the largest Nordic country by area.\n\n"
        + "Nordic countries consistently rank among the world's happiest and most equal societies."
    }

    var chinaIndiaContent: String {
        "China and India are the world's two most populous countries, together home to over "
        + "2.8 billion people — about 35% of humanity.\n\n"
        + "China covers about 9.6 million km² and has the world's second-largest economy. "
        + "The Great Wall, built over centuries, stretches thousands of kilometers.\n\n"
        + "India covers about 3.3 million km² and is the world's largest democracy. "
        + "The Ganges and Indus rivers are sacred in Hinduism. "
        + "India's constitution recognizes 22 official languages."
    }

    var southeastAsiaContent: String {
        "Southeast Asia comprises eleven countries: Brunei, Cambodia, Indonesia, Laos, Malaysia, "
        + "Myanmar, Philippines, Singapore, Thailand, Timor-Leste, and Vietnam.\n\n"
        + "Indonesia is the world's largest archipelago nation, with over 17,000 islands. "
        + "The Philippines has over 7,100 islands.\n\n"
        + "The Mekong River flows through China, Myanmar, Laos, Thailand, Cambodia, and Vietnam, "
        + "making it one of Southeast Asia's most important waterways."
    }

    var centralAsiaContent: String {
        "Central Asia consists of Kazakhstan, Kyrgyzstan, Tajikistan, Turkmenistan, and Uzbekistan "
        + "— all former Soviet republics that gained independence in 1991.\n\n"
        + "Kazakhstan is the world's ninth-largest country by area, yet has a relatively small population "
        + "of about 19 million. The Aral Sea has largely disappeared due to Soviet-era irrigation projects.\n\n"
        + "The Silk Road, an ancient network of trade routes, passed through Central Asia, "
        + "connecting China with the Mediterranean world."
    }

    var middleEastContent: String {
        "The Middle East is a transcontinental region spanning Western Asia and parts of North Africa. "
        + "It includes Saudi Arabia, Iran, Turkey, Iraq, Israel, Jordan, Lebanon, and the Gulf states.\n\n"
        + "The region is the birthplace of three major world religions: Judaism, Christianity, and Islam. "
        + "It contains the world's largest proven oil reserves.\n\n"
        + "The Arabian Peninsula is dominated by Saudi Arabia and the Arabian Desert. "
        + "Turkey straddles Europe and Asia — Istanbul is the only city in the world on two continents."
    }

    var northAfricaContent: String {
        "North Africa consists of Morocco, Algeria, Tunisia, Libya, Egypt, and Sudan — "
        + "countries along the Mediterranean coast and Sahara Desert.\n\n"
        + "Egypt is one of the world's oldest civilizations, with a history spanning over 5,000 years. "
        + "The ancient Egyptians built the pyramids at Giza, the last of the Seven Wonders still standing.\n\n"
        + "Algeria is Africa's largest country by area. Morocco is known for its medinas and Atlas Mountains. "
        + "Tunisia has the highest literacy rate in Africa."
    }

    var subSaharanContent: String {
        "Sub-Saharan Africa refers to the area south of the Sahara Desert — a vast region encompassing "
        + "diverse ecosystems from tropical rainforests to savannas to deserts.\n\n"
        + "Nigeria is Sub-Saharan Africa's most populous country and largest economy. "
        + "The Congo Basin contains the world's second-largest tropical rainforest. "
        + "The Great Rift Valley creates dramatic landscapes and lakes.\n\n"
        + "Africa has the world's youngest population — the median age is under 20."
    }

    var eastAfricaContent: String {
        "East Africa includes Ethiopia, Kenya, Tanzania, Uganda, Rwanda, Burundi, and several "
        + "other nations. The region is famous for the Great Rift Valley, Lake Victoria, "
        + "and extraordinary wildlife.\n\n"
        + "Ethiopia is Africa's second most populous country and has one of the world's longest "
        + "written histories. Addis Ababa is home to the African Union headquarters.\n\n"
        + "The Serengeti in Tanzania hosts the world's largest animal migration — millions of "
        + "wildebeest, zebra, and gazelle follow the rains across the plains."
    }

    var southernAfricaContent: String {
        "Southern Africa includes South Africa, Mozambique, Zimbabwe, Zambia, Botswana, "
        + "Namibia, and several smaller nations.\n\n"
        + "South Africa has three capital cities: Pretoria (executive), Cape Town (legislative), "
        + "and Bloemfontein (judicial). It emerged from apartheid in 1994 under Nelson Mandela.\n\n"
        + "Botswana is one of Africa's most stable democracies. "
        + "Victoria Falls, on the Zambia-Zimbabwe border, is one of the world's largest waterfalls."
    }

    var northAmericaContent: String {
        "North America's three largest countries — Canada, the United States, and Mexico — "
        + "account for the vast majority of the continent's land and population.\n\n"
        + "Canada is the world's second-largest country by total area, but one of the least densely "
        + "populated. Its vast boreal forests, Arctic tundra, and Rocky Mountains define its landscape.\n\n"
        + "Mexico has one of the richest cultural heritages in the Americas, "
        + "blending indigenous Mesoamerican cultures with Spanish colonial influence."
    }

    var centralAmericaContent: String {
        "Central America is a narrow land bridge connecting North and South America, comprising "
        + "Guatemala, Belize, Honduras, El Salvador, Nicaragua, Costa Rica, and Panama.\n\n"
        + "The Panama Canal, completed in 1914, connects the Atlantic and Pacific Oceans. "
        + "Costa Rica generates nearly all its electricity from renewable sources.\n\n"
        + "The Caribbean includes Cuba (the largest island), Hispaniola, Jamaica, Puerto Rico, "
        + "and hundreds of smaller islands — renowned for biodiversity and coral reefs."
    }

    var southAmericaContent: String {
        "South America is the fourth-largest continent, home to 14 countries. "
        + "Brazil alone makes up nearly half the continent's land area and population.\n\n"
        + "The Amazon River drains the world's largest tropical rainforest. "
        + "The Andes Mountains, running along the western coast, are the world's longest mountain chain.\n\n"
        + "Brazil is South America's dominant power. Argentina is known for its European immigrant "
        + "heritage, tango, and beef."
    }

    var pacificIslandsContent: String {
        "The Pacific Ocean contains thousands of islands grouped into three cultural regions: "
        + "Melanesia, Micronesia, and Polynesia.\n\n"
        + "Papua New Guinea is remarkable for its extraordinary biodiversity — it contains about 5% "
        + "of the world's species on less than 1% of its land area.\n\n"
        + "Polynesia includes Tonga, Samoa, Tuvalu, and — most remotely — the Cook Islands and Niue."
    }

    var caribbeanContent: String {
        "The Caribbean comprises over 700 islands. The region is divided into the Greater Antilles "
        + "(Cuba, Jamaica, Hispaniola, Puerto Rico) and the Lesser Antilles.\n\n"
        + "Cuba is the Caribbean's largest and most populous island. "
        + "Jamaica is famous for reggae music, born here in the 1960s.\n\n"
        + "Haiti and the Dominican Republic share the island of Hispaniola. "
        + "Haiti was the first Black republic in the world, achieving independence in 1804."
    }

    var atlanticIslandsContent: String {
        "The Atlantic and Indian Oceans contain several fascinating island nations.\n\n"
        + "In the Atlantic, Cape Verde has a unique Creole culture blending African and Portuguese "
        + "influences. São Tomé and Príncipe was uninhabited when Portuguese explorers arrived.\n\n"
        + "The Maldives is the world's lowest-lying country, threatened by rising sea levels. "
        + "Madagascar split from the African continent about 88 million years ago, "
        + "allowing unique wildlife to evolve in isolation."
    }
}
