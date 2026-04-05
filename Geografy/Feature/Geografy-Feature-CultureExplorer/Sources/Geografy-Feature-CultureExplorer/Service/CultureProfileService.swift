// swiftlint:disable line_length
import Foundation

// swiftlint:disable:next type_body_length
final class CultureProfileService {
    let profiles: [CultureProfile] = [
        CultureProfile(
            id: "FR",
            countryCode: "FR",
            nationalDish: "Bœuf Bourguignon",
            nationalInstrument: "Accordion",
            famousFor: ["Eiffel Tower", "Fine Wine", "Fashion", "Cuisine", "Art"],
            nationalHoliday: "Bastille Day",
            nationalHolidayDate: "July 14",
            greeting: "Bonjour",
            funCultureFact: "France is the most visited country in the world, receiving over 90 million tourists annually."
        ),
        CultureProfile(
            id: "DE",
            countryCode: "DE",
            nationalDish: "Sauerbraten",
            nationalInstrument: "Tuba",
            famousFor: ["Beer", "Oktoberfest", "Automobiles", "Castles", "Classical Music"],
            nationalHoliday: "German Unity Day",
            nationalHolidayDate: "October 3",
            greeting: "Guten Tag",
            funCultureFact: "Germany has over 1,500 different types of beer and around 1,300 breweries."
        ),
        CultureProfile(
            id: "IT",
            countryCode: "IT",
            nationalDish: "Pasta al Ragù",
            nationalInstrument: "Mandolin",
            famousFor: ["Pizza", "Colosseum", "Renaissance Art", "Fashion", "Opera"],
            nationalHoliday: "Republic Day",
            nationalHolidayDate: "June 2",
            greeting: "Buongiorno",
            funCultureFact: "Italy has more UNESCO World Heritage Sites than any other country — over 58 recognized sites."
        ),
        CultureProfile(
            id: "ES",
            countryCode: "ES",
            nationalDish: "Paella",
            nationalInstrument: "Classical Guitar",
            famousFor: ["Flamenco", "Bullfighting", "Tapas", "Sagrada Família", "Football"],
            nationalHoliday: "National Day of Spain",
            nationalHolidayDate: "October 12",
            greeting: "Hola",
            funCultureFact: "Spain has the second oldest restaurant in the world — Sobrino de Botín, open since 1725."
        ),
        CultureProfile(
            id: "GB",
            countryCode: "GB",
            nationalDish: "Chicken Tikka Masala",
            nationalInstrument: "Bagpipes",
            famousFor: ["Big Ben", "Tea Culture", "Football", "The Beatles", "The Royal Family"],
            nationalHoliday: "Guy Fawkes Night",
            nationalHolidayDate: "November 5",
            greeting: "Hello",
            funCultureFact: "The UK invented many of the world's most popular sports, including football, cricket, tennis and golf."
        ),
        CultureProfile(
            id: "US",
            countryCode: "US",
            nationalDish: "Apple Pie",
            nationalInstrument: "Banjo",
            famousFor: ["Hollywood", "Jazz", "Grand Canyon", "Space Exploration", "Fast Food"],
            nationalHoliday: "Independence Day",
            nationalHolidayDate: "July 4",
            greeting: "Hey",
            funCultureFact: "Americans consume about 100 acres of pizza every day, roughly 3 billion pizzas per year."
        ),
        CultureProfile(
            id: "JP",
            countryCode: "JP",
            nationalDish: "Sushi",
            nationalInstrument: "Koto",
            famousFor: ["Mount Fuji", "Anime", "Sushi", "Cherry Blossoms", "Technology"],
            nationalHoliday: "National Foundation Day",
            nationalHolidayDate: "February 11",
            greeting: "Konnichiwa",
            funCultureFact: "Japan has over 100 different convenience store chains and more vending machines per capita than any country."
        ),
        CultureProfile(
            id: "CN",
            countryCode: "CN",
            nationalDish: "Peking Duck",
            nationalInstrument: "Erhu",
            famousFor: ["Great Wall", "Pandas", "Tea Ceremony", "Silk Road", "Fireworks"],
            nationalHoliday: "National Day",
            nationalHolidayDate: "October 1",
            greeting: "Nǐ hǎo",
            funCultureFact: "China invented paper, printing, gunpowder, and the compass — four innovations that changed the world."
        ),
        CultureProfile(
            id: "IN",
            countryCode: "IN",
            nationalDish: "Khichdi",
            nationalInstrument: "Sitar",
            famousFor: ["Taj Mahal", "Yoga", "Spices", "Bollywood", "Cricket"],
            nationalHoliday: "Independence Day",
            nationalHolidayDate: "August 15",
            greeting: "Namaste",
            funCultureFact: "India is the birthplace of chess, yoga, and the decimal number system used worldwide today."
        ),
        CultureProfile(
            id: "BR",
            countryCode: "BR",
            nationalDish: "Feijoada",
            nationalInstrument: "Berimbau",
            famousFor: ["Carnival", "Football", "Amazon Rainforest", "Christ the Redeemer", "Samba"],
            nationalHoliday: "Independence Day",
            nationalHolidayDate: "September 7",
            greeting: "Olá",
            funCultureFact: "Brazil's Rio Carnival is the world's largest carnival, with over 2 million people on the streets per day."
        ),
        CultureProfile(
            id: "MX",
            countryCode: "MX",
            nationalDish: "Mole Poblano",
            nationalInstrument: "Guitarrón",
            famousFor: ["Tacos", "Dia de los Muertos", "Aztec Ruins", "Mariachi", "Tequila"],
            nationalHoliday: "Independence Day",
            nationalHolidayDate: "September 16",
            greeting: "Hola",
            funCultureFact: "Mexico City was built on a lake, and it still sinks by roughly 10 inches every year due to groundwater extraction."
        ),
        CultureProfile(
            id: "AU",
            countryCode: "AU",
            nationalDish: "Meat Pie",
            nationalInstrument: "Didgeridoo",
            famousFor: ["Sydney Opera House", "Kangaroos", "Great Barrier Reef", "Outback", "Cricket"],
            nationalHoliday: "Australia Day",
            nationalHolidayDate: "January 26",
            greeting: "G'day",
            funCultureFact: "Australia has the world's longest fence — the Dingo Fence — stretching 5,614 km across southeastern Australia."
        ),
        CultureProfile(
            id: "CA",
            countryCode: "CA",
            nationalDish: "Poutine",
            nationalInstrument: "Fiddle",
            famousFor: ["Maple Syrup", "Hockey", "Niagara Falls", "Politeness", "Diverse Nature"],
            nationalHoliday: "Canada Day",
            nationalHolidayDate: "July 1",
            greeting: "Hello / Bonjour",
            funCultureFact: "Canada produces 71% of the world's maple syrup, mostly from the province of Quebec."
        ),
        CultureProfile(
            id: "RU",
            countryCode: "RU",
            nationalDish: "Borscht",
            nationalInstrument: "Balalaika",
            famousFor: ["Red Square", "Ballet", "Vodka", "Trans-Siberian Railway", "Chess"],
            nationalHoliday: "Russia Day",
            nationalHolidayDate: "June 12",
            greeting: "Privet",
            funCultureFact: "Russia spans 11 time zones and is so vast it covers one-eighth of Earth's total land surface."
        ),
        CultureProfile(
            id: "KR",
            countryCode: "KR",
            nationalDish: "Kimchi",
            nationalInstrument: "Gayageum",
            famousFor: ["K-Pop", "Samsung", "Kimchi", "Taekwondo", "Korean Drama"],
            nationalHoliday: "Liberation Day",
            nationalHolidayDate: "August 15",
            greeting: "Annyeonghaseyo",
            funCultureFact: "South Korea has the fastest average internet speed in the world and over 90% smartphone penetration."
        ),
        CultureProfile(
            id: "TR",
            countryCode: "TR",
            nationalDish: "İskender Kebab",
            nationalInstrument: "Saz (Bağlama)",
            famousFor: ["Hagia Sophia", "Turkish Baths", "Tulips", "Tea Culture", "Carpets"],
            nationalHoliday: "Republic Day",
            nationalHolidayDate: "October 29",
            greeting: "Merhaba",
            funCultureFact: "Turkey is where tulips originated before being introduced to the Netherlands in the 16th century."
        ),
        CultureProfile(
            id: "EG",
            countryCode: "EG",
            nationalDish: "Koshari",
            nationalInstrument: "Oud",
            famousFor: ["Pyramids", "Nile River", "Pharaohs", "Sphinx", "Ancient Hieroglyphics"],
            nationalHoliday: "Revolution Day",
            nationalHolidayDate: "July 23",
            greeting: "Ahlan",
            funCultureFact: "Ancient Egyptians invented the 365-day calendar and were the first to use a 24-hour day."
        ),
        CultureProfile(
            id: "NG",
            countryCode: "NG",
            nationalDish: "Jollof Rice",
            nationalInstrument: "Talking Drum",
            famousFor: ["Nollywood", "Afrobeats", "Oil", "Diverse Cultures", "Football"],
            nationalHoliday: "Independence Day",
            nationalHolidayDate: "October 1",
            greeting: "Bawo ni",
            funCultureFact: "Nigeria's film industry Nollywood is the second largest in the world by volume, ahead of Hollywood."
        ),
        CultureProfile(
            id: "ZA",
            countryCode: "ZA",
            nationalDish: "Braai (Grilled Meat)",
            nationalInstrument: "Vuvuzela",
            famousFor: ["Mandela", "Safari", "Cape Town", "Diamond Mines", "Rainbow Nation"],
            nationalHoliday: "Freedom Day",
            nationalHolidayDate: "April 27",
            greeting: "Sawubona",
            funCultureFact: "South Africa is the only country in the world with three capital cities — Pretoria, Cape Town, and Bloemfontein."
        ),
        CultureProfile(
            id: "KE",
            countryCode: "KE",
            nationalDish: "Nyama Choma",
            nationalInstrument: "Nyatiti",
            famousFor: ["Maasai Warriors", "Safari", "Marathon Runners", "Great Rift Valley", "Tea"],
            nationalHoliday: "Jamhuri Day",
            nationalHolidayDate: "December 12",
            greeting: "Jambo",
            funCultureFact: "Kenya produces some of the world's finest long-distance runners and has dominated Olympic marathons for decades."
        ),
        CultureProfile(
            id: "AR",
            countryCode: "AR",
            nationalDish: "Asado",
            nationalInstrument: "Bandoneón",
            famousFor: ["Tango", "Football", "Patagonia", "Steak", "Iguazu Falls"],
            nationalHoliday: "Revolution Day",
            nationalHolidayDate: "May 25",
            greeting: "Hola",
            funCultureFact: "Argentina has more psychologists per capita than any other country in the world."
        ),
        CultureProfile(
            id: "CO",
            countryCode: "CO",
            nationalDish: "Bandeja Paisa",
            nationalInstrument: "Tiple",
            famousFor: ["Coffee", "Salsa Dancing", "Emeralds", "Biodiversity", "Gabriel García Márquez"],
            nationalHoliday: "Independence Day",
            nationalHolidayDate: "July 20",
            greeting: "Hola",
            funCultureFact: "Colombia is the only country in South America with both a Pacific and Caribbean coastline."
        ),
        CultureProfile(
            id: "TH",
            countryCode: "TH",
            nationalDish: "Pad Thai",
            nationalInstrument: "Ranat Ek",
            famousFor: ["Buddhist Temples", "Muay Thai", "Street Food", "Elephants", "Islands"],
            nationalHoliday: "King's Birthday",
            nationalHolidayDate: "July 28",
            greeting: "Sawasdee",
            funCultureFact: "Thailand is the world's largest exporter of rice and has never been colonized by a European power."
        ),
        CultureProfile(
            id: "ID",
            countryCode: "ID",
            nationalDish: "Nasi Goreng",
            nationalInstrument: "Gamelan",
            famousFor: ["Bali", "Batik", "Komodo Dragons", "Volcanoes", "Diverse Cultures"],
            nationalHoliday: "Independence Day",
            nationalHolidayDate: "August 17",
            greeting: "Halo",
            funCultureFact: "Indonesia is the world's largest archipelago, consisting of over 17,000 islands spread across the equator."
        ),
        CultureProfile(
            id: "VN",
            countryCode: "VN",
            nationalDish: "Phở",
            nationalInstrument: "Đàn Bầu",
            famousFor: ["Phở", "Hạ Long Bay", "Ao Dai", "Coffee Culture", "Motorbikes"],
            nationalHoliday: "National Day",
            nationalHolidayDate: "September 2",
            greeting: "Xin chào",
            funCultureFact: "Vietnam is the world's second-largest exporter of coffee and the largest exporter of cashew nuts."
        ),
        CultureProfile(
            id: "SA",
            countryCode: "SA",
            nationalDish: "Kabsa",
            nationalInstrument: "Oud",
            famousFor: ["Mecca", "Oil", "Desert Dunes", "Falconry", "Dates"],
            nationalHoliday: "Saudi National Day",
            nationalHolidayDate: "September 23",
            greeting: "Ahlan wa sahlan",
            funCultureFact: "Saudi Arabia sits on approximately 17% of the world's proven petroleum reserves."
        ),
        CultureProfile(
            id: "IR",
            countryCode: "IR",
            nationalDish: "Ghormeh Sabzi",
            nationalInstrument: "Tar",
            famousFor: ["Persian Poetry", "Saffron", "Carpets", "Ancient Persia", "Hospitality"],
            nationalHoliday: "Islamic Republic Day",
            nationalHolidayDate: "April 1",
            greeting: "Salâm",
            funCultureFact: "Iran is the world's largest producer of saffron, accounting for over 90% of global production."
        ),
        CultureProfile(
            id: "IL",
            countryCode: "IL",
            nationalDish: "Hummus",
            nationalInstrument: "Oud",
            famousFor: ["Jerusalem", "Dead Sea", "Tech Startups", "Falafel", "Desert Blooms"],
            nationalHoliday: "Independence Day",
            nationalHolidayDate: "May (varies)",
            greeting: "Shalom",
            funCultureFact: "Israel has more startups per capita than any country outside the United States."
        ),
        CultureProfile(
            id: "GR",
            countryCode: "GR",
            nationalDish: "Moussaka",
            nationalInstrument: "Bouzouki",
            famousFor: ["Acropolis", "Greek Mythology", "Mediterranean Diet", "Santorini", "Philosophy"],
            nationalHoliday: "Independence Day",
            nationalHolidayDate: "March 25",
            greeting: "Yiasas",
            funCultureFact: "Greece has more archaeological museums than any other country in the world."
        ),
        CultureProfile(
            id: "NL",
            countryCode: "NL",
            nationalDish: "Stamppot",
            nationalInstrument: "Carillon",
            famousFor: ["Tulips", "Windmills", "Cycling", "Van Gogh", "Cheese"],
            nationalHoliday: "King's Day",
            nationalHolidayDate: "April 27",
            greeting: "Hallo",
            funCultureFact: "The Netherlands exports more flowers than any country in the world — about 60% of all internationally traded flowers."
        ),
        CultureProfile(
            id: "SE",
            countryCode: "SE",
            nationalDish: "Köttbullar (Swedish Meatballs)",
            nationalInstrument: "Nyckelharpa",
            famousFor: ["ABBA", "IKEA", "Midnight Sun", "Vikings", "Innovation"],
            nationalHoliday: "National Day",
            nationalHolidayDate: "June 6",
            greeting: "Hej",
            funCultureFact: "Sweden invented the pacemaker, the safety match, and the zipper, among many other essential innovations."
        ),
        CultureProfile(
            id: "NO",
            countryCode: "NO",
            nationalDish: "Fårikål (Lamb and Cabbage)",
            nationalInstrument: "Hardanger Fiddle",
            famousFor: ["Northern Lights", "Fjords", "Vikings", "Salmon", "Trolls"],
            nationalHoliday: "Constitution Day",
            nationalHolidayDate: "May 17",
            greeting: "Hei",
            funCultureFact: "Norway has the world's longest road tunnel — the Lærdal Tunnel at 24.5 kilometers."
        ),
        CultureProfile(
            id: "PL",
            countryCode: "PL",
            nationalDish: "Bigos (Hunter's Stew)",
            nationalInstrument: "Violin",
            famousFor: ["Pierogi", "Chopin", "Amber", "Solidarity Movement", "Medieval Architecture"],
            nationalHoliday: "Independence Day",
            nationalHolidayDate: "November 11",
            greeting: "Cześć",
            funCultureFact: "Poland is the world's largest producer of amber and has been for centuries — Baltic amber from Poland is found across ancient trade routes."
        ),
        CultureProfile(
            id: "UA",
            countryCode: "UA",
            nationalDish: "Borscht",
            nationalInstrument: "Bandura",
            famousFor: ["Sunflowers", "Cossacks", "Wheat Fields", "Folk Art", "Orthodox Churches"],
            nationalHoliday: "Independence Day",
            nationalHolidayDate: "August 24",
            greeting: "Pryvit",
            funCultureFact: "Ukraine is the largest country entirely within Europe and is known as the breadbasket of Europe for its vast fertile plains."
        ),
        CultureProfile(
            id: "ET",
            countryCode: "ET",
            nationalDish: "Injera with Wat",
            nationalInstrument: "Krar",
            famousFor: ["Coffee Origin", "Ancient History", "Long-Distance Runners", "Lucy Fossil", "Lalibela"],
            nationalHoliday: "Victory of Adwa Day",
            nationalHolidayDate: "March 2",
            greeting: "Selam",
            funCultureFact: "Ethiopia is the birthplace of coffee — legend says a goat herder named Kaldi first discovered the energizing coffee bean."
        ),
        CultureProfile(
            id: "GH",
            countryCode: "GH",
            nationalDish: "Fufu with Groundnut Soup",
            nationalInstrument: "Atenteben",
            famousFor: ["Kente Cloth", "Gold", "Cocoa", "Peaceful Democracy", "Cape Coast Castle"],
            nationalHoliday: "Independence Day",
            nationalHolidayDate: "March 6",
            greeting: "Akwaaba",
            funCultureFact: "Ghana was the first Sub-Saharan African country to gain independence and paved the way for the African independence movement."
        ),
        CultureProfile(
            id: "MA",
            countryCode: "MA",
            nationalDish: "Tagine",
            nationalInstrument: "Guembri",
            famousFor: ["Marrakech", "Argan Oil", "Sahara Desert", "Riads", "Couscous"],
            nationalHoliday: "Throne Day",
            nationalHolidayDate: "July 30",
            greeting: "Marhaba",
            funCultureFact: "Morocco's University of Al-Qarawiyyin, founded in 859 AD, is the world's oldest continuously operating university."
        ),
        CultureProfile(
            id: "PE",
            countryCode: "PE",
            nationalDish: "Ceviche",
            nationalInstrument: "Quena",
            famousFor: ["Machu Picchu", "Incan Empire", "Llamas", "Ceviche", "Amazon River Source"],
            nationalHoliday: "Independence Day",
            nationalHolidayDate: "July 28",
            greeting: "Hola",
            funCultureFact: "Peru is the birthplace of the potato — over 3,000 varieties of potato grow in the Andean highlands."
        ),
        CultureProfile(
            id: "NZ",
            countryCode: "NZ",
            nationalDish: "Hāngī (Earth Oven Feast)",
            nationalInstrument: "Pūtōrino",
            famousFor: ["Haka", "Lord of the Rings", "Kiwi Bird", "Rugby", "Geysers"],
            nationalHoliday: "Waitangi Day",
            nationalHolidayDate: "February 6",
            greeting: "Kia ora",
            funCultureFact: "New Zealand was the first country to give women the right to vote, in 1893."
        ),
        CultureProfile(
            id: "PT",
            countryCode: "PT",
            nationalDish: "Bacalhau (Salted Cod)",
            nationalInstrument: "Portuguese Guitar",
            famousFor: ["Fado Music", "Port Wine", "Age of Exploration", "Pastel de Nata", "Sintra"],
            nationalHoliday: "Portugal Day",
            nationalHolidayDate: "June 10",
            greeting: "Olá",
            funCultureFact: "Portugal is the world's largest cork producer, supplying around 50% of global cork production."
        ),
    ]

    func profiles(matching query: String) -> [CultureProfile] {
        guard !query.isEmpty else { return profiles }
        let lowercased = query.lowercased()
        return profiles.filter { profile in
            countryName(for: profile.countryCode).lowercased().contains(lowercased)
                || profile.nationalDish.lowercased().contains(lowercased)
                || profile.famousFor.contains { $0.lowercased().contains(lowercased) }
        }
    }
}

// MARK: - Helpers
private extension CultureProfileService {
    func countryName(for code: String) -> String {
        Locale.current.localizedString(forRegionCode: code) ?? code
    }
}
