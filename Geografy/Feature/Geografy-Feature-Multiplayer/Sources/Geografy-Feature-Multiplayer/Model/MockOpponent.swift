import Foundation

public struct MockOpponent: Identifiable, Hashable {
    public let id: UUID
    public let name: String
    public let countryCode: String
    public let skillLevel: Double

    public static func == (lhs: MockOpponent, rhs: MockOpponent) -> Bool { lhs.id == rhs.id }
    public func hash(into hasher: inout Hasher) { hasher.combine(id) }
}

// MARK: - Factory
extension MockOpponent {
    public static func makeRandom() -> MockOpponent {
        let name = opponentNames.randomElement() ?? "Unknown"
        let countryCode = countryCodes.randomElement() ?? "US"
        let skillLevel = Double.random(in: 0.6...0.9)

        return MockOpponent(
            id: UUID(),
            name: name,
            countryCode: countryCode,
            skillLevel: skillLevel,
        )
    }
}

// MARK: - Name Pool
private extension MockOpponent {
    static let opponentNames: [String] = [
        "Alex Chen", "Sofia Rodriguez", "Yuki Tanaka", "Lars Eriksson",
        "Amara Okafor", "Marco Rossi", "Priya Sharma", "Lukas Muller",
        "Fatima Al-Hassan", "Dmitri Volkov", "Isabella Costa", "Kenji Nakamura",
        "Olga Petrov", "Carlos Mendez", "Aisha Mbeki", "Henrik Johansson",
        "Mei Lin", "Pavel Novak", "Zara Khan", "Tomasz Kowalski",
        "Anya Ivanova", "Diego Torres", "Hana Kim", "Ravi Patel",
        "Elena Popescu", "Oscar Lindgren", "Nadia Boulaid", "Felix Weber",
        "Leila Moradi", "Sven Andersen", "Chloe Dubois", "Arjun Reddy",
        "Ingrid Nilsen", "Omar Farouk", "Valentina Ruiz", "Mateo Silva",
        "Sakura Ito", "Bruno Ferreira", "Lina Bergman", "Rashid Ahmed",
        "Eva Horvath", "Nikolas Papadopoulos", "Amina Diallo", "Jan Novotny",
        "Marta Gomez", "Viktor Szabo", "Freya Madsen", "Emir Yilmaz",
        "Clara Schmidt", "Tiago Oliveira",
    ]

    static let countryCodes: [String] = [
        "US", "GB", "DE", "FR", "JP", "BR", "IN", "KR", "IT", "ES",
        "CA", "AU", "MX", "SE", "NO", "NL", "PL", "TR", "AR", "EG",
        "NG", "ZA", "KE", "TH", "VN", "PH", "CO", "CL", "PE", "CZ",
    ]
}
