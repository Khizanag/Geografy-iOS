struct CountryCultureEntry: Sendable {
    let cuisine: String?
    let music: String?
    let dance: String?
    let instrument: String?
    let art: String?
    let festivals: String?
    let nationalHoliday: String?
    let traditionalDress: String?
    let sport: String?
    let greeting: String?
    let famousFor: String?
    let funFact: String?

    init(
        cuisine: String? = nil,
        music: String? = nil,
        dance: String? = nil,
        instrument: String? = nil,
        art: String? = nil,
        festivals: String? = nil,
        nationalHoliday: String? = nil,
        traditionalDress: String? = nil,
        sport: String? = nil,
        greeting: String? = nil,
        famousFor: String? = nil,
        funFact: String? = nil
    ) {
        self.cuisine = cuisine
        self.music = music
        self.dance = dance
        self.instrument = instrument
        self.art = art
        self.festivals = festivals
        self.nationalHoliday = nationalHoliday
        self.traditionalDress = traditionalDress
        self.sport = sport
        self.greeting = greeting
        self.famousFor = famousFor
        self.funFact = funFact
    }
}

// MARK: - Highlights
extension CountryCultureEntry {
    struct Highlight: Identifiable {
        let icon: String
        let label: String
        let value: String

        var id: String { label }
    }

    var highlights: [Highlight] {
        let rows: [(String, String, String?)] = [
            ("fork.knife", "Cuisine", cuisine),
            ("music.note", "Music", music),
            ("figure.dance", "Dance", dance),
            ("guitars.fill", "Instrument", instrument),
            ("paintpalette.fill", "Art", art),
            ("party.popper.fill", "Festivals", festivals),
            ("calendar", "National holiday", nationalHoliday),
            ("tshirt.fill", "Traditional dress", traditionalDress),
            ("sportscourt.fill", "Sport", sport),
            ("hand.wave.fill", "Greeting", greeting),
            ("star.fill", "Famous for", famousFor),
        ]
        return rows.compactMap { icon, label, value in
            value.map { Highlight(icon: icon, label: label, value: $0) }
        }
    }
}
