// swiftlint:disable file_length
import SwiftUI

public struct Organization: Identifiable, Hashable, Sendable {
    public let id: String
    public let displayName: String
    public let fullName: String
    public let icon: String
    public let highlightColor: Color
    public let description: String
    public let logoURL: String?

    public init(
        id: String,
        displayName: String,
        fullName: String,
        icon: String,
        highlightColor: Color,
        description: String,
        logoURL: String?
    ) {
        self.id = id
        self.displayName = displayName
        self.fullName = fullName
        self.icon = icon
        self.highlightColor = highlightColor
        self.description = description
        self.logoURL = logoURL
    }

    public static func == (lhs: Organization, rhs: Organization) -> Bool {
        lhs.id == rhs.id
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

// MARK: - All Organizations
public extension Organization {
    static let all: [Organization] = [
        makeUN, makeNATO, makeEU, makeASEAN, makeAU,
        makeArabLeague, makeBRICS, makeCARICOM, makeCELAC,
        makeCIS, makeCommonwealth, makeEAC, makeECOWAS,
        makeG7, makeG20, makeGCC, makeMercosur,
        makeNordicCouncil, makeOAS, makeOECD, makeOIF,
        makeOPEC, makePIF, makeSAARC, makeSADC, makeSCO,
        makeUSMCA, makeV4, makeWTO
    ]

    static func find(_ id: String) -> Organization? {
        all.first { $0.id == id }
    }
}

// MARK: - Factory Methods
private extension Organization {
    static let makeUN = Organization(
        id: "UN",
        displayName: "UN",
        fullName: "United Nations",
        icon: "globe.americas.fill",
        highlightColor: Color(hex: "3498DB"),
        description: "Founded in 1945, the United Nations is an "
            + "international organization of 193 member states "
            + "committed to maintaining international peace and "
            + "security, developing friendly relations among "
            + "nations, and promoting social progress, better "
            + "living standards, and human rights.",
        logoURL: "https://upload.wikimedia.org/wikipedia/commons/"
            + "thumb/e/ee/UN_emblem_blue.svg/"
            + "200px-UN_emblem_blue.svg.png"
    )

    static let makeNATO = Organization(
        id: "NATO",
        displayName: "NATO",
        fullName: "North Atlantic Treaty Organization",
        icon: "shield.fill",
        highlightColor: Color(hex: "5C6BC0"),
        description: "Founded in 1949, NATO is a political and "
            + "military alliance based on collective defense. "
            + "The cornerstone principle — enshrined in "
            + "Article 5 — holds that an attack against one "
            + "member is considered an attack against all "
            + "members.",
        logoURL: "https://upload.wikimedia.org/wikipedia/commons/"
            + "thumb/3/37/Flag_of_NATO.svg/"
            + "200px-Flag_of_NATO.svg.png"
    )

    static let makeEU = Organization(
        id: "EU",
        displayName: "EU",
        fullName: "European Union",
        icon: "flag.fill",
        highlightColor: Color(hex: "2ECC71"),
        description: "Established by the Maastricht Treaty in "
            + "1993, the European Union is a political and "
            + "economic union of 27 European states. It "
            + "operates a single market, enables free movement "
            + "of people, goods, services, and capital, and "
            + "uses the euro as a common currency across most "
            + "member states.",
        logoURL: "https://upload.wikimedia.org/wikipedia/commons/"
            + "thumb/b/b7/Flag_of_Europe.svg/"
            + "200px-Flag_of_Europe.svg.png"
    )

    static let makeASEAN = Organization(
        id: "ASEAN",
        displayName: "ASEAN",
        fullName: "Association of Southeast Asian Nations",
        icon: "globe.asia.australia.fill",
        highlightColor: Color(hex: "F39C12"),
        description: "Founded in 1967, ASEAN promotes political "
            + "and economic cooperation, regional stability, "
            + "and social development across Southeast Asia. "
            + "It represents over 650 million people and one "
            + "of the world's fastest-growing economic regions.",
        logoURL: "https://upload.wikimedia.org/wikipedia/commons/"
            + "thumb/3/3f/ASEAN_Logo.svg/"
            + "200px-ASEAN_Logo.svg.png"
    )

    static let makeAU = Organization(
        id: "AU",
        displayName: "African Union",
        fullName: "African Union",
        icon: "globe.europe.africa.fill",
        highlightColor: Color(hex: "E67E22"),
        description: "Founded in 2002 as the successor to the "
            + "Organisation of African Unity, the African "
            + "Union is a continental body of 55 member "
            + "states. Its objectives include promoting unity, "
            + "development, and integration across Africa, and "
            + "representing the continent in global affairs.",
        logoURL: "https://upload.wikimedia.org/wikipedia/commons/"
            + "thumb/5/51/African_Union_Logo.svg/"
            + "200px-African_Union_Logo.svg.png"
    )

    static let makeArabLeague = Organization(
        id: "Arab League",
        displayName: "Arab League",
        fullName: "League of Arab States",
        icon: "moon.fill",
        highlightColor: Color(hex: "16A085"),
        description: "Founded in 1945, the League of Arab States "
            + "is a regional organization of 22 Arab-majority "
            + "countries in the Middle East and North Africa. "
            + "It coordinates political, economic, cultural, "
            + "and security policies among member states.",
        logoURL: "https://upload.wikimedia.org/wikipedia/commons/"
            + "thumb/5/54/Arab_League_seal.svg/"
            + "200px-Arab_League_seal.svg.png"
    )

    static let makeBRICS = Organization(
        id: "BRICS",
        displayName: "BRICS",
        fullName: "BRICS Nations",
        icon: "chart.line.uptrend.xyaxis",
        highlightColor: Color(hex: "E74C3C"),
        description: "BRICS is an intergovernmental organization "
            + "of major emerging economies. Originally "
            + "comprising Brazil, Russia, India, China, and "
            + "South Africa, the group expanded in 2024 to "
            + "include additional members. It seeks to reform "
            + "global institutions and foster cooperation "
            + "among developing nations.",
        logoURL: "https://upload.wikimedia.org/wikipedia/commons/"
            + "thumb/9/9c/BRICS_logo.svg/"
            + "200px-BRICS_logo.svg.png"
    )

    static let makeCIS = Organization(
        id: "CIS",
        displayName: "CIS",
        fullName: "Commonwealth of Independent States",
        icon: "snowflake",
        highlightColor: Color(hex: "9B59B6"),
        description: "Formed in 1991 following the dissolution "
            + "of the Soviet Union, the Commonwealth of "
            + "Independent States facilitates cooperation "
            + "among former Soviet republics on political, "
            + "economic, humanitarian, and security matters.",
        logoURL: "https://upload.wikimedia.org/wikipedia/commons/"
            + "thumb/4/48/CIS_Emblem.svg/"
            + "200px-CIS_Emblem.svg.png"
    )

    static let makeCommonwealth = Organization(
        id: "Commonwealth",
        displayName: "Commonwealth",
        fullName: "Commonwealth of Nations",
        icon: "crown.fill",
        highlightColor: Color(hex: "1ABC9C"),
        description: "The Commonwealth of Nations is a voluntary "
            + "association of 56 countries, most of which are "
            + "former territories of the British Empire. It "
            + "promotes democracy, rule of law, human rights, "
            + "and economic development among its members "
            + "across every continent.",
        logoURL: "https://upload.wikimedia.org/wikipedia/commons/"
            + "thumb/e/e4/Commonwealth_of_Nations_logo.svg/"
            + "200px-Commonwealth_of_Nations_logo.svg.png"
    )

    static let makeG7 = Organization(
        id: "G7",
        displayName: "G7",
        fullName: "Group of Seven",
        icon: "building.columns.fill",
        highlightColor: Color(hex: "F1C40F"),
        description: "The Group of Seven is an informal forum of "
            + "the world's seven largest advanced economies: "
            + "Canada, France, Germany, Italy, Japan, the "
            + "United Kingdom, and the United States. Leaders "
            + "meet annually to coordinate on major global "
            + "economic and political challenges.",
        logoURL: "https://upload.wikimedia.org/wikipedia/commons/"
            + "thumb/0/0b/G7.svg/200px-G7.svg.png"
    )

    static let makeG20 = Organization(
        id: "G20",
        displayName: "G20",
        fullName: "Group of Twenty",
        icon: "person.3.sequence.fill",
        highlightColor: Color(hex: "8E44AD"),
        description: "The Group of Twenty is an intergovernmental "
            + "forum comprising 19 countries plus the European "
            + "Union and African Union. Representing "
            + "approximately 85% of global GDP, it addresses "
            + "major issues related to the global economy, "
            + "financial stability, and sustainable "
            + "development.",
        logoURL: "https://upload.wikimedia.org/wikipedia/commons/"
            + "thumb/1/16/G20.svg/200px-G20.svg.png"
    )

    static let makeMercosur = Organization(
        id: "Mercosur",
        displayName: "Mercosur",
        fullName: "Mercosur",
        icon: "arrow.triangle.2.circlepath",
        highlightColor: Color(hex: "E91E63"),
        description: "Mercosur is a South American trade bloc "
            + "that promotes free trade and the movement of "
            + "goods, people, and currency. Full members "
            + "include Argentina, Brazil, Paraguay, and "
            + "Uruguay, with several associate and observer "
            + "states. It is one of the largest trading blocs "
            + "in the world.",
        logoURL: "https://upload.wikimedia.org/wikipedia/commons/"
            + "thumb/e/e6/Mercosur_Logo.svg/"
            + "200px-Mercosur_Logo.svg.png"
    )

    static let makeOECD = Organization(
        id: "OECD",
        displayName: "OECD",
        fullName: "Organisation for Economic Co-operation "
            + "and Development",
        icon: "chart.bar.fill",
        highlightColor: Color(hex: "00BCD4"),
        description: "The OECD is an intergovernmental "
            + "organization of 38 countries committed to "
            + "stimulating economic progress and world trade. "
            + "It provides a forum for governments to share "
            + "experiences and seek solutions to common "
            + "economic, social, and governance challenges.",
        logoURL: "https://upload.wikimedia.org/wikipedia/commons/"
            + "thumb/1/13/OECD_Logo.svg/"
            + "200px-OECD_Logo.svg.png"
    )

    static let makeOPEC = Organization(
        id: "OPEC",
        displayName: "OPEC",
        fullName: "Organization of the Petroleum Exporting "
            + "Countries",
        icon: "flame.fill",
        highlightColor: Color(hex: "FF5722"),
        description: "Founded in 1960, OPEC is a cartel of "
            + "oil-exporting nations that coordinates "
            + "petroleum policies to stabilize oil markets "
            + "and secure a fair and stable return for "
            + "producers. Its decisions significantly "
            + "influence global oil prices and energy markets.",
        logoURL: "https://upload.wikimedia.org/wikipedia/commons/"
            + "thumb/6/68/OPEC_logo.svg/"
            + "200px-OPEC_logo.svg.png"
    )

    static let makeSCO = Organization(
        id: "SCO",
        displayName: "SCO",
        fullName: "Shanghai Cooperation Organisation",
        icon: "star.fill",
        highlightColor: Color(hex: "2980B9"),
        description: "Founded in 2001, the Shanghai Cooperation "
            + "Organisation is a Eurasian political, economic, "
            + "and security alliance. It focuses on "
            + "counterterrorism, military cooperation, and "
            + "economic development across Central and South "
            + "Asia, making it one of the world's largest "
            + "regional organizations.",
        logoURL: "https://upload.wikimedia.org/wikipedia/commons/"
            + "thumb/1/1e/SCO_logo.svg/"
            + "200px-SCO_logo.svg.png"
    )

    static let makeUSMCA = Organization(
        id: "USMCA",
        displayName: "USMCA",
        fullName: "United States-Mexico-Canada Agreement",
        icon: "flag.2.crossed.fill",
        highlightColor: Color(hex: "27AE60"),
        description: "The United States-Mexico-Canada Agreement, "
            + "which replaced NAFTA in 2020, is a free trade "
            + "agreement governing commerce among the three "
            + "North American countries. It covers goods, "
            + "services, digital trade, intellectual property, "
            + "and labor and environmental standards.",
        logoURL: "https://upload.wikimedia.org/wikipedia/commons/"
            + "thumb/a/a0/USMCA_logo.svg/"
            + "200px-USMCA_logo.svg.png"
    )

    static let makeWTO = Organization(
        id: "WTO",
        displayName: "WTO",
        fullName: "World Trade Organization",
        icon: "cart.fill",
        highlightColor: Color(hex: "7986CB"),
        description: "Founded in 1995, the World Trade "
            + "Organization is the primary international body "
            + "governing global trade rules. It provides a "
            + "framework for negotiating trade agreements, "
            + "resolving trade disputes, and ensuring that "
            + "international trade flows as smoothly and "
            + "freely as possible.",
        logoURL: "https://upload.wikimedia.org/wikipedia/commons/"
            + "thumb/2/2f/WTO_logo.svg/"
            + "200px-WTO_logo.svg.png"
    )

    static let makeCARICOM = Organization(
        id: "CARICOM",
        displayName: "CARICOM",
        fullName: "Caribbean Community",
        icon: "sun.max.fill",
        highlightColor: Color(hex: "00ACC1"),
        description: "Founded in 1973, the Caribbean Community is "
            + "a grouping of 15 member states and 5 associate "
            + "members in the Caribbean. It promotes economic "
            + "integration, foreign policy coordination, and "
            + "social development across the region.",
        logoURL: "https://upload.wikimedia.org/wikipedia/commons/"
            + "thumb/4/4e/CARICOM_Flag.svg/"
            + "200px-CARICOM_Flag.svg.png"
    )

    static let makeCELAC = Organization(
        id: "CELAC",
        displayName: "CELAC",
        fullName: "Community of Latin American "
            + "and Caribbean States",
        icon: "globe.americas.fill",
        highlightColor: Color(hex: "AB47BC"),
        description: "Founded in 2011, CELAC is a regional "
            + "intergovernmental mechanism of 33 Latin "
            + "American and Caribbean states. It promotes "
            + "regional integration and serves as a unified "
            + "voice for the region in global affairs, "
            + "excluding the United States and Canada.",
        logoURL: "https://upload.wikimedia.org/wikipedia/commons/"
            + "thumb/e/e8/CELAC_logo.svg/"
            + "200px-CELAC_logo.svg.png"
    )

    static let makeEAC = Organization(
        id: "EAC",
        displayName: "EAC",
        fullName: "East African Community",
        icon: "mountain.2.fill",
        highlightColor: Color(hex: "43A047"),
        description: "Revived in 2000, the East African Community "
            + "is a regional intergovernmental organization "
            + "of 8 member states in East and Central Africa. "
            + "It aims to establish a common market, customs "
            + "union, and ultimately a political federation "
            + "among its members.",
        logoURL: "https://upload.wikimedia.org/wikipedia/commons/"
            + "thumb/6/6f/EAC_Logo.svg/"
            + "200px-EAC_Logo.svg.png"
    )

    static let makeECOWAS = Organization(
        id: "ECOWAS",
        displayName: "ECOWAS",
        fullName: "Economic Community of West African States",
        icon: "circle.hexagongrid.fill",
        highlightColor: Color(hex: "FFA726"),
        description: "Founded in 1975, ECOWAS is a regional "
            + "organization of 15 West African countries. "
            + "It promotes economic integration, peace, and "
            + "stability across the region, and has played "
            + "a key role in conflict resolution and "
            + "democratic governance in West Africa.",
        logoURL: "https://upload.wikimedia.org/wikipedia/commons/"
            + "thumb/e/e9/ECOWAS_Logo.svg/"
            + "200px-ECOWAS_Logo.svg.png"
    )

    static let makeGCC = Organization(
        id: "GCC",
        displayName: "GCC",
        fullName: "Gulf Cooperation Council",
        icon: "drop.fill",
        highlightColor: Color(hex: "26A69A"),
        description: "Founded in 1981, the Gulf Cooperation "
            + "Council is a regional intergovernmental "
            + "political and economic union of 6 Arab states "
            + "bordering the Persian Gulf. It coordinates "
            + "economic, security, and cultural policies "
            + "among its oil-rich member states.",
        logoURL: "https://upload.wikimedia.org/wikipedia/commons/"
            + "thumb/c/cb/GCC_Flag.svg/"
            + "200px-GCC_Flag.svg.png"
    )

    static let makeNordicCouncil = Organization(
        id: "Nordic Council",
        displayName: "Nordic Council",
        fullName: "Nordic Council",
        icon: "snowflake.circle.fill",
        highlightColor: Color(hex: "42A5F5"),
        description: "Founded in 1952, the Nordic Council is an "
            + "official inter-parliamentary body for "
            + "cooperation among the Nordic countries: "
            + "Denmark, Finland, Iceland, Norway, and "
            + "Sweden. It promotes shared values, free "
            + "movement, and cultural cooperation.",
        logoURL: "https://upload.wikimedia.org/wikipedia/commons/"
            + "thumb/8/8e/Nordic_Council_Logo.svg/"
            + "200px-Nordic_Council_Logo.svg.png"
    )

    static let makeOAS = Organization(
        id: "OAS",
        displayName: "OAS",
        fullName: "Organization of American States",
        icon: "building.2.fill",
        highlightColor: Color(hex: "5C6BC0"),
        description: "Founded in 1948, the Organization of "
            + "American States is the oldest regional "
            + "organization in the world, comprising 35 "
            + "independent states of the Americas. It "
            + "promotes democracy, human rights, security, "
            + "and development across the Western Hemisphere.",
        logoURL: "https://upload.wikimedia.org/wikipedia/commons/"
            + "thumb/0/0f/OAS_Seal.svg/"
            + "200px-OAS_Seal.svg.png"
    )

    static let makeOIF = Organization(
        id: "OIF",
        displayName: "Francophonie",
        fullName: "Organisation Internationale de la Francophonie",
        icon: "text.book.closed.fill",
        highlightColor: Color(hex: "7E57C2"),
        description: "Founded in 1970, the Organisation "
            + "Internationale de la Francophonie brings "
            + "together countries that share or have a "
            + "connection with the French language. With "
            + "around 88 member states and governments, it "
            + "promotes the French language, cultural "
            + "diversity, education, and democratic values.",
        logoURL: "https://upload.wikimedia.org/wikipedia/commons/"
            + "thumb/9/9a/OIF_Logo.svg/"
            + "200px-OIF_Logo.svg.png"
    )

    static let makePIF = Organization(
        id: "PIF",
        displayName: "Pacific Islands Forum",
        fullName: "Pacific Islands Forum",
        icon: "water.waves",
        highlightColor: Color(hex: "0097A7"),
        description: "Founded in 1971, the Pacific Islands Forum "
            + "is an inter-governmental organization of 18 "
            + "member states in the Pacific region. It "
            + "addresses key issues including climate change, "
            + "sustainable development, and regional security "
            + "for Pacific Island nations.",
        logoURL: "https://upload.wikimedia.org/wikipedia/commons/"
            + "thumb/6/67/PIF_Logo.svg/"
            + "200px-PIF_Logo.svg.png"
    )

    static let makeSAARC = Organization(
        id: "SAARC",
        displayName: "SAARC",
        fullName: "South Asian Association for Regional Cooperation",
        icon: "leaf.fill",
        highlightColor: Color(hex: "66BB6A"),
        description: "Founded in 1985, SAARC is a regional "
            + "intergovernmental organization of 8 South "
            + "Asian member states. It aims to promote "
            + "economic growth, social progress, and "
            + "cultural development in the region, though "
            + "it has been largely inactive since 2014.",
        logoURL: "https://upload.wikimedia.org/wikipedia/commons/"
            + "thumb/a/ab/SAARC_Logo.svg/"
            + "200px-SAARC_Logo.svg.png"
    )

    static let makeSADC = Organization(
        id: "SADC",
        displayName: "SADC",
        fullName: "Southern African Development Community",
        icon: "globe.europe.africa.fill",
        highlightColor: Color(hex: "EF5350"),
        description: "Founded in 1992, the Southern African "
            + "Development Community is a regional economic "
            + "community of 16 member states in southern "
            + "Africa. It promotes economic integration, "
            + "peace, security, and sustainable development "
            + "across the region.",
        logoURL: "https://upload.wikimedia.org/wikipedia/commons/"
            + "thumb/e/e3/SADC_Logo.svg/"
            + "200px-SADC_Logo.svg.png"
    )

    static let makeV4 = Organization(
        id: "V4",
        displayName: "Visegrád Group",
        fullName: "Visegrád Group",
        icon: "square.grid.2x2.fill",
        highlightColor: Color(hex: "EC407A"),
        description: "Founded in 1991, the Visegrád Group is a "
            + "cultural and political alliance of four "
            + "Central European states: Czech Republic, "
            + "Hungary, Poland, and Slovakia. Named after "
            + "the 1335 meeting of kings in Visegrád, it "
            + "coordinates EU policy positions and promotes "
            + "regional cooperation.",
        logoURL: nil
    )
}
