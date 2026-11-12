/// Culture facts merged from the former Culture Explorer and Deep Dive data, keyed by country code.
// swiftlint:disable:next type_body_length
enum CountryCulture {
    static let data: [String: CountryCultureEntry] = firstHalf.merging(secondHalf) { first, _ in first }

    private static let firstHalf: [String: CountryCultureEntry] = [
        "AR": CountryCultureEntry(
            cuisine: "Asado",
            music: "Tango / Folklore",
            dance: "Tango",
            instrument: "Bandoneón",
            festivals: "Buenos Aires Tango Festival",
            nationalHoliday: "Revolution Day (May 25)",
            traditionalDress: "Gaucho outfit",
            sport: "Football",
            greeting: "Hola",
            famousFor: "Tango, Football, Patagonia, Steak, Iguazu Falls",
            funFact: "Argentina has more psychologists per capita than any other country in the world."
        ),
        "AU": CountryCultureEntry(
            cuisine: "Vegemite on Toast, Meat Pie, Lamingtons, Barramundi",
            music: "Birthplace of AC/DC, INXS, and Kylie Minogue; didgeridoo is the world's oldest wind "
                + "instrument.",
            dance: "Aboriginal ceremonial dances",
            instrument: "Didgeridoo",
            art: "Aboriginal dot paintings represent the oldest continuous art tradition (65,000+ years).",
            festivals: "Australia Day, Vivid Sydney, Melbourne Cup, Sydney New Year's Eve",
            nationalHoliday: "Australia Day (January 26)",
            traditionalDress: "Aboriginal ochre and feathers",
            sport: "Cricket / Australian Rules Football",
            greeting: "G'day",
            famousFor: "Sydney Opera House, Kangaroos, Great Barrier Reef, Outback, Cricket",
            funFact: "Australia has the world's longest fence — the Dingo Fence — stretching 5,614 km across "
                + "southeastern Australia."
        ),
        "BR": CountryCultureEntry(
            cuisine: "Feijoada, Pão de Queijo, Açaí Bowl, Brigadeiro",
            music: "Birthplace of samba, bossa nova, and forró; heavily influenced global music.",
            dance: "Samba",
            instrument: "Berimbau",
            art: "Oscar Niemeyer's modernist architecture; vibrant street art scene in São Paulo.",
            festivals: "Carnival, Festa Junina, Parintins Folklore Festival, Círio de Nazaré",
            nationalHoliday: "Independence Day (September 7)",
            traditionalDress: "Bumba-meu-boi costume",
            sport: "Football",
            greeting: "Olá",
            famousFor: "Carnival, Football, Amazon Rainforest, Christ the Redeemer, Samba",
            funFact: "Brazil's Rio Carnival is the world's largest carnival, with over 2 million people on the "
                + "streets per day."
        ),
        "CA": CountryCultureEntry(
            cuisine: "Poutine, Butter Tarts, Nanaimo Bars, Tourtière",
            music: "Home to Drake, Celine Dion, Joni Mitchell, and The Weeknd.",
            dance: "Métis jigging / Square dancing",
            instrument: "Fiddle",
            art: "Group of Seven painters captured Canada's wilderness; Inuit soapstone carvings.",
            festivals: "Canada Day (July 1), Calgary Stampede, Winterlude, Toronto International Film Festival",
            nationalHoliday: "Canada Day (July 1)",
            traditionalDress: "Indigenous regalia",
            sport: "Ice Hockey",
            greeting: "Hello / Bonjour",
            famousFor: "Maple Syrup, Hockey, Niagara Falls, Politeness, Diverse Nature",
            funFact: "Canada produces 71% of the world's maple syrup, mostly from the province of Quebec."
        ),
        "CI": CountryCultureEntry(
            cuisine: "Attiéké / Fufu with okra sauce",
            music: "Zouglou / Coupé-Décalé",
            dance: "Coupé-Décalé",
            festivals: "Fête de l'Indépendance",
            traditionalDress: "Kente / Bogolanfini",
            sport: "Football",
            greeting: "Bonjour / An sô?",
            funFact: "Ivory Coast is the world's largest cocoa producer, responsible for 40% of global supply."
        ),
        "CL": CountryCultureEntry(
            cuisine: "Cazuela / Empanadas",
            music: "Cueca / Nueva Canción Chilena",
            dance: "Cueca",
            festivals: "Fiestas Patrias (September 18)",
            traditionalDress: "Huaso outfit / Manta",
            sport: "Football / Skiing",
            greeting: "Hola / ¿Cómo estái?",
            funFact: "Chile is the world's longest country at 4,300 km from north to south."
        ),
        "CM": CountryCultureEntry(
            cuisine: "Ndolé / Eru",
            music: "Bikutsi / Makossa",
            dance: "Bikutsi",
            festivals: "Ngondo Festival",
            traditionalDress: "Toghu (royal cloth)",
            sport: "Football",
            greeting: "Bonjour / Hello",
            funFact: "Cameroon is called Africa in miniature for its incredible geographic and cultural "
                + "diversity."
        ),
        "CN": CountryCultureEntry(
            cuisine: "Peking Duck, Dim Sum, Kung Pao Chicken, Mooncakes",
            music: "Traditional instruments like erhu and guzheng; rich operatic traditions (Peking Opera).",
            dance: "Dragon Dance / Ribbon Dance",
            instrument: "Erhu",
            art: "Renowned for calligraphy, silk painting, porcelain (china), and jade carving.",
            festivals: "Chinese New Year, Mid-Autumn Festival, Dragon Boat Festival, Lantern Festival",
            nationalHoliday: "National Day (October 1)",
            traditionalDress: "Hanfu / Qipao",
            sport: "Table Tennis",
            greeting: "Nǐ hǎo",
            famousFor: "Great Wall, Pandas, Tea Ceremony, Silk Road, Fireworks",
            funFact: "China invented paper, printing, gunpowder, and the compass — four innovations that changed "
                + "the world."
        ),
        "CO": CountryCultureEntry(
            cuisine: "Bandeja Paisa",
            music: "Cumbia / Vallenato",
            dance: "Cumbia / Mapalé",
            instrument: "Tiple",
            festivals: "Barranquilla Carnival",
            nationalHoliday: "Independence Day (July 20)",
            traditionalDress: "Pollera coloreada",
            sport: "Football / Cycling",
            greeting: "Hola",
            famousFor: "Coffee, Salsa Dancing, Emeralds, Biodiversity, Gabriel García Márquez",
            funFact: "Colombia is the only country in South America with both a Pacific and Caribbean coastline."
        ),
        "CU": CountryCultureEntry(
            cuisine: "Ropa Vieja / Moros y Cristianos",
            music: "Son Cubano / Salsa / Rumba",
            dance: "Salsa / Rumba / Cha-cha-cha",
            festivals: "Santiago de Cuba Carnival",
            traditionalDress: "Guayabera shirt / Rumba dress",
            sport: "Baseball / Boxing",
            greeting: "Hola / Qué bola?",
            funFact: "Cuba has the highest doctor-to-patient ratio in the world."
        ),
        "CZ": CountryCultureEntry(
            cuisine: "Svíčková / Trdelník",
            music: "Dvořák / Folk / Polka",
            dance: "Polka / Sousedská",
            festivals: "Prague Spring Music Festival",
            traditionalDress: "Kroj",
            sport: "Ice Hockey / Football",
            greeting: "Ahoj / Dobrý den",
            funFact: "The Czech Republic has the highest beer consumption per capita in the world."
        ),
        "DE": CountryCultureEntry(
            cuisine: "Bratwurst, Schnitzel, Pretzels, Black Forest Cake",
            music: "Home of Bach, Beethoven, and the world-renowned Berlin Philharmonic.",
            dance: "Schuhplattler / Waltz",
            instrument: "Tuba",
            art: "Birthplace of Bauhaus design movement; Expressionism through artists like Kirchner.",
            festivals: "Oktoberfest, Carnival (Karneval), Berlin Festival of Lights, Christmas Markets",
            nationalHoliday: "German Unity Day (October 3)",
            traditionalDress: "Dirndl / Lederhosen",
            sport: "Football",
            greeting: "Guten Tag",
            famousFor: "Beer, Oktoberfest, Automobiles, Castles, Classical Music",
            funFact: "Germany has over 1,500 different types of beer and around 1,300 breweries."
        ),
        "EG": CountryCultureEntry(
            cuisine: "Koshari, Ful Medames, Molokhia, Basbousa",
            music: "Umm Kulthum is the most famous Arab singer of all time; oud is the iconic instrument.",
            dance: "Belly Dance (Raqs Sharqi)",
            instrument: "Oud",
            art: "Ancient pharaonic art; intricate Islamic geometric patterns and calligraphy.",
            festivals: "Sham el-Nessim, Ramadan, Eid al-Fitr, Abu Simbel Sun Festival",
            nationalHoliday: "Revolution Day (July 23)",
            traditionalDress: "Galabiyya",
            sport: "Football",
            greeting: "Ahlan",
            famousFor: "Pyramids, Nile River, Pharaohs, Sphinx, Ancient Hieroglyphics",
            funFact: "Ancient Egyptians invented the 365-day calendar and were the first to use a 24-hour day."
        ),
        "ES": CountryCultureEntry(
            cuisine: "Paella, Tapas, Gazpacho, Churros con Chocolate",
            music: "Flamenco is a UNESCO Intangible Cultural Heritage; vibrant pop and reggaeton scene.",
            dance: "Flamenco / Jota",
            instrument: "Classical Guitar",
            art: "Home of Picasso, Dalí, and Gaudí's surreal architecture in Barcelona.",
            festivals: "La Tomatina, San Fermín (Running of the Bulls), Las Fallas, Semana Santa",
            nationalHoliday: "National Day of Spain (October 12)",
            traditionalDress: "Traje de Flamenca",
            sport: "Football",
            greeting: "Hola",
            famousFor: "Flamenco, Bullfighting, Tapas, Sagrada Família, Football",
            funFact: "Spain has the second oldest restaurant in the world — Sobrino de Botín, open since 1725."
        ),
        "ET": CountryCultureEntry(
            cuisine: "Injera with Wat",
            music: "Tizita / Eskista",
            dance: "Eskista",
            instrument: "Krar",
            festivals: "Timkat (Ethiopian Epiphany)",
            nationalHoliday: "Victory of Adwa Day (March 2)",
            traditionalDress: "Habesha Kemis",
            sport: "Long-distance running",
            greeting: "Selam",
            famousFor: "Coffee Origin, Ancient History, Long-Distance Runners, Lucy Fossil, Lalibela",
            funFact: "Ethiopia is the birthplace of coffee — legend says a goat herder named Kaldi first "
                + "discovered the energizing coffee bean."
        ),
        "FR": CountryCultureEntry(
            cuisine: "Croissants, Coq au Vin, Ratatouille, Crème Brûlée",
            music: "Famous for chanson, Edith Piaf, and a thriving electronic music scene (Daft Punk).",
            dance: "Can-Can",
            instrument: "Accordion",
            art: "Capital of Impressionism; home to Monet, Renoir, and the Louvre Museum.",
            festivals: "Bastille Day (July 14), Cannes Film Festival, Fête de la Musique, Nice Carnival",
            nationalHoliday: "Bastille Day (July 14)",
            traditionalDress: "Breton dress / Alsatian costume",
            sport: "Football",
            greeting: "Bonjour",
            famousFor: "Eiffel Tower, Fine Wine, Fashion, Cuisine, Art",
            funFact: "France is the most visited country in the world, receiving over 90 million tourists "
                + "annually."
        ),
        "GB": CountryCultureEntry(
            cuisine: "Fish and Chips, Sunday Roast, Shepherd's Pie, Scones with Clotted Cream",
            music: "Gave the world The Beatles, The Rolling Stones, Adele, and the British Invasion of the 1960s.",
            dance: "Morris Dancing / Highland Fling",
            instrument: "Bagpipes",
            art: "Home to the Tate Modern and National Gallery; birthplace of Turner and Banksy.",
            festivals: "Notting Hill Carnival, Guy Fawkes Night, Glastonbury Festival, Royal Ascot",
            nationalHoliday: "Guy Fawkes Night (November 5)",
            traditionalDress: "Kilt (Scotland) / Beefeater (England)",
            sport: "Football / Cricket",
            greeting: "Hello",
            famousFor: "Big Ben, Tea Culture, Football, The Beatles, The Royal Family",
            funFact: "The UK invented many of the world's most popular sports, including football, cricket, "
                + "tennis and golf."
        ),
        "GE": CountryCultureEntry(
            cuisine: "Khachapuri, Khinkali, Churchkhela, Pkhali",
            music: "UNESCO-recognized polyphonic singing dates back centuries; toastmaster (tamada) traditions.",
            art: "Medieval frescoes, goldsmith work, cloisonné enamel, and the Gelati Monastery murals.",
            festivals: "Tbilisoba, Rtveli (Grape Harvest), Alaverdoba, Independence Day (May 26)"
        ),
        "GH": CountryCultureEntry(
            cuisine: "Fufu with Groundnut Soup",
            music: "Highlife / Hiplife",
            dance: "Adowa / Kpanlogo",
            instrument: "Atenteben",
            festivals: "Homowo Harvest Festival",
            nationalHoliday: "Independence Day (March 6)",
            traditionalDress: "Kente cloth",
            sport: "Football",
            greeting: "Akwaaba",
            famousFor: "Kente Cloth, Gold, Cocoa, Peaceful Democracy, Cape Coast Castle",
            funFact: "Ghana was the first Sub-Saharan African country to gain independence and paved the way for "
                + "the African independence movement."
        ),
        "GR": CountryCultureEntry(
            cuisine: "Moussaka",
            music: "Rebetiko / Laïká",
            dance: "Sirtaki / Zeibekiko",
            instrument: "Bouzouki",
            festivals: "Apokries (Carnival)",
            nationalHoliday: "Independence Day (March 25)",
            traditionalDress: "Evzone uniform / Regional folk dress",
            sport: "Football / Sailing",
            greeting: "Yiasas",
            famousFor: "Acropolis, Greek Mythology, Mediterranean Diet, Santorini, Philosophy",
            funFact: "Greece has more archaeological museums than any other country in the world."
        ),
        "HU": CountryCultureEntry(
            cuisine: "Goulash / Lángos",
            music: "Bartók / Csárdás",
            dance: "Csárdás",
            festivals: "Budapest Spring Festival",
            traditionalDress: "Magyar embroidered folk dress",
            sport: "Football / Water Polo",
            greeting: "Szia / Jó napot",
            funFact: "Hungary invented the Rubik's Cube, the ballpoint pen, and the electric motor."
        ),
        "ID": CountryCultureEntry(
            cuisine: "Nasi Goreng",
            music: "Gamelan / Dangdut",
            dance: "Kecak / Pendet",
            instrument: "Gamelan",
            festivals: "Nyepi (Day of Silence)",
            nationalHoliday: "Independence Day (August 17)",
            traditionalDress: "Batik / Kebaya",
            sport: "Badminton",
            greeting: "Halo",
            famousFor: "Bali, Batik, Komodo Dragons, Volcanoes, Diverse Cultures",
            funFact: "Indonesia is the world's largest archipelago, consisting of over 17,000 islands spread "
                + "across the equator."
        ),
        "IL": CountryCultureEntry(
            cuisine: "Hummus",
            music: "Mizrahi / Klezmer",
            dance: "Hora",
            instrument: "Oud",
            festivals: "Purim / Passover",
            nationalHoliday: "Independence Day (May (varies))",
            traditionalDress: "Kippah / Tallit",
            sport: "Football / Basketball",
            greeting: "Shalom",
            famousFor: "Jerusalem, Dead Sea, Tech Startups, Falafel, Desert Blooms",
            funFact: "Israel has more startups per capita than any country outside the United States."
        ),
        "IN": CountryCultureEntry(
            cuisine: "Biryani, Butter Chicken, Dosa, Samosa",
            music: "Classical traditions of Hindustani and Carnatic music; Bollywood film scores.",
            dance: "Bharatanatyam",
            instrument: "Sitar",
            art: "Ancient cave paintings at Ajanta; intricate Mughal miniatures; contemporary art boom.",
            festivals: "Diwali, Holi, Navratri, Pongal",
            nationalHoliday: "Independence Day (August 15)",
            traditionalDress: "Sari",
            sport: "Cricket",
            greeting: "Namaste",
            famousFor: "Taj Mahal, Yoga, Spices, Bollywood, Cricket",
            funFact: "India is the birthplace of chess, yoga, and the decimal number system used worldwide today."
        ),
        "IR": CountryCultureEntry(
            cuisine: "Ghormeh Sabzi",
            music: "Persian classical / Dastgah",
            dance: "Persian classical dance",
            instrument: "Tar",
            festivals: "Nowruz (Persian New Year)",
            nationalHoliday: "Islamic Republic Day (April 1)",
            traditionalDress: "Chador / Shalvar",
            sport: "Football / Wrestling",
            greeting: "Salâm",
            famousFor: "Persian Poetry, Saffron, Carpets, Ancient Persia, Hospitality",
            funFact: "Iran is the world's largest producer of saffron, accounting for over 90% of global "
                + "production."
        ),
    ]
}
