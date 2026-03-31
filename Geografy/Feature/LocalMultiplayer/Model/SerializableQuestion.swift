#if !os(tvOS)
import Foundation
import GeografyCore

struct SerializableQuestion: Codable, Identifiable {
    let id: UUID
    let promptText: String
    let promptSubject: String?
    let promptFlag: String?
    let options: [SerializableOption]
    let correctOptionID: UUID
    let correctCountryName: String
    let correctCountryCode: String
}

// MARK: - Option
struct SerializableOption: Codable, Identifiable {
    let id: UUID
    let text: String?
    let flagCode: String?
}

// MARK: - Conversion
extension SerializableQuestion {
    init(from question: QuizQuestion) {
        self.id = question.id
        self.promptText = question.promptText
        self.promptSubject = question.promptSubject
        self.promptFlag = question.promptFlag
        self.options = question.options.map { SerializableOption(id: $0.id, text: $0.text, flagCode: $0.flagCode) }
        self.correctOptionID = question.correctOptionID
        self.correctCountryName = question.correctCountry.name
        self.correctCountryCode = question.correctCountry.code
    }

    func toQuizQuestion(using countryDataService: CountryDataService) -> QuizQuestion? {
        guard let country = countryDataService.country(for: correctCountryCode) else { return nil }
        return QuizQuestion(
            id: id,
            promptText: promptText,
            promptSubject: promptSubject,
            promptFlag: promptFlag,
            options: options.map { QuizOption(id: $0.id, text: $0.text, flagCode: $0.flagCode) },
            correctOptionID: correctOptionID,
            correctCountry: country
        )
    }
}
#endif
