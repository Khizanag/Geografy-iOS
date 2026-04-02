import Foundation

struct CultureProfile: Identifiable {
    let id: String
    let countryCode: String
    let nationalDish: String
    let nationalInstrument: String
    let famousFor: [String]
    let nationalHoliday: String
    let nationalHolidayDate: String
    let greeting: String
    let funCultureFact: String
}
