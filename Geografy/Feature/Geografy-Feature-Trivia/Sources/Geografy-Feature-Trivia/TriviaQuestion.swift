import Foundation

public struct TriviaQuestion: Identifiable, Sendable {
    public let id = UUID()
    public let statement: String
    public let isTrue: Bool
    public let explanation: String
}
