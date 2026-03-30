import Foundation

struct QuizQuestion: Identifiable {
    let id: UUID
    let promptText: String
    let promptSubject: String?
    let promptFlag: String?
    let options: [QuizOption]
    let correctOptionID: UUID
    let correctCountry: Country
}

// MARK: - QuizOption
struct QuizOption: Identifiable {
    let id: UUID
    let text: String?
    let flagCode: String?
}
