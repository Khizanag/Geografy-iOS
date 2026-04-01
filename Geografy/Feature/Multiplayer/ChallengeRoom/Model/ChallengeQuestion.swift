import Foundation

struct ChallengeQuestion: Identifiable, Hashable {
    let id = UUID()
    let question: String
    let options: [String]
    let correctIndex: Int
}
