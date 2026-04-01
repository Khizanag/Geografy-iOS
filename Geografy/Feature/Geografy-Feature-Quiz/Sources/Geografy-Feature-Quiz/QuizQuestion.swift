import Foundation
import Geografy_Core_Common

public struct QuizQuestion: Identifiable {
    public let id: UUID
    public let promptText: String
    public let promptSubject: String?
    public let promptFlag: String?
    public let options: [QuizOption]
    public let correctOptionID: UUID
    public let correctCountry: Country

    public init(
        id: UUID = UUID(),
        promptText: String,
        promptSubject: String? = nil,
        promptFlag: String? = nil,
        options: [QuizOption],
        correctOptionID: UUID,
        correctCountry: Country
    ) {
        self.id = id
        self.promptText = promptText
        self.promptSubject = promptSubject
        self.promptFlag = promptFlag
        self.options = options
        self.correctOptionID = correctOptionID
        self.correctCountry = correctCountry
    }
}

// MARK: - QuizOption
public struct QuizOption: Identifiable {
    public let id: UUID
    public let text: String?
    public let flagCode: String?

    public init(id: UUID = UUID(), text: String? = nil, flagCode: String? = nil) {
        self.id = id
        self.text = text
        self.flagCode = flagCode
    }
}
