import Foundation

public final class LanguageService {
    public init() {}
    public var families: [String] {
        Array(Set(languages.map { $0.family })).sorted()
    }

    public var maxSpeakers: Int { languages.map { $0.speakerCount }.max() ?? 1 }

    public func languages(in family: String) -> [Language] {
        languages.filter { $0.family == family }.sorted { $0.speakerCount > $1.speakerCount }
    }

    public func languages(matching query: String) -> [Language] {
        guard !query.isEmpty else { return languages }
        let lowercased = query.lowercased()
        return languages.filter {
            $0.name.lowercased().contains(lowercased) ||
            $0.nativeName.lowercased().contains(lowercased) ||
            $0.family.lowercased().contains(lowercased)
        }
    }
}

// MARK: - Data
extension LanguageService {
    public var languages: [Language] {
        topLanguages + regionalLanguages
    }
}

// MARK: - Top Languages
private extension LanguageService {
    var topLanguages: [Language] {
        [
            Language(
                id: "zh",
                name: "Mandarin Chinese",
                nativeName: "普通话",
                speakerCount: 1_118,
                countries: ["CN", "TW", "SG"],
                family: "Sino-Tibetan",
                script: "Chinese Characters",
                funFact: "Mandarin has four tones — the same syllable in different tones means different things."
            ),
            Language(
                id: "es",
                name: "Spanish",
                nativeName: "Español",
                speakerCount: 485,
                countries: [
                    "ES", "MX", "CO", "AR", "PE", "VE", "CL", "EC",
                    "GT", "CU", "BO", "DO", "HN", "PY", "SV", "NI", "CR", "PA", "UY", "GQ",
                ],
                family: "Indo-European",
                script: "Latin",
                funFact: "Spanish is the official language of 20 countries — more than any other language."
            ),
            Language(
                id: "en",
                name: "English",
                nativeName: "English",
                speakerCount: 380,
                countries: ["US", "GB", "CA", "AU", "NZ", "ZA", "IE", "IN", "NG", "PH"],
                family: "Indo-European",
                script: "Latin",
                funFact: "English borrows from over 350 languages and adds roughly 1,000 new words every year."
            ),
            Language(
                id: "hi",
                name: "Hindi",
                nativeName: "हिन्दी",
                speakerCount: 344,
                countries: ["IN"],
                family: "Indo-European",
                script: "Devanagari",
                funFact: "Hindi and Urdu sound alike in speech but use entirely different writing systems."
            ),
            Language(
                id: "ar",
                name: "Arabic",
                nativeName: "العربية",
                speakerCount: 332,
                countries: [
                    "SA", "EG", "DZ", "IQ", "MA", "LY", "JO", "AE",
                    "LB", "TN", "YE", "SY", "SD", "KW", "BH", "QA", "OM",
                ],
                family: "Afro-Asiatic",
                script: "Arabic",
                funFact: "Arabic is written right-to-left and is the root of English words like algebra and algorithm."
            ),
            Language(
                id: "bn",
                name: "Bengali",
                nativeName: "বাংলা",
                speakerCount: 234,
                countries: ["BD", "IN"],
                family: "Indo-European",
                script: "Bengali",
                funFact: "Bengali was central to the 1952 Language Movement, now International Mother Language Day."
            ),
            Language(
                id: "pt",
                name: "Portuguese",
                nativeName: "Português",
                speakerCount: 236,
                countries: ["PT", "BR", "AO", "MZ", "CV", "ST", "GW", "TL"],
                family: "Indo-European",
                script: "Latin",
                funFact: "Brazil alone accounts for over half of all Portuguese speakers in the world."
            ),
            Language(
                id: "ru",
                name: "Russian",
                nativeName: "Русский",
                speakerCount: 148,
                countries: ["RU", "BY", "KZ", "KG"],
                family: "Indo-European",
                script: "Cyrillic",
                funFact: "Russian is one of six UN official languages and the most spoken Slavic language."
            ),
            Language(
                id: "ja",
                name: "Japanese",
                nativeName: "日本語",
                speakerCount: 123,
                countries: ["JP"],
                family: "Japonic",
                script: "Hiragana, Katakana, Kanji",
                funFact: "Japanese uses three writing systems simultaneously — often in the same sentence."
            ),
            Language(
                id: "pa",
                name: "Punjabi",
                nativeName: "ਪੰਜਾਬੀ",
                speakerCount: 113,
                countries: ["PK", "IN"],
                family: "Indo-European",
                script: "Gurmukhi / Shahmukhi",
                funFact: "Punjabi is the most widely spoken language in Pakistan and the 10th most spoken globally."
            ),
        ]
    }
}

// MARK: - Regional Languages
private extension LanguageService {
    var regionalLanguages: [Language] {
        [
            Language(
                id: "de",
                name: "German",
                nativeName: "Deutsch",
                speakerCount: 100,
                countries: ["DE", "AT", "CH", "LU", "LI"],
                family: "Indo-European",
                script: "Latin",
                funFact: "German forms unlimited compounds — 'Donaudampfschifffahrtsgesellschaft' is a real word."
            ),
            Language(
                id: "jv",
                name: "Javanese",
                nativeName: "Basa Jawa",
                speakerCount: 98,
                countries: ["ID"],
                family: "Austronesian",
                script: "Latin / Javanese",
                funFact: "Javanese has distinct speech levels — words change based on the listener's social status."
            ),
            Language(
                id: "wuu",
                name: "Wu Chinese",
                nativeName: "吴语",
                speakerCount: 82,
                countries: ["CN"],
                family: "Sino-Tibetan",
                script: "Chinese Characters",
                funFact: "Shanghainese is not intelligible with Mandarin — they are both Chinese but very different."
            ),
            Language(
                id: "ms",
                name: "Malay",
                nativeName: "Bahasa Melayu",
                speakerCount: 80,
                countries: ["MY", "ID", "BN", "SG"],
                family: "Austronesian",
                script: "Latin / Arabic",
                funFact: "Malay and Indonesian are so similar that speakers can understand each other perfectly."
            ),
            Language(
                id: "te",
                name: "Telugu",
                nativeName: "తెలుగు",
                speakerCount: 83,
                countries: ["IN"],
                family: "Dravidian",
                script: "Telugu",
                funFact: "Telugu is known as the 'Italian of the East' because almost all its words end in vowels."
            ),
            Language(
                id: "vi",
                name: "Vietnamese",
                nativeName: "Tiếng Việt",
                speakerCount: 86,
                countries: ["VN"],
                family: "Austroasiatic",
                script: "Latin",
                funFact: "Vietnamese uses a Latin alphabet with diacritical marks to indicate its six distinct tones."
            ),
            Language(
                id: "ko",
                name: "Korean",
                nativeName: "한국어",
                speakerCount: 82,
                countries: ["KR", "KP"],
                family: "Koreanic",
                script: "Hangul",
                funFact: "Hangul (invented 1443) is considered one of the most scientific writing systems ever created."
            ),
            Language(
                id: "fr",
                name: "French",
                nativeName: "Français",
                speakerCount: 80,
                countries: [
                    "FR", "BE", "CH", "CA", "SN", "CI", "CM",
                    "MG", "BF", "ML", "RW", "BI", "DJ", "KM",
                ],
                family: "Indo-European",
                script: "Latin",
                funFact: "French was the global language of diplomacy for centuries and still influences English today."
            ),
            Language(
                id: "mr",
                name: "Marathi",
                nativeName: "मराठी",
                speakerCount: 83,
                countries: ["IN"],
                family: "Indo-European",
                script: "Devanagari",
                funFact: "Marathi is one of India's oldest literary languages, with records dating back to 1000 AD."
            ),
            Language(
                id: "ta",
                name: "Tamil",
                nativeName: "தமிழ்",
                speakerCount: 78,
                countries: ["IN", "LK", "SG"],
                family: "Dravidian",
                script: "Tamil",
                funFact: "Tamil is one of the world's oldest living languages, with literature over 2,000 years old."
            ),
            Language(
                id: "ur",
                name: "Urdu",
                nativeName: "اردو",
                speakerCount: 70,
                countries: ["PK", "IN"],
                family: "Indo-European",
                script: "Nastaliq (Arabic)",
                funFact: "Urdu and Hindi share the same spoken form but use entirely different scripts."
            ),
            Language(
                id: "tr",
                name: "Turkish",
                nativeName: "Türkçe",
                speakerCount: 79,
                countries: ["TR", "CY"],
                family: "Turkic",
                script: "Latin",
                funFact: "Turkish uses vowel harmony — all vowels in a word follow a pattern set by the first vowel."
            ),
            Language(
                id: "it",
                name: "Italian",
                nativeName: "Italiano",
                speakerCount: 68,
                countries: ["IT", "CH", "SM", "VA"],
                family: "Indo-European",
                script: "Latin",
                funFact: "Italian is closest to Latin and is the language of classical music notation worldwide."
            ),
            Language(
                id: "th",
                name: "Thai",
                nativeName: "ภาษาไทย",
                speakerCount: 61,
                countries: ["TH"],
                family: "Kra-Dai",
                script: "Thai",
                funFact: "Thai has 44 consonants, 15 vowel symbols, 5 tones — and no spaces between words."
            ),
            Language(
                id: "gu",
                name: "Gujarati",
                nativeName: "ગુજરાતી",
                speakerCount: 57,
                countries: ["IN"],
                family: "Indo-European",
                script: "Gujarati",
                funFact: "Mahatma Gandhi's native language was Gujarati, spoken by millions in the Indian diaspora."
            ),
            Language(
                id: "fa",
                name: "Persian",
                nativeName: "فارسی",
                speakerCount: 57,
                countries: ["IR", "AF", "TJ"],
                family: "Indo-European",
                script: "Arabic",
                funFact: "Persian was Asia's common tongue for centuries and shaped Turkish, Hindi, and Urdu deeply."
            ),
            Language(
                id: "pl",
                name: "Polish",
                nativeName: "Polski",
                speakerCount: 45,
                countries: ["PL"],
                family: "Indo-European",
                script: "Latin",
                funFact: "Polish has seven grammatical cases and one of the most complex consonant clusters in Europe."
            ),
            Language(
                id: "uk",
                name: "Ukrainian",
                nativeName: "Українська",
                speakerCount: 41,
                countries: ["UA"],
                family: "Indo-European",
                script: "Cyrillic",
                funFact: "Ukrainian is one of the most melodic Slavic languages and has won language beauty contests."
            ),
            Language(
                id: "nl",
                name: "Dutch",
                nativeName: "Nederlands",
                speakerCount: 25,
                countries: ["NL", "BE", "SR"],
                family: "Indo-European",
                script: "Latin",
                funFact: "Dutch gave English words like cookie, boss, coleslaw, and yankee during colonial contact."
            ),
            Language(
                id: "ha",
                name: "Hausa",
                nativeName: "هَوُسَ",
                speakerCount: 85,
                countries: ["NG", "NE", "GH", "CM"],
                family: "Afro-Asiatic",
                script: "Latin / Arabic",
                funFact: "Hausa is the dominant language of West Africa and a key trade tongue across the Sahel region."
            ),
            Language(
                id: "ka",
                name: "Georgian",
                nativeName: "ქართული",
                speakerCount: 4,
                countries: ["GE"],
                family: "Kartvelian",
                script: "Georgian (Mkhedruli)",
                funFact: "Georgian has its own unique alphabet with 33 letters, unrelated to any other writing system."
            ),
            Language(
                id: "sw",
                name: "Swahili",
                nativeName: "Kiswahili",
                speakerCount: 100,
                countries: ["TZ", "KE", "UG", "RW", "CD"],
                family: "Niger-Congo",
                script: "Latin",
                funFact: "Swahili is the most widely spoken African language and a lingua franca across East Africa."
            ),
            Language(
                id: "el",
                name: "Greek",
                nativeName: "Ελληνικά",
                speakerCount: 13,
                countries: ["GR", "CY"],
                family: "Indo-European",
                script: "Greek",
                funFact: "Greek has been written for 3,400+ years — the longest documented history of any language."
            ),
            Language(
                id: "he",
                name: "Hebrew",
                nativeName: "עברית",
                speakerCount: 9,
                countries: ["IL"],
                family: "Afro-Asiatic",
                script: "Hebrew",
                funFact: "Hebrew was revived from a liturgical to a living national language in the 20th century."
            ),
            Language(
                id: "hu",
                name: "Hungarian",
                nativeName: "Magyar",
                speakerCount: 13,
                countries: ["HU"],
                family: "Uralic",
                script: "Latin",
                funFact: "Hungarian is unrelated to its neighbors — it arrived in Europe from the Ural Mountains."
            ),
            Language(
                id: "fi",
                name: "Finnish",
                nativeName: "Suomi",
                speakerCount: 5,
                countries: ["FI"],
                family: "Uralic",
                script: "Latin",
                funFact: "Finnish has 15 cases and no grammatical gender — one pronoun covers he, she, and it."
            ),
            Language(
                id: "am",
                name: "Amharic",
                nativeName: "አማርኛ",
                speakerCount: 32,
                countries: ["ET"],
                family: "Afro-Asiatic",
                script: "Ge'ez (Ethiopic)",
                funFact: "Amharic uses the Ge'ez script with 231 characters — each consonant has 7 vowel forms."
            ),
            Language(
                id: "ro",
                name: "Romanian",
                nativeName: "Română",
                speakerCount: 24,
                countries: ["RO", "MD"],
                family: "Indo-European",
                script: "Latin",
                funFact: "Romanian is the closest living language to Latin, preserving more grammar than any other."
            ),
        ]
    }
}
