import Foundation

let independenceEvents: [IndependenceEvent] = [
    // Pre-1800
    IndependenceEvent(
        id: "US", countryCode: "US", countryName: "United States",
        year: 1776, independenceFrom: "United Kingdom",
        description: "Declared independence on July 4, 1776 after the American Revolutionary War."
    ),
    IndependenceEvent(
        id: "HT", countryCode: "HT", countryName: "Haiti",
        year: 1804, independenceFrom: "France",
        description: "Became the first Black republic after a successful slave revolution."
    ),
    // 1800s Latin American wave
    IndependenceEvent(
        id: "CO", countryCode: "CO", countryName: "Colombia",
        year: 1810, independenceFrom: "Spain",
        description: "Declared independence during the Napoleonic Wars disrupting Spanish colonial authority."
    ),
    IndependenceEvent(
        id: "VE", countryCode: "VE", countryName: "Venezuela",
        year: 1811, independenceFrom: "Spain",
        description: "One of the first South American nations to declare independence from Spain."
    ),
    IndependenceEvent(
        id: "PY", countryCode: "PY", countryName: "Paraguay",
        year: 1811, independenceFrom: "Spain",
        description: "Gained independence through a largely peaceful transition of power."
    ),
    IndependenceEvent(
        id: "AR", countryCode: "AR", countryName: "Argentina",
        year: 1816, independenceFrom: "Spain",
        description: "Declared independence at the Congress of Tucumán after years of revolution."
    ),
    IndependenceEvent(
        id: "CL", countryCode: "CL", countryName: "Chile",
        year: 1818, independenceFrom: "Spain",
        description: "Won independence led by Bernardo O'Higgins after the Battle of Chacabuco."
    ),
    IndependenceEvent(
        id: "MX", countryCode: "MX", countryName: "Mexico",
        year: 1821, independenceFrom: "Spain",
        description: "Achieved independence after an 11-year war of independence."
    ),
    IndependenceEvent(
        id: "PE", countryCode: "PE", countryName: "Peru",
        year: 1821, independenceFrom: "Spain",
        description: "Independence proclaimed by José de San Martín after liberation campaigns."
    ),
    IndependenceEvent(
        id: "GT", countryCode: "GT", countryName: "Guatemala",
        year: 1821, independenceFrom: "Spain",
        description: "Gained independence as part of the Central American independence movement."
    ),
    IndependenceEvent(
        id: "EC", countryCode: "EC", countryName: "Ecuador",
        year: 1822, independenceFrom: "Spain",
        description: "Became independent after the Battle of Pichincha led by Antonio José de Sucre."
    ),
    IndependenceEvent(
        id: "BR", countryCode: "BR", countryName: "Brazil",
        year: 1822, independenceFrom: "Portugal",
        description: "Declared independence by Prince Pedro I, becoming a constitutional monarchy."
    ),
    IndependenceEvent(
        id: "BO", countryCode: "BO", countryName: "Bolivia",
        year: 1825, independenceFrom: "Spain",
        description: "Named after Simón Bolívar who led the liberation of much of South America."
    ),
    IndependenceEvent(
        id: "UY", countryCode: "UY", countryName: "Uruguay",
        year: 1828, independenceFrom: "Brazil",
        description: "Gained independence as a buffer state between Argentina and Brazil."
    ),
    IndependenceEvent(
        id: "GR", countryCode: "GR", countryName: "Greece",
        year: 1821, independenceFrom: "Ottoman Empire",
        description: "Launched the Greek War of Independence, recognized internationally in 1830."
    ),
    IndependenceEvent(
        id: "BE", countryCode: "BE", countryName: "Belgium",
        year: 1830, independenceFrom: "Netherlands",
        description: "Separated from the United Kingdom of the Netherlands after the Belgian Revolution."
    ),
    IndependenceEvent(
        id: "LR", countryCode: "LR", countryName: "Liberia",
        year: 1847, independenceFrom: "American Colonization Society",
        description: "Founded by freed American slaves, becoming Africa's first republic."
    ),
    IndependenceEvent(
        id: "DO", countryCode: "DO", countryName: "Dominican Republic",
        year: 1844, independenceFrom: "Haiti",
        description: "Won independence from Haitian rule after a successful revolution."
    ),
    // Early 1900s
    IndependenceEvent(
        id: "AU", countryCode: "AU", countryName: "Australia",
        year: 1901, independenceFrom: "United Kingdom",
        description: "Six colonies federated to form the Commonwealth of Australia."
    ),
    IndependenceEvent(
        id: "NZ", countryCode: "NZ", countryName: "New Zealand",
        year: 1907, independenceFrom: "United Kingdom",
        description: "Became a self-governing dominion of the British Empire."
    ),
    IndependenceEvent(
        id: "ZA", countryCode: "ZA", countryName: "South Africa",
        year: 1910, independenceFrom: "United Kingdom",
        description: "Formed the Union of South Africa from four British colonies."
    ),
    // Post-WWI
    IndependenceEvent(
        id: "FI", countryCode: "FI", countryName: "Finland",
        year: 1917, independenceFrom: "Russia",
        description: "Declared independence during the Russian Revolution and subsequent civil war."
    ),
    IndependenceEvent(
        id: "PL", countryCode: "PL", countryName: "Poland",
        year: 1918, independenceFrom: "Germany/Russia/Austria",
        description: "Restored as an independent state after 123 years of partition."
    ),
    IndependenceEvent(
        id: "HU", countryCode: "HU", countryName: "Hungary",
        year: 1918, independenceFrom: "Austria-Hungary",
        description: "Became an independent republic after the dissolution of Austria-Hungary."
    ),
    IndependenceEvent(
        id: "CZ", countryCode: "CZ", countryName: "Czechia",
        year: 1918, independenceFrom: "Austria-Hungary",
        description: "Formed Czechoslovakia with Slovakia after WWI ended the Habsburg Empire."
    ),
    IndependenceEvent(
        id: "EE", countryCode: "EE", countryName: "Estonia",
        year: 1918, independenceFrom: "Russia",
        description: "Declared independence during the chaos of the Russian Revolution."
    ),
    IndependenceEvent(
        id: "LV", countryCode: "LV", countryName: "Latvia",
        year: 1918, independenceFrom: "Russia",
        description: "Proclaimed independence and fought a war of independence against Soviet forces."
    ),
    IndependenceEvent(
        id: "LT", countryCode: "LT", countryName: "Lithuania",
        year: 1918, independenceFrom: "Russia",
        description: "Restored statehood lost centuries earlier during the Russian Empire era."
    ),
    IndependenceEvent(
        id: "IE", countryCode: "IE", countryName: "Ireland",
        year: 1922, independenceFrom: "United Kingdom",
        description: "Established the Irish Free State after the Anglo-Irish War."
    ),
    IndependenceEvent(
        id: "EG", countryCode: "EG", countryName: "Egypt",
        year: 1922, independenceFrom: "United Kingdom",
        description: "Britain recognized Egyptian sovereignty, ending the British Protectorate."
    ),
    IndependenceEvent(
        id: "TR", countryCode: "TR", countryName: "Türkiye",
        year: 1923, independenceFrom: "Allied Powers",
        description: "Established the Republic of Turkey after the Turkish War of Independence."
    ),
    IndependenceEvent(
        id: "IQ", countryCode: "IQ", countryName: "Iraq",
        year: 1932, independenceFrom: "United Kingdom",
        description: "Gained full independence as the Kingdom of Iraq, ending the British Mandate."
    ),
    // Post-WWII
    IndependenceEvent(
        id: "SY", countryCode: "SY", countryName: "Syria",
        year: 1946, independenceFrom: "France",
        description: "French troops withdrew following international pressure after WWII."
    ),
    IndependenceEvent(
        id: "PH", countryCode: "PH", countryName: "Philippines",
        year: 1946, independenceFrom: "United States",
        description: "Granted independence as promised before WWII interrupted the transition."
    ),
    IndependenceEvent(
        id: "IN", countryCode: "IN", countryName: "India",
        year: 1947, independenceFrom: "United Kingdom",
        description: "Ended nearly 200 years of British rule through a non-violent independence movement."
    ),
    IndependenceEvent(
        id: "PK", countryCode: "PK", countryName: "Pakistan",
        year: 1947, independenceFrom: "United Kingdom",
        description: "Created as a separate Muslim-majority nation during the partition of British India."
    ),
    IndependenceEvent(
        id: "MM", countryCode: "MM", countryName: "Myanmar",
        year: 1948, independenceFrom: "United Kingdom",
        description: "Achieved independence as Burma after decades of British colonial rule."
    ),
    IndependenceEvent(
        id: "IL", countryCode: "IL", countryName: "Israel",
        year: 1948, independenceFrom: "United Kingdom",
        description: "Declared independence as the British Mandate of Palestine expired."
    ),
    IndependenceEvent(
        id: "ID", countryCode: "ID", countryName: "Indonesia",
        year: 1945, independenceFrom: "Netherlands",
        description: "Proclaimed independence immediately after Japan's WWII surrender."
    ),
    IndependenceEvent(
        id: "VN", countryCode: "VN", countryName: "Vietnam",
        year: 1945, independenceFrom: "France",
        description: "Ho Chi Minh declared the Democratic Republic of Vietnam after Japan's defeat."
    ),
    IndependenceEvent(
        id: "KR", countryCode: "KR", countryName: "South Korea",
        year: 1948, independenceFrom: "Japan/USA occupation",
        description: "Established the Republic of Korea after the end of Japanese colonial rule."
    ),
    // 1950s-60s African wave
    IndependenceEvent(
        id: "LY", countryCode: "LY", countryName: "Libya",
        year: 1951, independenceFrom: "Italy/United Kingdom",
        description: "Became the first African country to gain independence through the UN."
    ),
    IndependenceEvent(
        id: "MA", countryCode: "MA", countryName: "Morocco",
        year: 1956, independenceFrom: "France",
        description: "Ended 44 years of French protectorate after a nationalist independence movement."
    ),
    IndependenceEvent(
        id: "TN", countryCode: "TN", countryName: "Tunisia",
        year: 1956, independenceFrom: "France",
        description: "Negotiated independence peacefully from France through nationalist pressure."
    ),
    IndependenceEvent(
        id: "GH", countryCode: "GH", countryName: "Ghana",
        year: 1957, independenceFrom: "United Kingdom",
        description: "First sub-Saharan African country to gain independence, led by Kwame Nkrumah."
    ),
    IndependenceEvent(
        id: "GN", countryCode: "GN", countryName: "Guinea",
        year: 1958, independenceFrom: "France",
        description: "Voted overwhelmingly for full independence in a French referendum."
    ),
    IndependenceEvent(
        id: "CM", countryCode: "CM", countryName: "Cameroon",
        year: 1960, independenceFrom: "France",
        description: "Became independent as part of the Year of Africa when 17 nations gained freedom."
    ),
    IndependenceEvent(
        id: "SN", countryCode: "SN", countryName: "Senegal",
        year: 1960, independenceFrom: "France",
        description: "Gained independence as part of the mass decolonization of French West Africa."
    ),
    IndependenceEvent(
        id: "NG", countryCode: "NG", countryName: "Nigeria",
        year: 1960, independenceFrom: "United Kingdom",
        description: "Became independent as Africa's most populous nation through peaceful negotiation."
    ),
    IndependenceEvent(
        id: "CI", countryCode: "CI", countryName: "Côte d'Ivoire",
        year: 1960, independenceFrom: "France",
        description: "Gained independence peacefully under Félix Houphouët-Boigny's leadership."
    ),
    IndependenceEvent(
        id: "CD", countryCode: "CD", countryName: "DR Congo",
        year: 1960, independenceFrom: "Belgium",
        description: "Gained independence rapidly after a surge in nationalist movements."
    ),
    IndependenceEvent(
        id: "SL", countryCode: "SL", countryName: "Sierra Leone",
        year: 1961, independenceFrom: "United Kingdom",
        description: "Peacefully achieved independence with the help of Milton Margai."
    ),
    IndependenceEvent(
        id: "TZ", countryCode: "TZ", countryName: "Tanzania",
        year: 1961, independenceFrom: "United Kingdom",
        description: "Tanganyika gained independence, later merging with Zanzibar to form Tanzania."
    ),
    IndependenceEvent(
        id: "DZ", countryCode: "DZ", countryName: "Algeria",
        year: 1962, independenceFrom: "France",
        description: "Won independence after a brutal 8-year war costing over 1 million lives."
    ),
    IndependenceEvent(
        id: "UG", countryCode: "UG", countryName: "Uganda",
        year: 1962, independenceFrom: "United Kingdom",
        description: "Gained independence after peaceful negotiations with Britain."
    ),
    IndependenceEvent(
        id: "KE", countryCode: "KE", countryName: "Kenya",
        year: 1963, independenceFrom: "United Kingdom",
        description: "Achieved independence after the Mau Mau uprising weakened British resolve."
    ),
    IndependenceEvent(
        id: "ZM", countryCode: "ZM", countryName: "Zambia",
        year: 1964, independenceFrom: "United Kingdom",
        description: "Gained independence as Northern Rhodesia transitioned to majority rule."
    ),
    IndependenceEvent(
        id: "MW", countryCode: "MW", countryName: "Malawi",
        year: 1964, independenceFrom: "United Kingdom",
        description: "Nyasaland became independent Malawi under Hastings Banda's leadership."
    ),
    IndependenceEvent(
        id: "GW", countryCode: "GW", countryName: "Guinea-Bissau",
        year: 1974, independenceFrom: "Portugal",
        description: "Won independence through armed struggle led by PAIGC after years of war."
    ),
    IndependenceEvent(
        id: "MZ", countryCode: "MZ", countryName: "Mozambique",
        year: 1975, independenceFrom: "Portugal",
        description: "Achieved independence after Frelimo's armed struggle against Portuguese rule."
    ),
    IndependenceEvent(
        id: "AO", countryCode: "AO", countryName: "Angola",
        year: 1975, independenceFrom: "Portugal",
        description: "Gained independence from Portugal, immediately entering a devastating civil war."
    ),
    IndependenceEvent(
        id: "ZW", countryCode: "ZW", countryName: "Zimbabwe",
        year: 1980, independenceFrom: "United Kingdom",
        description: "Ended white minority rule and achieved independence as Zimbabwe under Mugabe."
    ),
    // Caribbean
    IndependenceEvent(
        id: "JM", countryCode: "JM", countryName: "Jamaica",
        year: 1962, independenceFrom: "United Kingdom",
        description: "Became independent as part of the dissolution of the West Indies Federation."
    ),
    IndependenceEvent(
        id: "TT", countryCode: "TT", countryName: "Trinidad and Tobago",
        year: 1962, independenceFrom: "United Kingdom",
        description: "Gained independence with a strong parliamentary tradition intact."
    ),
    IndependenceEvent(
        id: "BB", countryCode: "BB", countryName: "Barbados",
        year: 1966, independenceFrom: "United Kingdom",
        description: "Achieved independence after 339 years of British rule."
    ),
    // 1990s post-Soviet
    IndependenceEvent(
        id: "LT2", countryCode: "LT", countryName: "Lithuania",
        year: 1990, independenceFrom: "Soviet Union",
        description: "First Soviet republic to declare independence, igniting the Soviet collapse."
    ),
    IndependenceEvent(
        id: "EE2", countryCode: "EE", countryName: "Estonia",
        year: 1991, independenceFrom: "Soviet Union",
        description: "Restored independence through the Singing Revolution and international recognition."
    ),
    IndependenceEvent(
        id: "LV2", countryCode: "LV", countryName: "Latvia",
        year: 1991, independenceFrom: "Soviet Union",
        description: "Restored independence following a period of non-violent resistance."
    ),
    IndependenceEvent(
        id: "UA", countryCode: "UA", countryName: "Ukraine",
        year: 1991, independenceFrom: "Soviet Union",
        description: "Declared independence as the Soviet Union dissolved, confirmed by referendum."
    ),
    IndependenceEvent(
        id: "BY", countryCode: "BY", countryName: "Belarus",
        year: 1991, independenceFrom: "Soviet Union",
        description: "Declared sovereignty as the Soviet Union collapsed in August 1991."
    ),
    IndependenceEvent(
        id: "KZ", countryCode: "KZ", countryName: "Kazakhstan",
        year: 1991, independenceFrom: "Soviet Union",
        description: "Declared independence as the last Soviet republic, on December 16, 1991."
    ),
    IndependenceEvent(
        id: "GE", countryCode: "GE", countryName: "Georgia",
        year: 1991, independenceFrom: "Soviet Union",
        description: "Restored independence after a referendum showed overwhelming support."
    ),
    IndependenceEvent(
        id: "AZ", countryCode: "AZ", countryName: "Azerbaijan",
        year: 1991, independenceFrom: "Soviet Union",
        description: "Restored independence amid conflict over the Nagorno-Karabakh region."
    ),
    IndependenceEvent(
        id: "AM", countryCode: "AM", countryName: "Armenia",
        year: 1991, independenceFrom: "Soviet Union",
        description: "Gained independence after a referendum with 99% support for sovereignty."
    ),
    IndependenceEvent(
        id: "UZ", countryCode: "UZ", countryName: "Uzbekistan",
        year: 1991, independenceFrom: "Soviet Union",
        description: "Declared independence following the failed coup attempt against Gorbachev."
    ),
    IndependenceEvent(
        id: "TM", countryCode: "TM", countryName: "Turkmenistan",
        year: 1991, independenceFrom: "Soviet Union",
        description: "Declared independence as Soviet structures collapsed across Central Asia."
    ),
    IndependenceEvent(
        id: "KG", countryCode: "KG", countryName: "Kyrgyzstan",
        year: 1991, independenceFrom: "Soviet Union",
        description: "Gained independence as one of five Central Asian nations freed from Soviet rule."
    ),
    IndependenceEvent(
        id: "TJ", countryCode: "TJ", countryName: "Tajikistan",
        year: 1991, independenceFrom: "Soviet Union",
        description: "Declared independence, shortly followed by a devastating civil war."
    ),
    IndependenceEvent(
        id: "MD", countryCode: "MD", countryName: "Moldova",
        year: 1991, independenceFrom: "Soviet Union",
        description: "Declared independence and faced immediate conflict over the Transnistria region."
    ),
    IndependenceEvent(
        id: "HR", countryCode: "HR", countryName: "Croatia",
        year: 1991, independenceFrom: "Yugoslavia",
        description: "Declared independence from Yugoslavia, triggering the Croatian War of Independence."
    ),
    IndependenceEvent(
        id: "SI", countryCode: "SI", countryName: "Slovenia",
        year: 1991, independenceFrom: "Yugoslavia",
        description: "Gained independence after a brief Ten-Day War with Yugoslav forces."
    ),
    IndependenceEvent(
        id: "MK", countryCode: "MK", countryName: "North Macedonia",
        year: 1991, independenceFrom: "Yugoslavia",
        description: "Peacefully declared independence from Yugoslavia without military conflict."
    ),
    IndependenceEvent(
        id: "BA", countryCode: "BA", countryName: "Bosnia and Herzegovina",
        year: 1992, independenceFrom: "Yugoslavia",
        description: "Declared independence, triggering a catastrophic 3.5-year war."
    ),
    IndependenceEvent(
        id: "SK", countryCode: "SK", countryName: "Slovakia",
        year: 1993, independenceFrom: "Czechoslovakia",
        description: "Split peacefully from Czech Republic in the 'Velvet Divorce' on January 1."
    ),
    IndependenceEvent(
        id: "ER", countryCode: "ER", countryName: "Eritrea",
        year: 1993, independenceFrom: "Ethiopia",
        description: "Won independence after a 30-year war, with 99.8% voting yes in referendum."
    ),
    // Modern
    IndependenceEvent(
        id: "TL", countryCode: "TL", countryName: "East Timor",
        year: 2002, independenceFrom: "Indonesia",
        description: "Gained independence after a brutal occupation and UN-supervised transition."
    ),
    IndependenceEvent(
        id: "ME", countryCode: "ME", countryName: "Montenegro",
        year: 2006, independenceFrom: "Serbia",
        description: "Voted for independence by a narrow majority in a EU-supervised referendum."
    ),
    IndependenceEvent(
        id: "RS", countryCode: "RS", countryName: "Serbia",
        year: 2006, independenceFrom: "Serbia and Montenegro",
        description: "Became independent after Montenegro voted to dissolve their state union."
    ),
    IndependenceEvent(
        id: "XK", countryCode: "XK", countryName: "Kosovo",
        year: 2008, independenceFrom: "Serbia",
        description: "Declared independence, recognized by over 100 countries but disputed by Serbia."
    ),
    IndependenceEvent(
        id: "SS", countryCode: "SS", countryName: "South Sudan",
        year: 2011, independenceFrom: "Sudan",
        description: "Became the world's newest country after 98.8% voted for independence."
    ),
]
