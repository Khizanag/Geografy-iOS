#if !os(tvOS)
import Geografy_Core_Common
import Foundation

@Observable
public final class CustomQuizService {
    private(set) var quizzes: [CustomQuiz] = []
    private let storageKey = "custom_quizzes"

    public func loadQuizzes() {
        guard let data = UserDefaults.standard.data(forKey: storageKey),
              let decoded = try? JSONDecoder.iso8601.decode(
                  [CustomQuiz].self,
                  from: data
              ) else {
            return
        }
        quizzes = decoded
    }

    public func save(_ quiz: CustomQuiz) {
        quizzes.append(quiz)
        persist()
    }

    public func update(_ quiz: CustomQuiz) {
        guard let index = quizzes.firstIndex(where: { $0.id == quiz.id }) else {
            return
        }
        quizzes[index] = quiz
        persist()
    }

    public func delete(_ quiz: CustomQuiz) {
        quizzes.removeAll { $0.id == quiz.id }
        persist()
    }

    public func nameExists(_ name: String, excluding quizID: UUID? = nil) -> Bool {
        quizzes.contains { quiz in
            quiz.name.localizedCaseInsensitiveCompare(name) == .orderedSame
                && quiz.id != quizID
        }
    }
}

// MARK: - Persistence
private extension CustomQuizService {
    func persist() {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        guard let data = try? encoder.encode(quizzes) else { return }
        UserDefaults.standard.set(data, forKey: storageKey)
    }
}

// MARK: - JSON Decoder
private extension JSONDecoder {
    static let iso8601: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }()
}
#endif
