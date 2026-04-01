#if !os(tvOS)
import Foundation
import Geografy_Core_Common
import Geografy_Core_Service
import Geografy_Feature_Quiz

public struct SerializableQuestion: Codable, Identifiable {
    public let id: UUID
    public let promptText: String
    public let promptSubject: String?
    public let promptFlag: String?
    public let options: [SerializableOption]
    public let correctOptionID: UUID
    public let correctCountryName: String
    public let correctCountryCode: String
}

// MARK: - Option
public struct SerializableOption: Codable, Identifiable {
    public let id: UUID
    public let text: String?
    public let flagCode: String?
}

// MARK: - Conversion
extension SerializableQuestion {
    public init(from question: QuizQuestion) {
        self.id = question.id
        self.promptText = question.promptText
        self.promptSubject = question.promptSubject
        self.promptFlag = question.promptFlag
        self.options = question.options.map { SerializableOption(id: $0.id, text: $0.text, flagCode: $0.flagCode) }
        self.correctOptionID = question.correctOptionID
        self.correctCountryName = question.correctCountry.name
        self.correctCountryCode = question.correctCountry.code
    }

    @MainActor
    public func toQuizQuestion(using countryDataService: CountryDataService) -> QuizQuestion? {
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
