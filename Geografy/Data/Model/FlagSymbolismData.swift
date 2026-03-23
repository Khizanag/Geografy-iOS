import Foundation

struct FlagColorEntry {
    let name: String
    let hex: String
    let meaning: String
}

struct FlagEmblemEntry {
    let name: String
    let symbol: String
    let meaning: String
}

struct FlagSymbolism {
    let adoptedYear: Int?
    let colors: [FlagColorEntry]
    let emblems: [FlagEmblemEntry]
    let historicalNote: String?
}

// MARK: - Data

enum FlagSymbolismData {
    // swiftlint:disable:next function_body_length
    static let data: [String: FlagSymbolism] = [

        // MARK: Americas

        "US": FlagSymbolism(
            adoptedYear: 1960,
            colors: [
                FlagColorEntry(name: "Red", hex: "B22234", meaning: "Valor and hardiness"),
                FlagColorEntry(name: "White", hex: "FFFFFF", meaning: "Purity and innocence"),
                FlagColorEntry(name: "Blue", hex: "3C3B6E", meaning: "Vigilance, perseverance, and justice"),
            ],
            emblems: [
                FlagEmblemEntry(name: "50 Stars", symbol: "star.fill", meaning: "The 50 states of the union"),
                FlagEmblemEntry(name: "13 Stripes", symbol: "line.3.horizontal", meaning: "The 13 original colonies"),
            ],
            historicalNote: "The flag has changed 27 times since 1777. The current 50-star design was adopted on July 4, 1960, after Hawaii became the 50th state."
        ),
        "CA": FlagSymbolism(
            adoptedYear: 1965,
            colors: [
                FlagColorEntry(name: "Red", hex: "FF0000", meaning: "Sacrifice and valor"),
                FlagColorEntry(name: "White", hex: "FFFFFF", meaning: "Peace and honesty"),
            ],
            emblems: [
                FlagEmblemEntry(name: "Maple Leaf", symbol: "leaf.fill", meaning: "Canada's iconic national symbol, representing unity and identity"),
            ],
            historicalNote: "The maple leaf flag replaced the Canadian Red Ensign after a heated national debate in 1964. Prime Minister Lester Pearson championed a distinctive Canadian identity separate from British heritage."
        ),
        "MX": FlagSymbolism(
            adoptedYear: 1968,
            colors: [
                FlagColorEntry(name: "Green", hex: "006847", meaning: "Hope and independence"),
                FlagColorEntry(name: "White", hex: "FFFFFF", meaning: "Purity and religion"),
                FlagColorEntry(name: "Red", hex: "CE1126", meaning: "Blood of national heroes"),
            ],
            emblems: [
                FlagEmblemEntry(name: "Eagle on Cactus", symbol: "bird", meaning: "Based on the Aztec legend of the founding of Tenochtitlan — an eagle on a cactus devouring a serpent"),
            ],
            historicalNote: "Mexico's coat of arms depicts the Aztec legend: the god Huitzilopochtli told his people to build a city where they saw an eagle on a nopal cactus eating a snake — that place became Tenochtitlan (modern Mexico City)."
        ),
        "BR": FlagSymbolism(
            adoptedYear: 1889,
            colors: [
                FlagColorEntry(name: "Green", hex: "009C3B", meaning: "The vast forests and nature of Brazil"),
                FlagColorEntry(name: "Yellow", hex: "FFDF00", meaning: "The enormous gold reserves"),
                FlagColorEntry(name: "Blue", hex: "002776", meaning: "The night sky over Rio de Janeiro on November 15, 1889"),
            ],
            emblems: [
                FlagEmblemEntry(name: "Stars", symbol: "star.fill", meaning: "27 stars represent each of Brazil's 26 states and the Federal District"),
                FlagEmblemEntry(name: "Motto Band", symbol: "text.quote", meaning: "'Ordem e Progresso' (Order and Progress) — inspired by Auguste Comte's positivism"),
            ],
            historicalNote: "The stars on Brazil's flag are arranged to reflect the sky over Rio de Janeiro at 8:30 PM on November 15, 1889 — the precise moment the Republic was proclaimed."
        ),
        "AR": FlagSymbolism(
            adoptedYear: 1818,
            colors: [
                FlagColorEntry(name: "Light Blue", hex: "74ACDF", meaning: "The sky and the Río de la Plata river"),
                FlagColorEntry(name: "White", hex: "FFFFFF", meaning: "Purity and the Andes snowcaps"),
            ],
            emblems: [
                FlagEmblemEntry(name: "Sun of May", symbol: "sun.max.fill", meaning: "Represents the Inca sun god Inti, and commemorates the May Revolution of 1810"),
            ],
            historicalNote: "General Manuel Belgrano created the flag based on the blue-and-white cockade worn by independence fighters. The Sun of May was added in 1818, referencing the sun that appeared through clouds on the day of the first patriot government."
        ),
        "CO": FlagSymbolism(
            adoptedYear: 1861,
            colors: [
                FlagColorEntry(name: "Yellow", hex: "FCD116", meaning: "Sovereignty, justice, and the country's abundant gold"),
                FlagColorEntry(name: "Blue", hex: "003087", meaning: "The sky and the two oceans bordering Colombia"),
                FlagColorEntry(name: "Red", hex: "CE1126", meaning: "The blood shed for independence and the people's courage"),
            ],
            emblems: [],
            historicalNote: "Simón Bolívar reportedly chose yellow, blue, and red to represent 'golden' America separated by blue seas from 'bloody' Spain."
        ),
        "VE": FlagSymbolism(
            adoptedYear: 2006,
            colors: [
                FlagColorEntry(name: "Yellow", hex: "CF142B", meaning: "Venezuela's wealth and the sun"),
                FlagColorEntry(name: "Blue", hex: "00247D", meaning: "The Caribbean Sea and the courage of Venezuela's people"),
                FlagColorEntry(name: "Red", hex: "CF142B", meaning: "The blood of patriots who died in independence"),
            ],
            emblems: [
                FlagEmblemEntry(name: "Eight Stars", symbol: "star.fill", meaning: "The eight provinces that signed the Declaration of Independence in 1811"),
            ],
            historicalNote: "President Hugo Chávez added the eighth star in 2006 to honor the province of Guayana. The flag's design has Bolivarian origins, referencing the liberation movement across South America."
        ),
        "CL": FlagSymbolism(
            adoptedYear: 1817,
            colors: [
                FlagColorEntry(name: "White", hex: "FFFFFF", meaning: "The snow of the Andes Mountains"),
                FlagColorEntry(name: "Blue", hex: "0033A0", meaning: "The sky and the Pacific Ocean"),
                FlagColorEntry(name: "Red", hex: "D52B1E", meaning: "The blood spilled to achieve independence"),
            ],
            emblems: [
                FlagEmblemEntry(name: "Star", symbol: "star.fill", meaning: "A guide to progress and honor, representing the powers of the state"),
            ],
            historicalNote: "Chile's flag bears a strong resemblance to the Texas flag — both were likely influenced by the same revolutionary ideals of early 19th-century independence movements."
        ),
        "PE": FlagSymbolism(
            adoptedYear: 1825,
            colors: [
                FlagColorEntry(name: "Red", hex: "D91023", meaning: "The blood of heroes who fought for independence"),
                FlagColorEntry(name: "White", hex: "FFFFFF", meaning: "Peace and the purity of Peruvian intentions"),
            ],
            emblems: [
                FlagEmblemEntry(name: "Vicuña", symbol: "hare", meaning: "Native fauna — represents Peru's animal kingdom"),
                FlagEmblemEntry(name: "Cinchona Tree", symbol: "tree", meaning: "Native flora — source of quinine, the world's first anti-malarial"),
                FlagEmblemEntry(name: "Cornucopia", symbol: "cart.fill", meaning: "Mineral wealth of the nation"),
            ],
            historicalNote: "According to legend, General José de San Martín chose red and white after seeing flamingos rise from the sea at the time of his army's landing near Pisco in 1820."
        ),
        "CU": FlagSymbolism(
            adoptedYear: 1902,
            colors: [
                FlagColorEntry(name: "Blue", hex: "002A8F", meaning: "The three provinces of Cuba (represented by three stripes)"),
                FlagColorEntry(name: "White", hex: "FFFFFF", meaning: "The purity of the independence cause"),
                FlagColorEntry(name: "Red", hex: "CF142B", meaning: "The blood shed for independence and the revolutionary struggle"),
            ],
            emblems: [
                FlagEmblemEntry(name: "Lone Star", symbol: "star.fill", meaning: "The independent state of Cuba — giving the flag its popular name 'La Estrella Solitaria'"),
            ],
            historicalNote: "The Cuban flag was designed in 1849 by Venezuelan poet Miguel Teurbe Tolón and Cuban poet Narciso López. It was used by independence fighters before becoming the official national flag in 1902."
        ),
        "JM": FlagSymbolism(
            adoptedYear: 1962,
            colors: [
                FlagColorEntry(name: "Black", hex: "000000", meaning: "The hardships faced and overcome by the Jamaican people"),
                FlagColorEntry(name: "Gold", hex: "FED100", meaning: "Natural wealth and the beauty of sunlight"),
                FlagColorEntry(name: "Green", hex: "009B3A", meaning: "Agricultural wealth and the lush vegetation of the island"),
            ],
            emblems: [],
            historicalNote: "Jamaica's flag is the only national flag that contains neither red, white, nor blue. The original design had black, gold, and green in horizontal stripes, but was changed to the saltire (diagonal cross) design."
        ),
        "HT": FlagSymbolism(
            adoptedYear: 1843,
            colors: [
                FlagColorEntry(name: "Blue", hex: "00209F", meaning: "Represents the black population"),
                FlagColorEntry(name: "Red", hex: "D21034", meaning: "Represents the mixed-race population"),
            ],
            emblems: [
                FlagEmblemEntry(name: "Palm Tree", symbol: "tree", meaning: "Freedom and independence from slavery"),
                FlagEmblemEntry(name: "Cannon", symbol: "shield.fill", meaning: "Haiti's readiness to defend its liberty"),
            ],
            historicalNote: "Legend holds that Catherine Flon sewed the first Haitian flag by tearing the white stripe out of a French tricolor to symbolize the expulsion of the French and the union of blacks and mixed-race Haitians."
        ),
        "TT": FlagSymbolism(
            adoptedYear: 1962,
            colors: [
                FlagColorEntry(name: "Red", hex: "CE1126", meaning: "Fire — the warmth of the sun, the people's energy, and the country's courage"),
                FlagColorEntry(name: "Black", hex: "000000", meaning: "The dedication and strength of the Trinbagonian people"),
                FlagColorEntry(name: "White", hex: "FFFFFF", meaning: "The sea surrounding the islands and the equality of all"),
            ],
            emblems: [],
            historicalNote: "The black stripe can also represent the unity between the two islands of Trinidad and Tobago, running diagonally across the flag as a unifying band."
        ),
        "GT": FlagSymbolism(
            adoptedYear: 1871,
            colors: [
                FlagColorEntry(name: "Blue", hex: "4997D0", meaning: "The Pacific and Atlantic Oceans that border Guatemala"),
                FlagColorEntry(name: "White", hex: "FFFFFF", meaning: "Peace and purity"),
            ],
            emblems: [
                FlagEmblemEntry(name: "Quetzal", symbol: "bird", meaning: "The resplendent quetzal bird — symbol of liberty and Guatemala's national bird"),
                FlagEmblemEntry(name: "Scroll", symbol: "doc.text", meaning: "The date of independence: September 15, 1821"),
                FlagEmblemEntry(name: "Crossed Rifles and Swords", symbol: "shield", meaning: "Guatemala's willingness to defend its sovereignty"),
            ],
            historicalNote: nil
        ),
        "CR": FlagSymbolism(
            adoptedYear: 1848,
            colors: [
                FlagColorEntry(name: "Blue", hex: "002B7F", meaning: "The sky, opportunities, and perseverance"),
                FlagColorEntry(name: "White", hex: "FFFFFF", meaning: "Peace, wisdom, and happiness"),
                FlagColorEntry(name: "Red", hex: "CE1126", meaning: "The warmth of the Costa Rican people and the blood shed for freedom"),
            ],
            emblems: [
                FlagEmblemEntry(name: "Coat of Arms", symbol: "seal", meaning: "Features three volcanoes between two oceans, representing Costa Rica's geography"),
            ],
            historicalNote: "The red stripe was added in 1848 inspired by the French tricolor and the revolutionary spirit of 1848. Costa Rica's flag is unusual in that its coat of arms portrays the country as 'A Gateway to the Americas'."
        ),
        "PA": FlagSymbolism(
            adoptedYear: 1904,
            colors: [
                FlagColorEntry(name: "White", hex: "FFFFFF", meaning: "Peace between the two major political parties"),
                FlagColorEntry(name: "Red", hex: "D21034", meaning: "The Liberal Party"),
                FlagColorEntry(name: "Blue", hex: "003087", meaning: "The Conservative Party"),
            ],
            emblems: [
                FlagEmblemEntry(name: "Blue Star", symbol: "star.fill", meaning: "Civic virtue and purity"),
                FlagEmblemEntry(name: "Red Star", symbol: "star.fill", meaning: "Authority and law"),
            ],
            historicalNote: "The flag was designed by Manuel Encarnación Amador to represent peace and prosperity after Panama's independence from Colombia in 1903. The two stars represent the hope that both political parties will keep a clean record."
        ),
        "UY": FlagSymbolism(
            adoptedYear: 1830,
            colors: [
                FlagColorEntry(name: "White", hex: "FFFFFF", meaning: "Peace and the sky"),
                FlagColorEntry(name: "Blue", hex: "0038A8", meaning: "The rivers and the Río de la Plata"),
            ],
            emblems: [
                FlagEmblemEntry(name: "Sun of May", symbol: "sun.max.fill", meaning: "Same as Argentina's — commemorating the May Revolution and Inca solar symbolism"),
                FlagEmblemEntry(name: "Nine Stripes", symbol: "line.3.horizontal", meaning: "The nine original departments of Uruguay"),
            ],
            historicalNote: nil
        ),
        "BO": FlagSymbolism(
            adoptedYear: 1851,
            colors: [
                FlagColorEntry(name: "Red", hex: "D52B1E", meaning: "Valor and the blood of national heroes"),
                FlagColorEntry(name: "Yellow", hex: "F4C430", meaning: "Bolivia's mineral resources — the richest silver and tin mines in history"),
                FlagColorEntry(name: "Green", hex: "007A3D", meaning: "Bolivia's fertile land and agricultural wealth"),
            ],
            emblems: [
                FlagEmblemEntry(name: "Coat of Arms", symbol: "mountain.2.fill", meaning: "Features Cerro Rico (Rich Mountain), the condor, and the alpaca — icons of Bolivia's natural wealth"),
            ],
            historicalNote: nil
        ),
        "PY": FlagSymbolism(
            adoptedYear: 1842,
            colors: [
                FlagColorEntry(name: "Red", hex: "D52B1E", meaning: "Courage, patriotism, and equality"),
                FlagColorEntry(name: "White", hex: "FFFFFF", meaning: "Peace and unity"),
                FlagColorEntry(name: "Blue", hex: "0038A8", meaning: "Liberty, truth, and justice"),
            ],
            emblems: [
                FlagEmblemEntry(name: "Star of May", symbol: "star.fill", meaning: "The State Treasury seal on the reverse — the only flag in the world with different emblems on each side"),
            ],
            historicalNote: "Paraguay is one of only three countries whose flag has different designs on the obverse and reverse. The front shows the coat of arms, while the back shows the Treasury seal."
        ),
        "GY": FlagSymbolism(
            adoptedYear: 1966,
            colors: [
                FlagColorEntry(name: "Green", hex: "009E49", meaning: "Agriculture and the lush forests"),
                FlagColorEntry(name: "White", hex: "FFFFFF", meaning: "The country's rivers and waterways"),
                FlagColorEntry(name: "Yellow", hex: "FCD116", meaning: "Mineral wealth and a golden future"),
                FlagColorEntry(name: "Black", hex: "000000", meaning: "Endurance of the Guyanese people"),
                FlagColorEntry(name: "Red", hex: "CE1126", meaning: "Zeal and dynamism of nation-building"),
            ],
            emblems: [
                FlagEmblemEntry(name: "Golden Arrowhead", symbol: "arrowtriangle.right.fill", meaning: "Guyana's forward drive toward its future"),
            ],
            historicalNote: "Known as 'The Golden Arrowhead,' the flag was designed by American vexillologist Whitney Smith. The arrow points forward — toward progress — framed by white rivers and a black border of endurance."
        ),
        "EC": FlagSymbolism(
            adoptedYear: 1860,
            colors: [
                FlagColorEntry(name: "Yellow", hex: "FFD100", meaning: "Abundance of crops, fertility of the soil, and the sun"),
                FlagColorEntry(name: "Blue", hex: "0033A0", meaning: "The sky and the ocean"),
                FlagColorEntry(name: "Red", hex: "CE1126", meaning: "The blood of freedom fighters"),
            ],
            emblems: [
                FlagEmblemEntry(name: "Condor", symbol: "bird", meaning: "Power and the greatness of Ecuador"),
                FlagEmblemEntry(name: "Chimborazo", symbol: "mountain.2.fill", meaning: "The highest volcano in Ecuador, representing national territory"),
            ],
            historicalNote: nil
        ),
        "HN": FlagSymbolism(
            adoptedYear: 1866,
            colors: [
                FlagColorEntry(name: "Blue", hex: "0073CF", meaning: "The Caribbean Sea and the Pacific Ocean"),
                FlagColorEntry(name: "White", hex: "FFFFFF", meaning: "Peace, prosperity, and the purity of thoughts"),
            ],
            emblems: [
                FlagEmblemEntry(name: "Five Stars", symbol: "star.fill", meaning: "The five members of the former Central American Federation: Honduras, El Salvador, Guatemala, Nicaragua, and Costa Rica"),
            ],
            historicalNote: nil
        ),
        "NI": FlagSymbolism(
            adoptedYear: 1908,
            colors: [
                FlagColorEntry(name: "Blue", hex: "003DA5", meaning: "Justice and the two oceans of Nicaragua"),
                FlagColorEntry(name: "White", hex: "FFFFFF", meaning: "Virtue and peace"),
            ],
            emblems: [
                FlagEmblemEntry(name: "Triangle", symbol: "triangle", meaning: "Equality — the equilateral triangle at the center"),
                FlagEmblemEntry(name: "Rainbow over Volcano", symbol: "mountain.2.fill", meaning: "The five Central American nations represented by the rainbow over Momotombo volcano"),
            ],
            historicalNote: nil
        ),
        "DO": FlagSymbolism(
            adoptedYear: 1844,
            colors: [
                FlagColorEntry(name: "Blue", hex: "002D62", meaning: "Liberty"),
                FlagColorEntry(name: "Red", hex: "CE1126", meaning: "The blood of heroes who died for freedom"),
                FlagColorEntry(name: "White", hex: "FFFFFF", meaning: "Salvation"),
            ],
            emblems: [
                FlagEmblemEntry(name: "White Cross", symbol: "cross", meaning: "The Christian faith and the struggle for independence"),
                FlagEmblemEntry(name: "Bible and Cross", symbol: "book", meaning: "Christian faith — the Dominican Republic flag is the only flag with a Bible on it"),
            ],
            historicalNote: "The Dominican flag is unique in the Caribbean — it features a Bible open to John 8:32 ('And the truth shall set you free'), making it one of the only national flags in the world with a holy book."
        ),
        "SV": FlagSymbolism(
            adoptedYear: 1912,
            colors: [
                FlagColorEntry(name: "Blue", hex: "0F47AF", meaning: "The Pacific and Atlantic Oceans"),
                FlagColorEntry(name: "White", hex: "FFFFFF", meaning: "Peace and harmony"),
            ],
            emblems: [
                FlagEmblemEntry(name: "Five Volcanoes", symbol: "mountain.2.fill", meaning: "The five nations of Central America, separated by two oceans"),
                FlagEmblemEntry(name: "Phrygian Cap", symbol: "star.fill", meaning: "Liberty — the revolutionary cap atop the triangle"),
            ],
            historicalNote: nil
        ),

        // MARK: Europe

        "GB": FlagSymbolism(
            adoptedYear: 1801,
            colors: [
                FlagColorEntry(name: "Red", hex: "CF142B", meaning: "St George's Cross of England — also St Patrick's Cross of Ireland"),
                FlagColorEntry(name: "White", hex: "FFFFFF", meaning: "St Andrew's Cross of Scotland and the background of St George's Cross"),
                FlagColorEntry(name: "Blue", hex: "012169", meaning: "The field of St Andrew's Cross — representing Scotland"),
            ],
            emblems: [
                FlagEmblemEntry(name: "Union Jack", symbol: "star.of.david", meaning: "The combination of St George's Cross (England), St Andrew's Cross (Scotland), and St Patrick's Cross (Ireland)"),
            ],
            historicalNote: "The Union Flag was first created in 1606 when James VI of Scotland became James I of England. The Irish cross was added in 1801 after the Acts of Union merged Great Britain and Ireland."
        ),
        "FR": FlagSymbolism(
            adoptedYear: 1794,
            colors: [
                FlagColorEntry(name: "Blue", hex: "002395", meaning: "Freedom and the revolutionary tradition"),
                FlagColorEntry(name: "White", hex: "FFFFFF", meaning: "Equality and peace"),
                FlagColorEntry(name: "Red", hex: "ED2939", meaning: "Fraternity — the French people's brotherhood"),
            ],
            emblems: [],
            historicalNote: "The tricolore was born from the French Revolution. The colors combined the blue and red of Paris (the revolutionary city) with the royal white — a unification of the old and new orders. It directly inspired dozens of other national flags worldwide."
        ),
        "DE": FlagSymbolism(
            adoptedYear: 1949,
            colors: [
                FlagColorEntry(name: "Black", hex: "000000", meaning: "Determination and the dark history of oppression"),
                FlagColorEntry(name: "Red", hex: "DD0000", meaning: "Bravery, strength, and the blood of freedom"),
                FlagColorEntry(name: "Gold", hex: "FFCE00", meaning: "Generosity and the ideal of a golden future"),
            ],
            emblems: [],
            historicalNote: "The black-red-gold combination dates to the early 19th-century German nationalist movement. It was used in the Weimar Republic (1919–1933), abolished under the Nazis, and restored for West Germany in 1949 — symbolizing democratic Germany."
        ),
        "IT": FlagSymbolism(
            adoptedYear: 1948,
            colors: [
                FlagColorEntry(name: "Green", hex: "009246", meaning: "The hills and plains of Italy"),
                FlagColorEntry(name: "White", hex: "FFFFFF", meaning: "The Alpine snow"),
                FlagColorEntry(name: "Red", hex: "CE2B37", meaning: "The bloodshed during the Wars of Italian Independence"),
            ],
            emblems: [],
            historicalNote: "Italy's tricolore was inspired by the French flag during Napoleon's Italian campaigns. The green was added to the original blue-white-red French palette, said to represent Napoleon's Milanese Civic Guard uniform color."
        ),
        "ES": FlagSymbolism(
            adoptedYear: 1981,
            colors: [
                FlagColorEntry(name: "Red", hex: "AA151B", meaning: "Valor and hardiness"),
                FlagColorEntry(name: "Yellow", hex: "F1BF00", meaning: "Generosity and the golden wealth of Spain"),
            ],
            emblems: [
                FlagEmblemEntry(name: "Royal Crown", symbol: "crown", meaning: "The Spanish monarchy"),
                FlagEmblemEntry(name: "Pillars of Hercules", symbol: "line.3.horizontal", meaning: "The Strait of Gibraltar, with the motto 'Plus Ultra' — ever further"),
            ],
            historicalNote: "Charles III introduced the red-yellow-red design in 1785 to distinguish Spanish ships from other vessels at sea. The yellow (gold) band is twice as wide as each red band to make it more visible."
        ),
        "PT": FlagSymbolism(
            adoptedYear: 1911,
            colors: [
                FlagColorEntry(name: "Green", hex: "006600", meaning: "Hope and the sea voyages of the Age of Discovery"),
                FlagColorEntry(name: "Red", hex: "FF0000", meaning: "Revolution and the bloodshed of the 1910 Republican revolution"),
            ],
            emblems: [
                FlagEmblemEntry(name: "Armillary Sphere", symbol: "globe", meaning: "Symbol of the Age of Discovery — Portugal's global navigation achievements"),
                FlagEmblemEntry(name: "Shield with Bezants", symbol: "shield", meaning: "The five wounds of Christ and the coins paid as tribute to the Moors"),
            ],
            historicalNote: "The armillary sphere was used by Portuguese navigators to determine latitude at sea. It represents Portugal's pivotal role in the Age of Exploration and its far-flung maritime empire."
        ),
        "NL": FlagSymbolism(
            adoptedYear: 1937,
            colors: [
                FlagColorEntry(name: "Red", hex: "AE1C28", meaning: "Valor and hardiness — originally a brighter orange from the House of Orange"),
                FlagColorEntry(name: "White", hex: "FFFFFF", meaning: "Purity and honesty"),
                FlagColorEntry(name: "Blue", hex: "21468B", meaning: "Loyalty and justice"),
            ],
            emblems: [],
            historicalNote: "The Dutch flag was originally orange-white-blue (the colors of William of Orange) in the 16th century. The orange faded to red over centuries, and red was officially adopted in 1937. The flag heavily influenced Russia's and France's tricolors."
        ),
        "BE": FlagSymbolism(
            adoptedYear: 1831,
            colors: [
                FlagColorEntry(name: "Black", hex: "000000", meaning: "Strength and determination — from the arms of the Duchy of Brabant"),
                FlagColorEntry(name: "Yellow", hex: "FAE042", meaning: "Generosity — the golden lion of Brabant"),
                FlagColorEntry(name: "Red", hex: "EF3340", meaning: "Bravery — the red claws and tongue of the Brabant lion"),
            ],
            emblems: [],
            historicalNote: "The Belgian tricolor was inspired by the French Revolution and the colors of the Duchy of Brabant. The vertical orientation distinguishes it from similar tricolors like Germany's horizontal flag."
        ),
        "CH": FlagSymbolism(
            adoptedYear: 1848,
            colors: [
                FlagColorEntry(name: "Red", hex: "FF0000", meaning: "The blood of federal soldiers"),
                FlagColorEntry(name: "White", hex: "FFFFFF", meaning: "Purity, peace, and Alpine snow"),
            ],
            emblems: [
                FlagEmblemEntry(name: "White Cross", symbol: "cross", meaning: "Christianity and the Christian faith of the Swiss Confederation"),
            ],
            historicalNote: "Switzerland is one of only two countries with a square national flag (the other is Vatican City). The white cross has been a Swiss battle symbol since the 14th century, predating the confederation itself."
        ),
        "AT": FlagSymbolism(
            adoptedYear: 1945,
            colors: [
                FlagColorEntry(name: "Red", hex: "ED2939", meaning: "Valor and the blood of battles"),
                FlagColorEntry(name: "White", hex: "FFFFFF", meaning: "Peace and the snowcaps of the Alps"),
            ],
            emblems: [],
            historicalNote: "Austrian legend attributes the design to Duke Leopold V after the Battle of Ptolemais (1191). His white surcoat was completely soaked in blood except where a broad belt protected it, creating a red-white-red pattern."
        ),
        "SE": FlagSymbolism(
            adoptedYear: 1906,
            colors: [
                FlagColorEntry(name: "Blue", hex: "006AA7", meaning: "The sky, lakes, and sea surrounding Sweden"),
                FlagColorEntry(name: "Yellow", hex: "FECC02", meaning: "The sun and Sweden's golden fields"),
            ],
            emblems: [
                FlagEmblemEntry(name: "Nordic Cross", symbol: "cross", meaning: "Christianity — the cross extends to the flag's edges in the Scandinavian tradition"),
            ],
            historicalNote: nil
        ),
        "NO": FlagSymbolism(
            adoptedYear: 1821,
            colors: [
                FlagColorEntry(name: "Red", hex: "EF2B2D", meaning: "Courage and valor"),
                FlagColorEntry(name: "White", hex: "FFFFFF", meaning: "Peace and honesty"),
                FlagColorEntry(name: "Blue", hex: "002868", meaning: "Loyalty and justice"),
            ],
            emblems: [
                FlagEmblemEntry(name: "Nordic Cross", symbol: "cross", meaning: "Christianity, combined with the colors of Denmark (red/white) and France (tricolor) to represent democratic values"),
            ],
            historicalNote: "Norway's flag incorporates the Danish cross (red with white outline) and adds a blue inner cross — representing Norway's ties to Scandinavia and democratic ideals inspired by the French Revolution."
        ),
        "DK": FlagSymbolism(
            adoptedYear: 1370,
            colors: [
                FlagColorEntry(name: "Red", hex: "C60C30", meaning: "Courage and valor in battle"),
                FlagColorEntry(name: "White", hex: "FFFFFF", meaning: "Peace and honesty"),
            ],
            emblems: [
                FlagEmblemEntry(name: "Dannebrog Cross", symbol: "cross", meaning: "The Nordic cross, symbolizing Christianity in the Scandinavian tradition"),
            ],
            historicalNote: "The Dannebrog ('Danish cloth') is the world's oldest national flag still in continuous use. According to legend, it fell from the sky during the Battle of Lyndanisse in 1219, inspiring the Danish warriors to victory."
        ),
        "FI": FlagSymbolism(
            adoptedYear: 1918,
            colors: [
                FlagColorEntry(name: "White", hex: "FFFFFF", meaning: "The snow and ice of Finland's winters"),
                FlagColorEntry(name: "Blue", hex: "003580", meaning: "Finland's thousands of lakes and the blue sky"),
            ],
            emblems: [
                FlagEmblemEntry(name: "Nordic Cross", symbol: "cross", meaning: "Christianity and the Scandinavian/Nordic heritage of Finland"),
            ],
            historicalNote: "Finland adopted its flag upon declaring independence from Russia in 1917. The blue and white colors had been used in Finnish art and poetry for decades as symbols of the country's natural landscape."
        ),
        "PL": FlagSymbolism(
            adoptedYear: 1919,
            colors: [
                FlagColorEntry(name: "White", hex: "FFFFFF", meaning: "Purity and noble ideals"),
                FlagColorEntry(name: "Red", hex: "DC143C", meaning: "Sacrifice and valor — the blood shed for Poland"),
            ],
            emblems: [],
            historicalNote: "Poland's white eagle emblem is one of the oldest in Europe, dating from the 10th century. The white and red colors derive from the arms of the Polish-Lithuanian Commonwealth."
        ),
        "GR": FlagSymbolism(
            adoptedYear: 1978,
            colors: [
                FlagColorEntry(name: "Blue", hex: "0D5EAF", meaning: "The sky and the sea"),
                FlagColorEntry(name: "White", hex: "FFFFFF", meaning: "The breaking waves of the sea and the purity of the independence struggle"),
            ],
            emblems: [
                FlagEmblemEntry(name: "White Cross", symbol: "cross", meaning: "Greek Orthodox Christianity"),
                FlagEmblemEntry(name: "Nine Stripes", symbol: "line.3.horizontal", meaning: "The nine syllables of the phrase 'Ελευθερία ή Θάνατος' (Freedom or Death)"),
            ],
            historicalNote: "The nine blue and white stripes represent the nine syllables of the revolutionary slogan 'Freedom or Death,' used during the Greek War of Independence against Ottoman rule (1821–1829)."
        ),
        "UA": FlagSymbolism(
            adoptedYear: 1992,
            colors: [
                FlagColorEntry(name: "Blue", hex: "005BBB", meaning: "The clear blue sky over Ukraine"),
                FlagColorEntry(name: "Yellow", hex: "FFD500", meaning: "Golden wheat fields — Ukraine's agricultural abundance and identity"),
            ],
            emblems: [],
            historicalNote: "Ukraine's blue and yellow flag is one of the world's most recognizable bicolors. These colors were used in Ukrainian coats of arms since the medieval Principality of Galicia-Volhynia. The flag was readopted after independence from the USSR in 1991."
        ),
        "CZ": FlagSymbolism(
            adoptedYear: 1920,
            colors: [
                FlagColorEntry(name: "Blue", hex: "11457E", meaning: "Slovakia's mountains and rivers"),
                FlagColorEntry(name: "White", hex: "FFFFFF", meaning: "Bohemia and the purity of civic values"),
                FlagColorEntry(name: "Red", hex: "D7141A", meaning: "Moravia and the blood of Czechoslovakia's freedom fighters"),
            ],
            emblems: [],
            historicalNote: "When Czechoslovakia peacefully split into Czech Republic and Slovakia on January 1, 1993, Czech Republic kept the combined flag. Slovakia adopted a new flag without the blue triangle."
        ),
        "SK": FlagSymbolism(
            adoptedYear: 1992,
            colors: [
                FlagColorEntry(name: "White", hex: "FFFFFF", meaning: "The snow-capped Carpathian Mountains"),
                FlagColorEntry(name: "Blue", hex: "0B4EA2", meaning: "The rivers and the sky"),
                FlagColorEntry(name: "Red", hex: "EE1C25", meaning: "Bravery and the blood of freedom fighters"),
            ],
            emblems: [
                FlagEmblemEntry(name: "Double-Barred Cross", symbol: "cross", meaning: "The Apostolic Cross of Saints Cyril and Methodius, brought from Byzantium to Moravia in 863 AD"),
                FlagEmblemEntry(name: "Three Mountains", symbol: "mountain.2.fill", meaning: "The three mountain ranges of Slovakia: Tatra, Matra, and Fatra"),
            ],
            historicalNote: nil
        ),
        "HU": FlagSymbolism(
            adoptedYear: 1957,
            colors: [
                FlagColorEntry(name: "Red", hex: "CE2939", meaning: "Strength and bravery of the Hungarian people"),
                FlagColorEntry(name: "White", hex: "FFFFFF", meaning: "Faithfulness and the snow of the Carpathians"),
                FlagColorEntry(name: "Green", hex: "477050", meaning: "Hope and the fertile Hungarian plains"),
            ],
            emblems: [],
            historicalNote: "Hungary's tricolor was adopted during the revolution of 1848–49 against Habsburg rule, inspired by the French tricolor. The colors are derived from the Hungarian coat of arms used since the 12th century."
        ),
        "RO": FlagSymbolism(
            adoptedYear: 1989,
            colors: [
                FlagColorEntry(name: "Blue", hex: "002B7F", meaning: "Liberty and the sky"),
                FlagColorEntry(name: "Yellow", hex: "FCD116", meaning: "Justice and Romania's fertile lands"),
                FlagColorEntry(name: "Red", hex: "CE1126", meaning: "Fraternity and the blood of freedom fighters"),
            ],
            emblems: [],
            historicalNote: "Romania's tricolor was first used in 1848 during the Wallachian Revolution, inspired by the French tricolor. Romania removed the communist coat of arms from the flag in 1989 after the fall of Ceaușescu."
        ),
        "BG": FlagSymbolism(
            adoptedYear: 1990,
            colors: [
                FlagColorEntry(name: "White", hex: "FFFFFF", meaning: "Peace, love, and freedom"),
                FlagColorEntry(name: "Green", hex: "00966E", meaning: "Agriculture, fertility, and the forests"),
                FlagColorEntry(name: "Red", hex: "D01C1F", meaning: "The independence struggles and the valor of the Bulgarian people"),
            ],
            emblems: [],
            historicalNote: nil
        ),
        "RS": FlagSymbolism(
            adoptedYear: 2010,
            colors: [
                FlagColorEntry(name: "Red", hex: "C6363C", meaning: "Blood and valor"),
                FlagColorEntry(name: "Blue", hex: "0C4076", meaning: "Liberty"),
                FlagColorEntry(name: "White", hex: "FFFFFF", meaning: "Peace"),
            ],
            emblems: [
                FlagEmblemEntry(name: "Double-Headed Eagle", symbol: "bird", meaning: "Medieval Serbian heritage and sovereignty"),
                FlagEmblemEntry(name: "Four Firesteels", symbol: "flame", meaning: "Four Cyrillic letter С (S) representing the motto 'Samo sloga Srbina spasava' — Only unity saves the Serb"),
            ],
            historicalNote: nil
        ),
        "HR": FlagSymbolism(
            adoptedYear: 1990,
            colors: [
                FlagColorEntry(name: "Red", hex: "FF0000", meaning: "Valor and sacrifice"),
                FlagColorEntry(name: "White", hex: "FFFFFF", meaning: "Purity and peace"),
                FlagColorEntry(name: "Blue", hex: "171796", meaning: "Loyalty and determination"),
            ],
            emblems: [
                FlagEmblemEntry(name: "Checkerboard Shield", symbol: "checkmark.shield", meaning: "The historic Croatian red-and-white chequerboard (šahovnica) used since the medieval Kingdom of Croatia"),
            ],
            historicalNote: nil
        ),
        "SI": FlagSymbolism(
            adoptedYear: 1991,
            colors: [
                FlagColorEntry(name: "White", hex: "FFFFFF", meaning: "Purity and snow of the Alps"),
                FlagColorEntry(name: "Blue", hex: "003DA5", meaning: "Sky and rivers"),
                FlagColorEntry(name: "Red", hex: "EF3340", meaning: "Courage and sacrifice"),
            ],
            emblems: [
                FlagEmblemEntry(name: "Mount Triglav", symbol: "mountain.2.fill", meaning: "Slovenia's highest peak and national symbol, in white on blue"),
                FlagEmblemEntry(name: "Three Stars", symbol: "star.fill", meaning: "The historical County of Celje, representing freedom"),
                FlagEmblemEntry(name: "Blue Wavy Lines", symbol: "water.waves", meaning: "The Adriatic Sea and Slovenia's rivers"),
            ],
            historicalNote: nil
        ),

        // MARK: Asia

        "JP": FlagSymbolism(
            adoptedYear: 1870,
            colors: [
                FlagColorEntry(name: "White", hex: "FFFFFF", meaning: "Honesty and purity"),
                FlagColorEntry(name: "Red", hex: "BC002D", meaning: "The sun — sincerity and warmth"),
            ],
            emblems: [
                FlagEmblemEntry(name: "Hinomaru (Sun Disc)", symbol: "sun.max.fill", meaning: "The rising sun — Japan is known as 'Nippon' (the origin of the sun) and traces its imperial lineage to the sun goddess Amaterasu"),
            ],
            historicalNote: "The Hinomaru has been used in Japan since at least the Edo period. The current legal specifications were defined in the Law Regarding the National Flag and Anthem (1999), standardizing the exact shade of red and proportions."
        ),
        "CN": FlagSymbolism(
            adoptedYear: 1949,
            colors: [
                FlagColorEntry(name: "Red", hex: "DE2910", meaning: "The communist revolution and the blood of those who died for it"),
                FlagColorEntry(name: "Yellow", hex: "FFDE00", meaning: "The golden future of China"),
            ],
            emblems: [
                FlagEmblemEntry(name: "Large Star", symbol: "star.fill", meaning: "The Communist Party of China, leading the nation"),
                FlagEmblemEntry(name: "Four Small Stars", symbol: "star", meaning: "The four social classes: workers, peasants, urban petit-bourgeoisie, and national bourgeoisie"),
            ],
            historicalNote: "Designed by Zeng Liansong in 1949, the flag was chosen from nearly 3,000 submissions. The five stars reflect Mao Zedong's vision of a united Chinese people rallying around the Communist Party."
        ),
        "IN": FlagSymbolism(
            adoptedYear: 1947,
            colors: [
                FlagColorEntry(name: "Saffron", hex: "FF9933", meaning: "Courage, sacrifice, and the spirit of renunciation"),
                FlagColorEntry(name: "White", hex: "FFFFFF", meaning: "Peace, truth, and purity"),
                FlagColorEntry(name: "Green", hex: "138808", meaning: "Faith, chivalry, and the fertility of the land"),
            ],
            emblems: [
                FlagEmblemEntry(name: "Ashoka Chakra", symbol: "circle", meaning: "The Dhamma Chakra — the eternal wheel of law, with 24 spokes representing the hours of the day. Taken from the Lion Capital of Ashoka (3rd century BCE)"),
            ],
            historicalNote: "The Constituent Assembly replaced Gandhi's spinning wheel (charkha) with the Ashoka Chakra on July 22, 1947, to avoid political associations and represent a more universal Indian identity. The saffron and green also symbolize India's two major religions — Hinduism and Islam."
        ),
        "KR": FlagSymbolism(
            adoptedYear: 1950,
            colors: [
                FlagColorEntry(name: "White", hex: "FFFFFF", meaning: "Peace, purity, and the Korean love of peace"),
                FlagColorEntry(name: "Red", hex: "CD2E3A", meaning: "Positive cosmic forces"),
                FlagColorEntry(name: "Blue", hex: "0047A0", meaning: "Negative cosmic forces"),
            ],
            emblems: [
                FlagEmblemEntry(name: "Taeguk", symbol: "circle.and.line.horizontal", meaning: "The yin-yang balance of the universe — red (positive) above, blue (negative) below, in continuous rotation"),
                FlagEmblemEntry(name: "Four Trigrams", symbol: "square.grid.2x2", meaning: "Heaven (☰), Earth (☷), Water (☵), and Fire (☲) — representing the four elements and directions"),
            ],
            historicalNote: "The Taegukgi (Korean for 'flag') embodies Taoist philosophy. The four black trigrams are from the I Ching, representing heaven, earth, water, and fire — also standing for the four cardinal virtues: benevolence, wisdom, vitality, and justice."
        ),
        "SA": FlagSymbolism(
            adoptedYear: 1973,
            colors: [
                FlagColorEntry(name: "Green", hex: "006C35", meaning: "Islam and prosperity"),
                FlagColorEntry(name: "White", hex: "FFFFFF", meaning: "Peace"),
            ],
            emblems: [
                FlagEmblemEntry(name: "Shahada", symbol: "text.quote", meaning: "The Islamic declaration of faith: 'There is no god but Allah; Muhammad is the Messenger of Allah'"),
                FlagEmblemEntry(name: "Sword", symbol: "exclamationmark.triangle", meaning: "Justice and the power of the House of Saud"),
            ],
            historicalNote: "Saudi Arabia's flag is one of only three national flags with writing on it (the others being Afghanistan and Iran). The flag is never flown at half-mast because lowering the Shahada would be considered disrespectful."
        ),
        "TR": FlagSymbolism(
            adoptedYear: 1844,
            colors: [
                FlagColorEntry(name: "Red", hex: "E30A17", meaning: "The blood of Turkish martyrs and the setting sun"),
                FlagColorEntry(name: "White", hex: "FFFFFF", meaning: "Peace"),
            ],
            emblems: [
                FlagEmblemEntry(name: "Crescent Moon", symbol: "moon", meaning: "Traditional Islamic symbol representing progress"),
                FlagEmblemEntry(name: "Star", symbol: "star.fill", meaning: "Represents the Turkic states and the light of civilization"),
            ],
            historicalNote: "The crescent and star were already symbols of the Ottoman Empire long before Islam. After the siege of Constantinople in 1453, they became associated with Islam across the Middle East. Various legends connect the crescent to the Byzantine city."
        ),
        "PK": FlagSymbolism(
            adoptedYear: 1947,
            colors: [
                FlagColorEntry(name: "Green", hex: "01411C", meaning: "Islam and the Muslim majority"),
                FlagColorEntry(name: "White", hex: "FFFFFF", meaning: "Peace and the religious minorities of Pakistan"),
            ],
            emblems: [
                FlagEmblemEntry(name: "Crescent", symbol: "moon", meaning: "Progress and symbolizes the followers of Islam"),
                FlagEmblemEntry(name: "Star", symbol: "star.fill", meaning: "Light, knowledge, and guidance"),
            ],
            historicalNote: "The green represents Muslim majority and the white stripe the Hindu, Christian, and other minorities. The design was inspired by the flag of the All India Muslim League."
        ),
        "BD": FlagSymbolism(
            adoptedYear: 1972,
            colors: [
                FlagColorEntry(name: "Green", hex: "006A4E", meaning: "The lush greenery of Bangladesh and the vitality of its people"),
                FlagColorEntry(name: "Red", hex: "F42A41", meaning: "The rising sun and the blood of those who died in the Liberation War of 1971"),
            ],
            emblems: [
                FlagEmblemEntry(name: "Red Circle", symbol: "circle.fill", meaning: "The rising sun emerging from darkness — and the blood of over 3 million Bangladeshis who died for independence"),
            ],
            historicalNote: "Bangladesh's flag is inspired by Japan's. The red circle is slightly off-center toward the hoist side so it appears centered when the flag is flying. The original design (1971) included a yellow map of Bangladesh, which was removed in 1972."
        ),
        "ID": FlagSymbolism(
            adoptedYear: 1945,
            colors: [
                FlagColorEntry(name: "Red", hex: "CE1126", meaning: "Courage and valor"),
                FlagColorEntry(name: "White", hex: "FFFFFF", meaning: "Purity and peace"),
            ],
            emblems: [],
            historicalNote: "Indonesia's flag (Sang Saka Merah-Putih — 'Sacred Red and White') is nearly identical to Monaco's — both use red over white in identical proportions. The Indonesian colors derive from the Majapahit Empire's banner used over 700 years ago."
        ),
        "TH": FlagSymbolism(
            adoptedYear: 1917,
            colors: [
                FlagColorEntry(name: "Red", hex: "A51931", meaning: "The nation and the blood of those who sacrificed for Thailand"),
                FlagColorEntry(name: "White", hex: "FFFFFF", meaning: "Religion — the purity of Buddhism"),
                FlagColorEntry(name: "Blue", hex: "2D2A4A", meaning: "The monarchy — the most revered institution in Thailand"),
            ],
            emblems: [],
            historicalNote: "The blue stripe was added in 1917 by King Vajiravudh to show solidarity with the Allied Powers in World War I, who used similar colors. Thailand is the only Southeast Asian nation never colonized by Europeans."
        ),
        "VN": FlagSymbolism(
            adoptedYear: 1955,
            colors: [
                FlagColorEntry(name: "Red", hex: "DA251D", meaning: "Revolution, the blood of the fallen, and the country's socialist spirit"),
                FlagColorEntry(name: "Yellow", hex: "FFCD00", meaning: "The golden skin of the Vietnamese people and the future they are building"),
            ],
            emblems: [
                FlagEmblemEntry(name: "Five-Pointed Star", symbol: "star.fill", meaning: "The five classes of Vietnamese society: workers, peasants, intellectuals, traders, and soldiers — united under socialism"),
            ],
            historicalNote: "The red flag with a gold star was created by Nguyễn Hữu Tiến in 1940 for the Nam Kỳ uprising against French colonial rule. It became the official flag of North Vietnam in 1955 and unified Vietnam in 1975."
        ),
        "PH": FlagSymbolism(
            adoptedYear: 1898,
            colors: [
                FlagColorEntry(name: "Blue", hex: "0038A8", meaning: "Peace, truth, and justice"),
                FlagColorEntry(name: "Red", hex: "CE1126", meaning: "Patriotism and valor"),
                FlagColorEntry(name: "White", hex: "FFFFFF", meaning: "Equality and fraternity"),
            ],
            emblems: [
                FlagEmblemEntry(name: "Sun", symbol: "sun.max.fill", meaning: "Freedom and the eight provinces that first revolted against Spanish rule"),
                FlagEmblemEntry(name: "Three Stars", symbol: "star.fill", meaning: "The three main geographical regions: Luzon, Visayas, and Mindanao"),
            ],
            historicalNote: "Uniquely, the Philippine flag is displayed with the red stripe up during wartime and the blue stripe up during peace. It is the only national flag with this inverted-meaning tradition."
        ),
        "MY": FlagSymbolism(
            adoptedYear: 1963,
            colors: [
                FlagColorEntry(name: "Red", hex: "CC0001", meaning: "Courage and the willingness to sacrifice for the nation"),
                FlagColorEntry(name: "White", hex: "FFFFFF", meaning: "Purity and virtue"),
                FlagColorEntry(name: "Blue", hex: "010066", meaning: "Unity, harmony, and stability of the Malaysian people"),
                FlagColorEntry(name: "Yellow", hex: "FC0", meaning: "Royal color of the Malay rulers"),
            ],
            emblems: [
                FlagEmblemEntry(name: "14 Stripes", symbol: "line.3.horizontal", meaning: "The 13 states and the Federal Territories"),
                FlagEmblemEntry(name: "Crescent and Star", symbol: "moon", meaning: "Islam as the official religion"),
            ],
            historicalNote: nil
        ),
        "SG": FlagSymbolism(
            adoptedYear: 1959,
            colors: [
                FlagColorEntry(name: "Red", hex: "EF3340", meaning: "Universal brotherhood and equality of man"),
                FlagColorEntry(name: "White", hex: "FFFFFF", meaning: "Pervading and everlasting purity and virtue"),
            ],
            emblems: [
                FlagEmblemEntry(name: "Crescent Moon", symbol: "moon", meaning: "A young nation on the rise — Singapore was a new nation in 1959"),
                FlagEmblemEntry(name: "Five Stars", symbol: "star.fill", meaning: "Democracy, peace, progress, justice, and equality — the five ideals of Singapore"),
            ],
            historicalNote: "Singapore's flag was designed in 1959 by a government committee. The crescent was deliberately chosen to avoid association with any particular religion — Islam had already claimed the crescent, so the five stars were added to differentiate it."
        ),
        "KZ": FlagSymbolism(
            adoptedYear: 1992,
            colors: [
                FlagColorEntry(name: "Light Blue", hex: "00AFCA", meaning: "Peace, cultural unity, and the ethnic diversity of Kazakhstan"),
                FlagColorEntry(name: "Yellow", hex: "FEC50C", meaning: "Wealth and the country's grain"),
            ],
            emblems: [
                FlagEmblemEntry(name: "Golden Sun", symbol: "sun.max.fill", meaning: "Life, energy, and wealth — the sun has 32 rays shaped like grain"),
                FlagEmblemEntry(name: "Golden Eagle", symbol: "bird", meaning: "Freedom, power, and Kazakhstan's soaring spirit"),
                FlagEmblemEntry(name: "Shanyrak Pattern", symbol: "circle", meaning: "A traditional Kazakh pattern from the vertical band — based on the shanyrak, the crown of the yurt (home)"),
            ],
            historicalNote: "The blue background represents Tengrism — the Sky God worshipped by Turkic and Mongolian peoples. Kazakhstan's flag was designed by artist Shaken Niyazbekov and is considered one of the most artistically distinctive in the world."
        ),
        "UZ": FlagSymbolism(
            adoptedYear: 1991,
            colors: [
                FlagColorEntry(name: "Blue", hex: "1EB53A", meaning: "The sky and water — echoing Timur's empire banner"),
                FlagColorEntry(name: "White", hex: "FFFFFF", meaning: "Peace and purity"),
                FlagColorEntry(name: "Green", hex: "1EB53A", meaning: "Nature and renewal"),
            ],
            emblems: [
                FlagEmblemEntry(name: "Crescent", symbol: "moon", meaning: "Islam and the new moon of a new nation"),
                FlagEmblemEntry(name: "Twelve Stars", symbol: "star.fill", meaning: "The months of the year and the zodiac signs"),
            ],
            historicalNote: nil
        ),
        "MN": FlagSymbolism(
            adoptedYear: 1940,
            colors: [
                FlagColorEntry(name: "Red", hex: "C4272F", meaning: "Courage, prosperity, and the communist revolutionary legacy"),
                FlagColorEntry(name: "Blue", hex: "015197", meaning: "The eternal blue sky — the most sacred symbol in Mongolian culture"),
            ],
            emblems: [
                FlagEmblemEntry(name: "Soyombo", symbol: "flame", meaning: "A complex ideographic script character representing fire, sun, moon, earth, water, and the yin-yang"),
            ],
            historicalNote: "The Soyombo symbol was created by Buddhist monk Zanabazar in 1686 and represents the independence and sovereignty of Mongolia. Each element carries deep philosophical meaning from Buddhist and Mongolian cosmology."
        ),
        "IR": FlagSymbolism(
            adoptedYear: 1980,
            colors: [
                FlagColorEntry(name: "Green", hex: "239F40", meaning: "Growth, nature, and Islam"),
                FlagColorEntry(name: "White", hex: "FFFFFF", meaning: "Peace and honesty"),
                FlagColorEntry(name: "Red", hex: "DA0000", meaning: "Bravery, valor, and the blood of martyrs"),
            ],
            emblems: [
                FlagEmblemEntry(name: "Allah Emblem", symbol: "sparkle", meaning: "A stylized representation of 'Allah' composed of four crescents and a sword — also resembles a tulip, symbol of martyrdom"),
                FlagEmblemEntry(name: "Takbir Text", symbol: "text.quote", meaning: "'Allahu Akbar' (God is Great) written 22 times on the flag borders — marking the 22nd of Bahman (February 11), the date of the Islamic Revolution"),
            ],
            historicalNote: "After the 1979 Islamic Revolution, the lion-and-sun emblem was replaced with the Allah calligraphy. The repeating Takbir inscription was added — 11 times on each horizontal band's border — to commemorate the revolution's date."
        ),
        "IQ": FlagSymbolism(
            adoptedYear: 2008,
            colors: [
                FlagColorEntry(name: "Red", hex: "CE1126", meaning: "Courage and the blood of the Arab nation"),
                FlagColorEntry(name: "White", hex: "FFFFFF", meaning: "Tolerance and generosity"),
                FlagColorEntry(name: "Black", hex: "000000", meaning: "Oppression and the dark history Iraq has overcome"),
            ],
            emblems: [
                FlagEmblemEntry(name: "Takbir Text", symbol: "text.quote", meaning: "'Allahu Akbar' (God is Great) written in the Kufic script — added in 1991 by Saddam Hussein during the Gulf War. The current Kufic script version was standardized in 2008"),
            ],
            historicalNote: nil
        ),
        "IL": FlagSymbolism(
            adoptedYear: 1948,
            colors: [
                FlagColorEntry(name: "White", hex: "FFFFFF", meaning: "Purity, honesty, and the background of the Jewish prayer shawl (tallit)"),
                FlagColorEntry(name: "Blue", hex: "0038B8", meaning: "Heaven, the sea of Galilee, and the stripes of the Jewish tallit"),
            ],
            emblems: [
                FlagEmblemEntry(name: "Star of David", symbol: "star.of.david", meaning: "The Shield of David (Magen David) — a symbol of Judaism and Jewish identity for centuries"),
            ],
            historicalNote: "Israel's flag is based on the design of the Jewish prayer shawl (tallit), which features blue (or black) stripes on white cloth. The Star of David was formally adopted as a Zionist symbol in 1897."
        ),
        "JO": FlagSymbolism(
            adoptedYear: 1928,
            colors: [
                FlagColorEntry(name: "Black", hex: "000000", meaning: "The Abbasid Caliphate"),
                FlagColorEntry(name: "White", hex: "FFFFFF", meaning: "The Umayyad Caliphate"),
                FlagColorEntry(name: "Green", hex: "007A3D", meaning: "The Fatimid Caliphate"),
                FlagColorEntry(name: "Red", hex: "CE1126", meaning: "The Great Arab Revolt and the Hashemite dynasty"),
            ],
            emblems: [
                FlagEmblemEntry(name: "Seven-Pointed Star", symbol: "star.fill", meaning: "The seven verses of Al-Fatiha (the opening chapter of the Quran) and the unity of Arab peoples — also the seven hills of Amman"),
            ],
            historicalNote: nil
        ),
        "AE": FlagSymbolism(
            adoptedYear: 1971,
            colors: [
                FlagColorEntry(name: "Green", hex: "00732F", meaning: "Fertility and the prosperity of the land"),
                FlagColorEntry(name: "White", hex: "FFFFFF", meaning: "Peace and neutrality"),
                FlagColorEntry(name: "Black", hex: "000000", meaning: "Strength and the defeat of enemies"),
                FlagColorEntry(name: "Red", hex: "FF0000", meaning: "Courage, valor, and the blood of unity"),
            ],
            emblems: [],
            historicalNote: "The UAE's pan-Arab colors (black, white, green, red) were chosen when the seven emirates unified in 1971. Abdullah Al-Maainah designed the flag, inspired by the Arab Liberation flag."
        ),
        "QA": FlagSymbolism(
            adoptedYear: 1971,
            colors: [
                FlagColorEntry(name: "Maroon", hex: "8D1B3D", meaning: "The bloodshed in Qatar's wars and the country's natural dye from local sea creatures"),
                FlagColorEntry(name: "White", hex: "FFFFFF", meaning: "Peace"),
            ],
            emblems: [
                FlagEmblemEntry(name: "Serrated Edge", symbol: "chevron.right", meaning: "Nine white triangular points on the dividing line represent Qatar as the 9th member of the 'reconciled Emirates' after a treaty with Britain"),
            ],
            historicalNote: "Qatar's flag originally used red, but the intense sunlight of the Gulf faded it to the distinctive maroon color over time, which was then officially adopted. It is the only non-rectangular national flag besides Nepal."
        ),
        "LB": FlagSymbolism(
            adoptedYear: 1943,
            colors: [
                FlagColorEntry(name: "Red", hex: "FF0000", meaning: "The blood shed for liberation"),
                FlagColorEntry(name: "White", hex: "FFFFFF", meaning: "Purity, peace, and Lebanon's snow-capped mountains"),
            ],
            emblems: [
                FlagEmblemEntry(name: "Cedar Tree", symbol: "tree", meaning: "The Cedar of Lebanon — a symbol of holiness, eternity, and the cedar-wood trade of the ancient Phoenicians"),
            ],
            historicalNote: "The Cedar of God (Arz el-Rab in Arabic) has been a symbol of Lebanon since the time of the Phoenicians. The Bible mentions the cedars of Lebanon numerous times. The tree represents immortality, peace, and the country's cultural identity."
        ),
        "KW": FlagSymbolism(
            adoptedYear: 1961,
            colors: [
                FlagColorEntry(name: "Green", hex: "007A3D", meaning: "Fertile land and prosperity"),
                FlagColorEntry(name: "White", hex: "FFFFFF", meaning: "Peace and purity"),
                FlagColorEntry(name: "Red", hex: "CE1126", meaning: "The blood on Kuwaiti swords"),
                FlagColorEntry(name: "Black", hex: "000000", meaning: "The defeat of enemies in battle"),
            ],
            emblems: [],
            historicalNote: nil
        ),
        "OM": FlagSymbolism(
            adoptedYear: 1995,
            colors: [
                FlagColorEntry(name: "White", hex: "FFFFFF", meaning: "Peace and the Imam of Oman"),
                FlagColorEntry(name: "Red", hex: "DB161B", meaning: "Battles against foreign invaders"),
                FlagColorEntry(name: "Green", hex: "008000", meaning: "Fertility and the Jebel Akhdar mountains"),
            ],
            emblems: [
                FlagEmblemEntry(name: "Khanjar Dagger", symbol: "circle", meaning: "The national emblem: a traditional curved dagger (khanjar) crossed by two swords — symbolizing the Sultan's authority"),
            ],
            historicalNote: nil
        ),
        "AF": FlagSymbolism(
            adoptedYear: 2013,
            colors: [
                FlagColorEntry(name: "Black", hex: "000000", meaning: "The dark past of oppression"),
                FlagColorEntry(name: "Red", hex: "D32011", meaning: "The blood of those who died for the country"),
                FlagColorEntry(name: "Green", hex: "209F6F", meaning: "Hope for the future and Islam"),
            ],
            emblems: [
                FlagEmblemEntry(name: "Mosque and Pulpit", symbol: "building.columns", meaning: "A mosque with a mihrab (niche) and minbar (pulpit), representing the Islamic faith of Afghanistan"),
                FlagEmblemEntry(name: "Shahada and Date", symbol: "text.quote", meaning: "The Islamic declaration of faith above, with the Hijri year 1298 (1919 CE) — the year of Afghan independence from Britain"),
            ],
            historicalNote: "Afghanistan's flag has changed more than 20 times in the 20th century — more than any other nation. Each political change brought a new flag, from monarchy to republic to communist era to Islamic emirate to the current Islamic Republic design."
        ),

        // MARK: Africa

        "ZA": FlagSymbolism(
            adoptedYear: 1994,
            colors: [
                FlagColorEntry(name: "Black", hex: "000000", meaning: "Black South Africans and the people's struggle"),
                FlagColorEntry(name: "Green", hex: "007A4D", meaning: "Agriculture, natural resources, and the land"),
                FlagColorEntry(name: "Yellow", hex: "FFB612", meaning: "Mineral wealth — especially gold"),
                FlagColorEntry(name: "Red", hex: "DE3831", meaning: "Sacrifice and the violence of the apartheid past"),
                FlagColorEntry(name: "White", hex: "FFFFFF", meaning: "White South Africans"),
                FlagColorEntry(name: "Blue", hex: "002395", meaning: "The blue skies and possibilities of a new nation"),
            ],
            emblems: [
                FlagEmblemEntry(name: "Y-Shape / Pall", symbol: "arrow.triangle.branch", meaning: "The convergence and forward movement of diverse South African society — unity in diversity"),
            ],
            historicalNote: "South Africa's flag was designed in just one week in 1994 by State Herald Fred Brownell. It is said to be the most complex national flag in the world. The six colors represent the political parties that negotiated the end of apartheid."
        ),
        "NG": FlagSymbolism(
            adoptedYear: 1960,
            colors: [
                FlagColorEntry(name: "Green", hex: "008751", meaning: "Nigeria's vast forests, agriculture, and natural wealth"),
                FlagColorEntry(name: "White", hex: "FFFFFF", meaning: "Peace and unity between Nigeria's diverse peoples"),
            ],
            emblems: [],
            historicalNote: "Nigeria's simple green-white-green flag was designed by Michael Taiwo Akinkunmi, a student in London, who submitted it to a national competition in 1959. He reportedly forgot to include the red sun he designed in the middle, which was removed before selection."
        ),
        "EG": FlagSymbolism(
            adoptedYear: 1984,
            colors: [
                FlagColorEntry(name: "Red", hex: "CE1126", meaning: "Revolution and the blood sacrificed for Egypt's independence"),
                FlagColorEntry(name: "White", hex: "FFFFFF", meaning: "Peace"),
                FlagColorEntry(name: "Black", hex: "000000", meaning: "The end of the dark era of oppression"),
            ],
            emblems: [
                FlagEmblemEntry(name: "Eagle of Saladin", symbol: "bird", meaning: "The golden eagle of Saladin — strength and power. Saladin united Arab forces against the Crusaders"),
            ],
            historicalNote: "Egypt's flag shares the Pan-Arab colors (red, white, black) with Iraq and Syria. The Eagle of Saladin replaced the Hawk of Quraish (from the Prophet Muhammad's tribe) in 1984, referencing the unifying Arab hero who recaptured Jerusalem."
        ),
        "ET": FlagSymbolism(
            adoptedYear: 1996,
            colors: [
                FlagColorEntry(name: "Green", hex: "078930", meaning: "Hope for the future and the fertility of the land"),
                FlagColorEntry(name: "Yellow", hex: "FCDD09", meaning: "Peace and justice — the church"),
                FlagColorEntry(name: "Red", hex: "DA121A", meaning: "Sacrifice and patriotism — the blood shed for independence"),
            ],
            emblems: [
                FlagEmblemEntry(name: "Blue Circle", symbol: "circle", meaning: "Peace"),
                FlagEmblemEntry(name: "Yellow Pentagram", symbol: "star.fill", meaning: "The unity and equality of the nationalities and peoples of Ethiopia"),
                FlagEmblemEntry(name: "Rays", symbol: "sun.max", meaning: "The bright future of Ethiopia"),
            ],
            historicalNote: "Ethiopia's green, yellow, and red colors (the Pan-African colors) were adopted by many African nations after independence as a symbol of unity. Ethiopia, never colonized, is considered the 'father' of African independence movements."
        ),
        "KE": FlagSymbolism(
            adoptedYear: 1963,
            colors: [
                FlagColorEntry(name: "Black", hex: "006600", meaning: "The African people and their heritage"),
                FlagColorEntry(name: "Red", hex: "BB0000", meaning: "The blood shed in the struggle for independence"),
                FlagColorEntry(name: "Green", hex: "006600", meaning: "Agriculture and natural resources"),
                FlagColorEntry(name: "White", hex: "FFFFFF", meaning: "Peace and unity"),
            ],
            emblems: [
                FlagEmblemEntry(name: "Maasai Warrior Shield", symbol: "shield.fill", meaning: "Defense of the freedom won — the traditional Maasai shield"),
                FlagEmblemEntry(name: "Two Crossed Spears", symbol: "arrow.left.arrow.right", meaning: "The unity in defending freedom"),
            ],
            historicalNote: "Kenya's flag is based on the flag of the Kenya African National Union (KANU), which led the independence movement. The Maasai shield and spears represent Kenya's cultural heritage and readiness to defend its sovereignty."
        ),
        "GH": FlagSymbolism(
            adoptedYear: 1957,
            colors: [
                FlagColorEntry(name: "Red", hex: "CF0921", meaning: "The blood of those who died for independence"),
                FlagColorEntry(name: "Gold", hex: "FCD116", meaning: "Ghana's mineral wealth — particularly gold"),
                FlagColorEntry(name: "Green", hex: "078930", meaning: "The forests and agriculture"),
            ],
            emblems: [
                FlagEmblemEntry(name: "Black Star", symbol: "star.fill", meaning: "The 'Star of Africa' — African freedom and unity. It was Kwame Nkrumah's symbol for pan-African liberation"),
            ],
            historicalNote: "Ghana became the first sub-Saharan African country to gain independence in 1957. The black star was taken from the flag of Marcus Garvey's Black Star Line shipping company, which symbolized the return of African diaspora to their homeland."
        ),
        "TZ": FlagSymbolism(
            adoptedYear: 1964,
            colors: [
                FlagColorEntry(name: "Green", hex: "1EB53A", meaning: "The vegetation and the land of Tanzania"),
                FlagColorEntry(name: "Yellow", hex: "FCD116", meaning: "Mineral wealth"),
                FlagColorEntry(name: "Black", hex: "000000", meaning: "The Swahili-speaking people of Tanzania"),
                FlagColorEntry(name: "Blue", hex: "00A3DD", meaning: "The Indian Ocean, lakes, and rivers"),
            ],
            emblems: [],
            historicalNote: "Tanzania's flag was formed by combining the flags of Tanganyika (green-black-green) and Zanzibar (blue-black-green) when they merged in 1964. The diagonal band represents the union."
        ),
        "MA": FlagSymbolism(
            adoptedYear: 1915,
            colors: [
                FlagColorEntry(name: "Red", hex: "C1272D", meaning: "Hardiness, valor, strength, and bravery"),
                FlagColorEntry(name: "Green", hex: "006233", meaning: "Islam and peace"),
            ],
            emblems: [
                FlagEmblemEntry(name: "Pentagram (Seal of Solomon)", symbol: "star.of.david", meaning: "The five pillars of Islam and wisdom — Solomon's seal, an ancient symbol used in Morocco for centuries"),
            ],
            historicalNote: "The red background has been used by Moroccan royalty since the 17th century. The green interlaced pentagram was added in 1915 by Sultan Moulay Youssef to distinguish Morocco's merchant vessels from others."
        ),
        "DZ": FlagSymbolism(
            adoptedYear: 1962,
            colors: [
                FlagColorEntry(name: "Green", hex: "006233", meaning: "Islam and prosperity — the sacred color of the Prophet Muhammad"),
                FlagColorEntry(name: "White", hex: "FFFFFF", meaning: "Peace and purity"),
                FlagColorEntry(name: "Red", hex: "D21034", meaning: "The blood of martyrs who died for independence from France"),
            ],
            emblems: [
                FlagEmblemEntry(name: "Red Crescent", symbol: "moon", meaning: "Islam — specifically representing the Algerian Muslim identity"),
                FlagEmblemEntry(name: "Star", symbol: "star.fill", meaning: "The star of Islam and divine guidance"),
            ],
            historicalNote: "Algeria's flag was used by the National Liberation Front (FLN) during the eight-year independence war against France (1954–1962). The star and crescent were Islamic symbols used by Algerian nationalists to differentiate their cause from French colonial symbols."
        ),
        "TN": FlagSymbolism(
            adoptedYear: 1831,
            colors: [
                FlagColorEntry(name: "Red", hex: "E70013", meaning: "Martyrs' blood and the Ottoman heritage"),
                FlagColorEntry(name: "White", hex: "FFFFFF", meaning: "Peace"),
            ],
            emblems: [
                FlagEmblemEntry(name: "Red Crescent and Star", symbol: "moon", meaning: "Adopted from the Ottoman Empire, the crescent and star are Islamic symbols now deeply part of Tunisian identity"),
            ],
            historicalNote: "Tunisia's flag is one of the oldest in Africa and the Arab world. It was designed in 1827 by Husseinid Bey to distinguish Tunisian ships from the Ottoman Empire's fleet."
        ),
        "SN": FlagSymbolism(
            adoptedYear: 1960,
            colors: [
                FlagColorEntry(name: "Green", hex: "00853F", meaning: "Islam and the hope of Senegal's people"),
                FlagColorEntry(name: "Yellow", hex: "FDEF42", meaning: "Natural wealth and the wealth of the soil"),
                FlagColorEntry(name: "Red", hex: "E31B23", meaning: "The blood of independence fighters"),
            ],
            emblems: [
                FlagEmblemEntry(name: "Green Star", symbol: "star.fill", meaning: "Hope and unity — a five-pointed green star representing Africa and Senegal's aspiration"),
            ],
            historicalNote: nil
        ),
        "AO": FlagSymbolism(
            adoptedYear: 1975,
            colors: [
                FlagColorEntry(name: "Red", hex: "CC0000", meaning: "The blood shed for independence"),
                FlagColorEntry(name: "Black", hex: "000000", meaning: "Africa and the African continent"),
            ],
            emblems: [
                FlagEmblemEntry(name: "Cogwheel", symbol: "gearshape", meaning: "Industrial workers"),
                FlagEmblemEntry(name: "Machete", symbol: "scissors", meaning: "Agricultural workers and armed struggle"),
                FlagEmblemEntry(name: "Star", symbol: "star.fill", meaning: "Progress and international solidarity"),
            ],
            historicalNote: "Angola's flag is based on the flag of the MPLA (People's Movement for the Liberation of Angola), the dominant independence movement and ruling party since 1975. The black, red, and socialist symbols reflect the Cuban and Soviet influence on Angola's independence."
        ),
        "ZW": FlagSymbolism(
            adoptedYear: 1980,
            colors: [
                FlagColorEntry(name: "Green", hex: "006400", meaning: "Agriculture and rural areas"),
                FlagColorEntry(name: "Yellow", hex: "FFD200", meaning: "Mineral wealth"),
                FlagColorEntry(name: "Red", hex: "D21034", meaning: "The blood shed during the liberation struggle"),
                FlagColorEntry(name: "Black", hex: "000000", meaning: "The black majority of Zimbabwe"),
            ],
            emblems: [
                FlagEmblemEntry(name: "Zimbabwe Bird", symbol: "bird", meaning: "A carved soapstone bird from the ruins of Great Zimbabwe — a 900-year-old city and national symbol"),
                FlagEmblemEntry(name: "Red Star", symbol: "star.fill", meaning: "Zimbabwe's aspirations and the nation's socialist origins"),
                FlagEmblemEntry(name: "White Triangle", symbol: "triangle", meaning: "Peace"),
            ],
            historicalNote: "The Zimbabwe Bird soapstone sculptures were found in the ruins of Great Zimbabwe, a medieval city built between the 11th and 15th centuries. They were removed by colonial settlers and became a powerful symbol of reclaimed African heritage."
        ),
        "ZM": FlagSymbolism(
            adoptedYear: 1996,
            colors: [
                FlagColorEntry(name: "Green", hex: "198A00", meaning: "The natural resources of Zambia"),
                FlagColorEntry(name: "Red", hex: "EF0000", meaning: "The blood of freedom fighters"),
                FlagColorEntry(name: "Black", hex: "000000", meaning: "The Zambian people"),
                FlagColorEntry(name: "Orange", hex: "FF7000", meaning: "Mineral wealth — copper"),
            ],
            emblems: [
                FlagEmblemEntry(name: "African Fish Eagle", symbol: "bird", meaning: "Zambia's national bird — representing the people's ability to rise above the nation's problems"),
            ],
            historicalNote: nil
        ),
        "RW": FlagSymbolism(
            adoptedYear: 2001,
            colors: [
                FlagColorEntry(name: "Blue", hex: "20603D", meaning: "Happiness and peace"),
                FlagColorEntry(name: "Yellow", hex: "FAD201", meaning: "Economic development"),
                FlagColorEntry(name: "Green", hex: "20603D", meaning: "Natural resources and prosperity"),
            ],
            emblems: [
                FlagEmblemEntry(name: "Sun", symbol: "sun.max.fill", meaning: "Enlightenment — replacing the 'R' on the old flag to distance Rwanda from the genocide"),
            ],
            historicalNote: "Rwanda adopted a new flag in 2001 to distance itself from the 1994 genocide. The old flag had an 'R' in the center to distinguish it from Guinea's nearly identical tricolor. The new design represents a fresh start and national unity."
        ),
        "CM": FlagSymbolism(
            adoptedYear: 1975,
            colors: [
                FlagColorEntry(name: "Green", hex: "007A5E", meaning: "The forests and the southern vegetation"),
                FlagColorEntry(name: "Red", hex: "CE1126", meaning: "Independence, unity, and the spirit of the people"),
                FlagColorEntry(name: "Yellow", hex: "FCD116", meaning: "The sun and the savanna of the north"),
            ],
            emblems: [
                FlagEmblemEntry(name: "Yellow Star", symbol: "star.fill", meaning: "Unity of the country — the single star of Cameroon"),
            ],
            historicalNote: nil
        ),
        "CI": FlagSymbolism(
            adoptedYear: 1959,
            colors: [
                FlagColorEntry(name: "Orange", hex: "F77F00", meaning: "The savanna of the north and development"),
                FlagColorEntry(name: "White", hex: "FFFFFF", meaning: "Peace and unity between the north and south"),
                FlagColorEntry(name: "Green", hex: "009A44", meaning: "The coastal forests and hope for the future"),
            ],
            emblems: [],
            historicalNote: "Côte d'Ivoire's flag is almost identical to Ireland's (just with reversed colors). The orange represents the savanna in the north, while the green represents the forest in the south — united by the white of peace."
        ),
        "UG": FlagSymbolism(
            adoptedYear: 1962,
            colors: [
                FlagColorEntry(name: "Black", hex: "000000", meaning: "The African people of Uganda"),
                FlagColorEntry(name: "Yellow", hex: "FCDC04", meaning: "The abundant sunshine of Uganda"),
                FlagColorEntry(name: "Red", hex: "D90000", meaning: "African brotherhood"),
            ],
            emblems: [
                FlagEmblemEntry(name: "Grey Crowned Crane", symbol: "bird", meaning: "Uganda's national bird — known for its elegance and its connection to Uganda's wetlands"),
            ],
            historicalNote: nil
        ),
        "CD": FlagSymbolism(
            adoptedYear: 2006,
            colors: [
                FlagColorEntry(name: "Sky Blue", hex: "007FFF", meaning: "Peace"),
                FlagColorEntry(name: "Red", hex: "CE1126", meaning: "The blood of the country's martyrs"),
                FlagColorEntry(name: "Yellow", hex: "FFC400", meaning: "The country's wealth"),
            ],
            emblems: [
                FlagEmblemEntry(name: "Yellow Star", symbol: "star.fill", meaning: "The unity and hope of the Congolese people"),
            ],
            historicalNote: nil
        ),

        // MARK: Oceania

        "AU": FlagSymbolism(
            adoptedYear: 1901,
            colors: [
                FlagColorEntry(name: "Blue", hex: "00008B", meaning: "The sky and sea surrounding Australia"),
                FlagColorEntry(name: "Red", hex: "CF142B", meaning: "British heritage via the Union Jack"),
                FlagColorEntry(name: "White", hex: "FFFFFF", meaning: "Purity and the white stars of the Southern Cross"),
            ],
            emblems: [
                FlagEmblemEntry(name: "Union Jack", symbol: "star.of.david", meaning: "Australia's historical and constitutional links to the United Kingdom"),
                FlagEmblemEntry(name: "Commonwealth Star", symbol: "star.fill", meaning: "Seven points: one for each of Australia's six states, plus the seventh for the territories"),
                FlagEmblemEntry(name: "Southern Cross", symbol: "sparkles", meaning: "Australia's location in the Southern Hemisphere — these five stars are visible year-round from the entire continent"),
            ],
            historicalNote: "Australia's flag was chosen through a design competition in 1901, receiving 32,823 entries. Five similar designs were submitted and shared the prize. A competition for a new flag without the Union Jack is regularly debated in Australia."
        ),
        "NZ": FlagSymbolism(
            adoptedYear: 1902,
            colors: [
                FlagColorEntry(name: "Blue", hex: "00247D", meaning: "The Pacific Ocean surrounding New Zealand"),
                FlagColorEntry(name: "Red", hex: "CF142B", meaning: "British heritage via the Union Jack"),
                FlagColorEntry(name: "White", hex: "FFFFFF", meaning: "The stars of the Southern Cross"),
            ],
            emblems: [
                FlagEmblemEntry(name: "Union Jack", symbol: "star.of.david", meaning: "New Zealand's ties to the United Kingdom and the Commonwealth"),
                FlagEmblemEntry(name: "Southern Cross", symbol: "sparkles", meaning: "New Zealand's location in the Southern Hemisphere — four red stars with white outlines represent the Southern Cross constellation"),
            ],
            historicalNote: "New Zealand and Australia's flags are frequently confused. New Zealand held a referendum in 2015–2016 to potentially replace the flag, with 57% voting to keep the current design. New Zealand's Southern Cross uses only four stars (Australia's uses five)."
        ),
    ]
}
