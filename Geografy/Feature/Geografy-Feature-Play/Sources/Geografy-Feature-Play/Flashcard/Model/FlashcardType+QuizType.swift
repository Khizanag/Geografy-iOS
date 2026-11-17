import Geografy_Core_Common

public extension FlashcardType {
    /// The flashcard a quiz question practices, so a quiz answer counts toward the same review; nil for quizzes
    /// with no matching card, such as rankings or neighbors.
    init?(quizType: QuizType) {
        switch quizType {
        case .flagQuiz: self = .flagToCountry
        case .reverseFlag: self = .countryToFlag
        case .capitalQuiz: self = .countryToCapital
        case .reverseCapital: self = .capitalToCountry
        default: return nil
        }
    }
}
