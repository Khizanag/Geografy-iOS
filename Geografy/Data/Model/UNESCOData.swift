import Foundation

enum UNESCOSiteType: String {
    case cultural = "Cultural"
    case natural = "Natural"
    case mixed = "Mixed"
}

struct UNESCOSite {
    let name: String
    let type: UNESCOSiteType
    let yearInscribed: Int
    let description: String
}

// MARK: - Data
enum UNESCOData {
    // swiftlint:disable:next function_body_length
    static let data: [String: [UNESCOSite]] = [

        // MARK: Asia
        "CN": [
            UNESCOSite(name: "The Great Wall", type: .cultural, yearInscribed: 1987, description: "Stretching over 21,000 km, it is the largest military structure ever built, constructed across centuries of Chinese history."),
            UNESCOSite(name: "Imperial Palace of the Ming and Qing Dynasties (Forbidden City)", type: .cultural, yearInscribed: 1987, description: "The world's largest palace complex, home to 24 Chinese emperors over nearly 500 years."),
            UNESCOSite(name: "Mausoleum of the First Qin Emperor (Terracotta Army)", type: .cultural, yearInscribed: 1987, description: "The burial site of China's first emperor includes over 8,000 life-sized terracotta warriors, horses, and chariots."),
            UNESCOSite(name: "Peking Man Site at Zhoukoudian", type: .cultural, yearInscribed: 1987, description: "Contains fossils of Homo erectus pekinensis dating back 250,000–500,000 years, providing critical evidence of human evolution."),
            UNESCOSite(name: "Mount Taishan", type: .mixed, yearInscribed: 1987, description: "The most revered of China's Five Sacred Mountains, a place of pilgrimage for 3,000 years with over 22 temples and hundreds of inscriptions."),
            UNESCOSite(name: "Summer Palace, Beijing", type: .cultural, yearInscribed: 1998, description: "The masterpiece of Chinese landscape garden design, centering on Kunming Lake and Longevity Hill."),
            UNESCOSite(name: "Huangshan (Yellow Mountains)", type: .mixed, yearInscribed: 1990, description: "Renowned for granite peaks, ancient pines, hot springs, and clouds — one of China's most famous scenic spots."),
            UNESCOSite(name: "Jiuzhaigou Valley", type: .natural, yearInscribed: 1992, description: "Known for its colorful lakes, multi-level waterfalls, and snow-capped peaks, home to the giant panda."),
        ],
        "JP": [
            UNESCOSite(name: "Buddhist Monuments in the Horyu-ji Area", type: .cultural, yearInscribed: 1993, description: "The oldest surviving wooden structures in the world, containing some of the finest examples of Buddhist art from the 7th century."),
            UNESCOSite(name: "Historic Monuments of Ancient Kyoto", type: .cultural, yearInscribed: 1994, description: "Seventeen historic monuments including Kinkaku-ji (the Golden Pavilion) and Ginkaku-ji, representing 1,000 years as Japan's imperial capital."),
            UNESCOSite(name: "Historic Monuments of Ancient Nara", type: .cultural, yearInscribed: 1998, description: "Includes Tōdai-ji temple with its Great Buddha (Daibutsu), one of Japan's most celebrated cultural landmarks."),
            UNESCOSite(name: "Shrines and Temples of Nikkō", type: .cultural, yearInscribed: 1999, description: "The lavishly decorated Tōshō-gū mausoleum and Rinnō-ji temple complex in the mountains north of Tokyo."),
            UNESCOSite(name: "Hiroshima Peace Memorial (Genbaku Dome)", type: .cultural, yearInscribed: 1996, description: "The skeletal ruins of the Prefectural Industrial Promotion Hall, the only structure to survive the 1945 atomic bomb explosion."),
            UNESCOSite(name: "Itsukushima Shinto Shrine", type: .cultural, yearInscribed: 1996, description: "A Shinto shrine on Miyajima Island with a famous floating torii gate — one of Japan's three most celebrated views."),
            UNESCOSite(name: "Fujisan (Mount Fuji)", type: .cultural, yearInscribed: 2013, description: "Japan's iconic 3,776-meter volcano has inspired Japanese art and poetry for centuries, attracting 300,000 climbers annually."),
        ],
        "IN": [
            UNESCOSite(name: "Taj Mahal", type: .cultural, yearInscribed: 1983, description: "The white-marble mausoleum built by Mughal Emperor Shah Jahan for his wife Mumtaz Mahal — 'a teardrop on the cheek of time.'"),
            UNESCOSite(name: "Agra Fort", type: .cultural, yearInscribed: 1983, description: "The main residence of the Mughal emperors until 1638, this red sandstone fort contains palaces, mosques, and halls."),
            UNESCOSite(name: "Ajanta Caves", type: .cultural, yearInscribed: 1983, description: "Thirty rock-cut Buddhist cave monuments containing paintings and sculptures considered masterpieces of Buddhist religious art."),
            UNESCOSite(name: "Ellora Caves", type: .cultural, yearInscribed: 1983, description: "34 caves carved between the 6th and 11th centuries AD, representing Buddhist, Hindu, and Jain art side by side."),
            UNESCOSite(name: "Qutb Minar and its Monuments", type: .cultural, yearInscribed: 1993, description: "The highest brick minaret in the world (72.5 m), built in the 12th century at the onset of Islamic rule in India."),
            UNESCOSite(name: "Kaziranga National Park", type: .natural, yearInscribed: 1985, description: "Home to two-thirds of the world's one-horned rhinoceroses, along with tigers, elephants, and wild water buffalo."),
            UNESCOSite(name: "Mahabodhi Temple Complex, Bodh Gaya", type: .cultural, yearInscribed: 2002, description: "The site where Siddhartha Gautama attained enlightenment under the Bodhi tree — one of the most sacred Buddhist sites."),
        ],
        "KH": [
            UNESCOSite(name: "Angkor", type: .cultural, yearInscribed: 1992, description: "The Khmer Empire capital (9th–15th centuries) contains the world's largest religious monument — Angkor Wat — spread over 400 km²."),
        ],
        "VN": [
            UNESCOSite(name: "Hạ Long Bay", type: .natural, yearInscribed: 1994, description: "Over 1,600 limestone islands and islets rising from emerald waters in the Gulf of Tonkin, creating a seascape of extraordinary beauty."),
            UNESCOSite(name: "Complex of Huế Monuments", type: .cultural, yearInscribed: 1993, description: "The imperial city of the Nguyễn dynasty (1802–1945) featuring the Citadel, Royal Palace, temples, and royal tombs along the Perfume River."),
            UNESCOSite(name: "Hội An Ancient Town", type: .cultural, yearInscribed: 1999, description: "An exceptionally well-preserved Southeast Asian trading port from the 2nd century BC, reflecting cultural traditions from many civilizations."),
            UNESCOSite(name: "Mỹ Sơn Sanctuary", type: .cultural, yearInscribed: 1999, description: "A remarkable collection of tower temples built by Cham kings between the 4th and 14th centuries."),
        ],
        "TH": [
            UNESCOSite(name: "Historic City of Ayutthaya", type: .cultural, yearInscribed: 1991, description: "Ruins of the Thai capital (1350–1767) that was one of the world's largest cities, with 14 km of city walls and hundreds of temples."),
            UNESCOSite(name: "Historic Town of Sukhothai and Associated Towns", type: .cultural, yearInscribed: 1991, description: "The first capital of the Thai Kingdom (13th–14th centuries), with magnificent temples and sculptures in a distinctive Thai style."),
            UNESCOSite(name: "Thungyai-Huai Kha Khaeng Wildlife Sanctuaries", type: .natural, yearInscribed: 1991, description: "One of the largest intact forest areas in mainland Southeast Asia, supporting tigers, elephants, gaur, and banteng."),
        ],
        "ID": [
            UNESCOSite(name: "Borobudur Temple Compounds", type: .cultural, yearInscribed: 1991, description: "The world's largest Buddhist temple (9th century) features 2,672 relief panels and 504 Buddha statues on a terraced pyramid."),
            UNESCOSite(name: "Prambanan Temple Compounds", type: .cultural, yearInscribed: 1991, description: "The largest Hindu temple compound in Indonesia (9th century), dedicated to the Trimurti of Brahma, Vishnu, and Shiva."),
            UNESCOSite(name: "Komodo National Park", type: .natural, yearInscribed: 1991, description: "Home to the Komodo dragon — the world's largest living lizard — and spectacular marine biodiversity."),
            UNESCOSite(name: "Sangiran Early Man Site", type: .cultural, yearInscribed: 1996, description: "One of the world's most important prehistoric sites, where over 50 Homo erectus fossils have been found."),
        ],
        "PH": [
            UNESCOSite(name: "Rice Terraces of the Philippine Cordilleras", type: .cultural, yearInscribed: 1995, description: "The 2,000-year-old Ifugao rice terraces carved into the mountains of Luzon, often called 'the eighth wonder of the world.'"),
            UNESCOSite(name: "Baroque Churches of the Philippines", type: .cultural, yearInscribed: 1993, description: "Four churches built by the Spanish in the 16th–18th centuries, representing a unique blend of European Baroque and Asian architectural styles."),
            UNESCOSite(name: "Puerto Princesa Subterranean River National Park", type: .natural, yearInscribed: 1999, description: "Features a spectacular limestone karst landscape with an underground river 8.2 km long — one of the longest in the world."),
            UNESCOSite(name: "Tubbataha Reef Marine Park", type: .natural, yearInscribed: 1993, description: "A pristine coral reef in the Sulu Sea, the marine equivalent of a rainforest with 600 fish species and 360 coral species."),
        ],
        "MY": [
            UNESCOSite(name: "Melaka and George Town", type: .cultural, yearInscribed: 2008, description: "Historic cities of the Straits of Malacca that demonstrate multi-cultural trading ports shaped by successive colonial powers."),
            UNESCOSite(name: "Kinabalu Park", type: .natural, yearInscribed: 2000, description: "Mount Kinabalu (4,095 m) in Sabah hosts one of the world's richest assemblages of plants, including 800 orchid species."),
            UNESCOSite(name: "Gunung Mulu National Park", type: .natural, yearInscribed: 2000, description: "Features the world's largest cave passage, the Sarawak Chamber, and some of the most extraordinary examples of karst topography."),
        ],
        "PK": [
            UNESCOSite(name: "Archaeological Ruins at Moenjodaro", type: .cultural, yearInscribed: 1980, description: "One of the world's earliest cities (2500 BCE), part of the Indus Valley Civilization with sophisticated urban planning."),
            UNESCOSite(name: "Fort and Shalamar Gardens in Lahore", type: .cultural, yearInscribed: 1981, description: "The Lahore Fort contains 21 monuments from the Mughal era; the Shalamar Gardens represent the height of Mughal garden design."),
            UNESCOSite(name: "Taxila", type: .cultural, yearInscribed: 1980, description: "An important city at the crossroads of three trade routes, Taxila was a center of Gandhara culture and Buddhist learning from the 5th century BCE."),
            UNESCOSite(name: "Rohtas Fort", type: .cultural, yearInscribed: 1997, description: "An outstanding example of early Muslim military architecture in South Asia, built by Sher Shah Suri in the 16th century."),
        ],
        "BD": [
            UNESCOSite(name: "Mosque City of Bagerhat", type: .cultural, yearInscribed: 1985, description: "An ancient mosque city built in the 15th century by the Muslim saint Khan Jahan Ali, containing 360 mosques and religious buildings."),
            UNESCOSite(name: "Ruins of the Buddhist Vihara at Paharpur", type: .cultural, yearInscribed: 1985, description: "The largest known Buddhist monastery south of the Himalayas (8th century), which influenced Buddhist architecture across Asia."),
            UNESCOSite(name: "The Sundarbans", type: .natural, yearInscribed: 1997, description: "The world's largest mangrove forest at the mouth of the Ganges, home to the iconic Bengal tiger and Irrawaddy dolphin."),
        ],
        "NP": [
            UNESCOSite(name: "Sagarmatha National Park", type: .natural, yearInscribed: 1979, description: "Home to Mount Everest (8,849 m), the world's highest peak, along with glaciers, deep gorges, and the Sherpa culture."),
            UNESCOSite(name: "Chitwan National Park", type: .natural, yearInscribed: 1984, description: "One of Asia's finest wildlife reserves, protecting the last populations of the one-horned rhinoceros and the Bengal tiger in Nepal."),
            UNESCOSite(name: "Kathmandu Valley", type: .cultural, yearInscribed: 1979, description: "Seven monument zones including Pashupatinath Temple, Swayambhunath (Monkey Temple), and Boudhanath stupa."),
            UNESCOSite(name: "Lumbini, the Birthplace of the Lord Buddha", type: .cultural, yearInscribed: 1997, description: "The sacred garden where Queen Mayadevi gave birth to Siddhartha Gautama (Buddha) in 623 BCE."),
        ],
        "LK": [
            UNESCOSite(name: "Ancient City of Sigiriya", type: .cultural, yearInscribed: 1982, description: "A 5th-century rock fortress and palace ruin rising 200 m from the jungle floor, with stunning frescoes and water gardens."),
            UNESCOSite(name: "Sacred City of Anuradhapura", type: .cultural, yearInscribed: 1982, description: "The ancient capital of Sri Lanka for over 1,000 years contains some of the world's oldest surviving Buddhist monuments."),
            UNESCOSite(name: "Old Town of Galle and its Fortifications", type: .cultural, yearInscribed: 1988, description: "A historic port city built by Dutch colonists in the 17th century, illustrating the interaction between European architecture and South Asian tradition."),
            UNESCOSite(name: "Sacred City of Kandy", type: .cultural, yearInscribed: 1988, description: "The last capital of the ancient kingdom, home to the Temple of the Tooth Relic — the most revered Buddhist shrine in Sri Lanka."),
        ],
        "IR": [
            UNESCOSite(name: "Persepolis", type: .cultural, yearInscribed: 1979, description: "The ceremonial capital of the Achaemenid Empire (6th–4th centuries BCE), featuring massive terrace complexes and bas-relief carvings."),
            UNESCOSite(name: "Meidan Emam (Naqsh-e Jahan Square), Esfahan", type: .cultural, yearInscribed: 1979, description: "One of the largest city squares in the world (512 × 163 m), surrounded by the Shah Mosque, Ali Qapu Palace, and bazaars."),
            UNESCOSite(name: "Pasargadae", type: .cultural, yearInscribed: 2004, description: "The first dynasty capital of the Achaemenid Empire, containing the tomb of Cyrus the Great — the founder of human rights."),
            UNESCOSite(name: "Golestan Palace", type: .cultural, yearInscribed: 2013, description: "The royal Qajar complex in Tehran (18th–19th centuries), combining Persian craftsmanship with European influences."),
        ],
        "SA": [
            UNESCOSite(name: "Al-Hijr Archaeological Site (Madâin Sâlih)", type: .cultural, yearInscribed: 2008, description: "Saudi Arabia's first UNESCO site: a Nabataean city from the 1st century BCE with 111 rock-cut monumental tombs."),
            UNESCOSite(name: "At-Turaif District in ad-Dir'iyah", type: .cultural, yearInscribed: 2010, description: "The first capital of the Saudi dynasty, founded in the 15th century in the Najd region."),
            UNESCOSite(name: "Historic Jeddah, the Gate to Makkah", type: .cultural, yearInscribed: 2014, description: "A trading port since the 7th century, featuring remarkable coral buildings and the old Jeddah Corniche."),
        ],
        "AE": [
            UNESCOSite(name: "Al Ain Oasis", type: .cultural, yearInscribed: 2011, description: "A cluster of six oases in Al Ain with traditional falaj irrigation systems that have sustained life in the desert for millennia."),
        ],
        "JO": [
            UNESCOSite(name: "Petra", type: .cultural, yearInscribed: 1985, description: "The ancient Nabataean capital carved entirely from rose-red sandstone cliffs, known as 'the Rose City.' One of the New Seven Wonders."),
            UNESCOSite(name: "Wadi Rum Protected Area", type: .mixed, yearInscribed: 2011, description: "A dramatic desert landscape of sandstone mountains and canyons with petroglyphs spanning 12,000 years of human history."),
        ],
        "LB": [
            UNESCOSite(name: "Anjar", type: .cultural, yearInscribed: 1984, description: "A unique Umayyad city from the early 8th century, providing exceptional evidence of Islamic urban planning."),
            UNESCOSite(name: "Baalbek", type: .cultural, yearInscribed: 1984, description: "Home to the best-preserved Roman temples in the world, including the massive Temple of Jupiter with 20-meter columns."),
            UNESCOSite(name: "Byblos", type: .cultural, yearInscribed: 1984, description: "One of the oldest continuously inhabited cities in the world, where the alphabet was developed and exported by Phoenician traders."),
            UNESCOSite(name: "Tyre", type: .cultural, yearInscribed: 1984, description: "The ancient Phoenician metropolis that invented purple dye, established Carthage, and first used glass in trade."),
        ],
        "UZ": [
            UNESCOSite(name: "Itchan Kala", type: .cultural, yearInscribed: 1990, description: "The walled inner town of Khiva, an ancient oasis city on the Silk Road, preserved as a living museum of Islamic architecture."),
            UNESCOSite(name: "Historic Centre of Bukhara", type: .cultural, yearInscribed: 1993, description: "A 2,500-year-old city and major center of Islamic scholarship, featuring the Ark citadel, Kalyan Minaret, and countless madrasahs."),
            UNESCOSite(name: "Samarkand – Crossroads of Cultures", type: .cultural, yearInscribed: 2001, description: "Founded in the 7th century BCE and Tamerlane's capital, featuring the Registan — perhaps the most beautiful urban ensemble in Central Asia."),
        ],
        "MN": [
            UNESCOSite(name: "Orkhon Valley Cultural Landscape", type: .cultural, yearInscribed: 2004, description: "The heartland of nomadic empires for millennia, from the first Turks to Genghis Khan, featuring the ruins of the Mongol capital Karakorum."),
        ],

        // MARK: Europe
        "IT": [
            UNESCOSite(name: "Historic Centre of Rome", type: .cultural, yearInscribed: 1980, description: "The Eternal City encompasses the Colosseum, the Roman Forum, the Pantheon, and 2,700 years of architectural history."),
            UNESCOSite(name: "Venice and its Lagoon", type: .cultural, yearInscribed: 1987, description: "Built on 118 islands separated by canals, Venice is a unique masterpiece of art, architecture, and an extraordinary relationship with the sea."),
            UNESCOSite(name: "Historic Centre of Florence", type: .cultural, yearInscribed: 1982, description: "The cradle of the Renaissance, home to the Cathedral (Duomo), Uffizi Gallery, and works of Botticelli, Michelangelo, and da Vinci."),
            UNESCOSite(name: "Archaeological Areas of Pompeii, Herculaneum, and Torre Annunziata", type: .cultural, yearInscribed: 1997, description: "Preserved by the 79 AD eruption of Vesuvius, these cities provide an unparalleled snapshot of ancient Roman life."),
            UNESCOSite(name: "Amalfi Coast", type: .cultural, yearInscribed: 1997, description: "A dramatic coastline with vertically stratified settlements, gardens, and citrus groves clinging to precipitous cliffs above the Mediterranean."),
            UNESCOSite(name: "Cinque Terre", type: .cultural, yearInscribed: 1997, description: "Five dramatic clifftop villages linked by ancient terraced vineyards, olive groves, and coastal paths along the Italian Riviera."),
        ],
        "ES": [
            UNESCOSite(name: "Alhambra, Generalife and Albayzín, Granada", type: .cultural, yearInscribed: 1984, description: "The masterpiece of Moorish architecture: the Alhambra palace complex with its intricate geometric decoration and gardens."),
            UNESCOSite(name: "Works of Antoni Gaudí", type: .cultural, yearInscribed: 1984, description: "Seven architectural works by Gaudí including the Sagrada Família, Park Güell, and Casa Milà — visionary examples of organic Art Nouveau."),
            UNESCOSite(name: "Santiago de Compostela (Old Town)", type: .cultural, yearInscribed: 1985, description: "The endpoint of the famous Camino de Santiago pilgrimage route, centered on the cathedral said to contain the tomb of St. James."),
            UNESCOSite(name: "Historic City of Toledo", type: .cultural, yearInscribed: 1986, description: "A city of three cultures — Christian, Muslim, and Jewish — that coexisted for centuries, creating remarkable architectural harmony."),
        ],
        "FR": [
            UNESCOSite(name: "Palace and Park of Versailles", type: .cultural, yearInscribed: 1979, description: "The grandest example of French classical architecture: Louis XIV's palace with 700 rooms and 800 hectares of formal gardens."),
            UNESCOSite(name: "Mont-Saint-Michel and its Bay", type: .cultural, yearInscribed: 1979, description: "A rocky tidal island crowned by a medieval monastery, connected to the mainland only by sand at low tide — one of France's most iconic landmarks."),
            UNESCOSite(name: "Chartres Cathedral", type: .cultural, yearInscribed: 1979, description: "The best-preserved medieval cathedral in France, famous for its stunning Gothic architecture and 176 stained-glass windows."),
            UNESCOSite(name: "Banks of the Seine in Paris", type: .cultural, yearInscribed: 1991, description: "From the Eiffel Tower to the Louvre, the banks of the Seine embody the history of Paris across 2,000 years."),
            UNESCOSite(name: "Prehistoric Sites and Decorated Caves of the Vézère Valley", type: .cultural, yearInscribed: 1979, description: "The world's greatest collection of prehistoric art, including the Lascaux cave paintings dating back 17,000 years."),
        ],
        "DE": [
            UNESCOSite(name: "Cologne Cathedral", type: .cultural, yearInscribed: 1996, description: "The largest Gothic cathedral in Northern Europe, under construction for over 600 years (1248–1880), dominating Cologne's skyline."),
            UNESCOSite(name: "Aachen Cathedral", type: .cultural, yearInscribed: 1978, description: "One of the first UNESCO sites, Charlemagne's Palace Chapel (792–805 AD) became the model for Carolingian architecture across Europe."),
            UNESCOSite(name: "Palaces and Parks of Potsdam and Berlin", type: .cultural, yearInscribed: 1990, description: "The crown jewel is Sanssouci Palace, Frederick the Great's rococo summer residence and private retreat."),
            UNESCOSite(name: "Town of Bamberg", type: .cultural, yearInscribed: 1993, description: "A remarkably preserved medieval town that influenced the development of art and architecture in Central Europe."),
        ],
        "GB": [
            UNESCOSite(name: "Stonehenge, Avebury and Associated Sites", type: .cultural, yearInscribed: 1986, description: "The world's most famous prehistoric megalithic monument, with massive standing stones aligned to the summer solstice."),
            UNESCOSite(name: "Tower of London", type: .cultural, yearInscribed: 1988, description: "A millennium-old fortress, palace, and prison housing the Crown Jewels — with Beefeaters guarding its traditions since 1485."),
            UNESCOSite(name: "Westminster Palace, Westminster Abbey and Saint Margaret's Church", type: .cultural, yearInscribed: 1987, description: "The Palace of Westminster (Parliament) and Westminster Abbey are two of England's most iconic monuments."),
            UNESCOSite(name: "Canterbury Cathedral, St Augustine's Abbey and St Martin's Church", type: .cultural, yearInscribed: 1988, description: "The cradle of English Christianity, where the murder of Archbishop Thomas Becket in 1170 sparked one of history's greatest pilgrimages."),
            UNESCOSite(name: "City of Bath", type: .cultural, yearInscribed: 1987, description: "Built around natural hot springs, Bath features Britain's most celebrated Roman baths and perfectly preserved Georgian architecture."),
            UNESCOSite(name: "Ironbridge Gorge", type: .cultural, yearInscribed: 1986, description: "Birthplace of the Industrial Revolution — the world's first cast-iron bridge (1779) stands over the Severn Gorge."),
        ],
        "GR": [
            UNESCOSite(name: "Acropolis, Athens", type: .cultural, yearInscribed: 1987, description: "The Parthenon and other monuments on this rocky outcrop are the supreme expression of the ancient Greek genius."),
            UNESCOSite(name: "Delphi", type: .cultural, yearInscribed: 1987, description: "The sanctuary of Apollo where the famous Oracle pronounced prophecies, considered the 'navel of the world' by ancient Greeks."),
            UNESCOSite(name: "Sanctuary of Asklepios at Epidaurus", type: .cultural, yearInscribed: 1988, description: "The birthplace of medicine, featuring the best-preserved ancient Greek theater with perfect acoustics."),
            UNESCOSite(name: "Archaeological Site of Olympia", type: .cultural, yearInscribed: 1989, description: "The sacred grove and sanctuary where the Olympic Games were held every four years for over a millennium."),
            UNESCOSite(name: "Meteora", type: .mixed, yearInscribed: 1988, description: "Byzantine monasteries perched atop extraordinary sandstone pillars rising 400 meters from the plain of Thessaly."),
        ],
        "PL": [
            UNESCOSite(name: "Historic Centre of Kraków", type: .cultural, yearInscribed: 1978, description: "One of the first UNESCO sites, Kraków's medieval core with its magnificent market square is remarkably well-preserved."),
            UNESCOSite(name: "Wieliczka and Bochnia Royal Salt Mines", type: .cultural, yearInscribed: 1978, description: "Underground cathedral, chapels, and lakes entirely carved from salt — operated continuously for 700 years."),
            UNESCOSite(name: "Auschwitz Birkenau — German Nazi Concentration and Extermination Camp", type: .cultural, yearInscribed: 1979, description: "A monument to the murder of over 1.1 million people, primarily Jews — the largest extermination camp of the Holocaust."),
            UNESCOSite(name: "Białowieża Forest", type: .natural, yearInscribed: 1979, description: "The last primeval forest of Europe, home to the European bison (żubr), the continent's heaviest land animal."),
        ],
        "CZ": [
            UNESCOSite(name: "Historic Centre of Prague", type: .cultural, yearInscribed: 1992, description: "One of the best-preserved medieval capitals in Europe, with the Charles Bridge, Hradčany Castle, and Old Town Square."),
            UNESCOSite(name: "Historic Centre of Český Krumlov", type: .cultural, yearInscribed: 1992, description: "A Bohemian town frozen in time, with a magnificent castle winding along the Vltava River."),
            UNESCOSite(name: "Kutná Hora: Historical Town Centre with the Church of Saint Barbara", type: .cultural, yearInscribed: 1995, description: "A silver-mining city that was once one of Europe's wealthiest, featuring the Ossuary (Bone Church) decorated with human bones."),
        ],
        "HU": [
            UNESCOSite(name: "Budapest, with the Banks of the Danube", type: .cultural, yearInscribed: 1987, description: "The twin cities of Buda (Buda Castle) and Pest (Parliament Building) frame the Danube in a spectacular urban ensemble."),
            UNESCOSite(name: "Hollókő Old Village and its Surroundings", type: .cultural, yearInscribed: 1987, description: "A preserved example of traditional rural life in the Cserhát hills, with a 13th-century castle and folk architecture."),
            UNESCOSite(name: "Hortobágy National Park — the Puszta", type: .cultural, yearInscribed: 1999, description: "Europe's largest semi-arid steppe with ancient pastoral traditions still practiced by Hungarian csikós cowboys."),
        ],
        "UA": [
            UNESCOSite(name: "Saint-Sophia Cathedral and Related Monastic Buildings, Kyiv", type: .cultural, yearInscribed: 1990, description: "Founded in the 11th century by Yaroslav the Wise, the cathedral contains original Byzantine mosaics and frescoes."),
            UNESCOSite(name: "Kyiv-Pechersk Lavra (Monastery of the Caves)", type: .cultural, yearInscribed: 1990, description: "A network of underground tunnels and catacombs beneath the monastery hold the mummified remains of monks and saints."),
        ],
        "NO": [
            UNESCOSite(name: "Bryggen (The Wharf) in Bergen", type: .cultural, yearInscribed: 1979, description: "Colorful wooden Hanseatic League buildings from the 14th–16th centuries — once a major trading center for dried fish."),
            UNESCOSite(name: "Urnes Stave Church", type: .cultural, yearInscribed: 1979, description: "The oldest stave church in Norway (12th century), featuring intricate Viking carved ornamentation."),
            UNESCOSite(name: "Rock Art of Alta", type: .cultural, yearInscribed: 1985, description: "Over 6,000 carvings of animals, boats, and humans carved into rock 2,000–7,000 years ago, painted red-ochre on a fjord."),
            UNESCOSite(name: "West Norwegian Fjords — Geirangerfjord and Nærøyfjord", type: .natural, yearInscribed: 2005, description: "The most spectacular fjords in the world, with vertical cliff walls rising 1,400 m from the water."),
        ],
        "SE": [
            UNESCOSite(name: "Royal Domain of Drottningholm", type: .cultural, yearInscribed: 1991, description: "The private residence of the Swedish royal family, with a 17th-century palace and perfectly preserved Baroque theater."),
            UNESCOSite(name: "Birka and Hovgården", type: .cultural, yearInscribed: 1993, description: "The 8th–10th century Viking trading center on Lake Mälaren — Sweden's first town and a crossroads of trade routes."),
            UNESCOSite(name: "Decorated Farmhouses of Hälsingland", type: .cultural, yearInscribed: 2012, description: "Seven 19th-century timber farmhouses with painted rooms, representing the peak of traditional Swedish folk art."),
        ],
        "FI": [
            UNESCOSite(name: "Fortress of Suomenlinna", type: .cultural, yearInscribed: 1991, description: "An 18th-century sea fortress built on six islands protecting Helsinki harbour — today a residential area with 800 inhabitants."),
            UNESCOSite(name: "Old Rauma", type: .cultural, yearInscribed: 1991, description: "One of the oldest and best-preserved wooden towns in Scandinavia, with 600 buildings from the 18th and 19th centuries."),
            UNESCOSite(name: "Petäjävesi Old Church", type: .cultural, yearInscribed: 1994, description: "A Lutheran log church from 1763, a masterpiece of Finnish carpenter craftsmanship combining Gothic and Renaissance elements."),
        ],
        "DK": [
            UNESCOSite(name: "Jelling Mounds, Runic Stones and Church", type: .cultural, yearInscribed: 1994, description: "A 10th-century Viking complex considered 'Denmark's birth certificate' — where King Harald Bluetooth converted Denmark to Christianity."),
            UNESCOSite(name: "Roskilde Cathedral", type: .cultural, yearInscribed: 1995, description: "The first Gothic cathedral in Scandinavia and burial site of 39 Danish kings and queens since 1559."),
            UNESCOSite(name: "Kronborg Castle", type: .cultural, yearInscribed: 2000, description: "The castle that inspired Elsinore in Shakespeare's Hamlet, guarding the narrow strait between Denmark and Sweden."),
        ],
        "NL": [
            UNESCOSite(name: "Mill Network at Kinderdijk-Elshout", type: .cultural, yearInscribed: 1997, description: "The world's largest concentration of windmills (19) — built in the 18th century to manage water levels in the Dutch polders."),
            UNESCOSite(name: "Schokland and Surroundings", type: .cultural, yearInscribed: 1995, description: "An ancient island reclaimed from the sea, demonstrating humanity's centuries-long struggle with water management."),
            UNESCOSite(name: "Amsterdam Defence Line", type: .cultural, yearInscribed: 1996, description: "A 135-km ring of fortifications around Amsterdam (1883–1920), protecting the city using a unique system of controlled flooding."),
        ],
        "BE": [
            UNESCOSite(name: "Grand Place, Brussels", type: .cultural, yearInscribed: 1998, description: "The central market square of Brussels, surrounded by opulent Baroque guild halls — Victor Hugo called it 'the most beautiful square in the world.'"),
            UNESCOSite(name: "Belfries of Belgium and France", type: .cultural, yearInscribed: 1999, description: "56 towers (32 in Belgium) that were powerful symbols of the growing power of medieval towns."),
            UNESCOSite(name: "Plantin-Moretus Museum, Antwerp", type: .cultural, yearInscribed: 2005, description: "The best-preserved Renaissance printing house in the world, showing how the printing press transformed European civilization."),
        ],
        "CH": [
            UNESCOSite(name: "Convent of Saint Gall", type: .cultural, yearInscribed: 1983, description: "One of the finest examples of Carolingian architecture in the world, with a library housing 170,000 manuscripts dating to the 8th century."),
            UNESCOSite(name: "Jungfrau-Aletsch Protected Area", type: .natural, yearInscribed: 2001, description: "The largest glacier in the Alps (Aletsch Glacier, 23 km), with the iconic Eiger, Mönch, and Jungfrau peaks."),
            UNESCOSite(name: "Rhaetian Railway in the Albula/Bernina Landscapes", type: .cultural, yearInscribed: 2008, description: "A masterpiece of railway engineering crossing the Alps with 196 bridges and viaducts at up to 2,253 m elevation."),
        ],
        "AT": [
            UNESCOSite(name: "Palace and Gardens of Schönbrunn", type: .cultural, yearInscribed: 1996, description: "The principal summer residence of Habsburg emperors, with 1,441 rooms and magnificent Baroque gardens."),
            UNESCOSite(name: "Historic Centre of Vienna", type: .cultural, yearInscribed: 2001, description: "Vienna's Ringstrasse boulevard features world-class museums, the State Opera, Parliament, and imperial palaces."),
            UNESCOSite(name: "Hallstatt-Dachstein / Salzkammergut Cultural Landscape", type: .mixed, yearInscribed: 1997, description: "The village of Hallstatt on a Alpine lake was the center of Celtic salt mining for 3,000 years."),
        ],
        "PT": [
            UNESCOSite(name: "Central Zone of the Town of Angra do Heroísmo in the Azores", type: .cultural, yearInscribed: 1983, description: "The first European colonial town in the Atlantic (14th century), an important waystation for explorers sailing to the New World."),
            UNESCOSite(name: "Monastery of the Hieronymites and Tower of Belém", type: .cultural, yearInscribed: 1983, description: "Manueline-style monuments built to celebrate Vasco da Gama's voyage to India, at the point where the Tagus meets the Atlantic."),
            UNESCOSite(name: "Historic Centre of Sintra", type: .cultural, yearInscribed: 1995, description: "A 19th-century Romantic architectural ensemble in a mountain setting, featuring the colorful Pena Palace."),
            UNESCOSite(name: "Alto Douro Wine Region", type: .cultural, yearInscribed: 2001, description: "The oldest demarcated wine region in the world (1756), producing Port wine from terraced vineyards along the Douro River."),
        ],

        // MARK: Americas
        "US": [
            UNESCOSite(name: "Grand Canyon National Park", type: .natural, yearInscribed: 1979, description: "The Colorado River carved this 446-km gorge reaching 1.6 km deep over 5-6 million years, exposing 2 billion years of geological history."),
            UNESCOSite(name: "Yellowstone National Park", type: .natural, yearInscribed: 1978, description: "The world's first national park contains half the world's geysers, including Old Faithful, above one of Earth's largest supervolcanoes."),
            UNESCOSite(name: "Yosemite National Park", type: .natural, yearInscribed: 1984, description: "Iconic granite monoliths El Capitan and Half Dome rise above a valley carved by glaciers 10,000 years ago."),
            UNESCOSite(name: "Statue of Liberty", type: .cultural, yearInscribed: 1984, description: "France's gift to America (1886) — the copper lady at the gateway to New York Harbor has welcomed millions of immigrants."),
            UNESCOSite(name: "Everglades National Park", type: .natural, yearInscribed: 1979, description: "The largest subtropical wilderness in the US, a 'river of grass' that is the only place where alligators and crocodiles coexist."),
            UNESCOSite(name: "Monumental Earthworks of Poverty Point", type: .cultural, yearInscribed: 2014, description: "A 3,700-year-old mound complex in Louisiana built by a hunter-gatherer society with no agriculture."),
        ],
        "MX": [
            UNESCOSite(name: "Pre-Hispanic City of Teotihuacan", type: .cultural, yearInscribed: 1987, description: "The largest city in pre-Columbian Americas, featuring the Pyramid of the Sun (third-largest pyramid on Earth) and Avenue of the Dead."),
            UNESCOSite(name: "Pre-Hispanic City of Chichen-Itza", type: .cultural, yearInscribed: 1988, description: "The Mayan city where El Castillo pyramid's shadow creates a serpent effect during equinoxes — one of the New Seven Wonders."),
            UNESCOSite(name: "Pre-Hispanic City and National Park of Palenque", type: .cultural, yearInscribed: 1987, description: "The most artistically refined Maya city, with the Palace and Temple of the Inscriptions containing the tomb of King Pakal."),
            UNESCOSite(name: "Historic Centre of Oaxaca and Archaeological Zone of Monte Albán", type: .cultural, yearInscribed: 1987, description: "The first major Mesoamerican city, capital of the Zapotec civilization from 500 BCE to 700 CE."),
        ],
        "BR": [
            UNESCOSite(name: "Iguaçu National Park", type: .natural, yearInscribed: 1986, description: "The widest waterfall system in the world: 275 falls up to 82 m high and 2.7 km wide along the Brazil-Argentina border."),
            UNESCOSite(name: "Brasília", type: .cultural, yearInscribed: 1987, description: "The modernist capital built from scratch in 41 months (1956–1960), a UNESCO city for its urban planning by Costa and Niemeyer."),
            UNESCOSite(name: "Historic Town of Ouro Preto", type: .cultural, yearInscribed: 1980, description: "A former gold-rush capital of Brazil with exceptional 18th-century Baroque architecture and sculptures by Aleijadinho."),
            UNESCOSite(name: "Central Amazon Conservation Complex", type: .natural, yearInscribed: 2000, description: "The world's largest protected area of tropical rainforest, critical for global climate regulation."),
        ],
        "AR": [
            UNESCOSite(name: "Iguazú National Park", type: .natural, yearInscribed: 1984, description: "The Argentine side of the world's most spectacular waterfall system, accessible via walkways into the 'Devil's Throat.'"),
            UNESCOSite(name: "Los Glaciares National Park", type: .natural, yearInscribed: 1981, description: "Home to Perito Moreno Glacier — one of the few advancing glaciers in the world — and the jagged Fitz Roy massif."),
            UNESCOSite(name: "Jesuit Block and Estancias of Córdoba", type: .cultural, yearInscribed: 2000, description: "A 17th-century Jesuit complex including South America's oldest university, demonstrating the Jesuits' unique rural missions."),
            UNESCOSite(name: "Península Valdés", type: .natural, yearInscribed: 1999, description: "A key site for the conservation of marine mammals including southern right whales, elephant seals, and penguins."),
        ],
        "CL": [
            UNESCOSite(name: "Rapa Nui National Park (Easter Island)", type: .cultural, yearInscribed: 1995, description: "The remote Pacific island with 900 monumental stone statues (moai) carved by the Polynesian Rapa Nui people from the 10th century."),
            UNESCOSite(name: "Historic Quarter of the Seaport City of Valparaíso", type: .cultural, yearInscribed: 2003, description: "Chile's 'Jewel of the Pacific': a labyrinth of hills with colorful houses, funiculars, and street murals."),
            UNESCOSite(name: "Churches of Chiloé", type: .cultural, yearInscribed: 2000, description: "Sixteen wooden churches built by the Jesuits in the 17th–18th centuries, representing a unique mestizo tradition."),
        ],
        "PE": [
            UNESCOSite(name: "Historic Sanctuary of Machu Picchu", type: .mixed, yearInscribed: 1983, description: "The 15th-century Inca citadel perched 2,430 m above the Sacred Valley, 'discovered' by Hiram Bingham in 1911 — one of the New Seven Wonders."),
            UNESCOSite(name: "Chan Chan Archaeological Zone", type: .cultural, yearInscribed: 1986, description: "Capital of the Chimu Kingdom (9th–15th centuries), the largest pre-Columbian city in South America."),
            UNESCOSite(name: "Huascarán National Park", type: .natural, yearInscribed: 1985, description: "Home to the world's highest tropical mountain range, with 663 glaciers and rare wildlife including the spectacled bear."),
        ],
        "CO": [
            UNESCOSite(name: "Port, Fortresses and Group of Monuments, Cartagena", type: .cultural, yearInscribed: 1984, description: "The best-preserved colonial city in South America, protected by massive fortifications built by Spain to guard silver shipments."),
            UNESCOSite(name: "Los Katíos National Park", type: .natural, yearInscribed: 1994, description: "A biological corridor connecting South and North America, with extraordinary biodiversity in lowland forests and swamps."),
            UNESCOSite(name: "Coffee Cultural Landscape of Colombia", type: .cultural, yearInscribed: 2011, description: "The Colombian Eje Cafetero — a 100-year-old tradition of shade-grown coffee on steep Andean slopes, shaping culture and identity."),
        ],
        "CU": [
            UNESCOSite(name: "Old Havana and its Fortification System", type: .cultural, yearInscribed: 1982, description: "A living museum of baroque and neoclassical architecture, with the largest fortification in the Americas at El Morro castle."),
            UNESCOSite(name: "Trinidad and the Valley de los Ingenios", type: .cultural, yearInscribed: 1988, description: "A perfectly preserved colonial Spanish town with pastel houses and cobblestone streets, surrounded by sugar mill ruins."),
            UNESCOSite(name: "Viñales Valley", type: .cultural, yearInscribed: 1999, description: "Dramatic limestone mogotes (hills) rise from a fertile valley where tobacco for Cuban cigars is grown using traditional methods."),
        ],
        "DO": [
            UNESCOSite(name: "Colonial City of Santo Domingo", type: .cultural, yearInscribed: 1990, description: "The first European city in the Americas, founded in 1498 by Bartholomew Columbus, with the oldest cathedral, university, and hospital in the New World."),
        ],

        // MARK: Africa
        "EG": [
            UNESCOSite(name: "Memphis and its Necropolis – the Pyramid Fields", type: .cultural, yearInscribed: 1979, description: "The Great Pyramid of Giza — the only surviving Wonder of the Ancient World — along with the Great Sphinx and Step Pyramid."),
            UNESCOSite(name: "Nubian Monuments from Abu Simbel to Philae", type: .cultural, yearInscribed: 1979, description: "Ramesses II's twin temples, relocated block-by-block in the 1960s to save them from the rising waters of Lake Nasser."),
            UNESCOSite(name: "Islamic Cairo", type: .cultural, yearInscribed: 1979, description: "One of the world's oldest Islamic cities, with 600 mosques, madrasahs, mausoleums, and fountains from the 7th century onward."),
            UNESCOSite(name: "Ancient Thebes with its Necropolis", type: .cultural, yearInscribed: 1979, description: "The Valley of the Kings — burial ground of pharaohs including Tutankhamun — and the Karnak temple complex."),
        ],
        "MA": [
            UNESCOSite(name: "Medina of Fez", type: .cultural, yearInscribed: 1981, description: "The world's largest intact medieval city, with 9,000 alleys and no cars — founded in 789 CE, home to the world's oldest university."),
            UNESCOSite(name: "Medina of Marrakesh", type: .cultural, yearInscribed: 1985, description: "A living medieval city centered on the Djemaa el-Fna square — one of the world's great public spaces."),
            UNESCOSite(name: "Ksar of Aït-Ben-Haddou", type: .cultural, yearInscribed: 1987, description: "A spectacular earthen fortified village (ksar) on the former caravan route, used as backdrop for dozens of films."),
            UNESCOSite(name: "Archaeological Site of Volubilis", type: .cultural, yearInscribed: 1997, description: "The best-preserved Roman ruins in Morocco, featuring remarkable floor mosaics from the 3rd century AD."),
        ],
        "TN": [
            UNESCOSite(name: "Medina of Tunis", type: .cultural, yearInscribed: 1979, description: "One of the finest medinas in the Arab-Muslim world, with 700 historic buildings and the Ez-Zitouna Mosque as its heart."),
            UNESCOSite(name: "Archaeological Site of Carthage", type: .cultural, yearInscribed: 1979, description: "The ancient Phoenician and Roman city defeated by Rome in the Punic Wars — its founding myths include the story of Queen Dido."),
            UNESCOSite(name: "Amphitheatre of El Jem", type: .cultural, yearInscribed: 1979, description: "The third-largest Roman amphitheater in the world (35,000 capacity), better preserved than the Colosseum in Rome."),
        ],
        "ET": [
            UNESCOSite(name: "Rock-Hewn Churches, Lalibela", type: .cultural, yearInscribed: 1978, description: "Eleven monolithic 12th-century churches carved underground from a single rock — considered 'the eighth wonder of the world' and a living pilgrimage site."),
            UNESCOSite(name: "Aksum", type: .cultural, yearInscribed: 1980, description: "Ancient obelisks (stelae) mark the tombs of the Aksumite kingdom (1st–13th centuries AD) — one of the great civilizations of antiquity."),
            UNESCOSite(name: "Fasil Ghebbi, Gondar Region", type: .cultural, yearInscribed: 1979, description: "The 17th-century royal enclosure of Gondar contains six castles, earning Ethiopia the nickname 'Camelot of Africa.'"),
            UNESCOSite(name: "Simien National Park", type: .natural, yearInscribed: 1978, description: "A dramatic highland plateau with cliffs dropping 1,500 m, home to the gelada baboon and the endangered Ethiopian wolf."),
        ],
        "KE": [
            UNESCOSite(name: "Lake Turkana National Parks", type: .natural, yearInscribed: 1997, description: "The world's largest desert lake and oldest lake in East Africa, a cradle of human evolution with Homo habilis fossils."),
            UNESCOSite(name: "Mount Kenya National Park / Natural Forest", type: .natural, yearInscribed: 1997, description: "Africa's second-highest peak (5,199 m) is a major water tower of eastern Africa, with unique afro-alpine flora."),
            UNESCOSite(name: "Lamu Old Town", type: .cultural, yearInscribed: 2001, description: "The oldest and best-preserved Swahili settlement in East Africa, built without mortar — surviving buildings date to the 14th century."),
            UNESCOSite(name: "Sacred Mijikenda Kaya Forests", type: .cultural, yearInscribed: 2008, description: "11 forest sites that contain the remains of villages of the Mijikenda people, sacred centers of cultural and spiritual life."),
        ],
        "TZ": [
            UNESCOSite(name: "Ngorongoro Conservation Area", type: .mixed, yearInscribed: 1979, description: "The world's largest intact volcanic caldera hosts the greatest density of large mammals on Earth: lions, elephants, and black rhinos."),
            UNESCOSite(name: "Serengeti National Park", type: .natural, yearInscribed: 1981, description: "Home to the greatest wildlife spectacle on Earth — the annual wildebeest migration of 1.5 million animals."),
            UNESCOSite(name: "Ruins of Kilwa Kisiwani and Ruins of Songo Mnara", type: .cultural, yearInscribed: 1981, description: "Remains of East African trading ports from the 9th to 19th centuries that controlled the gold trade from Zimbabwe."),
            UNESCOSite(name: "Stone Town of Zanzibar", type: .cultural, yearInscribed: 2000, description: "A Swahili, Arab, Persian, Indian, and European trading city, center of the Indian Ocean trade and the spice trade."),
        ],
        "ZA": [
            UNESCOSite(name: "Robben Island", type: .cultural, yearInscribed: 1999, description: "Where Nelson Mandela was imprisoned for 18 of his 27 years — now a symbol of the triumph of the human spirit over injustice."),
            UNESCOSite(name: "Fossil Hominid Sites of South Africa (Cradle of Humankind)", type: .cultural, yearInscribed: 1999, description: "The Sterkfontein and surrounding caves have yielded more than a third of all early hominid fossils ever found."),
            UNESCOSite(name: "Greater St Lucia Wetland Park (iSimangaliso)", type: .natural, yearInscribed: 1999, description: "Africa's largest estuarine system, where hippos and crocodiles coexist with humpback whale breeding grounds offshore."),
            UNESCOSite(name: "Cape Floral Region Protected Areas", type: .natural, yearInscribed: 2004, description: "One of the world's six floral kingdoms, with 9,600 plant species in an area smaller than Portugal."),
        ],
        "NG": [
            UNESCOSite(name: "Osun-Osogbo Sacred Grove", type: .cultural, yearInscribed: 2005, description: "The last sacred forest in Yorubaland, with shrines, sculptures, and the Oshun river goddess — a living tradition of supernatural beliefs."),
            UNESCOSite(name: "Sukur Cultural Landscape", type: .cultural, yearInscribed: 1999, description: "A remarkable cultural landscape with a palace, terraced fields, and ironworking traditions in the Mandara Mountains."),
        ],
        "GH": [
            UNESCOSite(name: "Forts and Castles, Volta, Greater Accra, Central and Western Regions", type: .cultural, yearInscribed: 1979, description: "A chain of European-built forts along Ghana's coast that were used as dungeons for millions of enslaved Africans."),
            UNESCOSite(name: "Asante Traditional Buildings", type: .cultural, yearInscribed: 1980, description: "The remaining sacred buildings of the Asante people — formerly the richest kingdom in West Africa."),
        ],
        "ML": [
            UNESCOSite(name: "Old Towns of Djenné", type: .cultural, yearInscribed: 1988, description: "The Great Mosque of Djenné — the largest mud-brick building in the world — rebuilt annually by the entire community."),
            UNESCOSite(name: "Timbuktu", type: .cultural, yearInscribed: 1988, description: "Once 'the city of gold,' Timbuktu was a center of Islamic learning with 180 Quranic schools and 25,000 students in the 15th century."),
        ],
        "SN": [
            UNESCOSite(name: "Island of Gorée", type: .cultural, yearInscribed: 1978, description: "The small island off Dakar was the largest slave-trading center on the African coast — a sobering memorial to the transatlantic trade."),
            UNESCOSite(name: "Bassari Country: Bassari, Fula and Bedik Cultural Landscapes", type: .cultural, yearInscribed: 2012, description: "Inhabited for over 1,000 years by the Bassari people, preserving rice cultivation and cultural traditions unchanged for centuries."),
        ],
        "LY": [
            UNESCOSite(name: "Archaeological Site of Leptis Magna", type: .cultural, yearInscribed: 1982, description: "The best-preserved Roman city in the world, birthplace of Emperor Septimius Severus — with a 25,000-seat theater and magnificent Arch of Septimius."),
            UNESCOSite(name: "Archaeological Site of Cyrene", type: .cultural, yearInscribed: 1982, description: "The ancient Greek city founded in 631 BCE features a sanctuary of Apollo and the Temple of Zeus, larger than the Parthenon."),
            UNESCOSite(name: "Rock-Art Sites of Tadrart Acacus", type: .cultural, yearInscribed: 1985, description: "Thousands of cave paintings spanning 12,000 years in the Sahara Desert, depicting wildlife that disappeared as the desert expanded."),
        ],
        "ZW": [
            UNESCOSite(name: "Mosi-oa-Tunya / Victoria Falls", type: .natural, yearInscribed: 1989, description: "The world's largest curtain of falling water: 1,708 m wide and 108 m tall — called 'the smoke that thunders' in Kololo."),
            UNESCOSite(name: "Great Zimbabwe National Monument", type: .cultural, yearInscribed: 1986, description: "The ruins of a medieval stone city (11th–15th centuries), capital of the Kingdom of Zimbabwe — the largest ancient structure south of the Sahara."),
            UNESCOSite(name: "Khami Ruins National Monument", type: .cultural, yearInscribed: 1986, description: "The capital of the Torwa dynasty (1450–1683), built using a distinctive terrace and platform construction technique."),
        ],

        // MARK: Oceania
        "AU": [
            UNESCOSite(name: "Great Barrier Reef", type: .natural, yearInscribed: 1981, description: "The world's largest coral reef system (2,300 km), visible from space — home to 1,500 species of fish and 4,000 types of mollusk."),
            UNESCOSite(name: "Sydney Opera House", type: .cultural, yearInscribed: 2007, description: "Jørn Utzon's 1973 masterpiece with its distinctive sail-shaped shells is one of the 20th century's greatest architectural works."),
            UNESCOSite(name: "Kakadu National Park", type: .mixed, yearInscribed: 1981, description: "Contains the world's largest collection of Aboriginal rock art, some over 20,000 years old, alongside diverse billabong ecosystems."),
            UNESCOSite(name: "Uluru-Kata Tjuta National Park", type: .mixed, yearInscribed: 1987, description: "The sacred red monolith Uluru (Ayers Rock) and the domed rocks of Kata Tjuta are the spiritual heart of the Anangu people."),
        ],
        "NZ": [
            UNESCOSite(name: "Te Wahipounamu – South West New Zealand", type: .natural, yearInscribed: 1990, description: "A vast wilderness of fjords, glaciers, and mountains — the last landmass to be settled by humans (Māori in 1200 AD)."),
            UNESCOSite(name: "Tongariro National Park", type: .mixed, yearInscribed: 1990, description: "New Zealand's oldest national park, with active volcanoes sacred to the Māori — Mount Ngauruhoe doubled as Mount Doom in Lord of the Rings."),
            UNESCOSite(name: "New Zealand Sub-Antarctic Islands", type: .natural, yearInscribed: 1998, description: "Five remote island groups representing some of the Earth's most diverse and abundant concentration of seabirds and penguins."),
        ],

        // MARK: Russia
        "RU": [
            UNESCOSite(name: "Historic Centre of Saint Petersburg and Related Groups of Monuments", type: .cultural, yearInscribed: 1990, description: "Peter the Great's window to Europe, with the Hermitage, Winter Palace, Peterhof fountains, and 18th-century architectural masterpieces."),
            UNESCOSite(name: "Moscow Kremlin and Red Square", type: .cultural, yearInscribed: 1990, description: "The Kremlin's cathedrals and palaces sit beside Red Square's St. Basil's Cathedral — the symbol of Russia's power and history."),
            UNESCOSite(name: "Lake Baikal", type: .natural, yearInscribed: 1996, description: "The world's deepest lake (1,642 m), containing 20% of all unfrozen fresh water on Earth — with 3,700 unique plant and animal species."),
            UNESCOSite(name: "Volcanoes of Kamchatka", type: .natural, yearInscribed: 1996, description: "The most outstanding example of active volcanism in the world: 29 active volcanoes and the world's greatest concentration of geysers."),
            UNESCOSite(name: "Golden Mountains of Altai", type: .natural, yearInscribed: 1998, description: "The source of major Siberian rivers, with mountain steppe, taiga, and glaciers supporting snow leopards and Altai argali sheep."),
        ],

        // MARK: Turkey
        "TR": [
            UNESCOSite(name: "Historic Areas of Istanbul", type: .cultural, yearInscribed: 1985, description: "The Hagia Sophia, Topkapi Palace, and the Blue Mosque at the crossroads of Europe and Asia — 2,600 years of layered civilizations."),
            UNESCOSite(name: "Göreme National Park and the Rock Sites of Cappadocia", type: .mixed, yearInscribed: 1985, description: "A surreal volcanic landscape with fairy chimneys, underground cities housing up to 20,000 people, and rock-cut churches with Byzantine frescoes."),
            UNESCOSite(name: "Troy", type: .cultural, yearInscribed: 1998, description: "Nine distinct layers of the legendary city of the Trojan War, first excavated by Heinrich Schliemann in 1870."),
            UNESCOSite(name: "Hierapolis-Pamukkale", type: .mixed, yearInscribed: 1988, description: "Sparkling white terraces of calcium carbonate (travertine) formed by thermal springs, alongside a Greco-Roman spa city."),
        ],
    ]
}
