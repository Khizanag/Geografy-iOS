import SwiftUI

struct Organization: Identifiable, Hashable {
    let id: String
    let displayName: String
    let fullName: String
    let icon: String
    let highlightColor: Color
    let description: String
    let logoURL: String?

    static func == (lhs: Organization, rhs: Organization) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

// MARK: - All Organizations

extension Organization {
    // swiftlint:disable line_length
    static let all: [Organization] = [
        Organization(
            id: "UN",
            displayName: "UN",
            fullName: "United Nations",
            icon: "globe.americas.fill",
            highlightColor: Color(hex: "3498DB"),
            description: "Founded in 1945, the United Nations is an international organization of 193 member states committed to maintaining international peace and security, developing friendly relations among nations, and promoting social progress, better living standards, and human rights.",
            logoURL: "https://upload.wikimedia.org/wikipedia/commons/thumb/e/ee/UN_emblem_blue.svg/200px-UN_emblem_blue.svg.png"
        ),
        Organization(
            id: "NATO",
            displayName: "NATO",
            fullName: "North Atlantic Treaty Organization",
            icon: "shield.fill",
            highlightColor: Color(hex: "5C6BC0"),
            description: "Founded in 1949, NATO is a political and military alliance based on collective defense. The cornerstone principle — enshrined in Article 5 — holds that an attack against one member is considered an attack against all members.",
            logoURL: "https://upload.wikimedia.org/wikipedia/commons/thumb/3/37/Flag_of_NATO.svg/200px-Flag_of_NATO.svg.png"
        ),
        Organization(
            id: "EU",
            displayName: "EU",
            fullName: "European Union",
            icon: "flag.fill",
            highlightColor: Color(hex: "2ECC71"),
            description: "Established by the Maastricht Treaty in 1993, the European Union is a political and economic union of 27 European states. It operates a single market, enables free movement of people, goods, services, and capital, and uses the euro as a common currency across most member states.",
            logoURL: "https://upload.wikimedia.org/wikipedia/commons/thumb/b/b7/Flag_of_Europe.svg/200px-Flag_of_Europe.svg.png"
        ),
        Organization(
            id: "ASEAN",
            displayName: "ASEAN",
            fullName: "Association of Southeast Asian Nations",
            icon: "globe.asia.australia.fill",
            highlightColor: Color(hex: "F39C12"),
            description: "Founded in 1967, ASEAN promotes political and economic cooperation, regional stability, and social development across Southeast Asia. It represents over 650 million people and one of the world's fastest-growing economic regions.",
            logoURL: "https://upload.wikimedia.org/wikipedia/commons/thumb/3/3f/ASEAN_Logo.svg/200px-ASEAN_Logo.svg.png"
        ),
        Organization(
            id: "AU",
            displayName: "African Union",
            fullName: "African Union",
            icon: "globe.europe.africa.fill",
            highlightColor: Color(hex: "E67E22"),
            description: "Founded in 2002 as the successor to the Organisation of African Unity, the African Union is a continental body of 55 member states. Its objectives include promoting unity, development, and integration across Africa, and representing the continent in global affairs.",
            logoURL: "https://upload.wikimedia.org/wikipedia/commons/thumb/5/51/African_Union_Logo.svg/200px-African_Union_Logo.svg.png"
        ),
        Organization(
            id: "Arab League",
            displayName: "Arab League",
            fullName: "League of Arab States",
            icon: "moon.fill",
            highlightColor: Color(hex: "16A085"),
            description: "Founded in 1945, the League of Arab States is a regional organization of 22 Arab-majority countries in the Middle East and North Africa. It coordinates political, economic, cultural, and security policies among member states.",
            logoURL: "https://upload.wikimedia.org/wikipedia/commons/thumb/5/54/Arab_League_seal.svg/200px-Arab_League_seal.svg.png"
        ),
        Organization(
            id: "BRICS",
            displayName: "BRICS",
            fullName: "BRICS Nations",
            icon: "chart.line.uptrend.xyaxis",
            highlightColor: Color(hex: "E74C3C"),
            description: "BRICS is an intergovernmental organization of major emerging economies. Originally comprising Brazil, Russia, India, China, and South Africa, the group expanded in 2024 to include additional members. It seeks to reform global institutions and foster cooperation among developing nations.",
            logoURL: "https://upload.wikimedia.org/wikipedia/commons/thumb/9/9c/BRICS_logo.svg/200px-BRICS_logo.svg.png"
        ),
        Organization(
            id: "CIS",
            displayName: "CIS",
            fullName: "Commonwealth of Independent States",
            icon: "snowflake",
            highlightColor: Color(hex: "9B59B6"),
            description: "Formed in 1991 following the dissolution of the Soviet Union, the Commonwealth of Independent States facilitates cooperation among former Soviet republics on political, economic, humanitarian, and security matters.",
            logoURL: "https://upload.wikimedia.org/wikipedia/commons/thumb/4/48/CIS_Emblem.svg/200px-CIS_Emblem.svg.png"
        ),
        Organization(
            id: "Commonwealth",
            displayName: "Commonwealth",
            fullName: "Commonwealth of Nations",
            icon: "crown.fill",
            highlightColor: Color(hex: "1ABC9C"),
            description: "The Commonwealth of Nations is a voluntary association of 56 countries, most of which are former territories of the British Empire. It promotes democracy, rule of law, human rights, and economic development among its members across every continent.",
            logoURL: "https://upload.wikimedia.org/wikipedia/commons/thumb/e/e4/Commonwealth_of_Nations_logo.svg/200px-Commonwealth_of_Nations_logo.svg.png"
        ),
        Organization(
            id: "G7",
            displayName: "G7",
            fullName: "Group of Seven",
            icon: "building.columns.fill",
            highlightColor: Color(hex: "F1C40F"),
            description: "The Group of Seven is an informal forum of the world's seven largest advanced economies: Canada, France, Germany, Italy, Japan, the United Kingdom, and the United States. Leaders meet annually to coordinate on major global economic and political challenges.",
            logoURL: "https://upload.wikimedia.org/wikipedia/commons/thumb/0/0b/G7.svg/200px-G7.svg.png"
        ),
        Organization(
            id: "G20",
            displayName: "G20",
            fullName: "Group of Twenty",
            icon: "person.3.sequence.fill",
            highlightColor: Color(hex: "8E44AD"),
            description: "The Group of Twenty is an intergovernmental forum comprising 19 countries plus the European Union and African Union. Representing approximately 85% of global GDP, it addresses major issues related to the global economy, financial stability, and sustainable development.",
            logoURL: "https://upload.wikimedia.org/wikipedia/commons/thumb/1/16/G20.svg/200px-G20.svg.png"
        ),
        Organization(
            id: "Mercosur",
            displayName: "Mercosur",
            fullName: "Mercosur",
            icon: "arrow.triangle.2.circlepath",
            highlightColor: Color(hex: "E91E63"),
            description: "Mercosur is a South American trade bloc that promotes free trade and the movement of goods, people, and currency. Full members include Argentina, Brazil, Paraguay, and Uruguay, with several associate and observer states. It is one of the largest trading blocs in the world.",
            logoURL: "https://upload.wikimedia.org/wikipedia/commons/thumb/e/e6/Mercosur_Logo.svg/200px-Mercosur_Logo.svg.png"
        ),
        Organization(
            id: "OECD",
            displayName: "OECD",
            fullName: "Organisation for Economic Co-operation and Development",
            icon: "chart.bar.fill",
            highlightColor: Color(hex: "00BCD4"),
            description: "The OECD is an intergovernmental organization of 38 countries committed to stimulating economic progress and world trade. It provides a forum for governments to share experiences and seek solutions to common economic, social, and governance challenges.",
            logoURL: "https://upload.wikimedia.org/wikipedia/commons/thumb/1/13/OECD_Logo.svg/200px-OECD_Logo.svg.png"
        ),
        Organization(
            id: "OPEC",
            displayName: "OPEC",
            fullName: "Organization of the Petroleum Exporting Countries",
            icon: "flame.fill",
            highlightColor: Color(hex: "FF5722"),
            description: "Founded in 1960, OPEC is a cartel of oil-exporting nations that coordinates petroleum policies to stabilize oil markets and secure a fair and stable return for producers. Its decisions significantly influence global oil prices and energy markets.",
            logoURL: "https://upload.wikimedia.org/wikipedia/commons/thumb/6/68/OPEC_logo.svg/200px-OPEC_logo.svg.png"
        ),
        Organization(
            id: "SCO",
            displayName: "SCO",
            fullName: "Shanghai Cooperation Organisation",
            icon: "star.fill",
            highlightColor: Color(hex: "2980B9"),
            description: "Founded in 2001, the Shanghai Cooperation Organisation is a Eurasian political, economic, and security alliance. It focuses on counterterrorism, military cooperation, and economic development across Central and South Asia, making it one of the world's largest regional organizations.",
            logoURL: "https://upload.wikimedia.org/wikipedia/commons/thumb/1/1e/SCO_logo.svg/200px-SCO_logo.svg.png"
        ),
        Organization(
            id: "USMCA",
            displayName: "USMCA",
            fullName: "United States-Mexico-Canada Agreement",
            icon: "flag.2.crossed.fill",
            highlightColor: Color(hex: "27AE60"),
            description: "The United States-Mexico-Canada Agreement, which replaced NAFTA in 2020, is a free trade agreement governing commerce among the three North American countries. It covers goods, services, digital trade, intellectual property, and labor and environmental standards.",
            logoURL: "https://upload.wikimedia.org/wikipedia/commons/thumb/a/a0/USMCA_logo.svg/200px-USMCA_logo.svg.png"
        ),
        Organization(
            id: "WTO",
            displayName: "WTO",
            fullName: "World Trade Organization",
            icon: "cart.fill",
            highlightColor: Color(hex: "7986CB"),
            description: "Founded in 1995, the World Trade Organization is the primary international body governing global trade rules. It provides a framework for negotiating trade agreements, resolving trade disputes, and ensuring that international trade flows as smoothly and freely as possible.",
            logoURL: "https://upload.wikimedia.org/wikipedia/commons/thumb/2/2f/WTO_logo.svg/200px-WTO_logo.svg.png"
        ),
    ]
    // swiftlint:enable line_length

    static func find(_ id: String) -> Organization? {
        all.first { $0.id == id }
    }
}
