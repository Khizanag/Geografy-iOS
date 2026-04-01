import Foundation
import Geografy_Core_Common

struct CultureService {
    var facts: [CultureFact] { allFacts }

    func facts(matching query: String) -> [CultureFact] {
        guard !query.isEmpty else { return facts }
        let lowercased = query.lowercased()
        return facts.filter { fact in
            countryName(for: fact.countryCode).lowercased().contains(lowercased)
                || fact.music.lowercased().contains(lowercased)
                || fact.cuisine.lowercased().contains(lowercased)
                || fact.dance.lowercased().contains(lowercased)
        }
    }
}

// MARK: - Helpers
private extension CultureService {
    func countryName(for code: String) -> String {
        Locale.current.localizedString(forRegionCode: code) ?? code
    }
}

// MARK: - Data
private extension CultureService {
    var allFacts: [CultureFact] { [
        CultureFact(
            id: "PT", countryCode: "PT",
            music: "Fado",
            dance: "Vira",
            cuisine: "Bacalhau (Salted Cod)",
            festival: "Festas de Lisboa",
            traditionalDress: "Saia de Basqueira",
            sport: "Football",
            greeting: "Olá / Bom dia",
            funFact: "Portugal is the world's largest cork producer, supplying around 50% of global cork."
        ),
        CultureFact(
            id: "JP", countryCode: "JP",
            music: "J-Pop / Enka",
            dance: "Bon Odori",
            cuisine: "Sushi / Ramen",
            festival: "Hanami (Cherry Blossom)",
            traditionalDress: "Kimono",
            sport: "Sumo",
            greeting: "Konnichiwa",
            funFact: "Japan has more vending machines per capita than any country in the world."
        ),
        CultureFact(
            id: "BR", countryCode: "BR",
            music: "Samba / Bossa Nova",
            dance: "Samba",
            cuisine: "Feijoada",
            festival: "Rio Carnival",
            traditionalDress: "Bumba-meu-boi costume",
            sport: "Football",
            greeting: "Olá / Tudo bem?",
            funFact: "Brazil's Rio Carnival sees over 2 million people on the streets every single day."
        ),
        CultureFact(
            id: "IN", countryCode: "IN",
            music: "Bollywood / Classical",
            dance: "Bharatanatyam",
            cuisine: "Curry / Biryani",
            festival: "Diwali",
            traditionalDress: "Sari",
            sport: "Cricket",
            greeting: "Namaste",
            funFact: "India is the birthplace of chess, yoga, and the decimal number system."
        ),
        CultureFact(
            id: "MX", countryCode: "MX",
            music: "Mariachi",
            dance: "Jarabe Tapatío",
            cuisine: "Tacos / Mole",
            festival: "Día de los Muertos",
            traditionalDress: "Charro suit / China Poblana",
            sport: "Football",
            greeting: "Hola / Buenos días",
            funFact: "Mexico City was built on a lake and still sinks roughly 10 inches every year."
        ),
        CultureFact(
            id: "FR", countryCode: "FR",
            music: "Chanson française",
            dance: "Can-Can",
            cuisine: "Croissant / Baguette / Coq au Vin",
            festival: "Bastille Day",
            traditionalDress: "Breton dress / Alsatian costume",
            sport: "Football",
            greeting: "Bonjour",
            funFact: "France is the most visited country in the world, receiving over 90 million tourists annually."
        ),
        CultureFact(
            id: "EG", countryCode: "EG",
            music: "Shaabi / Arabic Maqam",
            dance: "Belly Dance (Raqs Sharqi)",
            cuisine: "Koshari / Ful Medames",
            festival: "Eid Al-Fitr / Sham El-Nessim",
            traditionalDress: "Galabiyya",
            sport: "Football",
            greeting: "Ahlan / As-salamu alaykum",
            funFact: "Ancient Egyptians invented the 365-day calendar and the 24-hour day."
        ),
        CultureFact(
            id: "ES", countryCode: "ES",
            music: "Flamenco",
            dance: "Flamenco / Jota",
            cuisine: "Paella / Tapas",
            festival: "La Tomatina / San Fermín",
            traditionalDress: "Traje de Flamenca",
            sport: "Football",
            greeting: "Hola / Buenos días",
            funFact: "Spain has the second oldest restaurant in the world — Sobrino de Botín, open since 1725."
        ),
        CultureFact(
            id: "IT", countryCode: "IT",
            music: "Opera / Canzone italiana",
            dance: "Tarantella",
            cuisine: "Pizza / Pasta",
            festival: "Venice Carnival",
            traditionalDress: "Regional folk costumes",
            sport: "Football",
            greeting: "Buongiorno / Ciao",
            funFact: "Italy has more UNESCO World Heritage Sites than any other country — over 58 recognized sites."
        ),
        CultureFact(
            id: "CN", countryCode: "CN",
            music: "Chinese Classical / Peking Opera",
            dance: "Dragon Dance / Ribbon Dance",
            cuisine: "Peking Duck / Dim Sum",
            festival: "Chinese New Year",
            traditionalDress: "Hanfu / Qipao",
            sport: "Table Tennis",
            greeting: "Nǐ hǎo",
            funFact: "China invented paper, printing, gunpowder, and the compass."
        ),
        CultureFact(
            id: "RU", countryCode: "RU",
            music: "Classical / Folk / Chanson",
            dance: "Kalinka / Cossack dance",
            cuisine: "Borscht / Pelmeni",
            festival: "Maslenitsa (Butter Week)",
            traditionalDress: "Sarafan / Kosovorotka",
            sport: "Ice Hockey / Chess",
            greeting: "Zdravstvuyte / Privet",
            funFact: "Russia spans 11 time zones and covers one-eighth of Earth's total land surface."
        ),
        CultureFact(
            id: "DE", countryCode: "DE",
            music: "Classical / Volksmusik",
            dance: "Schuhplattler / Waltz",
            cuisine: "Bratwurst / Sauerbraten",
            festival: "Oktoberfest",
            traditionalDress: "Dirndl / Lederhosen",
            sport: "Football",
            greeting: "Guten Tag / Hallo",
            funFact: "Germany has over 1,500 different types of beer and around 1,300 breweries."
        ),
        CultureFact(
            id: "GB", countryCode: "GB",
            music: "Rock / Pop / Classical",
            dance: "Morris Dancing / Highland Fling",
            cuisine: "Fish and Chips / Roast Dinner",
            festival: "Guy Fawkes Night / Edinburgh Festival",
            traditionalDress: "Kilt (Scotland) / Beefeater (England)",
            sport: "Football / Cricket",
            greeting: "Hello / How do you do?",
            funFact: "The UK invented football, cricket, tennis, and golf."
        ),
        CultureFact(
            id: "GR", countryCode: "GR",
            music: "Rebetiko / Laïká",
            dance: "Sirtaki / Zeibekiko",
            cuisine: "Moussaka / Souvlaki",
            festival: "Apokries (Carnival)",
            traditionalDress: "Evzone uniform / Regional folk dress",
            sport: "Football / Sailing",
            greeting: "Yiasas / Kalimera",
            funFact: "Greece has more archaeological museums than any other country in the world."
        ),
        CultureFact(
            id: "TR", countryCode: "TR",
            music: "Turkish Classical / Arabesk",
            dance: "Horon / Zeybek",
            cuisine: "Kebab / Baklava",
            festival: "Republic Day / Whirling Dervishes Festival",
            traditionalDress: "Shalwar / Bindallı",
            sport: "Football / Oil Wrestling",
            greeting: "Merhaba / Günaydın",
            funFact: "Tulips originated in Turkey before being introduced to the Netherlands in the 16th century."
        ),
        CultureFact(
            id: "KR", countryCode: "KR",
            music: "K-Pop / Gugak (Traditional)",
            dance: "Buchaechum (Fan Dance) / K-Pop idol dances",
            cuisine: "Kimchi / Bibimbap",
            festival: "Chuseok (Harvest Festival)",
            traditionalDress: "Hanbok",
            sport: "Taekwondo / Baseball",
            greeting: "Annyeonghaseyo",
            funFact: "South Korea has the fastest average internet speed in the world."
        ),
        CultureFact(
            id: "AU", countryCode: "AU",
            music: "Aboriginal / Rock / Country",
            dance: "Aboriginal ceremonial dances",
            cuisine: "Meat Pie / Vegemite on toast",
            festival: "Australia Day / Sydney New Year's Eve",
            traditionalDress: "Aboriginal ochre and feathers",
            sport: "Cricket / Australian Rules Football",
            greeting: "G'day / How ya going?",
            funFact: "Australia has the world's longest fence — the Dingo Fence — stretching 5,614 km."
        ),
        CultureFact(
            id: "CA", countryCode: "CA",
            music: "Country / Indigenous / Pop",
            dance: "Métis jigging / Square dancing",
            cuisine: "Poutine / Maple Syrup",
            festival: "Canada Day / Montreal Jazz Festival",
            traditionalDress: "Indigenous regalia",
            sport: "Ice Hockey",
            greeting: "Hello / Bonjour",
            funFact: "Canada produces 71% of the world's maple syrup, mostly from Quebec."
        ),
        CultureFact(
            id: "US", countryCode: "US",
            music: "Jazz / Blues / Rock / Hip-Hop",
            dance: "Line Dancing / Breakdance",
            cuisine: "BBQ / Apple Pie",
            festival: "4th of July / Mardi Gras",
            traditionalDress: "Native American regalia",
            sport: "American Football / Baseball",
            greeting: "Hey / How are you?",
            funFact: "Americans consume about 3 billion pizzas per year — roughly 100 acres of pizza every day."
        ),
        CultureFact(
            id: "AR", countryCode: "AR",
            music: "Tango / Folklore",
            dance: "Tango",
            cuisine: "Asado (BBQ) / Empanadas",
            festival: "Buenos Aires Tango Festival",
            traditionalDress: "Gaucho outfit",
            sport: "Football",
            greeting: "Hola / ¿Cómo estás?",
            funFact: "Argentina has more psychologists per capita than any other country in the world."
        ),
        CultureFact(
            id: "ZA", countryCode: "ZA",
            music: "Kwaito / Afrikaans folk / Gospel",
            dance: "Gumboot dance / Pantsula",
            cuisine: "Braai (BBQ) / Bobotie",
            festival: "Heritage Day / Jazz festivals",
            traditionalDress: "Zulu / Xhosa beaded garments",
            sport: "Rugby / Football / Cricket",
            greeting: "Sawubona / Hoe gaan dit?",
            funFact: "South Africa is the only country with three capitals — Pretoria, Cape Town, and Bloemfontein."
        ),
        CultureFact(
            id: "TH", countryCode: "TH",
            music: "Luk Thung / Mor Lam",
            dance: "Khon (Classical Masked Dance)",
            cuisine: "Pad Thai / Tom Yum",
            festival: "Songkran (Water Festival)",
            traditionalDress: "Chut Thai",
            sport: "Muay Thai",
            greeting: "Sawasdee",
            funFact: "Thailand has never been colonized by a European power in its entire history."
        ),
        CultureFact(
            id: "ID", countryCode: "ID",
            music: "Gamelan / Dangdut",
            dance: "Kecak / Pendet",
            cuisine: "Nasi Goreng / Rendang",
            festival: "Nyepi (Day of Silence)",
            traditionalDress: "Batik / Kebaya",
            sport: "Badminton",
            greeting: "Halo / Selamat pagi",
            funFact: "Indonesia is the world's largest archipelago with over 17,000 islands."
        ),
        CultureFact(
            id: "NG", countryCode: "NG",
            music: "Afrobeats / Highlife",
            dance: "Bata / Atilogwu",
            cuisine: "Jollof Rice / Egusi Soup",
            festival: "Argungu Fishing Festival",
            traditionalDress: "Agbada / Ankara",
            sport: "Football",
            greeting: "Bawo ni / How far?",
            funFact: "Nigeria's Nollywood is the second largest film industry in the world by volume."
        ),
        CultureFact(
            id: "KE", countryCode: "KE",
            music: "Benga / Gospel",
            dance: "Adumu (Maasai jumping dance)",
            cuisine: "Nyama Choma / Ugali",
            festival: "Jamhuri Day / Lamu Cultural Festival",
            traditionalDress: "Maasai shuka / Kanga",
            sport: "Long-distance running / Football",
            greeting: "Jambo / Habari",
            funFact: "Kenya has dominated Olympic long-distance running for decades."
        ),
        CultureFact(
            id: "ET", countryCode: "ET",
            music: "Tizita / Eskista",
            dance: "Eskista",
            cuisine: "Injera / Doro Wat",
            festival: "Timkat (Ethiopian Epiphany)",
            traditionalDress: "Habesha Kemis",
            sport: "Long-distance running",
            greeting: "Selam / Tena yistilign",
            funFact: "Ethiopia is the birthplace of coffee — the word coffee derives from Kaffa, a region in Ethiopia."
        ),
        CultureFact(
            id: "MA", countryCode: "MA",
            music: "Gnawa / Andalusian classical",
            dance: "Guedra / Ahouach",
            cuisine: "Tagine / Couscous",
            festival: "Mawazine Music Festival",
            traditionalDress: "Djellaba / Caftan",
            sport: "Football",
            greeting: "Marhaba / As-salam alaykum",
            funFact: "Morocco's University of Al-Qarawiyyin, founded in 859 AD, is the world's oldest university."
        ),
        CultureFact(
            id: "PE", countryCode: "PE",
            music: "Marinera / Vals Criollo",
            dance: "Marinera",
            cuisine: "Ceviche / Lomo Saltado",
            festival: "Inti Raymi (Festival of the Sun)",
            traditionalDress: "Pollera (colorful skirt)",
            sport: "Football / Surfing",
            greeting: "Hola / Buenos días",
            funFact: "Peru is the birthplace of the potato — over 3,000 varieties grow in the Andean highlands."
        ),
        CultureFact(
            id: "VN", countryCode: "VN",
            music: "Quan Họ / Cải Lương",
            dance: "Nón lá (conical hat dance)",
            cuisine: "Phở / Bánh mì",
            festival: "Tết (Lunar New Year)",
            traditionalDress: "Áo Dài",
            sport: "Football / Martial Arts",
            greeting: "Xin chào",
            funFact: "Vietnam is the world's second-largest exporter of coffee and largest exporter of cashews."
        ),
        CultureFact(
            id: "SA", countryCode: "SA",
            music: "Saudi traditional / Khaleeji",
            dance: "Ardha (sword dance)",
            cuisine: "Kabsa / Mandi",
            festival: "Saudi National Day / Eid Al-Adha",
            traditionalDress: "Thobe / Abaya",
            sport: "Football / Falconry",
            greeting: "As-salam alaykum / Ahlan",
            funFact: "Saudi Arabia sits on approximately 17% of the world's proven petroleum reserves."
        ),
        CultureFact(
            id: "IR", countryCode: "IR",
            music: "Persian classical / Dastgah",
            dance: "Persian classical dance",
            cuisine: "Ghormeh Sabzi / Chelo Kabab",
            festival: "Nowruz (Persian New Year)",
            traditionalDress: "Chador / Shalvar",
            sport: "Football / Wrestling",
            greeting: "Salâm / Dorud",
            funFact: "Iran produces over 90% of the world's saffron supply."
        ),
        CultureFact(
            id: "PL", countryCode: "PL",
            music: "Chopin / Polka / Folk",
            dance: "Mazurka / Polonaise",
            cuisine: "Pierogi / Bigos",
            festival: "Kraków Jazz Festival / Wianki",
            traditionalDress: "Krakowiak costume",
            sport: "Football / Volleyball",
            greeting: "Cześć / Dzień dobry",
            funFact: "Poland is the world's largest producer of amber, found across ancient trade routes."
        ),
        CultureFact(
            id: "NL", countryCode: "NL",
            music: "Gabber / Dutch folk",
            dance: "Klompen (clog dance)",
            cuisine: "Stroopwafel / Stamppot",
            festival: "King's Day",
            traditionalDress: "Klompen / Klederdracht",
            sport: "Football / Cycling / Speed skating",
            greeting: "Hallo / Goedendag",
            funFact: "The Netherlands exports about 60% of all internationally traded flowers."
        ),
        CultureFact(
            id: "SE", countryCode: "SE",
            music: "ABBA / Melodic Death Metal",
            dance: "Polska / Hambo",
            cuisine: "Köttbullar (meatballs) / Gravlax",
            festival: "Midsommar",
            traditionalDress: "Folkdräkt",
            sport: "Football / Ice Hockey",
            greeting: "Hej / God morgon",
            funFact: "Sweden invented the pacemaker, safety match, and zipper."
        ),
        CultureFact(
            id: "NO", countryCode: "NO",
            music: "Black Metal / Hardanger fiddle",
            dance: "Halling / Springleik",
            cuisine: "Fårikål / Lutefisk",
            festival: "Constitution Day (Syttende Mai)",
            traditionalDress: "Bunad",
            sport: "Cross-country skiing / Football",
            greeting: "Hei / God dag",
            funFact: "Norway has the world's longest road tunnel — the Lærdal Tunnel at 24.5 km."
        ),
        CultureFact(
            id: "CO", countryCode: "CO",
            music: "Cumbia / Vallenato",
            dance: "Cumbia / Mapalé",
            cuisine: "Bandeja Paisa / Arepa",
            festival: "Barranquilla Carnival",
            traditionalDress: "Pollera coloreada",
            sport: "Football / Cycling",
            greeting: "Hola / ¿Qué más?",
            funFact: "Colombia is the only country in South America with both Pacific and Caribbean coastlines."
        ),
        CultureFact(
            id: "NZ", countryCode: "NZ",
            music: "Māori waiata / Indie folk",
            dance: "Haka / Poi",
            cuisine: "Hāngī / Pavlova",
            festival: "Waitangi Day / WOMAD",
            traditionalDress: "Kākahu (Māori cloak)",
            sport: "Rugby",
            greeting: "Kia ora",
            funFact: "New Zealand was the first country to give women the right to vote, in 1893."
        ),
        CultureFact(
            id: "UA", countryCode: "UA",
            music: "Ukrainian folk / Bandura music",
            dance: "Hopak / Kolomiyka",
            cuisine: "Borscht / Varenyky",
            festival: "Ivana Kupala (Midsummer)",
            traditionalDress: "Vyshyvanka (embroidered shirt)",
            sport: "Football / Boxing",
            greeting: "Pryvit / Dobryi den",
            funFact: "Ukraine is the largest country entirely within Europe — the breadbasket of Europe."
        ),
        CultureFact(
            id: "IL", countryCode: "IL",
            music: "Mizrahi / Klezmer",
            dance: "Hora",
            cuisine: "Hummus / Falafel / Shakshuka",
            festival: "Purim / Passover",
            traditionalDress: "Kippah / Tallit",
            sport: "Football / Basketball",
            greeting: "Shalom",
            funFact: "Israel has more startups per capita than any country outside the United States."
        ),
        CultureFact(
            id: "GH", countryCode: "GH",
            music: "Highlife / Hiplife",
            dance: "Adowa / Kpanlogo",
            cuisine: "Fufu / Jollof Rice",
            festival: "Homowo Harvest Festival",
            traditionalDress: "Kente cloth",
            sport: "Football",
            greeting: "Akwaaba / Ete sen",
            funFact: "Ghana was the first Sub-Saharan African country to gain independence, in 1957."
        ),
        CultureFact(
            id: "SN", countryCode: "SN",
            music: "Mbalax / Sabar",
            dance: "Sabar",
            cuisine: "Thieboudienne (fish and rice)",
            festival: "Dakar Biennale",
            traditionalDress: "Boubou",
            sport: "Football / Wrestling",
            greeting: "Mangi dem / Salamalekum",
            funFact: "Senegal is home to the largest baobab trees on the continent, called the Tree of Life."
        ),
        CultureFact(
            id: "CL", countryCode: "CL",
            music: "Cueca / Nueva Canción Chilena",
            dance: "Cueca",
            cuisine: "Cazuela / Empanadas",
            festival: "Fiestas Patrias (September 18)",
            traditionalDress: "Huaso outfit / Manta",
            sport: "Football / Skiing",
            greeting: "Hola / ¿Cómo estái?",
            funFact: "Chile is the world's longest country at 4,300 km from north to south."
        ),
        CultureFact(
            id: "HU", countryCode: "HU",
            music: "Bartók / Csárdás",
            dance: "Csárdás",
            cuisine: "Goulash / Lángos",
            festival: "Budapest Spring Festival",
            traditionalDress: "Magyar embroidered folk dress",
            sport: "Football / Water Polo",
            greeting: "Szia / Jó napot",
            funFact: "Hungary invented the Rubik's Cube, the ballpoint pen, and the electric motor."
        ),
        CultureFact(
            id: "CZ", countryCode: "CZ",
            music: "Dvořák / Folk / Polka",
            dance: "Polka / Sousedská",
            cuisine: "Svíčková / Trdelník",
            festival: "Prague Spring Music Festival",
            traditionalDress: "Kroj",
            sport: "Ice Hockey / Football",
            greeting: "Ahoj / Dobrý den",
            funFact: "The Czech Republic has the highest beer consumption per capita in the world."
        ),
        CultureFact(
            id: "CM", countryCode: "CM",
            music: "Bikutsi / Makossa",
            dance: "Bikutsi",
            cuisine: "Ndolé / Eru",
            festival: "Ngondo Festival",
            traditionalDress: "Toghu (royal cloth)",
            sport: "Football",
            greeting: "Bonjour / Hello",
            funFact: "Cameroon is called Africa in miniature for its incredible geographic and cultural diversity."
        ),
        CultureFact(
            id: "CI", countryCode: "CI",
            music: "Zouglou / Coupé-Décalé",
            dance: "Coupé-Décalé",
            cuisine: "Attiéké / Fufu with okra sauce",
            festival: "Fête de l'Indépendance",
            traditionalDress: "Kente / Bogolanfini",
            sport: "Football",
            greeting: "Bonjour / An sô?",
            funFact: "Ivory Coast is the world's largest cocoa producer, responsible for 40% of global supply."
        ),
        CultureFact(
            id: "CU", countryCode: "CU",
            music: "Son Cubano / Salsa / Rumba",
            dance: "Salsa / Rumba / Cha-cha-cha",
            cuisine: "Ropa Vieja / Moros y Cristianos",
            festival: "Santiago de Cuba Carnival",
            traditionalDress: "Guayabera shirt / Rumba dress",
            sport: "Baseball / Boxing",
            greeting: "Hola / Qué bola?",
            funFact: "Cuba has the highest doctor-to-patient ratio in the world."
        ),
        CultureFact(
            id: "MM", countryCode: "MM",
            music: "Anyein / Classical Burmese",
            dance: "Yama Zatdaw",
            cuisine: "Mohinga (fish noodle soup)",
            festival: "Thingyan Water Festival",
            traditionalDress: "Longyi (sarong)",
            sport: "Chinlone (rattan ball sport)",
            greeting: "Mingalaba",
            funFact: "Myanmar's Shwedagon Pagoda is over 2,500 years old and coated in gold worth billions."
        ),
        CultureFact(
            id: "PH", countryCode: "PH",
            music: "Kundiman / OPM (Original Pilipino Music)",
            dance: "Tinikling (bamboo dance)",
            cuisine: "Adobo / Sinigang",
            festival: "Sinulog Festival",
            traditionalDress: "Barong Tagalog / Baro't Saya",
            sport: "Basketball / Boxing",
            greeting: "Kumusta / Magandang araw",
            funFact: "The Philippines is the world's largest archipelago of islands with 7,641 islands."
        ),
        CultureFact(
            id: "SD", countryCode: "SD",
            music: "Halqatum / Sudanese folk",
            dance: "Nuba dance",
            cuisine: "Ful medames / Kisra",
            festival: "Eid celebrations / Nile Festival",
            traditionalDress: "Thobe (women) / Jallabiya (men)",
            sport: "Football",
            greeting: "Ahlan / As-salam alaykum",
            funFact: "Sudan has more ancient pyramids than Egypt — over 200 of them still standing in the desert."
        ),
    ] }
}
