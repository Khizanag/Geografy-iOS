/// A tab of the World Facts screen.
public enum WorldFactsTopic: String, CaseIterable, Hashable, Identifiable, Sendable {
    case records
    case oceans
    case features
    case landmarks

    public var id: String { rawValue }

    public var title: String {
        switch self {
        case .records: "Records"
        case .oceans: "Oceans"
        case .features: "Features"
        case .landmarks: "Landmarks"
        }
    }
}
