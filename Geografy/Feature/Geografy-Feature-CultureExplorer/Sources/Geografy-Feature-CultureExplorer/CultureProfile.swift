import Foundation

struct CultureProfile: Identifiable {
    public let id: String
    public let countryCode: String
    public let nationalDish: String
    public let nationalInstrument: String
    public let famousFor: [String]
    public let nationalHoliday: String
    public let nationalHolidayDate: String
    public let greeting: String
    public let funCultureFact: String
}
