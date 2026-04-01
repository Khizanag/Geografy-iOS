import Foundation

struct TriviaQuestion: Identifiable {
    let id = UUID()
    let statement: String
    let isTrue: Bool
    let explanation: String
}
